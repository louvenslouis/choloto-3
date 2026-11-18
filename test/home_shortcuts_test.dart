import 'package:choloto/components/home_shortcuts.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final reduceMotion in [false, true]) {
    testWidgets(
        'shortcuts focus, hover and activate with reduced motion $reduceMotion',
        (tester) async {
      final taps = <String>[];
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: const [
          FFLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('fr')],
        home: Builder(
            builder: (context) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(disableAnimations: reduceMotion),
                  child: Scaffold(
                      body: HomeShortcuts(
                    wide: true,
                    onVideo: () => taps.add('video'),
                    onStats: () => taps.add('stats'),
                    onTchala: () => taps.add('tchala'),
                    onHistory: () => taps.add('history'),
                  )),
                )),
      ));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(taps, ['video']);
      taps.clear();
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: const Offset(1, 599));
      final video = find.byKey(const ValueKey('home-shortcut-video'));
      final scale =
          find.descendant(of: video, matching: find.byType(AnimatedScale));
      final center = tester.getCenter(video);
      await mouse.moveTo(center);
      await tester.pumpAndSettle();
      expect(tester.widget<AnimatedScale>(scale).scale,
          reduceMotion ? 1 : greaterThan(1));
      await mouse.down(center);
      await tester.pumpAndSettle();
      expect(tester.widget<AnimatedScale>(scale).scale,
          reduceMotion ? 1 : lessThan(1));
      await mouse.up();
      await tester.pumpAndSettle();
      for (final id in ['stats', 'tchala', 'history']) {
        await tester.tap(find.byKey(ValueKey('home-shortcut-$id')));
        await tester.pumpAndSettle();
      }
      expect(taps, ['video', 'stats', 'tchala', 'history']);
      expect(tester.takeException(), isNull);
    });
  }
}
