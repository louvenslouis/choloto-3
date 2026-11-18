import 'package:choloto/components/home_feature_card.dart';
import 'package:choloto/components/home_feature_section.dart';
import 'package:choloto/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _drawsAsset = 'assets/images/home/lottery_drum.webp';
const _vipAsset = 'assets/images/home/vip_amethyst_medal.webp';
const _chanceAsset = 'assets/images/home/lucky_cross_3d_x.png';

Widget _testApp({
  required ThemeMode themeMode,
  required Widget child,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: const [Locale('en'), Locale('fr'), Locale('cr')],
    localizationsDelegates: const [
      FFLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      FallbackMaterialLocalizationDelegate(),
      FallbackCupertinoLocalizationDelegate()
    ],
    theme: ThemeData(brightness: Brightness.light),
    darkTheme: ThemeData(brightness: Brightness.dark),
    themeMode: themeMode,
    home: Scaffold(body: child),
  );
}

HomeFeatureCard _card({
  required String id,
  required String title,
  required HomeFeatureTone tone,
  required String assetPath,
  VoidCallback? onTap,
}) {
  return HomeFeatureCard(
    semanticId: id,
    title: title,
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

// Allow the finite hero and tile entrances to reach their resting frames.
Future<void> _finishCardTransitions(WidgetTester tester) async {
  await tester.pumpAndSettle();
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
  final (titleKey, asset) = switch (tone) {
    HomeFeatureTone.draws => ('home_latest_draws', _drawsAsset),
    HomeFeatureTone.chance => ('afym167o', _chanceAsset),
  };
  return _card(
    id: tone.name,
    title: strings.getText(titleKey),
    tone: tone,
    assetPath: asset,
  );
}

HomeFeatureSection _section({
  Widget? stories,
  required ValueChanged<String> onAction,
}) =>
    HomeFeatureSection(
      stories: stories,
      draws: const SizedBox(height: 100, key: ValueKey('draws')),
      onViewResults: () => onAction('results'),
      onVip: () => onAction('vip'),
      onChance: () => onAction('chance'),
      onVideo: () => onAction('video'),
      onStats: () => onAction('stats'),
      onTchala: () => onAction('tchala'),
      onHistory: () => onAction('history'),
    );

void main() {
  testWidgets('renders a tappable results card with the lottery drum',
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
              id: 'draws',
              title: 'Derniers tirages',
              tone: HomeFeatureTone.draws,
              assetPath: _drawsAsset,
              onTap: () => taps++,
            ),
          ),
        ),
      ),
    );
    await _finishCardTransitions(tester);

    final gradientContainer = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('home-feature-gradient-draws')),
    );
    final decoration = gradientContainer.decoration! as BoxDecoration;

    expect(decoration.gradient, isA<LinearGradient>());
    final drum = tester.widget<Image>(
      find.byKey(const ValueKey('home-feature-image-draws')),
    );
    final drumSource = (drum.image as ResizeImage).imageProvider as AssetImage;
    expect(drumSource.assetName, _drawsAsset);
    await tester.tap(find.byKey(const ValueKey('home-feature-card-draws')));
    await _finishCardTransitions(tester);
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'VIP medal lifts above amethyst, settles and honors motion settings',
      (tester) async {
    await _setViewport(tester, const Size(390, 844));
    final tapped = <String>[];
    Widget scene({bool reduceMotion = false, bool ticking = true}) => _testApp(
          themeMode: ThemeMode.dark,
          child: MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              disableAnimations: reduceMotion,
            ),
            child: TickerMode(
              enabled: ticking,
              child: SingleChildScrollView(
                child: _section(onAction: tapped.add),
              ),
            ),
          ),
        );
    await tester.pumpWidget(scene());
    await tester.pump();
    final hero = find.byKey(const ValueKey('home-vip-hero'));
    final medalFinder = find.byKey(const ValueKey('home-vip-medal'));
    final motion = find.byKey(const ValueKey('home-vip-medal-motion'));
    final light = find.byKey(const ValueKey('home-vip-light-sweep'));
    final card = find.byKey(const ValueKey('home-open-vip'));
    final surface = tester.widget<DecoratedBox>(find
        .ancestor(
          of: light,
          matching: find.byType(DecoratedBox),
        )
        .first);
    final material = surface.decoration as BoxDecoration;
    expect((material.image!.image as AssetImage).assetName,
        'assets/images/home/amethyst.webp');
    expect(material.gradient, DarkModeTheme().designToken.home.vipAmethyst);
    final medal = tester.widget<Image>(medalFinder);
    expect(((medal.image as ResizeImage).imageProvider as AssetImage).assetName,
        _vipAsset);
    expect(tester.getTopLeft(hero).dy, 0,
        reason: 'An empty story rail must not reserve space.');

    Matrix4 medalTransform() => tester.widget<Transform>(motion).transform;
    final initial = medalTransform();
    var repaints = 0;
    final painter = tester.widget<CustomPaint>(light).painter!;
    void onRepaint() => repaints++;
    painter.addListener(onRepaint);
    await tester.pump(const Duration(milliseconds: 270));
    expect(medalTransform(), isNot(initial));
    expect(repaints, greaterThan(0));

    await tester.pumpWidget(scene(ticking: false));
    final paused = medalTransform();
    repaints = 0;
    await tester.pump(const Duration(seconds: 2));
    expect(medalTransform(), paused);
    expect(repaints, 0);

    await tester.pumpWidget(scene());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
    final settled = medalTransform();
    expect(settled, isNot(paused));
    expect(tester.getTopLeft(medalFinder).dy,
        lessThan(tester.getTopLeft(card).dy));
    expect(tester.getSize(medalFinder).height,
        greaterThan(tester.getSize(card).height));
    repaints = 0;
    await tester.pump(const Duration(seconds: 2));
    expect(repaints, 0);
    await tester.tapAt(tester.getCenter(medalFinder));
    expect(tapped, ['vip']);
    painter.removeListener(onRepaint);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(scene(reduceMotion: true));
    expect(medalTransform(), settled);
    await tester.pump(const Duration(milliseconds: 200));
    expect(medalTransform(), settled);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('reveals cards fluidly and respects reduced motion',
      (tester) async {
    await _setViewport(tester, const Size(390.0, 844.0));

    Widget chanceCard({bool reduceMotion = false}) => MediaQuery(
          data: MediaQueryData(
            size: const Size(390.0, 844.0),
            disableAnimations: reduceMotion,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: _card(
              id: 'chance',
              title: 'Lucky Cross',
              tone: HomeFeatureTone.chance,
              assetPath: _chanceAsset,
            ),
          ),
        );

    await tester.pumpWidget(
      _testApp(themeMode: ThemeMode.dark, child: chanceCard()),
    );

    FadeTransition entrance() => tester.widget<FadeTransition>(
          find.byKey(const ValueKey('home-feature-entrance-chance')),
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
        child: chanceCard(reduceMotion: true),
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
            id: 'draws',
            title: 'Derniers tirages',
            tone: HomeFeatureTone.draws,
            assetPath: _drawsAsset,
          ),
        ),
      ),
    );
    await _finishCardTransitions(tester);

    final cardFinder = find.byKey(const ValueKey('home-feature-card-draws'));
    final interactionFinder =
        find.byKey(const ValueKey('home-feature-interaction-scale-draws'));
    final artworkFinder =
        find.byKey(const ValueKey('home-feature-artwork-motion-draws'));
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

          final card = tester.widget<AnimatedContainer>(
            find.byKey(ValueKey('home-feature-gradient-$id')),
          );
          final decoration = card.decoration! as BoxDecoration;
          final gradient = decoration.gradient! as LinearGradient;
          final title = tester.widget<Text>(
            find.byKey(ValueKey('home-feature-title-$id')),
          );
          final titleColor = title.style!.color!;
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
          final texture = decoration.image!.image as AssetImage;
          expect(
              texture.assetName,
              tone == HomeFeatureTone.draws
                  ? 'assets/images/home/brushed_gold.webp'
                  : 'assets/images/home/sapphire.webp');
          expect(
              tester
                  .getTopLeft(find.byKey(ValueKey('home-feature-image-$id')))
                  .dy,
              lessThan(tester
                  .getTopLeft(find.byKey(ValueKey('home-feature-card-$id')))
                  .dy));
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
              expect(
                  _contrastRatio(titleColor, base), greaterThanOrEqualTo(4.5));
            }
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final locale in const [Locale('fr'), Locale('en'), Locale('cr')]) {
    for (final mode in const [ThemeMode.dark, ThemeMode.light]) {
      for (final width in [320.0, 800.0, 1160.0]) {
        for (final scale in [1.0, 2.0]) {
          testWidgets(
              'casino layout ${locale.languageCode} ${mode.name} width $width scale $scale',
              (tester) async {
            await _setViewport(tester, Size(width, 700));
            final tapped = <String>[];
            await tester.pumpWidget(_testApp(
              themeMode: mode,
              locale: locale,
              child: MediaQuery(
                data: MediaQueryData(
                    size: Size(width, 700),
                    textScaler: TextScaler.linear(scale)),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _section(
                    onAction: tapped.add,
                    stories:
                        const SizedBox(height: 80, key: ValueKey('stories')),
                  ),
                ),
              ),
            ));
            await _finishCardTransitions(tester);
            final strings = FFLocalizations(locale);
            final hero = find.byKey(const ValueKey('home-vip-hero'));
            final stories = find.byKey(const ValueKey('stories'));
            expect(tester.getBottomLeft(stories).dy,
                lessThanOrEqualTo(tester.getTopLeft(hero).dy));
            expect(
                find.descendant(
                    of: hero, matching: find.text(strings.getText('covzb0rd'))),
                findsOneWidget);
            expect(
                find.descendant(
                    of: hero,
                    matching: find.text(strings.getText('home_open_vip'))),
                findsOneWidget);
            final chance =
                find.byKey(const ValueKey('home-feature-card-chance'));
            final results =
                find.byKey(const ValueKey('home-feature-card-draws'));
            expect(
                find.descendant(
                    of: results,
                    matching: find.text(strings.getText('home_latest_draws'))),
                findsOneWidget);
            if (width == 1160 && scale == 1) {
              expect(tester.getTopRight(hero).dx,
                  lessThan(tester.getTopLeft(results).dx));
              expect(
                  tester.getTopLeft(results).dx, tester.getTopLeft(chance).dx);
            } else if (width == 320 && scale == 1) {
              expect(tester.getBottomLeft(hero).dy,
                  lessThanOrEqualTo(tester.getTopLeft(results).dy));
              expect(
                  tester.getTopLeft(results).dy, tester.getTopLeft(chance).dy);
            }
            for (final (key, id) in [
              ('home-open-vip', 'vip'),
              ('home-feature-card-draws', 'results'),
              ('home-feature-card-chance', 'chance'),
              for (final id in ['video', 'stats', 'tchala', 'history'])
                ('home-shortcut-$id', id),
            ]) {
              final item = find.byKey(ValueKey(key));
              await tester.ensureVisible(item);
              await tester.tap(item);
              await tester.pump();
              expect(tapped.last, id);
              final rect = tester.getRect(item);
              expect(rect.left, greaterThanOrEqualTo(16));
              expect(rect.right, lessThanOrEqualTo(width - 16));
            }
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  }
}
