import 'dart:io';

import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:choloto/settings/parametres/subscription_settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    if (const bool.fromEnvironment('CAPTURE_SETTINGS')) {
      for (final font in {
        'Google sans flex':
            'assets/fonts/GoogleSansFlex-VariableFont_GRAD,ROND,opsz,slnt,wdth,wght.ttf',
        'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
        'packages/font_awesome_flutter/FontAwesomeSolid':
            'packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf',
      }.entries) {
        await (FontLoader(font.key)..addFont(rootBundle.load(font.value)))
            .load();
      }
      // Same local font used by the payment screen capture harness.
      final inter = ByteData.sublistView(
          await File('/tmp/choloto-inter.ttf').readAsBytes());
      await (FontLoader('Inter_regular')..addFont(Future.value(inter))).load();
    }
  });
  for (final language in ['fr', 'en', 'cr']) {
    for (final brightness in Brightness.values) {
      for (final width in [320.0, 1280.0]) {
        testWidgets('subscription tile $language ${brightness.name} $width',
            (tester) async {
          tester.view.physicalSize = Size(width, 720);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          var taps = 0;

          Future<void> showTile(DateTime? expiration) async {
            await tester.pumpWidget(MaterialApp(
              locale: Locale(language),
              supportedLocales: const [
                Locale('fr'),
                Locale('en'),
                Locale('cr')
              ],
              localizationsDelegates: const [
                FFLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                FallbackMaterialLocalizationDelegate(),
                FallbackCupertinoLocalizationDelegate(),
              ],
              theme: ThemeData(brightness: brightness),
              home: Scaffold(
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: RepaintBoundary(
                    key: const ValueKey('preview'),
                    child: SubscriptionSettingsTile(
                      expiration: expiration,
                      onTap: () => taps++,
                    ),
                  ),
                ),
              ),
            ));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            expect(find.byType(ListTile), findsOneWidget);
            expect(
              find.text(FFLocalizations(Locale(language)).getText('eywbwq85')),
              findsOneWidget,
            );
          }

          await showTile(DateTime(2099, 9, 30));
          final tile = tester.widget<ListTile>(find.byType(ListTile));
          final activeText = (tile.subtitle! as Text).data!;
          expect(activeText, contains('2099'));
          expect(
              activeText,
              startsWith({
                'fr': 'Votre abonnement expire le',
                'en': 'Your subscription expires on',
                'cr': 'Abònman ou ap ekspire',
              }[language]!));
          expect(
            tester.getTopLeft(find.text(activeText)).dy,
            greaterThan(tester.getTopLeft(find.byWidget(tile.title!)).dy),
          );
          await tester.tap(find.byType(ListTile));
          await tester.pumpAndSettle();
          expect(taps, 1);

          if (const bool.fromEnvironment('CAPTURE_SETTINGS')) {
            await expectLater(
              find.byKey(const ValueKey('preview')),
              matchesGoldenFile(
                '/tmp/choloto-subscription-$language-${brightness.name}-${width.toInt()}.png',
              ),
            );
          }

          await showTile(DateTime(2000));
          expect(
              find.text({
                'fr': 'Votre abonnement est expiré',
                'en': 'Your subscription has expired',
                'cr': 'Abònman ou ekspire',
              }[language]!),
              findsOneWidget);

          await showTile(null);
          expect(
              tester.widget<ListTile>(find.byType(ListTile)).subtitle, isNull);
          await tester.tap(find.byType(ListTile));
          expect(taps, 2);
        });
      }
    }
  }
}
