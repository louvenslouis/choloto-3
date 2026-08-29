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
    final deviceLanguage =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final initialLanguage = _locale?.languageCode ??
        (FFLocalizations.languages().contains(deviceLanguage)
            ? deviceLanguage
            : 'fr');
    PushNotificationService.instance.setLanguageCode(initialLanguage);
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
            final localizations = FFLocalizations.of(notificationContext);
            final localizedTitle = title.isNotEmpty
                ? title
                : localizations.getVariableText(
                    frText: 'Nouvelle prédiction disponible',
                    enText: 'New prediction available',
                    crText: 'Nouvo prediksyon disponib',
                  );
            final localizedBody = body.isNotEmpty
                ? body
                : localizations.getVariableText(
                    frText:
                        'Touchez pour consulter la nouvelle prédiction VIP.',
                    enText: 'Tap to view the new VIP prediction.',
                    crText: 'Peze pou w gade nouvo prediksyon VIP la.',
                  );
            ScaffoldMessenger.of(notificationContext).showSnackBar(
              SnackBar(
                content: Text('$localizedTitle\n$localizedBody'),
                action: SnackBarAction(
                  label: localizations.getVariableText(
                    frText: 'Voir',
                    enText: 'View',
                    crText: 'Gade',
                  ),
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
    PushNotificationService.instance.setLanguageCode(language);
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

  void _selectTab(int index) => safeSetState(() {
        _currentPage = null;
        _currentPageName = _tabNames[index];
        _tabPages[index] ??= _createTab(index);
      });

  List<NavigationRailDestination> _railDestinations(
    BuildContext context,
  ) =>
      [
        NavigationRailDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home_rounded),
          label: Text(
            FFLocalizations.of(context).getText(
              'uer2q4no' /* Accueil */,
            ),
          ),
        ),
        NavigationRailDestination(
          icon: const FaIcon(FontAwesomeIcons.checkToSlot),
          selectedIcon: const FaIcon(FontAwesomeIcons.checkToSlot),
          label: Text(
            FFLocalizations.of(context).getText(
              'wakkucok' /* Tirages */,
            ),
          ),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.workspace_premium_outlined),
          selectedIcon: const Icon(Icons.workspace_premium_rounded),
          label: Text(
            FFLocalizations.of(context).getText(
              'xj2saev3' /* VIP */,
            ),
          ),
        ),
        NavigationRailDestination(
          icon: const FaIcon(FontAwesomeIcons.book),
          selectedIcon: const FaIcon(FontAwesomeIcons.bookOpen),
          label: Text(
            FFLocalizations.of(context).getText(
              '14smzvpm' /* Tchala */,
            ),
          ),
        ),
      ];

  List<BottomNavigationBarItem> _bottomDestinations(
    BuildContext context,
  ) =>
      [
        BottomNavigationBarItem(
          icon: const Icon(
            Icons.home_outlined,
            size: 24.0,
          ),
          activeIcon: const Icon(
            Icons.home_rounded,
            size: 24.0,
          ),
          label: FFLocalizations.of(context).getText(
            'uer2q4no' /* Accueil */,
          ),
          tooltip: '',
        ),
        BottomNavigationBarItem(
          icon: const FaIcon(
            FontAwesomeIcons.checkToSlot,
            size: 24.0,
          ),
          label: FFLocalizations.of(context).getText(
            'wakkucok' /* Tirages */,
          ),
          tooltip: '',
        ),
        BottomNavigationBarItem(
          icon: const Icon(
            Icons.workspace_premium_outlined,
            size: 24.0,
          ),
          activeIcon: const Icon(
            Icons.workspace_premium_rounded,
            size: 24.0,
          ),
          label: FFLocalizations.of(context).getText(
            'xj2saev3' /* VIP */,
          ),
          tooltip: '',
        ),
        BottomNavigationBarItem(
          icon: const FaIcon(
            FontAwesomeIcons.book,
            size: 24.0,
          ),
          activeIcon: const FaIcon(
            FontAwesomeIcons.bookOpen,
            size: 24.0,
          ),
          label: FFLocalizations.of(context).getText(
            '14smzvpm' /* Tchala */,
          ),
          tooltip: '',
        ),
      ];

  Widget _buildRail(
    BuildContext context, {
    required int currentIndex,
    required bool extended,
  }) {
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;
    final unselectedColor = theme.primaryText.withValues(alpha: 0.72);

    return NavigationRail(
      key: const ValueKey('primary-navigation-rail'),
      selectedIndex: currentIndex,
      onDestinationSelected: _selectTab,
      extended: extended,
      labelType:
          extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
      minWidth: spacing.xl * 2.5,
      minExtendedWidth: spacing.xl * 8.0,
      backgroundColor: theme.secondaryBackground,
      groupAlignment: -1.0,
      useIndicator: true,
      indicatorColor: theme.primary,
      selectedIconTheme: IconThemeData(
        color: theme.onPrimary,
        size: spacing.lg,
      ),
      unselectedIconTheme: IconThemeData(
        color: unselectedColor,
        size: spacing.lg,
      ),
      selectedLabelTextStyle: theme.labelLarge.override(
        color: theme.primary,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: theme.labelLarge.override(
        color: unselectedColor,
        fontWeight: FontWeight.w500,
      ),
      leading: Padding(
        padding: EdgeInsets.fromLTRB(
          spacing.md,
          spacing.lg,
          spacing.md,
          spacing.xl,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(theme.designToken.radius.sm),
              child: Image.asset(
                'assets/images/Logo_Choloto_509.png',
                key: const ValueKey('primary-navigation-logo'),
                width: extended ? spacing.xl * 2.0 : spacing.xl * 1.5,
                height: extended ? spacing.xl * 2.0 : spacing.xl * 1.5,
                fit: BoxFit.cover,
              ),
            ),
            if (extended) ...[
              SizedBox(width: spacing.md),
              Text(
                FFLocalizations.of(context).getText(
                  'loh576na' /* CHOLOTO */,
                ),
                style: theme.titleLarge.override(
                  color: theme.primaryText,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ],
        ),
      ),
      destinations: _railDestinations(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _tabNames.indexOf(_currentPageName);
    final showNavigationRail = responsiveVisibility(
      context: context,
      phone: false,
      tablet: false,
      tabletLandscape: true,
      desktop: true,
    );
    final extendNavigationRail =
        MediaQuery.sizeOf(context).width >= kBreakpointLarge;
    final page = _currentPage ??
        IndexedStack(
          index: currentIndex,
          children:
              _tabPages.map((page) => page ?? const SizedBox.shrink()).toList(),
        );

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      resizeToAvoidBottomInset: !widget.disableResizeToAvoidBottomInset,
      body: showNavigationRail
          ? Row(
              children: [
                SafeArea(
                  right: false,
                  child: _buildRail(
                    context,
                    currentIndex: currentIndex,
                    extended: extendNavigationRail,
                  ),
                ),
                Expanded(child: page),
              ],
            )
          : page,
      bottomNavigationBar: showNavigationRail
          ? null
          : BottomNavigationBar(
              key: const ValueKey('primary-bottom-navigation'),
              currentIndex: currentIndex,
              onTap: _selectTab,
              backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
              selectedItemColor: FlutterFlowTheme.of(context).primary,
              unselectedItemColor: FlutterFlowTheme.of(context).alternate,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              items: _bottomDestinations(context),
            ),
    );
  }
}
