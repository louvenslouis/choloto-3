import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:choloto/flutter_flow/flutter_flow_theme.dart';
import 'package:choloto/main.dart';
import 'package:choloto/auth/base_auth_user_provider.dart';
import 'package:choloto/flutter_flow/nav/nav.dart';
import 'package:choloto/tchala/tchala_data_repository.dart';
import 'package:choloto/tchala/tchala_widget.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class _Visitor extends Fake implements BaseAuthUser {
  @override
  bool get loggedIn => false;
}

Widget _navigationApp({
  required Locale locale,
  required ThemeMode themeMode,
  required String initialPage,
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: const [Locale('fr'), Locale('en'), Locale('cr')],
    localizationsDelegates: const [
      FFLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      FallbackMaterialLocalizationDelegate(),
      FallbackCupertinoLocalizationDelegate(),
    ],
    theme: ThemeData(brightness: Brightness.light),
    darkTheme: ThemeData(brightness: Brightness.dark),
    themeMode: themeMode,
    home: NavBarPage(
      initialPage: initialPage,
      page: const ColoredBox(
        key: ValueKey('navigation-test-page'),
        color: Colors.transparent,
      ),
    ),
  );
}

Future<void> _pumpAtSize(
  WidgetTester tester, {
  required Size size,
  Locale locale = const Locale('fr'),
  ThemeMode themeMode = ThemeMode.dark,
  String initialPage = 'VIP',
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    _navigationApp(
        locale: locale, themeMode: themeMode, initialPage: initialPage),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets(
      'home changes navigation at the tablet breakpoint without replacing the page',
      (tester) async {
    await _pumpAtSize(tester, size: const Size(766, 900), initialPage: 'Home');
    final pageFinder = find.byKey(const ValueKey('navigation-test-page'));
    final pageElement = tester.element(pageFinder);
    expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .currentIndex,
        0);
    tester.view.physicalSize = const Size(767, 900);
    await tester.pumpAndSettle();
    expect(tester.element(pageFinder), same(pageElement));
    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsNothing);
    expect(
        find.byKey(const ValueKey('home-desktop-navigation')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-header-logo')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-header-actions')), findsOneWidget);
    for (final name in ['Home', 'Tirages', 'VIP', 'Tchala']) {
      expect(find.byKey(ValueKey('desktop-tab-$name')).hitTestable(),
          findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping Tchala in the home header selects its existing tab',
      (tester) async {
    tester.binding.defaultBinaryMessenger.setMockMessageHandler(
      'dev.flutter.pigeon.firebase_analytics_platform_interface.FirebaseAnalyticsHostApi.logEvent',
      (_) async => const StandardMessageCodec().encodeMessage([null]),
    );
    await _pumpAtSize(tester, size: const Size(1440, 900), initialPage: 'Home');
    await tester.tap(find.byKey(const ValueKey('desktop-tab-Tchala')));
    await tester.pump();
    expect(find.byType(TchalaWidget), findsOneWidget);
    final tab = tester
        .widget<TextButton>(find.byKey(const ValueKey('desktop-tab-Tchala')));
    expect(tab.style!.foregroundColor!.resolve({}),
        DarkModeTheme().designToken.home.statsAccent);
    expect(find.byKey(const ValueKey('tchala-desktop-navigation')),
        findsOneWidget);
    final pages =
        tester.widget<IndexedStack>(find.byType(IndexedStack)).children;
    expect((pages.first as TickerMode).enabled, isFalse);
    expect(pages.last, isA<TchalaWidget>());
    expect(find.byKey(const ValueKey('home-desktop-navigation')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Tirages keeps its selection and page across the header breakpoint',
      (tester) async {
    await _pumpAtSize(tester,
        size: const Size(766, 900), initialPage: 'Tirages');
    final page = find.byKey(const ValueKey('navigation-test-page'));
    final element = tester.element(page);
    expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .currentIndex,
        1);

    tester.view.physicalSize = const Size(767, 900);
    await tester.pumpAndSettle();
    expect(tester.element(page), same(element));
    expect(find.byKey(const ValueKey('tirages-desktop-navigation')),
        findsOneWidget);
    final palette = FlutterFlowTheme.of(element);
    Color? colorOf(String tab) => tester
        .widget<TextButton>(
          find.byKey(ValueKey('desktop-tab-$tab')).hitTestable(),
        )
        .style!
        .foregroundColor!
        .resolve({});
    expect(colorOf('Tirages'), palette.designToken.home.statsAccent);
    expect(colorOf('Home'), palette.primaryText);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets(
      'Saints route opens the calendar and back restores Tchala symbols',
      (tester) async {
    tester.binding.defaultBinaryMessenger.setMockMessageHandler(
      'dev.flutter.pigeon.firebase_analytics_platform_interface.FirebaseAnalyticsHostApi.logEvent',
      (_) async => const StandardMessageCodec().encodeMessage([null]),
    );
    await tester.runAsync(() => tchalaDataRepository.reload());
    Future<void> settleRoute() async {
      await tester.pump();
      await tester.pump();
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
    }

    final notifier = AppStateNotifier.createForTesting()
      ..user = _Visitor()
      ..stopShowingSplashImage();
    final router = createRouter(notifier)..goNamed(TchalaWidget.routeName);
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr')],
      localizationsDelegates: const [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    ));
    await settleRoute();
    int tab() => tester.widget<TabBar>(find.byType(TabBar)).controller!.index;
    expect(tab(), 0);
    router.pushNamed(TchalaWidget.saintsRouteName);
    await settleRoute();
    expect(tab(), 1);
    expect(find.text('Rechercher un saint ou une date'), findsOneWidget);
    expect(find.byKey(const ValueKey('saints-focus')), findsOneWidget);
    router.pop();
    await settleRoute();
    expect(tab(), 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps bottom navigation on a small phone', (tester) async {
    await _pumpAtSize(tester, size: const Size(320, 568));

    expect(
      find.byKey(const ValueKey('primary-bottom-navigation')),
      findsOneWidget,
    );
    expect(find.byType(NavigationRail), findsNothing);
    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      2,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps bottom navigation on tablet portrait', (tester) async {
    await _pumpAtSize(tester, size: const Size(600, 900));

    expect(
      find.byKey(const ValueKey('primary-bottom-navigation')),
      findsOneWidget,
    );
    expect(find.byType(NavigationRail), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final locale in const [Locale('fr'), Locale('en'), Locale('cr')]) {
    for (final themeMode in const [ThemeMode.dark, ThemeMode.light]) {
      testWidgets(
        'uses a compact tablet-landscape menu in ${locale.languageCode} '
        'and ${themeMode.name} mode',
        (tester) async {
          await _pumpAtSize(
            tester,
            size: const Size(800, 600),
            locale: locale,
            themeMode: themeMode,
          );

          final rail = tester.widget<NavigationRail>(
            find.byKey(const ValueKey('primary-navigation-rail')),
          );

          expect(find.byType(BottomNavigationBar), findsNothing);
          expect(rail.extended, isFalse);
          expect(rail.labelType, NavigationRailLabelType.all);
          expect(rail.selectedIndex, 2);
          expect(rail.destinations, hasLength(4));
          expect(
            find.byKey(const ValueKey('primary-navigation-logo')),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'uses an extended desktop menu in ${locale.languageCode} '
        'and ${themeMode.name} mode',
        (tester) async {
          await _pumpAtSize(
            tester,
            size: const Size(1440, 900),
            locale: locale,
            themeMode: themeMode,
          );

          final rail = tester.widget<NavigationRail>(
            find.byKey(const ValueKey('primary-navigation-rail')),
          );
          final localizations = FFLocalizations(locale);

          expect(find.byType(BottomNavigationBar), findsNothing);
          expect(rail.extended, isTrue);
          expect(rail.labelType, NavigationRailLabelType.none);
          expect(rail.selectedIndex, 2);
          expect(
            find.text(localizations.getText('uer2q4no')),
            findsOneWidget,
          );
          expect(
            find.text(localizations.getText('wakkucok')),
            findsOneWidget,
          );
          expect(
            find.text(localizations.getText('xj2saev3')),
            findsOneWidget,
          );
          expect(
            find.text(localizations.getText('14smzvpm')),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
