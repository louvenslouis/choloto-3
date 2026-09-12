import '/components/vip_prediction_header.dart';
import '/components/vip_page_header.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/autres/bingo/bingo_card_v_i_p/bingo_card_v_i_p_widget.dart';
import '/backend/backend.dart';
import '/components/don_widget.dart';
import '/components/vip_motion.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/settings/devenir_v_i_p/devenir_v_i_p_widget.dart';
import '/settings/upgrade/subscription_transaction.dart';
import '/vip/universal_v_i_p/universal_v_i_p_widget.dart';
import '/vip/v_i_pboloto/v_i_pboloto_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'vip_model.dart';
export 'vip_model.dart';

class VipWidget extends StatefulWidget {
  const VipWidget({super.key});

  static String routeName = 'VIP';
  static String routePath = '/vip';

  @override
  State<VipWidget> createState() => _VipWidgetState();
}

class _VipWidgetState extends State<VipWidget> {
  late VipModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final SubscriptionTransactionRepository _transactionsRepository =
      SubscriptionTransactionRepository();

  StreamSubscription<List<SubscriptionTransaction>>?
      _transactionMembershipSubscription;
  String? _transactionsUserUid;
  DateTime? _latestRecordedSubscriptionEnd;
  bool _latestTransactionIsCancellation = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VipModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'VIP'});
    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('VIP_PAGE_VIP_ON_INIT_STATE');
      logFirebaseEvent('VIP_wait__delay');
      await Future.delayed(
        Duration(
          milliseconds: 5000,
        ),
      );
      logFirebaseEvent('VIP_update_page_state');
      _model.pourboireHide = true;
      safeSetState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _transactionMembershipSubscription?.cancel();
    _model.dispose();

    super.dispose();
  }

  void _ensureTransactionMembershipStream() {
    if (!loggedIn ||
        currentUserUid.isEmpty ||
        _transactionsUserUid == currentUserUid) {
      return;
    }

    _transactionsUserUid = currentUserUid;
    _latestRecordedSubscriptionEnd = null;
    _latestTransactionIsCancellation = false;
    _transactionMembershipSubscription?.cancel();
    _transactionMembershipSubscription =
        _transactionsRepository.watchForUser(currentUserUid).listen(
      (transactions) {
        final latestEnd = latestRecordedSubscriptionEnd(transactions);
        final latestIsCancellation =
            latestSubscriptionTransactionIsCancellation(transactions);
        if (!mounted || latestEnd == _latestRecordedSubscriptionEnd) {
          if (mounted &&
              latestIsCancellation != _latestTransactionIsCancellation) {
            safeSetState(
              () => _latestTransactionIsCancellation = latestIsCancellation,
            );
          }
          return;
        }
        safeSetState(() {
          _latestRecordedSubscriptionEnd = latestEnd;
          _latestTransactionIsCancellation = latestIsCancellation;
        });
      },
      onError: (_) {
        // The profile stream remains the fallback when transaction history is
        // unavailable (for example before the owner-read rules are deployed).
      },
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: _buildPage);

  Widget _buildPage(BuildContext context, BoxConstraints constraints) {
    context.watch<FFAppState>();
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    _ensureTransactionMembershipStream();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Tooltip(
              message: FFLocalizations.of(context).getText('viphsttip'),
              child: FloatingActionButton.small(
                heroTag: 'vip_history_fab',
                onPressed: () async {
                  logFirebaseEvent('VIP_HISTORY_FAB_ON_TAP');
                  context.pushNamed(VipHistoryWidget.routeName);
                },
                backgroundColor: theme.secondaryBackground,
                foregroundColor: FlutterFlowTheme.of(context).primary,
                elevation: 4.0,
                child: const Icon(Icons.history_rounded, size: 21.0),
              ).vipActionFeedback(),
            ).vipEntrance(delayMs: 220),
            const SizedBox(height: 10.0),
            AnimatedSize(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.centerRight,
              child: FloatingActionButton.extended(
                heroTag: 'vip_tip_fab',
                onPressed: () async {
                  logFirebaseEvent('VIP_FloatingActionButton_qjsc5kip_ON_TAP');
                  logFirebaseEvent('FloatingActionButton_bottom_sheet');
                  await showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) => Padding(
                      padding: MediaQuery.viewInsetsOf(context),
                      child: DonWidget(),
                    ),
                  );
                },
                isExtended: _model.pourboireHide == false,
                backgroundColor: theme.secondaryBackground,
                foregroundColor: FlutterFlowTheme.of(context).primary,
                icon: FaIcon(
                  FontAwesomeIcons.mugHot,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 21.0,
                ),
                elevation: 4.0,
                label: Visibility(
                  visible: _model.pourboireHide == false,
                  child: Text(
                    FFLocalizations.of(context).getText(
                      'isn2t0tf' /* POURBOIRE */,
                    ),
                    style: FlutterFlowTheme.of(context).labelLarge.override(
                          color: FlutterFlowTheme.of(context).primary,
                          fontSize: 15.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w900,
                          fontStyle:
                              FlutterFlowTheme.of(context).labelLarge.fontStyle,
                        ),
                  ),
                ),
              ),
            ).vipActionFeedback().vipEntrance(delayMs: 280),
          ],
        ),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
              VipPageHeader.heightFor(context, width: constraints.maxWidth)),
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: tokens.vip.felt),
            child: SafeArea(
              bottom: false,
              child: VipPageHeader(
                onProfile: () {
                  logFirebaseEvent('VIP_PAGE_Card_elizvnyh_ON_TAP');
                  logFirebaseEvent('Card_navigate_to');
                  context.pushNamed(ProfilWidget.routeName);
                },
                avatar: AuthUserStreamWidget(
                  builder: (context) => currentUserPhoto.isEmpty
                      ? Icon(Icons.person_rounded,
                          color: theme.onPrimary, size: 30)
                      : CachedNetworkImage(
                          fadeInDuration: const Duration(milliseconds: 500),
                          fadeOutDuration: const Duration(milliseconds: 500),
                          imageUrl: currentUserPhoto,
                          errorWidget: (context, url, error) => Icon(
                            Icons.person_rounded,
                            color: theme.onPrimary,
                            size: 30,
                          ),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          top: true,
          child: Container(
            decoration: BoxDecoration(),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (FFAppState().bingo.hasDate() &&
                      FFAppState().bingo.hasExpiration() &&
                      (FFAppState().bingo.expiration! >= getCurrentTimestamp))
                    wrapWithModel(
                      model: _model.bingoCardVIPModel,
                      updateCallback: () => safeSetState(() {}),
                      child: BingoCardVIPWidget(),
                    ).vipEntrance(delayMs: 80),
                  AuthUserStreamWidget(
                    builder: (context) {
                      // Start the fallback audit stream after the auth stream
                      // has delivered the current UID. This covers the brief
                      // window where a renewal is written before the profile
                      // snapshot is refreshed.
                      _ensureTransactionMembershipStream();
                      if (loggedIn && currentUserDocument == null) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(
                              FlutterFlowTheme.of(context)
                                  .designToken
                                  .spacing
                                  .lg,
                            ),
                            child: CircularProgressIndicator(
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                          ),
                        );
                      }

                      final subscriptionEnd = effectiveSubscriptionEnd(
                        profileEnd: currentUserDocument?.endSub,
                        latestRecordedEnd: _latestRecordedSubscriptionEnd,
                        latestTransactionIsCancellation:
                            _latestTransactionIsCancellation,
                      );
                      if (loggedIn &&
                          hasActiveVipSubscription(
                            expiration: subscriptionEnd,
                            now: getCurrentTimestamp,
                          )) {
                        return StreamBuilder<List<PredictionRecord>>(
                          stream: queryPredictionRecord(
                            queryBuilder: (predictionRecord) => predictionRecord
                                .orderBy('date', descending: true),
                            singleRecord: true,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Padding(
                                padding: EdgeInsets.all(
                                  FlutterFlowTheme.of(context)
                                      .designToken
                                      .spacing
                                      .lg,
                                ),
                                child: Text(
                                  FFLocalizations.of(context)
                                      .getText('viphsterd'),
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                      ),
                                ),
                              );
                            }

                            if (!snapshot.hasData) {
                              return Center(
                                child: SizedBox(
                                  width: 50.0,
                                  height: 50.0,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      FlutterFlowTheme.of(context).primary,
                                    ),
                                  ),
                                ),
                              );
                            }
                            List<PredictionRecord>
                                listViewPredictionRecordList = snapshot.data!;
                            if (listViewPredictionRecordList.isEmpty) {
                              return SizedBox.shrink();
                            }
                            final listViewPredictionRecord =
                                listViewPredictionRecordList.first;

                            return ListView(
                              padding: EdgeInsets.zero,
                              primary: false,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              children: [
                                VipPredictionHeader(
                                  label:
                                      '${FFLocalizations.of(context).getText('vipproblb')}: ${dateTimeFormat(
                                    "MMMMEEEEd",
                                    listViewPredictionRecord.date,
                                    locale: FFLocalizations.of(context)
                                        .languageCode,
                                  )} ${listViewPredictionRecord.periode}',
                                  percentage:
                                      '${listViewPredictionRecord.pourcentage}%',
                                ).vipEntrance(delayMs: 80),
                                GridView(
                                  padding: EdgeInsets.fromLTRB(
                                    0,
                                    0,
                                    0,
                                    100.0,
                                  ),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 0.0,
                                    mainAxisSpacing: 0.0,
                                    childAspectRatio: 1.0,
                                  ),
                                  primary: false,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  children: [
                                    wrapWithModel(
                                      model: _model.favoriModel,
                                      updateCallback: () => safeSetState(() {}),
                                      child: UniversalVIPWidget(
                                        name: listViewPredictionRecord!
                                            .favori.name,
                                        autre: '',
                                        chiffre: listViewPredictionRecord
                                            ?.favori?.boul,
                                        ref:
                                            listViewPredictionRecord?.reference,
                                        icon: Icon(
                                          Icons.star,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          size: 20.0,
                                        ),
                                      ),
                                    ).vipEntrance(delayMs: 125),
                                    wrapWithModel(
                                      model: _model.soutniModel,
                                      updateCallback: () => safeSetState(() {}),
                                      child: UniversalVIPWidget(
                                        name: listViewPredictionRecord!
                                            .soutni.name,
                                        chiffre: listViewPredictionRecord
                                            ?.soutni?.boul,
                                        ref:
                                            listViewPredictionRecord?.reference,
                                        icon: FaIcon(
                                          FontAwesomeIcons.peopleCarry,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          size: 20.0,
                                        ),
                                      ),
                                    ).vipEntrance(delayMs: 170),
                                    wrapWithModel(
                                      model: _model.vIPbolotoModel,
                                      updateCallback: () => safeSetState(() {}),
                                      child: VIPbolotoWidget(
                                        name: listViewPredictionRecord!
                                            .boloto.name,
                                        chiffre: listViewPredictionRecord
                                            ?.boloto?.boul,
                                        ref:
                                            listViewPredictionRecord?.reference,
                                      ),
                                    ).vipEntrance(delayMs: 215),
                                    wrapWithModel(
                                      model: _model.mariageModel,
                                      updateCallback: () => safeSetState(() {}),
                                      child: UniversalVIPWidget(
                                        name: listViewPredictionRecord!
                                            .mariage.name,
                                        chiffre: listViewPredictionRecord
                                            ?.mariage?.boul,
                                        ref:
                                            listViewPredictionRecord?.reference,
                                        icon: FaIcon(
                                          FontAwesomeIcons.link,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          size: 20.0,
                                        ),
                                      ),
                                    ).vipEntrance(delayMs: 260),
                                    wrapWithModel(
                                      model: _model.chif3Model,
                                      updateCallback: () => safeSetState(() {}),
                                      child: UniversalVIPWidget(
                                        name: listViewPredictionRecord!
                                            .chif3.name,
                                        icon: Icon(
                                          Icons.looks_3,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          size: 20.0,
                                        ),
                                        chiffre: listViewPredictionRecord
                                            ?.chif3?.boul,
                                        ref:
                                            listViewPredictionRecord?.reference,
                                      ),
                                    ).vipEntrance(delayMs: 305),
                                    wrapWithModel(
                                      model: _model.chif4Model,
                                      updateCallback: () => safeSetState(() {}),
                                      child: UniversalVIPWidget(
                                        name: listViewPredictionRecord!
                                            .chif4.name,
                                        icon: Icon(
                                          Icons.looks_4,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          size: 20.0,
                                        ),
                                        chiffre: listViewPredictionRecord
                                            ?.chif4?.boul,
                                        ref:
                                            listViewPredictionRecord?.reference,
                                      ),
                                    ).vipEntrance(delayMs: 350),
                                    wrapWithModel(
                                      model: _model.extraModel,
                                      updateCallback: () => safeSetState(() {}),
                                      child: UniversalVIPWidget(
                                        name: listViewPredictionRecord!
                                            .extra.name,
                                        icon: FaIcon(
                                          FontAwesomeIcons.meteor,
                                          color: theme.error,
                                          size: 20.0,
                                        ),
                                        chiffre: listViewPredictionRecord
                                            ?.extra?.boul,
                                        ref:
                                            listViewPredictionRecord?.reference,
                                      ),
                                    ).vipEntrance(delayMs: 395),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        return wrapWithModel(
                          model: _model.devenirVIPModel,
                          updateCallback: () => safeSetState(() {}),
                          child: DevenirVIPWidget(),
                        ).vipEntrance(delayMs: 100);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
