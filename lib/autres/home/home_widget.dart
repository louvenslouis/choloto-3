import 'dart:async';

import '/auth/firebase_auth/auth_util.dart';
import '/autres/bingo/bingo/bingo_dialog.dart';
import '/autres/bingo/bingo/bingo_story_button.dart';
import '/backend/backend.dart';
import '/components/home_feature_card.dart';
import '/components/home_header_actions.dart';
import '/components/home_stories_rail.dart';
import '/components/rappel_fin_abonnement_widget.dart';
import '/components/tirages_home_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/engagement_service.dart';
import '/youtube/youtube_feed_service.dart';
import '/youtube/youtube_story.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'home_model.dart';
export 'home_model.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  static String routeName = 'Home';
  static String routePath = '/home';

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> with WidgetsBindingObserver {
  late HomeModel _model;

  StreamSubscription<UserRecord?>? _subscriptionReminderSubscription;
  StreamSubscription<List<BingoRecord>>? _bingoStoriesSubscription;
  Timer? _subscriptionExpirationTimer;
  Timer? _bingoExpirationTimer;
  List<BingoRecord> _bingoRecords = const [];
  DateTime? _latestSubscriptionExpiration;
  bool _homeDialogsReady = false;
  bool _subscriptionReminderHandled = false;
  bool _youtubeStoriesLoading = true;
  bool _youtubeStoriesLoadFailed = false;
  bool _youtubeStoriesViewed = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  int _assetCacheWidth(BuildContext context, double logicalWidth) =>
      (logicalWidth * MediaQuery.devicePixelRatioOf(context)).ceil();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _model = createModel(context, () => HomeModel());
    _updateSubscriptionExpiration(
      currentUserDocument?.endSub,
      rebuild: false,
    );
    _subscriptionReminderSubscription = authenticatedUserStream.listen((user) {
      _updateSubscriptionExpiration(user?.endSub);
      unawaited(_maybeShowSubscriptionExpirationReminder());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(recordDailyEngagement(userReference: currentUserReference));
      unawaited(_loadYoutubeStories());
      unawaited(_loadBetaFeatures());
    });

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Home'});
    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      unawaited(_initializeBingoStories());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bingoExpirationTimer?.cancel();
    _subscriptionExpirationTimer?.cancel();
    unawaited(_bingoStoriesSubscription?.cancel());
    unawaited(_subscriptionReminderSubscription?.cancel());
    _model.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(recordDailyEngagement(userReference: currentUserReference));
      unawaited(_loadYoutubeStories());
      safeSetState(() {});
    }
  }

  Future<void> _initializeBingoStories() async {
    logFirebaseEvent('HOME_PAGE_Home_ON_INIT_STATE');
    logFirebaseEvent('Home_bingorequette');
    try {
      final records = await queryBingoRecordOnce(
        queryBuilder: (bingoRecord) =>
            bingoRecord.orderBy('date', descending: true),
      );
      await _applyBingoRecords(records, showAutomaticDialog: true);
    } catch (error) {
      debugPrint('Bingo story feed error: $error');
    } finally {
      if (mounted) {
        _homeDialogsReady = true;
        await _maybeShowSubscriptionExpirationReminder();
        if (mounted) _subscribeToBingoStories();
      }
    }
  }

  void _subscribeToBingoStories() {
    if (_bingoStoriesSubscription != null) return;
    _bingoStoriesSubscription = queryBingoRecord(
      queryBuilder: (bingoRecord) =>
          bingoRecord.orderBy('date', descending: true),
    ).listen(
      (records) => unawaited(_applyBingoRecords(records)),
      onError: (Object error) {
        debugPrint('Bingo story stream error: $error');
      },
    );
  }

  Future<void> _applyBingoRecords(
    List<BingoRecord> records, {
    bool showAutomaticDialog = false,
  }) async {
    if (!mounted) return;
    final now = getCurrentTimestamp;
    _bingoRecords = List.unmodifiable(records);
    _model.bingooutput = records.firstOrNull;
    _model.bingoStories = _activeBingoRecords(now);
    _scheduleBingoExpirationRefresh(now);

    final latest = _model.bingooutput;
    if (latest?.hasDate() ?? false) {
      if (FFAppState().bingo.date != latest?.date) {
        logFirebaseEvent('Home_update_app_state');
        FFAppState().updateBingoStruct(
          (bingo) => bingo
            ..date = latest?.date
            ..vue = false
            ..doc = latest?.reference
            ..gagner = null
            ..refGain = null
            ..dataStack = latest!.dataStack.toList()
            ..expiration = latest.expiration,
        );
      }
    } else if (FFAppState().bingo.hasDate()) {
      logFirebaseEvent('Home_update_app_state');
      FFAppState().bingo = BingoStruct();
    }
    safeSetState(() {});

    final latestIsActive = latest != null &&
        _model.bingoStories
            .any((record) => record.reference == latest.reference);
    if (!showAutomaticDialog ||
        !latestIsActive ||
        FFAppState().bingo.vue ||
        !mounted) {
      return;
    }

    logFirebaseEvent('Home_alert_dialog');
    await showBingoDialog(context: context, bingos: _model.bingoStories);
    if (!mounted) return;
    logFirebaseEvent('Home_update_app_state');
    FFAppState().updateBingoStruct((bingo) => bingo..vue = true);
    safeSetState(() {});
  }

  List<BingoRecord> _activeBingoRecords(DateTime now) => _bingoRecords
      .where(
        (record) => isBingoActive(
          bingoDate: record.date,
          expiration: record.expiration,
          now: now,
        ),
      )
      .toList(growable: false);

  void _scheduleBingoExpirationRefresh(DateTime now) {
    _bingoExpirationTimer?.cancel();
    final nextExpiration = _bingoRecords
        .map((record) => record.expiration)
        .whereType<DateTime>()
        .where((expiration) => !expiration.isBefore(now))
        .minOrNull;
    if (nextExpiration == null) return;

    _bingoExpirationTimer = Timer(
      nextExpiration.difference(now) + const Duration(milliseconds: 1),
      () {
        if (!mounted) return;
        final refreshedAt = getCurrentTimestamp;
        _model.bingoStories = _activeBingoRecords(refreshedAt);
        _scheduleBingoExpirationRefresh(refreshedAt);
        safeSetState(() {});
      },
    );
  }

  void _updateSubscriptionExpiration(
    DateTime? expiration, {
    bool rebuild = true,
  }) {
    final expirationChanged = _latestSubscriptionExpiration != expiration;
    _latestSubscriptionExpiration = expiration;
    _subscriptionExpirationTimer?.cancel();

    if (expirationChanged) {
      _subscriptionReminderHandled = false;
    }
    if (rebuild) {
      safeSetState(() {});
    }

    final timeUntilExpiration = expiration?.difference(getCurrentTimestamp);
    if (timeUntilExpiration != null && timeUntilExpiration > Duration.zero) {
      final refreshDelay = timeUntilExpiration > const Duration(days: 1)
          ? const Duration(days: 1)
          : timeUntilExpiration;
      _subscriptionExpirationTimer = Timer(refreshDelay, () {
        if (!mounted) {
          return;
        }
        safeSetState(() {});
        unawaited(_maybeShowSubscriptionExpirationReminder());
        _updateSubscriptionExpiration(
          _latestSubscriptionExpiration,
          rebuild: false,
        );
      });
    }
  }

  Future<void> _maybeShowSubscriptionExpirationReminder() async {
    final expiration = _latestSubscriptionExpiration;
    if (!mounted ||
        !_homeDialogsReady ||
        _subscriptionReminderHandled ||
        expiration == null ||
        !shouldShowSubscriptionExpirationReminder(
          expiration: expiration,
          now: getCurrentTimestamp,
        )) {
      return;
    }

    _subscriptionReminderHandled = true;
    logFirebaseEvent('HOME_SUB_EXPIRY_REMINDER_SHOWN');
    final shouldRenew = await showDialog<bool>(
      context: context,
      barrierColor: FlutterFlowTheme.of(context)
          .primaryBackground
          .withValues(alpha: 0.78),
      builder: (dialogContext) => Dialog(
        elevation: 0.0,
        insetPadding: EdgeInsets.all(
          FlutterFlowTheme.of(dialogContext).designToken.spacing.md,
        ),
        backgroundColor: Colors.transparent,
        child: RappelFinAbonnementWidget(
          expiration: expiration,
          onRenew: () => Navigator.of(dialogContext).pop(true),
          onDismiss: () => Navigator.of(dialogContext).pop(false),
        ),
      ),
    );

    if (!mounted || shouldRenew != true) {
      return;
    }

    logFirebaseEvent('HOME_SUB_EXPIRY_REMINDER_RENEW');
    context.pushNamed(UpgradeWidget.routeName);
  }

  Future<void> _loadYoutubeStories() async {
    if (mounted) {
      safeSetState(() {
        _youtubeStoriesLoading = true;
        _youtubeStoriesLoadFailed = false;
      });
    }
    try {
      final videos = await loadYoutubeStoryVideos(
        fallbackTitle: FFLocalizations.of(context).getText('ytfallback'),
        now: getCurrentTimestamp,
      );
      if (!mounted) {
        return;
      }

      safeSetState(() {
        _model.youtubeStories = videos;
        _youtubeStoriesLoading = false;
        _youtubeStoriesLoadFailed = false;
      });
    } catch (error) {
      debugPrint('YouTube story feed error: $error');
      if (mounted) {
        safeSetState(() {
          _youtubeStoriesLoading = false;
          _youtubeStoriesLoadFailed = true;
        });
      }
    }
  }

  Future<void> _loadBetaFeatures() async {
    try {
      logFirebaseEvent('Home_Betafeatures');
      final beta = await querySettingsRecordOnce(
        singleRecord: true,
      ).then((settings) => settings.firstOrNull);
      if (!mounted) {
        return;
      }

      _model.beta = beta;
      if (beta?.betaFeatures != FFAppState().betaFeatures) {
        logFirebaseEvent('Home_betaFeatures');
        FFAppState().betaFeatures = BetaFeaturesStruct(
          stories: valueOrDefault<bool>(
            beta?.betaFeatures.stories,
            false,
          ),
          statsBingo: valueOrDefault<bool>(
            beta?.betaFeatures.statsBingo,
            false,
          ),
        );
        safeSetState(() {});
      }
    } catch (error) {
      debugPrint('Home beta feature loading skipped: $error');
    }
  }

  Widget? _buildStoriesRail(BuildContext context) {
    if (!(_youtubeStoriesLoading ||
        _youtubeStoriesLoadFailed ||
        _model.youtubeStories.isNotEmpty ||
        isBingoStoryCollectionAvailable(
          activeStoryCount: _model.bingoStories.length,
        ))) {
      return null;
    }
    return HomeStoriesRail(
      loading: _youtubeStoriesLoading,
      loadFailed: _youtubeStoriesLoadFailed,
      onRetry: () => unawaited(_loadYoutubeStories()),
      stories: [
        if (isBingoStoryCollectionAvailable(
          activeStoryCount: _model.bingoStories.length,
        ))
          BingoStoryButton(
            viewed: FFAppState().bingo.vue,
            storyCount: _model.bingoStories.length,
            onTap: () async {
              logFirebaseEvent(
                'HOME_PAGE_bingo_story_ON_TAP',
              );
              await showBingoDialog(
                context: context,
                bingos: _model.bingoStories
                    .where(
                      (record) => isBingoActive(
                        bingoDate: record.date,
                        expiration: record.expiration,
                        now: getCurrentTimestamp,
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        if (_model.youtubeStories.isNotEmpty)
          YoutubeStoryButton(
            video: _model.youtubeStories.first,
            viewed: _youtubeStoriesViewed,
            storyCount: _model.youtubeStories.length,
            onTap: () async {
              logFirebaseEvent(
                'HOME_PAGE_youtube_story_ON_TAP',
              );
              await showYoutubeStoryDialog(
                context: context,
                videos: _model.youtubeStories,
              );
              if (mounted) {
                safeSetState(
                  () => _youtubeStoriesViewed = true,
                );
              }
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor:
              FlutterFlowTheme.of(context).designToken.background.home,
          floatingActionButton: HomeSupportFab(
            onSupport: () async {
              logFirebaseEvent(
                'HOME_PAGE_support_agent_ICN_ON_TAP',
              );
              logFirebaseEvent('IconButton_navigate_to');
              await context.pushNamed(
                CustomerserviceWidget.routeName,
              );
            },
          ),
          body: DecoratedBox(
            key: const ValueKey('home-background-gradient'),
            decoration: BoxDecoration(
              gradient: FlutterFlowTheme.of(context)
                  .designToken
                  .background
                  .homeGradient,
            ),
            child: NestedScrollView(
              floatHeaderSlivers: false,
              headerSliverBuilder: (context, _) => [
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  toolbarHeight: 64.0,
                  backgroundColor:
                      FlutterFlowTheme.of(context).designToken.background.home,
                  surfaceTintColor:
                      FlutterFlowTheme.of(context).designToken.background.home,
                  automaticallyImplyLeading: false,
                  titleSpacing:
                      FlutterFlowTheme.of(context).designToken.spacing.md,
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          FlutterFlowTheme.of(context).designToken.radius.md,
                        ),
                        child: Image.asset(
                          'assets/images/Logo_Choloto_509.png',
                          key: const ValueKey('home-header-logo'),
                          width: 42.0,
                          height: 42.0,
                          cacheWidth: _assetCacheWidth(context, 42.0),
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(
                        width:
                            FlutterFlowTheme.of(context).designToken.spacing.sm,
                      ),
                      Flexible(
                        child: Text(
                          FFLocalizations.of(context).getText(
                            'loh576na' /* CHOLOTO */,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style:
                              FlutterFlowTheme.of(context).titleLarge.override(
                                    fontSize: 20.0,
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    HomeHeaderActions(
                      onAchievements: () async {
                        logFirebaseEvent('HOME_PAGE_query_stats_ICN_ON_TAP');
                        logFirebaseEvent('IconButton_navigate_to');
                        await context.pushNamed(
                          AccomplissementsWidget.routeName,
                        );
                      },
                      onSettings: () async {
                        logFirebaseEvent(
                          'HOME_PAGE_settings_outlined_ICN_ON_TAP',
                        );
                        logFirebaseEvent('IconButton_navigate_to');
                        await context.pushNamed(ParametresWidget.routeName);
                      },
                    ),
                    SizedBox(
                      width:
                          FlutterFlowTheme.of(context).designToken.spacing.sm,
                    ),
                  ],
                  shape: Border(
                    bottom: BorderSide(
                      color: FlutterFlowTheme.of(context)
                          .primaryText
                          .withValues(alpha: 0.06),
                    ),
                  ),
                  centerTitle: false,
                  elevation: 0.0,
                  scrolledUnderElevation: 0.0,
                )
              ],
              body: Builder(
                builder: (context) {
                  return SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        FlutterFlowTheme.of(context).designToken.spacing.md,
                        FlutterFlowTheme.of(context).designToken.spacing.sm,
                        FlutterFlowTheme.of(context).designToken.spacing.md,
                        // Keep the last card clear of the support FAB.
                        FlutterFlowTheme.of(context).designToken.spacing.xl * 3,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1120.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (isSubscriptionExpired(
                                expiration: _latestSubscriptionExpiration,
                                now: getCurrentTimestamp,
                              ))
                                ExpiredSubscriptionCard(
                                  onRenew: () {
                                    logFirebaseEvent(
                                      'HOME_EXPIRED_SUB_RENEW',
                                    );
                                    context.pushNamed(UpgradeWidget.routeName);
                                  },
                                ),
                              HomeFeatureSection(
                                stories: _buildStoriesRail(context),
                                vipCard: HomeFeatureCard(
                                  semanticId: 'vip',
                                  title: FFLocalizations.of(context).getText(
                                    'covzb0rd' /* ABONNEMENT VIP */,
                                  ),
                                  description:
                                      FFLocalizations.of(context).getText(
                                    'uvl7vow9' /* Probabilités des jeux de loterie. */,
                                  ),
                                  assetPath:
                                      'assets/images/home/vip_membership_3d_v2.png',
                                  tone: HomeFeatureTone.vip,
                                  onTap: () {
                                    logFirebaseEvent(
                                      'HOME_PAGE_membership_ON_TAP',
                                    );
                                    logFirebaseEvent('membership_navigate_to');
                                    context.pushNamed(VipWidget.routeName);
                                  },
                                ),
                                chanceCard: HomeFeatureCard(
                                  semanticId: 'chance',
                                  title: FFLocalizations.of(context).getText(
                                    'afym167o' /* CROIX DE LA CHANCE */,
                                  ),
                                  description:
                                      FFLocalizations.of(context).getText(
                                    'pqih1sxe' /* Tente chaque jour et gagne GROS. */,
                                  ),
                                  assetPath:
                                      'assets/images/home/lucky_cross_3d_x.png',
                                  tone: HomeFeatureTone.chance,
                                  onTap: () {
                                    logFirebaseEvent(
                                      'HOME_PAGE_croixChance_ON_TAP',
                                    );
                                    logFirebaseEvent('croixChance_navigate_to');
                                    context.pushNamed(CroixWidget.routeName);
                                  },
                                ),
                                draws: wrapWithModel(
                                  model: _model.tiragesHomeModel,
                                  updateCallback: () => safeSetState(() {}),
                                  child: const TiragesHomeWidget(),
                                ),
                                videoCard: HomeFeatureCard(
                                  semanticId: 'video',
                                  title: FFLocalizations.of(context).getText(
                                    'fkwji2m2' /* YOUTUBE */,
                                  ),
                                  description:
                                      FFLocalizations.of(context).getText(
                                    'gcjztr88' /* Regarde, abonne-toi et reste connecté. */,
                                  ),
                                  assetPath:
                                      'assets/images/home/video_play_3d_v2.png',
                                  tone: HomeFeatureTone.video,
                                  onTap: () {
                                    logFirebaseEvent('HOME_PAGE_ytube_ON_TAP');
                                    logFirebaseEvent('ytube_navigate_to');
                                    context.pushNamed(YoutubeWidget.routeName);
                                  },
                                ),
                              ),
                            ].divide(SizedBox(
                              height: FlutterFlowTheme.of(context)
                                  .designToken
                                  .spacing
                                  .sm,
                            )),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
