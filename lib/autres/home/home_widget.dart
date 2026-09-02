import 'dart:async';

import '/auth/firebase_auth/auth_util.dart';
import '/autres/bingo/bingo/bingo_dialog.dart';
import '/autres/bingo/bingo/bingo_story_button.dart';
import '/backend/backend.dart';
import '/components/home_feature_card.dart';
import '/components/home_stories_rail.dart';
import '/components/rappel_fin_abonnement_widget.dart';
import '/components/tirages_home_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
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
  Timer? _subscriptionExpirationTimer;
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
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('HOME_PAGE_Home_ON_INIT_STATE');
      // bingo requette
      logFirebaseEvent('Home_bingorequette');
      final bingoRecords = await queryBingoRecordOnce(
        queryBuilder: (bingoRecord) =>
            bingoRecord.orderBy('date', descending: true),
      );
      _model.bingooutput = bingoRecords.firstOrNull;
      _model.bingoStories = bingoRecords
          .where(
            (record) => isBingoActive(
              bingoDate: record.date,
              expiration: record.expiration,
              now: getCurrentTimestamp,
            ),
          )
          .toList(growable: false);
      if (!mounted) {
        return;
      }
      if (_model.bingooutput?.hasDate() ?? false) {
        if (FFAppState().bingo.date != _model.bingooutput?.date) {
          logFirebaseEvent('Home_update_app_state');
          FFAppState().updateBingoStruct(
            (e) => e
              ..date = _model.bingooutput?.date
              ..vue = false
              ..doc = _model.bingooutput?.reference
              ..gagner = null
              ..refGain = null
              ..dataStack = _model.bingooutput!.dataStack.toList()
              ..expiration = _model.bingooutput?.expiration,
          );
          safeSetState(() {});
        }
        if ((FFAppState().bingo.vue == false) &&
            (_model.bingooutput?.hasExpiration() ?? false) &&
            (_model.bingooutput!.expiration! >= getCurrentTimestamp)) {
          logFirebaseEvent('Home_alert_dialog');
          await showBingoDialog(
            context: context,
            bingos: _model.bingoStories,
          );

          logFirebaseEvent('Home_update_app_state');
          FFAppState().updateBingoStruct(
            (e) => e..vue = true,
          );
          safeSetState(() {});
        }
      } else {
        logFirebaseEvent('Home_update_app_state');
        FFAppState().bingo = BingoStruct();
        safeSetState(() {});
      }

      _homeDialogsReady = true;
      await _maybeShowSubscriptionExpirationReminder();
      if (!mounted) {
        return;
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscriptionExpirationTimer?.cancel();
    unawaited(_subscriptionReminderSubscription?.cancel());
    _model.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(recordDailyEngagement(userReference: currentUserReference));
      safeSetState(() {});
    }
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
      final videos = await loadYoutubeVideos(
        fallbackTitle: FFLocalizations.of(context).getText('ytfallback'),
      );
      if (!mounted) {
        return;
      }

      safeSetState(() {
        _model.youtubeStories = youtubeVideosPublishedWithin(
          videos,
          now: getCurrentTimestamp,
        );
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
      if (beta?.betaFeatures.stories != FFAppState().betaFeatures.stories) {
        logFirebaseEvent('Home_betaFeatures');
        FFAppState().betaFeatures = BetaFeaturesStruct(
          stories: valueOrDefault<bool>(
            beta?.betaFeatures.stories,
            false,
          ),
        );
        safeSetState(() {});
      } else if (beta?.betaFeatures.statsBingo !=
          FFAppState().betaFeatures.statsBingo) {
        logFirebaseEvent('Home_betaFeatures');
        FFAppState().betaFeatures = BetaFeaturesStruct(
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
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          body: NestedScrollView(
            floatHeaderSlivers: false,
            headerSliverBuilder: (context, _) => [
              SliverAppBar(
                pinned: true,
                floating: false,
                toolbarHeight: 72.0,
                backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
                surfaceTintColor:
                    FlutterFlowTheme.of(context).primaryBackground,
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
                        style: FlutterFlowTheme.of(context).titleLarge.override(
                              fontSize: 20.0,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  FlutterFlowIconButton(
                    borderColor: FlutterFlowTheme.of(context)
                        .primaryText
                        .withValues(alpha: 0.08),
                    borderRadius:
                        FlutterFlowTheme.of(context).designToken.radius.full,
                    borderWidth: 1.0,
                    buttonSize: 40.0,
                    fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                    hoverColor: FlutterFlowTheme.of(context)
                        .primary
                        .withValues(alpha: 0.14),
                    hoverIconColor: FlutterFlowTheme.of(context).primary,
                    icon: Icon(
                      Icons.query_stats_rounded,
                      color: FlutterFlowTheme.of(context).primaryText,
                      size: 22.0,
                    ),
                    onPressed: () async {
                      logFirebaseEvent('HOME_PAGE_query_stats_ICN_ON_TAP');
                      logFirebaseEvent('IconButton_navigate_to');
                      context.pushNamed(AccomplissementsWidget.routeName);
                    },
                  ),
                  SizedBox(
                    width: FlutterFlowTheme.of(context).designToken.spacing.xs,
                  ),
                  FlutterFlowIconButton(
                    borderColor: FlutterFlowTheme.of(context)
                        .primaryText
                        .withValues(alpha: 0.08),
                    borderRadius:
                        FlutterFlowTheme.of(context).designToken.radius.full,
                    borderWidth: 1.0,
                    buttonSize: 40.0,
                    fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                    hoverColor: FlutterFlowTheme.of(context)
                        .primary
                        .withValues(alpha: 0.14),
                    hoverIconColor: FlutterFlowTheme.of(context).primary,
                    icon: Icon(
                      Icons.settings_outlined,
                      color: FlutterFlowTheme.of(context).primaryText,
                      size: 22.0,
                    ),
                    onPressed: () async {
                      logFirebaseEvent(
                        'HOME_PAGE_settings_outlined_ICN_ON_TAP',
                      );
                      logFirebaseEvent('IconButton_navigate_to');
                      context.pushNamed(ParametresWidget.routeName);
                    },
                  ),
                  SizedBox(
                    width: FlutterFlowTheme.of(context).designToken.spacing.sm,
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
                      FlutterFlowTheme.of(context).designToken.spacing.xl,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1120.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            HomeStoriesRail(
                              loading: _youtubeStoriesLoading,
                              loadFailed: _youtubeStoriesLoadFailed,
                              onRetry: () => unawaited(_loadYoutubeStories()),
                              stories: [
                                if (isBingoStoryCollectionAvailable(
                                  viewed: FFAppState().bingo.vue,
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
                            ),
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
                              vipCard: HomeFeatureCard(
                                semanticId: 'vip',
                                title: FFLocalizations.of(context).getText(
                                  'covzb0rd' /* ABONNEMENT VIP */,
                                ),
                                description:
                                    FFLocalizations.of(context).getText(
                                  'uvl7vow9' /* Accède à tous les avantages exclusifs. */,
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
                                    'assets/images/home/lucky_cross_3d_v2.png',
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
                          ].divide(const SizedBox(height: 16.0)),
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
    );
  }
}
