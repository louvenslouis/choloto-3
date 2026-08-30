import 'dart:async';

import '/auth/firebase_auth/auth_util.dart';
import '/autres/bingo/bingo/bingo_dialog.dart';
import '/autres/bingo/bingo/bingo_story_button.dart';
import '/backend/backend.dart';
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
import 'package:google_fonts/google_fonts.dart';
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
      });
    } catch (error) {
      debugPrint('YouTube story feed error: $error');
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
                backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
                automaticallyImplyLeading: false,
                leading: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/Logo_Choloto_509.png',
                      height: 20.0,
                      cacheWidth: _assetCacheWidth(context, 20.0),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(
                  FFLocalizations.of(context).getText(
                    'loh576na' /* CHOLOTO */,
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.w900,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        fontSize: 20.0,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w900,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                ),
                actions: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: FlutterFlowIconButton(
                          borderRadius: 8.0,
                          buttonSize: 40.0,
                          icon: Icon(
                            Icons.query_stats,
                            color: FlutterFlowTheme.of(context).info,
                            size: 24.0,
                          ),
                          onPressed: () async {
                            logFirebaseEvent(
                                'HOME_PAGE_query_stats_ICN_ON_TAP');
                            logFirebaseEvent('IconButton_navigate_to');
                            context.pushNamed(AccomplissementsWidget.routeName);
                          },
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: FlutterFlowIconButton(
                          borderRadius: 8.0,
                          buttonSize: 40.0,
                          icon: Icon(
                            Icons.settings_outlined,
                            color: FlutterFlowTheme.of(context).info,
                            size: 24.0,
                          ),
                          onPressed: () async {
                            logFirebaseEvent(
                                'HOME_PAGE_settings_outlined_ICN_ON_TAP');
                            logFirebaseEvent('IconButton_navigate_to');

                            context.pushNamed(ParametresWidget.routeName);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
                centerTitle: true,
                elevation: 0.0,
              )
            ],
            body: Builder(
              builder: (context) {
                return SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.all(2.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          if (isBingoStoryCollectionAvailable(
                                viewed: FFAppState().bingo.vue,
                                activeStoryCount: _model.bingoStories.length,
                              ) ||
                              _model.youtubeStories.isNotEmpty)
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    if (isBingoStoryCollectionAvailable(
                                      viewed: FFAppState().bingo.vue,
                                      activeStoryCount:
                                          _model.bingoStories.length,
                                    ))
                                      BingoStoryButton(
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
                                                    expiration:
                                                        record.expiration,
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
                                        onTap: () async {
                                          logFirebaseEvent(
                                            'HOME_PAGE_youtube_story_ON_TAP',
                                          );
                                          await showYoutubeStoryDialog(
                                            context: context,
                                            videos: _model.youtubeStories,
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),
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
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              logFirebaseEvent('HOME_PAGE_membership_ON_TAP');
                              logFirebaseEvent('membership_navigate_to');

                              context.pushNamed(VipWidget.routeName);
                            },
                            child: Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              color: Color(0xFF650BB0),
                              elevation: 3.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Container(
                                height: 145.0,
                                decoration: BoxDecoration(),
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: 50.0,
                                        ),
                                        decoration: BoxDecoration(),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  10.0, 0.0, 0.0, 0.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    -1.0, -1.0),
                                                child: Text(
                                                  FFLocalizations.of(context)
                                                      .getText(
                                                    'covzb0rd' /* MEMBERSHIP */,
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        fontSize: 25.0,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .onDecorative,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ),
                                              Text(
                                                FFLocalizations.of(context)
                                                    .getText(
                                                  'uvl7vow9' /* Accède à tous les avantages ex... */,
                                                ),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                      fontSize: 15.0,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .onDecorative,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(15.0),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.asset(
                                          'assets/images/viplogo_-_Moyenne.png',
                                          width: 100.0,
                                          height: 100.0,
                                          cacheWidth:
                                              _assetCacheWidth(context, 100.0),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              logFirebaseEvent('HOME_PAGE_croixChance_ON_TAP');
                              logFirebaseEvent('croixChance_navigate_to');

                              context.pushNamed(CroixWidget.routeName);
                            },
                            child: Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              color: FlutterFlowTheme.of(context).primary,
                              elevation: 3.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Container(
                                height: 145.0,
                                decoration: BoxDecoration(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: 50.0,
                                        ),
                                        decoration: BoxDecoration(),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  10.0, 0.0, 0.0, 0.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    -1.0, -1.0),
                                                child: Text(
                                                  FFLocalizations.of(context)
                                                      .getText(
                                                    'afym167o' /* CROIX DE LA CHANCE */,
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .onPrimary,
                                                        fontSize: 25.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ),
                                              Text(
                                                FFLocalizations.of(context)
                                                    .getText(
                                                  'pqih1sxe' /* Tente chaque jour et gagne GRO... */,
                                                ),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .onPrimary,
                                                      fontSize: 15.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(15.0),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.asset(
                                          'assets/images/croixcholoto_-_Moyenne.png',
                                          width: 100.0,
                                          height: 100.0,
                                          cacheWidth:
                                              _assetCacheWidth(context, 100.0),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          wrapWithModel(
                            model: _model.tiragesHomeModel,
                            updateCallback: () => safeSetState(() {}),
                            child: TiragesHomeWidget(),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              logFirebaseEvent('HOME_PAGE_ytube_ON_TAP');
                              logFirebaseEvent('ytube_navigate_to');

                              context.pushNamed(YoutubeWidget.routeName);
                            },
                            child: Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              color: FlutterFlowTheme.of(context).primary,
                              elevation: 3.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Container(
                                height: 145.0,
                                decoration: BoxDecoration(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: 50.0,
                                        ),
                                        decoration: BoxDecoration(),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  10.0, 0.0, 0.0, 0.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    -1.0, -1.0),
                                                child: Text(
                                                  FFLocalizations.of(context)
                                                      .getText(
                                                    'fkwji2m2' /* YOUTUBE */,
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .onPrimary,
                                                        fontSize: 25.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ),
                                              Text(
                                                FFLocalizations.of(context)
                                                    .getText(
                                                  'gcjztr88' /* Regarde, Abonne-toi et reste c... */,
                                                ),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .onPrimary,
                                                      fontSize: 15.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(15.0),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.asset(
                                          'assets/images/youtube_-_Moyenne.png',
                                          width: 100.0,
                                          height: 100.0,
                                          cacheWidth:
                                              _assetCacheWidth(context, 100.0),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ].divide(SizedBox(height: 6.0)),
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
