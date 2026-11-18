import 'dart:async';

import '/auth/firebase_auth/auth_util.dart';
import '/autres/bingo/bingo/bingo_dialog.dart';
import '/autres/bingo/bingo/bingo_story_button.dart';
import '/backend/backend.dart';
import '/components/home_feature_section.dart';
import '/components/home_header_actions.dart';
import '/components/home_page_scaffold.dart';
import '/components/home_stories_rail.dart';
import '/components/rappel_fin_abonnement_widget.dart';
import '/components/tirages_home_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/engagement_service.dart';
import '/support/support_conversation.dart';
import '/youtube/youtube_feed_service.dart';
import '/youtube/youtube_story.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'home_model.dart';
export 'home_model.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key, this.inTabShell = false});

  final bool inTabShell;

  static String routeName = 'Home';
  static String routePath = '/home';

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> with WidgetsBindingObserver {
  late HomeModel _model;

  StreamSubscription<UserRecord?>? _subscriptionReminderSubscription;
  StreamSubscription<SupportConversation?>? _supportConversationSubscription;
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
  final _supportRepository = SupportConversationRepository();
  SupportConversation? _supportConversation;
  String _supportSubscriptionUid = '';
  int _supportShakeTrigger = 0;
  bool _bingoInitialSnapshotHandled = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

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
      _subscribeToSupportConversation(currentUserUid);
      _updateSubscriptionExpiration(user?.endSub);
      unawaited(_maybeShowSubscriptionExpirationReminder());
    });
    _subscribeToSupportConversation(currentUserUid);
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
    unawaited(_supportConversationSubscription?.cancel());
    _model.dispose();

    super.dispose();
  }

  void _subscribeToSupportConversation(String uid) {
    if (_supportSubscriptionUid == uid &&
        (_supportConversationSubscription != null || uid.isEmpty)) {
      return;
    }
    unawaited(_supportConversationSubscription?.cancel());
    _supportConversationSubscription = null;
    _supportSubscriptionUid = uid;
    _supportConversation = null;
    if (uid.isEmpty) {
      if (mounted) safeSetState(() {});
      return;
    }

    _supportConversationSubscription =
        _supportRepository.watchConversation(uid).listen(
      (conversation) {
        final previousLastMessageId =
            _supportConversation?.data['last_message_id'];
        final latestLastMessageId = conversation?.data['last_message_id'];
        if ((conversation?.pendingAdminMessages ?? 0) > 0 &&
            latestLastMessageId != null &&
            latestLastMessageId != previousLastMessageId) {
          _supportShakeTrigger++;
        }
        _supportConversation = conversation;
        if (mounted) safeSetState(() {});
      },
      onError: (Object error) {
        debugPrint('Support conversation stream error: $error');
        if (mounted) {
          _supportConversation = null;
          safeSetState(() {});
        }
      },
    );
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
    if (_bingoStoriesSubscription != null) return;
    _bingoStoriesSubscription = queryBingoRecord(
      queryBuilder: (bingoRecord) =>
          bingoRecord.orderBy('date', descending: true),
    ).listen(
      (records) {
        final isInitialSnapshot = !_bingoInitialSnapshotHandled;
        _bingoInitialSnapshotHandled = true;
        unawaited(
          _handleBingoRecords(
            records,
            showAutomaticDialog: isInitialSnapshot,
          ),
        );
      },
      onError: (Object error) {
        debugPrint('Bingo story stream error: $error');
        if (!_bingoInitialSnapshotHandled) {
          _bingoInitialSnapshotHandled = true;
          unawaited(_finishHomeDialogInitialization());
        }
      },
    );
  }

  Future<void> _handleBingoRecords(
    List<BingoRecord> records, {
    required bool showAutomaticDialog,
  }) async {
    await _applyBingoRecords(
      records,
      showAutomaticDialog: showAutomaticDialog,
    );
    if (showAutomaticDialog) await _finishHomeDialogInitialization();
  }

  Future<void> _finishHomeDialogInitialization() async {
    if (!mounted || _homeDialogsReady) return;
    _homeDialogsReady = true;
    await _maybeShowSubscriptionExpirationReminder();
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
    final loadedAt = getCurrentTimestamp;
    if (!FFAppState().shouldRefreshBetaFeatures(loadedAt)) return;
    try {
      logFirebaseEvent('Home_Betafeatures');
      final beta = await querySettingsRecordOnce(
        singleRecord: true,
      ).then((settings) => settings.firstOrNull);
      if (!mounted) {
        return;
      }

      _model.beta = beta;
      FFAppState().markBetaFeaturesFetched(loadedAt);
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

    return HomePageScaffold(
      scaffoldKey: scaffoldKey,
      inTabShell: widget.inTabShell,
      support: HomeSupportFab(
        messageCount: _supportConversation?.pendingAdminMessages ?? 0,
        shakeTrigger: _supportShakeTrigger,
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
      buildSections: (supportBesideStories) => [
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
          storyAction: supportBesideStories,
          onViewResults: () {
            logFirebaseEvent('HOME_VIEW_RESULTS_ON_TAP');
            context.pushNamed(TiragesWidget.routeName);
          },
          onVip: () {
            logFirebaseEvent('HOME_PAGE_membership_ON_TAP');
            logFirebaseEvent('membership_navigate_to');
            context.pushNamed(VipWidget.routeName);
          },
          onChance: () {
            logFirebaseEvent('HOME_PAGE_croixChance_ON_TAP');
            logFirebaseEvent('croixChance_navigate_to');
            context.pushNamed(CroixWidget.routeName);
          },
          onVideo: () {
            logFirebaseEvent('HOME_PAGE_ytube_ON_TAP');
            logFirebaseEvent('ytube_navigate_to');
            context.pushNamed(YoutubeWidget.routeName);
          },
          onStats: () {
            logFirebaseEvent('HOME_PAGE_query_stats_ICN_ON_TAP');
            context.pushNamed(AccomplissementsWidget.routeName);
          },
          onTchala: () => context.pushNamed(TchalaWidget.routeName),
          onHistory: () => context.pushNamed(VipHistoryWidget.routeName),
          draws: wrapWithModel(
            model: _model.tiragesHomeModel,
            updateCallback: () => safeSetState(() {}),
            child: const TiragesHomeWidget(),
          ),
        ),
      ],
    );
  }
}
