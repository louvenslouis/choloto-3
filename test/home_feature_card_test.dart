import 'package:choloto/components/home_feature_card.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _vipAsset = 'assets/images/home/vip_membership_3d_v2.png';
const _chanceAsset = 'assets/images/home/lucky_cross_3d_x.png';
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

// VIP sparkles loop continuously; only wait for finite entrance/press effects.
Future<void> _finishCardTransitions(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 800));
}

double _contrastRatio(Color foreground, Color background) {
  final opaqueForeground = Color.alphaBlend(foreground, background);
  final lighter =
      opaqueForeground.computeLuminance() > background.computeLuminance()
          ? opaqueForeground
          : background;
  final darker = lighter == opaqueForeground ? background : opaqueForeground;
  return (lighter.computeLuminance() + 0.05) /
      (darker.computeLuminance() + 0.05);
}

HomeFeatureCard _localizedCard(HomeFeatureTone tone, FFLocalizations strings) {
  final (titleKey, descriptionKey, asset) = switch (tone) {
    HomeFeatureTone.vip => ('covzb0rd', 'uvl7vow9', _vipAsset),
    HomeFeatureTone.chance => ('afym167o', 'pqih1sxe', _chanceAsset),
    HomeFeatureTone.video => ('fkwji2m2', 'gcjztr88', _videoAsset),
  };
  return _card(
    id: tone.name,
    title: strings.getText(titleKey),
    description: strings.getText(descriptionKey),
    tone: tone,
    assetPath: asset,
  );
}

