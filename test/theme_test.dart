import 'package:choloto/app_state.dart';
import 'package:choloto/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('application theme', () {
    test('home uses readable warm charcoal without changing the base palette',
        () {
      final theme = DarkModeTheme();
      final background = theme.designToken.background.home;
      expect(background, isNot(theme.primaryBackground));
      expect(background.computeLuminance(), greaterThan(0.01));
      for (final foreground in [theme.primaryText, theme.primary]) {
        final contrast = (foreground.computeLuminance() + 0.05) /
            (background.computeLuminance() + 0.05);
        expect(contrast, greaterThanOrEqualTo(7.0));
      }
      expect(theme.primaryBackground, const Color(0xFF000000));
    });

    test('home keeps the existing off-white surface in light mode', () {
      final theme = LightModeTheme();
      expect(theme.designToken.background.home, theme.primaryBackground);
    });

    testWidgets('uses the unchanged black palette in dark mode',
        (tester) async {
      late FlutterFlowTheme resolvedTheme;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          darkTheme: ThemeData(brightness: Brightness.dark),
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (context) {
              resolvedTheme = FlutterFlowTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolvedTheme, isA<DarkModeTheme>());
      expect(resolvedTheme.primary, const Color(0xFFEDB900));
      expect(resolvedTheme.primaryBackground, const Color(0xFF000000));
      expect(resolvedTheme.secondaryBackground, const Color(0xFF1C1C1E));
      expect(resolvedTheme.primaryText, const Color(0xFFFFFFFF));
    });

    testWidgets('uses a light palette while keeping yellow as primary',
        (tester) async {
      late FlutterFlowTheme resolvedTheme;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          darkTheme: ThemeData(brightness: Brightness.dark),
          themeMode: ThemeMode.light,
          home: Builder(
            builder: (context) {
              resolvedTheme = FlutterFlowTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolvedTheme, isA<LightModeTheme>());
      expect(resolvedTheme.primary, const Color(0xFFEDB900));
      expect(resolvedTheme.primaryBackground, const Color(0xFFF7F7F7));
      expect(resolvedTheme.secondaryBackground, const Color(0xFFFFFFFF));
      expect(resolvedTheme.primaryText, const Color(0xFF14181B));
    });

    test('keeps dark as default and persists explicit light activation',
        () async {
      SharedPreferences.setMockInitialValues({});
      FFAppState.reset();

      final initialState = FFAppState();
      await initialState.initializePersistedState();
      expect(initialState.lightThemeEnabled, isFalse);

      initialState.lightThemeEnabled = true;
      FFAppState.reset();

      final restoredState = FFAppState();
      await restoredState.initializePersistedState();
      expect(restoredState.lightThemeEnabled, isTrue);
    });
  });
}
