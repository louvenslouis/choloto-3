import 'package:choloto/app_state.dart';
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