void main() {
  testWidgets('renders a tappable gradient card with its VIP asset',
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
    await _finishCardTransitions(tester);

    final gradientContainer = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('home-feature-gradient-vip')),
    );
    final decoration = gradientContainer.decoration! as BoxDecoration;

    expect(decoration.gradient, isA<LinearGradient>());
    expect(
      find.byKey(const ValueKey('home-feature-image-vip')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('home-feature-card-vip')));
    await _finishCardTransitions(tester);
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('VIP sparkles repaint, preserve taps and respect reduced motion',
      (tester) async {
    var taps = 0;
    Widget scene({bool reduceMotion = false, bool ticking = true}) => _testApp(
          themeMode: ThemeMode.dark,
          child: MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              disableAnimations: reduceMotion,
            ),
            child: TickerMode(
              enabled: ticking,
              child: Center(
                child: _card(
                  id: 'vip',
                  title: 'VIP',
                  description: 'Premium',
                  tone: HomeFeatureTone.vip,
                  assetPath: _vipAsset,
                  onTap: () => taps++,
                ),
              ),
            ),
          ),
        );
    await tester.pumpWidget(scene());
    await _finishCardTransitions(tester);
    final sparkles = find.byKey(const ValueKey('home-vip-sparkles'));
    final cardRect = tester.getRect(
      find.byKey(const ValueKey('home-feature-card-vip')),
    );
    expect(tester.getRect(sparkles), cardRect);
    var repaints = 0;
    final painter = tester.widget<CustomPaint>(sparkles).painter!;
    void onRepaint() => repaints++;
    painter.addListener(onRepaint);
    await tester.pump(const Duration(milliseconds: 350));
    expect(repaints, greaterThan(0));
    await tester.tapAt(tester.getCenter(sparkles));
    expect(taps, 1);

    await tester.pumpWidget(scene(reduceMotion: true));
    repaints = 0;
    await tester.pump(const Duration(seconds: 1));
    expect(repaints, 0);

    await tester.pumpWidget(scene());
    await tester.pump(const Duration(milliseconds: 350));
    expect(repaints, greaterThan(0));
    await tester.pumpWidget(scene(ticking: false));
    repaints = 0;
    await tester.pump(const Duration(seconds: 1));
    expect(repaints, 0);
    painter.removeListener(onRepaint);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('reveals cards fluidly and respects reduced motion',
      (tester) async {
    await _setViewport(tester, const Size(390.0, 844.0));

    Widget videoCard({bool reduceMotion = false}) => MediaQuery(
          data: MediaQueryData(
            size: const Size(390.0, 844.0),
            disableAnimations: reduceMotion,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: _card(
              id: 'video',
              title: 'YOUTUBE',
              description: 'Regarde et reste connecté.',
              tone: HomeFeatureTone.video,
              assetPath: _videoAsset,
            ),
          ),
        );

    await tester.pumpWidget(
      _testApp(themeMode: ThemeMode.dark, child: videoCard()),
    );

    FadeTransition entrance() => tester.widget<FadeTransition>(
          find.byKey(const ValueKey('home-feature-entrance-video')),
        );

    await tester.pump();
    expect(entrance().opacity.value, 0.0);
    await tester.pump(const Duration(milliseconds: 250));
    expect(entrance().opacity.value, greaterThan(0.0));
    await _finishCardTransitions(tester);
    expect(entrance().opacity.value, 1.0);

    await tester.pumpWidget(
      _testApp(
        themeMode: ThemeMode.dark,
        child: videoCard(reduceMotion: true),
      ),
    );
    await tester.pump();
    expect(entrance().opacity.value, 1.0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lifts on hover and compresses on touch', (tester) async {
    await _setViewport(tester, const Size(390.0, 844.0));
    await tester.pumpWidget(
      _testApp(
        themeMode: ThemeMode.dark,
        child: Align(
          alignment: Alignment.topCenter,
          child: _card(
            id: 'vip',
            title: 'ABONNEMENT VIP',
            description: 'Accède à tous les avantages exclusifs.',
            tone: HomeFeatureTone.vip,
            assetPath: _vipAsset,
          ),
        ),
      ),
    );
    await _finishCardTransitions(tester);

    final cardFinder = find.byKey(const ValueKey('home-feature-card-vip'));
    final interactionFinder =
        find.byKey(const ValueKey('home-feature-interaction-scale-vip'));
    final artworkFinder =
        find.byKey(const ValueKey('home-feature-artwork-motion-vip'));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(cardFinder));
    await tester.pump(const Duration(milliseconds: 260));

    expect(tester.widget<AnimatedScale>(interactionFinder).scale, 1.008);
    expect(tester.widget<AnimatedScale>(artworkFinder).scale, 1.03);

    await mouse.moveTo(Offset.zero);
    await _finishCardTransitions(tester);
    final touch = await tester.startGesture(tester.getCenter(cardFinder));
    await tester.pump(const Duration(milliseconds: 30));
    expect(tester.widget<AnimatedScale>(interactionFinder).scale, 0.985);
    expect(tester.widget<AnimatedScale>(artworkFinder).scale, 0.97);
    await touch.up();
    await _finishCardTransitions(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders the Chance artwork as a 3D X asset', (tester) async {
    await _setViewport(tester, const Size(320.0, 568.0));

    await tester.pumpWidget(
      _testApp(
        themeMode: ThemeMode.dark,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _card(
              id: 'chance',
              title: 'CROIX DE LA CHANCE',
              description: 'Tente chaque jour et gagne GROS.',
              tone: HomeFeatureTone.chance,
              assetPath: _chanceAsset,
            ),
          ),
        ),
      ),
    );
    await _finishCardTransitions(tester);

    final artwork = tester.widget<Image>(
      find.byKey(const ValueKey('home-feature-image-chance')),
    );
    expect(artwork.image, isA<ResizeImage>());
    final resizedImage = artwork.image as ResizeImage;
    expect(resizedImage.imageProvider, isA<AssetImage>());
    expect(
      (resizedImage.imageProvider as AssetImage).assetName,
      _chanceAsset,
    );
    expect(tester.takeException(), isNull);
  });

  for (final tone in HomeFeatureTone.values) {
    for (final themeMode in const [ThemeMode.dark, ThemeMode.light]) {
      testWidgets(
        '${tone.name} card has a premium background and readable copy in ${themeMode.name}',
        (tester) async {
          await _setViewport(tester, const Size(320.0, 700.0));
          final id = tone.name;

          await tester.pumpWidget(
            _testApp(
              themeMode: themeMode,
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child:
                      _localizedCard(tone, FFLocalizations(const Locale('fr'))),
                ),
              ),
            ),
          );
          await _finishCardTransitions(tester);

          expect(find.byKey(const ValueKey('home-vip-sparkles')),
              tone == HomeFeatureTone.vip ? findsOneWidget : findsNothing);

          final card = tester.widget<AnimatedContainer>(
            find.byKey(ValueKey('home-feature-gradient-$id')),
          );
          final decoration = card.decoration! as BoxDecoration;
          final gradient = decoration.gradient! as LinearGradient;
          final title = tester.widget<Text>(
            find.byKey(ValueKey('home-feature-title-$id')),
          );
          final description = tester.widget<Text>(
            find.byKey(ValueKey('home-feature-description-$id')),
          );
          final titleColor = title.style!.color!;
          final descriptionColor = description.style!.color!;
          final borderRadius = decoration.borderRadius! as BorderRadius;
          final border = decoration.border! as Border;

          expect(
            tester
                .getSize(
                  find.byKey(ValueKey('home-feature-gradient-$id')),
                )
                .height,
            lessThanOrEqualTo(140.0),
          );
          expect(borderRadius.topLeft.x, 24.0);
          expect(border.top.width, lessThanOrEqualTo(1.0));
          // Verify contrast across the entire card background in both themes.
          for (var segment = 0;
              segment < gradient.colors.length - 1;
              segment++) {
            for (var step = 0; step <= 10; step++) {
              final base = Color.lerp(
                gradient.colors[segment],
                gradient.colors[segment + 1],
                step / 10,
              )!;
              {
                final background = base;
                expect(
                  _contrastRatio(titleColor, background),
                  greaterThanOrEqualTo(7.0),
                );
                expect(
                  _contrastRatio(descriptionColor, background),
                  greaterThanOrEqualTo(4.5),
                );
              }
            }
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final locale in const [Locale('fr'), Locale('en'), Locale('cr')]) {
    for (final themeMode in const [ThemeMode.dark, ThemeMode.light]) {
      for (final width in [320.0, 800.0, 1160.0]) {
        for (final scale in [1.0, 2.0]) {
          testWidgets(
            'fits all localized cards at $width px in '
            '${locale.languageCode} ${themeMode.name} scale $scale',
            (tester) async {
              await _setViewport(tester, Size(width, 700.0));
              final strings = FFLocalizations(locale);
              await tester.pumpWidget(
                _testApp(
                  themeMode: themeMode,
                  child: MediaQuery(
                    data: MediaQueryData(
                        size: Size(width, 700),
                        textScaler: TextScaler.linear(scale)),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: HomeFeatureSection(
                        vipCard: _localizedCard(HomeFeatureTone.vip, strings),
                        chanceCard:
                            _localizedCard(HomeFeatureTone.chance, strings),
                        videoCard:
                            _localizedCard(HomeFeatureTone.video, strings),
                        draws: const SizedBox(height: 100.0),
                      ),
                    ),
                  ),
                ),
              );
              await _finishCardTransitions(tester);

              for (final tone in HomeFeatureTone.values) {
                final card =
                    find.byKey(ValueKey('home-feature-card-${tone.name}'));
                expect(card, findsOneWidget);
                final title = find.byKey(
                  ValueKey('home-feature-title-${tone.name}'),
                );
                final description = find.byKey(
                  ValueKey('home-feature-description-${tone.name}'),
                );
                // Important copy stays complete when translations or text size grow.
                expect(tester.widget<Text>(title).maxLines, isNull);
                expect(tester.widget<Text>(description).maxLines, isNull);
                expect(tester.getBottomRight(description).dy,
                    lessThan(tester.getBottomRight(card).dy));
                expect(tester.getTopLeft(card).dx, greaterThanOrEqualTo(16.0));
                expect(tester.getBottomRight(card).dx,
                    lessThanOrEqualTo(width - 16));
              }
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
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
    await _finishCardTransitions(tester);

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
    await _finishCardTransitions(tester);

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
