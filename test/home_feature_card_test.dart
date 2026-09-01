import 'package:choloto/components/home_feature_card.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _vipAsset = 'assets/images/home/vip_membership_3d_v2.png';
const _chanceAsset = 'assets/images/home/lucky_cross_3d_v2.png';
const _videoAsset = 'assets/images/home/video_play_3d_v2.png';

Widget _testApp({
  required ThemeMode themeMode,
  required Widget child,
}) {
  return MaterialApp(
    theme: ThemeData(brightness: Brightness.light),
    darkTheme: ThemeData(brightness: Brightness.dark),
    themeMode: themeMode,
    home: Scaffold(body: child),
  );
}

HomeFeatureCard _card({
  required String id,
  required String title,
  required String description,
  required HomeFeatureTone tone,
  required String assetPath,
  VoidCallback? onTap,
}) {
  return HomeFeatureCard(
    semanticId: id,
    title: title,
    description: description,
    tone: tone,
    assetPath: assetPath,
    onTap: onTap ?? () {},
  );
}

Future<void> _setViewport(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('renders a tappable gradient card with its 3D asset',
      (tester) async {
    await _setViewport(tester, const Size(320.0, 568.0));
    var taps = 0;

    await tester.pumpWidget(
      _testApp(
        themeMode: ThemeMode.dark,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _card(
              id: 'vip',
              title: 'ABONNEMENT VIP',
              description: 'Accède à tous les avantages exclusifs.',
              tone: HomeFeatureTone.vip,
              assetPath: _vipAsset,
              onTap: () => taps++,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final gradientContainer = tester.widget<Container>(
      find.byKey(const ValueKey('home-feature-gradient-vip')),
    );
    final decoration = gradientContainer.decoration! as BoxDecoration;

    expect(decoration.gradient, isA<LinearGradient>());
    expect(
      find.byKey(const ValueKey('home-feature-image-vip')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('home-feature-card-vip')));
    await tester.pumpAndSettle();
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });

  for (final locale in const [Locale('fr'), Locale('en'), Locale('cr')]) {
    for (final themeMode in const [ThemeMode.dark, ThemeMode.light]) {
      testWidgets(
        'fits localized chance content on a small phone in '
        '${locale.languageCode} ${themeMode.name}',
        (tester) async {
          await _setViewport(tester, const Size(320.0, 568.0));
          final localizations = FFLocalizations(locale);

          await tester.pumpWidget(
            _testApp(
              themeMode: themeMode,
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _card(
                    id: 'chance',
                    title: localizations.getText('afym167o'),
                    description: localizations.getText('pqih1sxe'),
                    tone: HomeFeatureTone.chance,
                    assetPath: _chanceAsset,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.byKey(const ValueKey('home-feature-card-chance')),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('keeps draw placement on mobile and builds a three-card web row',
      (tester) async {
    await _setViewport(tester, const Size(390.0, 900.0));

    Widget section() => HomeFeatureSection(
          vipCard: _card(
            id: 'vip',
            title: 'VIP',
            description: 'Premium',
            tone: HomeFeatureTone.vip,
            assetPath: _vipAsset,
          ),
          chanceCard: _card(
            id: 'chance',
            title: 'CHANCE',
            description: 'Daily game',
            tone: HomeFeatureTone.chance,
            assetPath: _chanceAsset,
          ),
          draws: const SizedBox(
            key: ValueKey('draws-placeholder'),
            height: 100.0,
          ),
          videoCard: _card(
            id: 'video',
            title: 'VIDEO',
            description: 'Watch',
            tone: HomeFeatureTone.video,
            assetPath: _videoAsset,
          ),
        );

    await tester.pumpWidget(
      _testApp(
        themeMode: ThemeMode.dark,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: section(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('home-feature-mobile-layout')),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('draws-placeholder'))).dy,
      lessThan(
        tester
            .getTopLeft(
              find.byKey(const ValueKey('home-feature-card-video')),
            )
            .dy,
      ),
    );

    await _setViewport(tester, const Size(1160.0, 700.0));
    await tester.pumpWidget(
      _testApp(
        themeMode: ThemeMode.light,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: section(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('home-feature-wide-layout')),
      findsOneWidget,
    );
    final vipTop = tester
        .getTopLeft(find.byKey(const ValueKey('home-feature-card-vip')))
        .dy;
    final chanceTop = tester
        .getTopLeft(find.byKey(const ValueKey('home-feature-card-chance')))
        .dy;
    final videoTop = tester
        .getTopLeft(find.byKey(const ValueKey('home-feature-card-video')))
        .dy;
    expect(chanceTop, vipTop);
    expect(videoTop, vipTop);
    expect(tester.takeException(), isNull);
  });
}
