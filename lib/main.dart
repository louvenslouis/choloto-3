import 'dart:async';

import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'auth/firebase_auth/auth_util.dart';

import 'backend/firebase/firebase_config.dart';
import 'components/home_header_actions.dart';
import 'components/home_page_scaffold.dart';
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
      if (user.loggedIn && !user.isAnonymous) {
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
      theme: DarkModeTheme().materialTheme,
      themeMode: ThemeMode.dark,
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

  static const _destinations = [
    (
      label: 'uer2q4no',
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home_rounded),
      homeIcon: Icon(Icons.home_outlined),
    ),
    (
      label: 'wakkucok',
      icon: FaIcon(FontAwesomeIcons.checkToSlot),
      activeIcon: FaIcon(FontAwesomeIcons.checkToSlot),
      homeIcon: Icon(Icons.confirmation_number_outlined),
    ),
    (
      label: 'xj2saev3',
      icon: Icon(Icons.workspace_premium_outlined),
      activeIcon: Icon(Icons.workspace_premium_rounded),
      homeIcon: FaIcon(FontAwesomeIcons.crown, size: 20),
    ),
    (
      label: '14smzvpm',
      icon: FaIcon(FontAwesomeIcons.book),
      activeIcon: FaIcon(FontAwesomeIcons.bookOpen),
      homeIcon: Icon(Icons.menu_book_outlined),
    ),
  ];

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
        0 => const HomeWidget(inTabShell: true),
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

  List<BottomNavigationBarItem> _bottomDestinations(
    BuildContext context, {
    required bool onHome,
  }) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    return [
      for (final destination in _destinations)
        BottomNavigationBarItem(
          label: FFLocalizations.of(context).getText(destination.label),
          tooltip: '',
          icon: onHome ? destination.homeIcon : destination.icon,
          activeIcon: onHome
              ? Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.spacing.sm + tokens.spacing.xs,
                    vertical: tokens.spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primary,
                    borderRadius: BorderRadius.circular(tokens.radius.sm),
                  ),
                  child: IconTheme.merge(
                    data: IconThemeData(color: theme.onPrimary),
                    child: destination.homeIcon,
                  ),
                )
              : destination.activeIcon,
        ),
    ];
  }

  PreferredSizeWidget _homeDesktopBar(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final strings = FFLocalizations.of(context);
    final compact = MediaQuery.sizeOf(context).width < kBreakpointLarge;
    return AppBar(
      key: const ValueKey('home-desktop-navigation'),
      automaticallyImplyLeading: false,
      centerTitle: false,
      toolbarHeight: tokens.spacing.xl * 2,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: tokens.background.home,
      shape: Border(bottom: BorderSide(color: tokens.home.edge)),
      titleSpacing: compact ? tokens.spacing.md : tokens.spacing.lg,
      title: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: HomePageScaffold.maxContentWidth),
          child: SizedBox(
            height: tokens.spacing.xl * 2,
            child: NavigationToolbar(
              leading: const HomeHeaderBrand(),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!compact)
                    Container(
                      width: 1,
                      height: tokens.spacing.lg,
                      margin:
                          EdgeInsetsDirectional.only(end: tokens.spacing.xl),
                      color: tokens.home.edge,
                    ),
                  HomeHeaderActions.navigation(context),
                ],
              ),
              middleSpacing: tokens.spacing.md,
              middle: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < _destinations.length; i++)
                      Semantics(
                        selected: i == 0,
                        child: TextButton(
                          key: ValueKey('desktop-tab-${_tabNames[i]}'),
                          onPressed: () => _selectTab(i),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: compact
                                    ? tokens.spacing.xs
                                    : tokens.spacing.md),
                            minimumSize: const Size(kMinInteractiveDimension,
                                kMinInteractiveDimension),
                            foregroundColor: i == 0
                                ? tokens.home.statsAccent
                                : theme.primaryText,
                            textStyle:
                                (compact ? theme.titleSmall : theme.titleMedium)
                                    .copyWith(
                              fontWeight:
                                  i == 0 ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                                border: i == 0
                                    ? Border(
                                        bottom: BorderSide(
                                            color: theme.primary, width: 2))
                                    : null),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: tokens.spacing.sm),
                              child:
                                  Text(strings.getText(_destinations[i].label)),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

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
      destinations: [
        for (final destination in _destinations)
          NavigationRailDestination(
            icon: destination.icon,
            selectedIcon: destination.activeIcon,
            label: Text(FFLocalizations.of(context).getText(destination.label)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final onHome = _currentPageName == 'Home';
    final navigationBackground =
        onHome ? theme.designToken.background.home : theme.primaryBackground;
    final currentIndex = _tabNames.indexOf(_currentPageName);
    final wide = responsiveVisibility(
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
          children: [
            TickerMode(
              enabled: onHome,
              child: _tabPages.first ?? const SizedBox.shrink(),
            ),
            for (final page in _tabPages.skip(1))
              page ?? const SizedBox.shrink(),
          ],
        );

    return Scaffold(
      backgroundColor: navigationBackground,
      resizeToAvoidBottomInset: !widget.disableResizeToAvoidBottomInset,
      appBar: wide && onHome ? _homeDesktopBar(context) : null,
      body: Row(
        children: [
          if (wide && !onHome)
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
      ),
      bottomNavigationBar: wide
          ? null
          : Container(
              foregroundDecoration: onHome
                  ? BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              color: theme.designToken.home.edge
                                  .withValues(alpha: .6))))
                  : null,
              child: BottomNavigationBar(
                key: const ValueKey('primary-bottom-navigation'),
                currentIndex: currentIndex,
                onTap: _selectTab,
                backgroundColor: navigationBackground,
                selectedItemColor: theme.primary,
                unselectedItemColor:
                    onHome ? theme.designToken.home.mutedText : theme.alternate,
                selectedFontSize: onHome ? 12 : 14,
                selectedLabelStyle: onHome
                    ? theme.labelMedium.copyWith(fontWeight: FontWeight.w800)
                    : null,
                unselectedLabelStyle: onHome
                    ? theme.labelMedium.copyWith(fontWeight: FontWeight.w600)
                    : null,
                elevation: onHome ? 0 : null,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
                items: _bottomDestinations(context, onHome: onHome),
              ),
            ),
    );
  }
}
