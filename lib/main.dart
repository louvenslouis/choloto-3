import 'dart:async';

import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'auth/firebase_auth/auth_util.dart';

import 'backend/firebase/firebase_config.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import 'services/push_notification_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await initFirebase();
  await FFLocalizations.initialize();

  final appState = FFAppState(); // Initialize FFAppState
  await appState.initializePersistedState();

  runApp(ChangeNotifierProvider(
    create: (context) => appState,
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class MyAppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  late ThemeMode _themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.path;
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();
  StreamSubscription<dynamic>? _authenticatedUserSubscription;
  StreamSubscription<BaseAuthUser>? _firebaseUserSubscription;
  StreamSubscription<dynamic>? _jwtTokenSubscription;

  @override
  void initState() {
    super.initState();

    _locale = FFLocalizations.getStoredLocale();
    _themeMode =
        FFAppState().lightThemeEnabled ? ThemeMode.light : ThemeMode.dark;
    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    unawaited(
      PushNotificationService.instance.initialize(
        onOpenPrediction: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _router.goNamed(VipWidget.routeName);
            }
          });
        },
        onForegroundPrediction: (title, body) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final notificationContext = appNavigatorKey.currentContext;
            if (notificationContext == null) {
              return;
            }
            ScaffoldMessenger.of(notificationContext).showSnackBar(
              SnackBar(
                content: Text('$title\n$body'),
                action: SnackBarAction(
                  label: 'Voir',
                  onPressed: () => _router.goNamed(VipWidget.routeName),
                ),
              ),
            );
          });
        },
      ),
    );
    _authenticatedUserSubscription = authenticatedUserStream.listen((_) {});
    _firebaseUserSubscription = cholotoFirebaseUserStream().listen((user) {
      _appStateNotifier.update(user);
      if (user.loggedIn) {
        unawaited(
          PushNotificationService.instance.syncAuthorizedSubscription(),
        );
      }
    });
    _jwtTokenSubscription = jwtTokenStream.listen((_) {});
    Future.delayed(
      Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  @override
  void dispose() {
    _authenticatedUserSubscription?.cancel();
    _firebaseUserSubscription?.cancel();
    _jwtTokenSubscription?.cancel();

    super.dispose();
  }

  void setLocale(String language) {
    FFLocalizations.storeLocale(language);
    safeSetState(() => _locale = createLocale(language));
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode == ThemeMode.light ? ThemeMode.light : ThemeMode.dark;
        FFAppState().lightThemeEnabled = _themeMode == ThemeMode.light;
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'CHOLOTO',
      scrollBehavior: MyAppScrollBehavior(),
      localizationsDelegates: [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationDelegate(),
        FallbackCupertinoLocalizationDelegate(),
      ],
      locale: _locale,
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
        Locale('cr'),
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFFEDB900),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFEDB900),
          onPrimary: Color(0xFF000000),
          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF14181B),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        useMaterial3: false,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFEDB900),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFEDB900),
          onPrimary: Color(0xFF000000),
          surface: Color(0xFF1C1C1E),
          onSurface: Color(0xFFFFFFFF),
        ),
        scaffoldBackgroundColor: const Color(0xFF000000),
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}

class NavBarPage extends StatefulWidget {
  NavBarPage({
    Key? key,
    this.initialPage,
    this.page,
    this.disableResizeToAvoidBottomInset = false,
  }) : super(key: key);

  final String? initialPage;
  final Widget? page;
  final bool disableResizeToAvoidBottomInset;

  @override
  _NavBarPageState createState() => _NavBarPageState();
}

/// This is the private State class that goes with NavBarPage.
class _NavBarPageState extends State<NavBarPage> {
  static const _tabNames = ['Home', 'Tirages', 'VIP', 'Tchala'];

  String _currentPageName = 'Home';
  late Widget? _currentPage;
  late List<Widget?> _tabPages;

  @override
  void initState() {
    super.initState();
    _currentPageName = widget.initialPage ?? _currentPageName;
    _currentPage = widget.page;
    _tabPages = List<Widget?>.filled(_tabNames.length, null);
    if (_currentPage == null) {
      final initialIndex = _tabNames.indexOf(_currentPageName);
      _tabPages[initialIndex] = _createTab(initialIndex);
    }
  }

  Widget _createTab(int index) => switch (index) {
        0 => HomeWidget(),
        1 => TiragesWidget(),
        2 => VipWidget(),
        3 => TchalaWidget(),
        _ => HomeWidget(),
      };

  @override
  Widget build(BuildContext context) {
    final currentIndex = _tabNames.indexOf(_currentPageName);

    return Scaffold(
      resizeToAvoidBottomInset: !widget.disableResizeToAvoidBottomInset,
      body: _currentPage ??
          IndexedStack(
            index: currentIndex,
            children: _tabPages
                .map((page) => page ?? const SizedBox.shrink())
                .toList(),
          ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => safeSetState(() {
          _currentPage = null;
          _currentPageName = _tabNames[i];
          _tabPages[i] ??= _createTab(i);
        }),
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        selectedItemColor: FlutterFlowTheme.of(context).primary,
        unselectedItemColor: FlutterFlowTheme.of(context).alternate,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
              size: 24.0,
            ),
            label: FFLocalizations.of(context).getText(
              'uer2q4no' /* Accueil */,
            ),
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.voteYea,
              size: 24.0,
            ),
            label: FFLocalizations.of(context).getText(
              'wakkucok' /* Tirages */,
            ),
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.workspace_premium_rounded,
              size: 24.0,
            ),
            label: FFLocalizations.of(context).getText(
              'xj2saev3' /* VIP */,
            ),
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.book,
              size: 24.0,
            ),
            label: FFLocalizations.of(context).getText(
              '14smzvpm' /* Tchala */,
            ),
            tooltip: '',
          )
        ],
      ),
    );
  }
}
