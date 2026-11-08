import 'dart:async';

import 'package:choloto/ads/draw_ad_platform_mobile.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// Use the same wire formats as the native SDK in these channel tests.
// ignore: implementation_imports
import 'package:google_mobile_ads/src/ad_instance_manager.dart';
// ignore: implementation_imports
import 'package:google_mobile_ads/src/ump/user_messaging_codec.dart';

void main() {
  final messenger =
      TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger;
  final ump = MethodChannel('plugins.flutter.io/google_mobile_ads/ump',
      StandardMethodCodec(UserMessagingCodec()));
  final ads = MethodChannel('plugins.flutter.io/google_mobile_ads',
      StandardMethodCodec(AdMessageCodec()));
  late List<String> requested;
  late Completer<void> initialConsent;
  late bool allowed;
  late int disposals;
  late int lastAdId;
  setUp(() {
    requested = [];
    allowed = true;
    disposals = 0;
    messenger.setMockMethodCallHandler(SystemChannels.platform_views,
        (call) async {
      if (call.method == 'create' &&
          defaultTargetPlatform == TargetPlatform.android) {
        return 1;
      }
      if (call.method == 'resize') {
        return {
          'width': call.arguments['width'],
          'height': call.arguments['height']
        };
      }
      return null;
    });
    messenger.setMockMethodCallHandler(ump, (call) async {
      switch (call.method) {
        case 'ConsentInformation#requestConsentInfoUpdate':
          return null;
        case 'UserMessagingPlatform#loadAndShowConsentFormIfRequired':
          initialConsent = Completer<void>();
          await initialConsent.future;
          return null;
        case 'ConsentInformation#getPrivacyOptionsRequirementStatus':
          return 1;
        case 'ConsentInformation#canRequestAds':
          return allowed;
        case 'UserMessagingPlatform#showPrivacyOptionsForm':
          allowed = false;
          return null;
        default:
          throw StateError(call.method);
      }
    });
    messenger.setMockMethodCallHandler(ads, (call) async {
      switch (call.method) {
        case '_init':
          return null;
        case 'MobileAds#initialize':
          return InitializationStatus({});
        case 'loadBannerAd':
          lastAdId = call.arguments['adId'] as int;
          requested.add(call.arguments['adUnitId'] as String);
          return null;
        case 'disposeAd':
          disposals++;
          return null;
        default:
          throw StateError(call.method);
      }
    });
  });
  tearDown(() {
    messenger.setMockMethodCallHandler(ump, null);
    messenger.setMockMethodCallHandler(ads, null);
    messenger.setMockMethodCallHandler(SystemChannels.platform_views, null);
  });

  Widget screen(String language, Brightness brightness) => MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: Builder(
            builder: (context) => Localizations.override(
                  context: context,
                  locale: Locale(language),
                  delegates: const [FFLocalizationsDelegate()],
                  child: const Scaffold(
                      body: Align(
                          alignment: Alignment.bottomCenter,
                          child: DrawAdPlacement())),
                )),
      );

  for (final entry in {
    'fr': 'Confidentialité des annonces',
    'en': 'Ad privacy options',
    'cr': 'Konfidansyalite piblisite'
  }.entries) {
    for (final brightness in Brightness.values) {
      testWidgets('consent and revocation for ${entry.key} ${brightness.name}',
          (tester) async {
        await tester.binding.setSurfaceSize(brightness == Brightness.dark
            ? const Size(320, 568)
            : const Size(1000, 768));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(screen(entry.key, brightness));
        expect(requested, isEmpty);
        initialConsent.complete();
        await tester.pumpAndSettle();
        expect(requested, [
          defaultTargetPlatform == TargetPlatform.android
              ? 'ca-app-pub-3940256099942544/6300978111'
              : 'ca-app-pub-3940256099942544/2934735716'
        ]);
        final banner = instanceManager.adFor(lastAdId) as BannerAd;
        banner.listener.onAdLoaded!(banner);
        await tester.pumpAndSettle();
        expect(tester.getSize(find.byType(AdWidget)), const Size(320, 50));
        expect(find.text(entry.value), findsOneWidget);
        await tester.tap(find.text(entry.value));
        await tester.pumpAndSettle();
        expect(find.byType(AdWidget), findsNothing);
        expect(disposals, 1);
        expect(requested, hasLength(1));
        expect(tester.takeException(), isNull);
      },
          variant: const TargetPlatformVariant(
              {TargetPlatform.android, TargetPlatform.iOS}));
    }
  }
  testWidgets('leaving before consent resolves cancels the request',
      (tester) async {
    await tester.pumpWidget(screen('en', Brightness.dark));
    await tester.pumpWidget(const SizedBox());
    initialConsent.complete();
    await tester.pumpAndSettle();
    expect(requested, isEmpty);
  });
}
