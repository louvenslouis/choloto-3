import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'auth/firebase_auth/auth_util.dart';

import 'backend/firebase/firebase_config.dart';
import 'components/home_header_actions.dart';
import '/components/page_header_app_bar.dart';
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
        onOpen: _openPushNotification,
        onForeground: (message) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final notificationContext = appNavigatorKey.currentContext;
            final route = PushNotificationService.instance.routeFor(message);
            if (!mounted || notificationContext == null || route == null) {
              return;
            }
            final localizations = FFLocalizations.of(notificationContext);
            String title =
                message.data['title'] is String ? message.data['title'] : '';
            String body =
                message.data['body'] is String ? message.data['body'] : '';
            if (message.data['type'] == 'new_prediction') {
              if (title.isEmpty) {
                title = localizations.getVariableText(
                  frText: 'Nouvelle prédiction disponible',
                  enText: 'New prediction available',
                  crText: 'Nouvo prediksyon disponib',
                );
              }
              if (body.isEmpty) {
                body = localizations.getVariableText(
                  frText: 'Touchez pour consulter la nouvelle prédiction VIP.',
                  enText: 'Tap to view the new VIP prediction.',
                  crText: 'Peze pou w gade nouvo prediksyon VIP la.',
                );
              }
            }
            final content =
                [title, body].where((text) => text.isNotEmpty).join('\n');
            if (content.isEmpty) return;
            ScaffoldMessenger.of(notificationContext).showSnackBar(
              SnackBar(
                content: Text(content),
                action: SnackBarAction(
                  label: localizations.getVariableText(
                    frText: 'Voir',
                    enText: 'View',
                    crText: 'Gade',
                  ),
                  onPressed: () => _openPushNotification(message),
                ),
              ),
            );
          });
          WidgetsBinding.instance.ensureVisualUpdate();
        },
      ),
    );
    _authenticatedUserSubscription = authenticatedUserStream.listen((_) {});
    _firebaseUserSubscription = cholotoFirebaseUserStream().listen((user) {
      _appStateNotifier.update(user);
      unawaited(PushNotificationService.instance.syncAuthorizedSubscription());
    });
    _jwtTokenSubscription = jwtTokenStream.listen((_) {});
  }

  void _openPushNotification(RemoteMessage message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = PushNotificationService.instance.routeFor(message);
      if (!mounted || route == null) return;
      if (message.data['type'] == 'new_bingo') {
        unawaited(_router.push<void>(route));
      } else {
        _router.go(route);
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
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
      builder: (context, child) {
        final preferences = FFAppState().devicePreferences;
        return ListenableBuilder(
          listenable: preferences,
          builder: (context, _) => MediaQuery(
            data: preferences.applyTo(MediaQuery.of(context)),
            child: child!,
          ),
        );
      },
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
    (label: 'uer2q4no', icon: Icon(Icons.home_outlined)),
    (label: 'wakkucok', icon: FaIcon(FontAwesomeIcons.checkToSlot)),
    (label: 'xj2saev3', icon: FaIcon(FontAwesomeIcons.crown, size: 20)),
    (label: '14smzvpm', icon: Icon(Icons.menu_book_outlined)),
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
      BuildContext context, Color selectedColor) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    return [
      for (final destination in _destinations)
        BottomNavigationBarItem(
          label: FFLocalizations.of(context).getText(destination.label),
          tooltip: '',
          icon: destination.icon,
          activeIcon: Container(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spacing.sm + tokens.spacing.xs,
              vertical: tokens.spacing.xs,
            ),
            decoration: BoxDecoration(
              color: selectedColor,
              borderRadius: BorderRadius.circular(tokens.radius.sm),
            ),
            child: IconTheme.merge(
              data: IconThemeData(color: theme.onPrimary),
              child: destination.icon,
            ),
          ),
        ),
    ];
  }

  PreferredSizeWidget _desktopTabBar(BuildContext context, int selectedIndex) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final strings = FFLocalizations.of(context);
    final compact = MediaQuery.sizeOf(context).width < kBreakpointLarge;
    final vip = _tabNames[selectedIndex] == 'VIP';
    return AppBar(
      key: ValueKey(
          '${_tabNames[selectedIndex].toLowerCase()}-desktop-navigation'),
      automaticallyImplyLeading: false,
      centerTitle: false,
      toolbarHeight: tokens.spacing.xl * 2,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: tokens.background.home,
      flexibleSpace: selectedIndex == 0 ? const PageHeaderBackdrop() : null,
      shape: selectedIndex == 0
          ? null
          : Border(bottom: BorderSide(color: tokens.home.edge)),
      titleSpacing: compact ? tokens.spacing.md : tokens.spacing.lg,
      title: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: HomePageScaffold.maxContentWidth),
          child: SizedBox(
            height: tokens.spacing.xl * 2,
            child: NavigationToolbar(
              leading: const HomeHeaderBrand(),
              trailing: selectedIndex == 0
                  ? HomeHeaderActions.navigation(context)
                  : null,
              middleSpacing: tokens.spacing.md,
              middle: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < _destinations.length; i++)
                      Semantics(
                        selected: i == selectedIndex,
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
                            foregroundColor: i == selectedIndex
                                ? (vip
                                    ? tokens.home.amethystGlow
                                    : tokens.home.statsAccent)
                                : theme.primaryText,
                            textStyle:
                                (compact ? theme.titleSmall : theme.titleMedium)
                                    .copyWith(
                              fontWeight: i == selectedIndex
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                                border: i == selectedIndex
                                    ? Border(
                                        bottom: BorderSide(
                                            color: vip
                                                ? tokens.home.amethystGlow
                                                : theme.primary,
                                            width: 2))
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

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final onHome = _currentPageName == 'Home';
    final tokens = theme.designToken;
    final navigationBackground = tokens.background.home;
    final selectedColor =
        _currentPageName == 'VIP' ? tokens.home.amethystGlow : theme.primary;
    final currentIndex = _tabNames.indexOf(_currentPageName);
    final wide = responsiveVisibility(
      context: context,
      phone: false,
      tablet: false,
      tabletLandscape: true,
      desktop: true,
    );
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
      appBar: wide ? _desktopTabBar(context, currentIndex) : null,
      body: page,
      bottomNavigationBar: wide
          ? null
          : Container(
              foregroundDecoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
                        color: tokens.home.edge.withValues(alpha: .6))),
              ),
              child: BottomNavigationBar(
                key: const ValueKey('primary-bottom-navigation'),
                currentIndex: currentIndex,
                onTap: _selectTab,
                backgroundColor: navigationBackground,
                selectedItemColor: selectedColor,
                unselectedItemColor: tokens.home.mutedText,
                selectedFontSize: 12,
                selectedLabelStyle:
                    theme.labelMedium.copyWith(fontWeight: FontWeight.w800),
                unselectedLabelStyle:
                    theme.labelMedium.copyWith(fontWeight: FontWeight.w600),
                elevation: 0,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
                items: _bottomDestinations(context, selectedColor),
              ),
            ),
    );
  }
}
