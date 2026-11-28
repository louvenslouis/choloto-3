import 'package:choloto/app_state.dart';
import 'package:choloto/components/page_header_app_bar.dart';
import 'package:choloto/flutter_flow/flutter_flow_theme.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:choloto/main.dart' show MyApp;
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Keep the real app on its launch route while testing its theme offline.
class _StartupAuth extends FirebaseAuthPlatform {
  @override
  FirebaseAuthPlatform delegateFor(
          {required FirebaseApp app, Persistence? persistence}) =>
      this;
  @override
  FirebaseAuthPlatform setInitialValues(
          {Object? currentUser, String? languageCode}) =>
      this;
  @override
  Stream<UserPlatform?> authStateChanges() => const Stream.empty();
  @override
  Stream<UserPlatform?> idTokenChanges() => const Stream.empty();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  group('application theme', () {
    double contrast(Color a, Color b) {
      final x = a.computeLuminance();
      final y = b.computeLuminance();
      return (x > y ? x + 0.05 : y + 0.05) / (x > y ? y + 0.05 : x + 0.05);
    }

    test('page headers fade vertically into each dark page surface', () {
      final theme = DarkModeTheme();
      final tokens = theme.designToken;
      for (final vip in [false, true]) {
        final decoration = tokens.background.pageHeader(vip: vip);
        final gradient = decoration.gradient! as LinearGradient;
        expect(gradient.begin, Alignment.topCenter);
        expect(gradient.end, Alignment.bottomCenter);
        expect(gradient.colors.first.a, greaterThan(0));
        expect(gradient.colors.last.a, 0);
        expect(decoration.border, isNull);
        expect(decoration.borderRadius, isNull);
        for (final base in [
          tokens.background.home,
          theme.primaryBackground,
          theme.secondaryBackground
        ]) {
          for (final color in gradient.colors) {
            expect(contrast(theme.primaryText, Color.alphaBlend(color, base)),
                greaterThanOrEqualTo(4.5));
          }
        }
      }
      expect(tokens.background.pageHeader(),
          isNot(tokens.background.pageHeader(vip: true)));
    });

    testWidgets(
        'secondary page header fills the toolbar and preserves its actions',
        (tester) async {
      final tokens = DarkModeTheme().designToken;
      var taps = 0;
      for (final vip in [false, true]) {
        await tester.pumpWidget(MaterialApp(
          theme: DarkModeTheme().materialTheme,
          home: Scaffold(
              appBar: PageHeaderAppBar(
            vip: vip,
            title: const Text('Page'),
            leading: BackButton(onPressed: () => taps++),
            actions: [
              IconButton(
                  icon: const Icon(Icons.refresh), onPressed: () => taps++)
            ],
          )),
        ));
        final surface = find.byWidgetPredicate((w) =>
            w is DecoratedBox &&
            w.decoration == tokens.background.pageHeader(vip: vip));
        expect(tester.getRect(surface),
            tester.getRect(find.byType(PageHeaderAppBar)));
        await tester.tap(find.byType(BackButton));
        await tester.tap(find.byIcon(Icons.refresh));
      }
      expect(taps, 4);
    });

    test('VIP casino materials retain readable text on dark surfaces', () {
      final theme = DarkModeTheme();
      final materials = theme.designToken.vip;
      expect(materials.felt.colors.toSet().length, greaterThan(1));
      for (final color in materials.felt.colors) {
        expect(contrast(theme.primaryText, color), greaterThanOrEqualTo(4.5));
      }
      for (final color in materials.plaque.colors) {
        expect(
            contrast(materials.numberText, color), greaterThanOrEqualTo(4.5));
      }
      // Number insets remain close to the surrounding card material.
      for (var i = 0; i < materials.plaque.colors.length; i++) {
        expect(contrast(materials.plaque.colors[i], materials.felt.colors[i]),
            lessThan(1.5));
      }
      expect(
          contrast(theme.onPrimary, theme.primary), greaterThanOrEqualTo(4.5));
    });
    test('home cards and shortcut colors remain legible on dark surfaces', () {
      final theme = DarkModeTheme();
      final home = theme.designToken.home;
      expect(home.panel.gradient, home.surface);
      expect(home.panel.border, Border.all(color: home.panelEdge));
      expect(home.panel.borderRadius,
          BorderRadius.circular(theme.designToken.radius.md));
      for (final color in [...home.vipAmethyst.colors, ...home.chance.colors]) {
        expect(contrast(theme.onDecorative, color), greaterThanOrEqualTo(4.5));
      }
      for (final color in home.membership.colors) {
        expect(contrast(theme.onPrimary, color), greaterThanOrEqualTo(4.5));
      }
      for (final surface in home.surface.colors) {
        for (final foreground in [
          theme.primaryText,
          home.mutedText,
          home.videoAccent,
          home.statsAccent,
          home.tchalaAccent,
          home.historyAccent,
        ]) {
          expect(contrast(foreground, surface), greaterThanOrEqualTo(4.5));
        }
      }
    });
    test('VIP numbers and titles use distinct settings of the bundled face',
        () {
      final theme = DarkModeTheme();
      final type = theme.designToken.vip.typography;
      for (final size in [25.0, 32.0, 46.0, 60.0]) {
        final value = type.numeral(size);
        expect(value.fontFamily, theme.displaySmallFamily);
        expect(
            value.fontFeatures, contains(const FontFeature.tabularFigures()));
        expect(value.fontVariations, contains(FontVariation.opticalSize(size)));
        expect(value.fontVariations, contains(const FontVariation.width(78)));
        final separator = type.pairSeparator(value);
        expect(separator.fontWeight!.value, lessThan(value.fontWeight!.value));
        expect(separator.fontSize, value.fontSize);
      }
      final name = type.heading(36);
      expect(name.fontFamily, theme.displaySmallFamily);
      expect(name.fontVariations!.any((axis) => axis.axis == 'wdth'), isFalse);
      expect(type.category(compact: true).letterSpacing, greaterThan(0));
      for (final compact in [true, false]) {
        final poster = type.posterTitle(compact: compact);
        expect(poster.fontFamily, theme.titleSmallFamily);
        expect(poster.fontWeight!.value,
            greaterThan(type.numeral(32).fontWeight!.value));
        expect(poster.fontVariations, contains(const FontVariation.slant(-10)));
        expect(poster.fontVariations, contains(const FontVariation.width(87)));
        for (final jewel in FFVipJewel.values) {
          for (final surface
              in theme.designToken.vip.titleRibbon(jewel).colors) {
            expect(contrast(poster.color!, surface), greaterThanOrEqualTo(4.5),
                reason: jewel.name);
          }
        }
      }
    });
    test('engraved VIP pass and poster text keep their contrast', () {
      final theme = DarkModeTheme();
      final vip = theme.designToken.vip;
      for (final background in vip.pass.gradient!.colors) {
        expect(contrast(theme.onDecorative, background),
            greaterThanOrEqualTo(4.5));
        expect(contrast(vip.goldLight, background), greaterThanOrEqualTo(4.5));
      }
      for (final jewel in FFVipJewel.values) {
        final brightestTextArea =
            Color.alphaBlend(vip.posterShade(jewel), theme.onDecorative);
        expect(contrast(theme.primaryText, brightestTextArea),
            greaterThanOrEqualTo(4.5),
            reason: jewel.name);
      }
    });
    test('amethyst VIP actions and card icons remain legible', () {
      final theme = DarkModeTheme();
      final tokens = theme.designToken;
      final accent = tokens.home.amethystGlow;
      expect(contrast(theme.onPrimary, accent), greaterThanOrEqualTo(4.5));
      for (final background in [
        ...tokens.vip.felt.colors,
        ...tokens.home.surface.colors,
        tokens.background.home,
      ]) {
        expect(contrast(accent, background), greaterThanOrEqualTo(4.5));
        expect(contrast(tokens.home.mutedText, background),
            greaterThanOrEqualTo(4.5));
      }
    });
    test('home uses a subtle dark gradient without changing the base palette',
        () {
      final theme = DarkModeTheme();
      final background = theme.designToken.background.home;
      final gradient = theme.designToken.background.homeGradient;
      expect(background, isNot(theme.primaryBackground));
      expect(background.computeLuminance(), lessThan(0.004));
      expect(gradient.colors, hasLength(3));
      expect(gradient.colors[1], isNot(background));
      expect(gradient.colors[1].r, lessThanOrEqualTo(24 / 255));
      expect(gradient.colors[1].g, lessThanOrEqualTo(20 / 255));
      for (final color in gradient.colors) {
        final contrast = (theme.primaryText.computeLuminance() + 0.05) /
            (color.computeLuminance() + 0.05);
        expect(contrast, greaterThanOrEqualTo(7.0));
      }
      expect(theme.primaryBackground, const Color(0xFF000000));
    });

    testWidgets(
        'legacy light preference and changes to system appearance keep the app dark',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'ff_lightThemeEnabled': true,
        'ff_user': 'CHOLOTO',
      });
      FFAppState.reset();
      addTearDown(FFAppState.reset);
      await Firebase.initializeApp();
      FirebaseAuthPlatform.instance = _StartupAuth();
      await FFLocalizations.initialize();
      await FFAppState().initializePersistedState();
      expect(FFAppState().user, 'CHOLOTO');

      final dispatcher = tester.binding.platformDispatcher;
      addTearDown(dispatcher.clearPlatformBrightnessTestValue);
      dispatcher.platformBrightnessTestValue = Brightness.light;
      await tester.pumpWidget(MyApp());
      for (final system in [
        Brightness.light,
        Brightness.dark,
        Brightness.light
      ]) {
        dispatcher.platformBrightnessTestValue = system;
        await tester.pumpAndSettle();
        final context = tester.element(find.byType(Navigator).first);
        expect(MediaQuery.platformBrightnessOf(context), system);
        final material = Theme.of(context);
        final palette = FlutterFlowTheme.of(context);
        expect(material.brightness, Brightness.dark);
        expect(material.scaffoldBackgroundColor, const Color(0xFF000000));
        expect(palette.primary, const Color(0xFFEDB900));
        expect(palette.primaryBackground, material.scaffoldBackgroundColor);
        expect(palette.secondaryBackground, const Color(0xFF1C1C1E));
        expect(palette.primaryText, const Color(0xFFFFFFFF));
      }
    });
  });
}
