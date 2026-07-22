import '/auth/base_auth_user_provider.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/autres/bingo/stackbingo/stackbingo_widget.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'bingo_card_v_i_p_model.dart';
export 'bingo_card_v_i_p_model.dart';

class BingoCardVIPWidget extends StatefulWidget {
  const BingoCardVIPWidget({super.key});

  @override
  State<BingoCardVIPWidget> createState() => _BingoCardVIPWidgetState();
}

class _BingoCardVIPWidgetState extends State<BingoCardVIPWidget> {
  late BingoCardVIPModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BingoCardVIPModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return SafeArea(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeIn,
        height: _model.minimise == false ? 250.0 : 60.0,
        decoration: BoxDecoration(),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
          child: Card(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            color: FlutterFlowTheme.of(context).primaryBackground,
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/images/bingo-2.png',
                          height: 30.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                      FFButtonWidget(
                        onPressed: () async {
                          logFirebaseEvent(
                              'BINGO_CARD_V_I_P_Button_vv92t9cq_ON_TAP');
                          logFirebaseEvent('Button_update_component_state');
                          _model.minimise = !_model.minimise;
                          safeSetState(() {});
                        },
                        text: _model.minimise == false ? 'Reduire' : 'Agrandir',
                        icon: FaIcon(
                          FontAwesomeIcons.minusSquare,
                          size: 15.0,
                        ),
                        options: FFButtonOptions(
                          height: 25.0,
                          padding: EdgeInsetsDirectional.fromSTEB(
                              6.0, 0.0, 6.0, 0.0),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          iconColor: FlutterFlowTheme.of(context).alternate,
                          color: Color(0x00F8BB00),
                          textStyle: FlutterFlowTheme.of(context)
                              .titleSmall
                              .override(
                                fontFamily: 'Google sans flex',
                                color: FlutterFlowTheme.of(context).alternate,
                                fontSize: 12.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.normal,
                              ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        showLoadingIndicator: false,
                      ),
                    ],
                  ),
                  if (_model.minimise == false)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primaryBackground,
                      ),
                      child: wrapWithModel(
                        model: _model.stackbingoModel,
                        updateCallback: () => safeSetState(() {}),
                        child: StackbingoWidget(),
                      ),
                    ),
                  if ((_model.minimise == false) && loggedIn)
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          FFLocalizations.of(context).getText(
                            'ch00aogu' /* Ou te gagné ak nou ? */,
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color:
                                FlutterFlowTheme.of(context).primaryBackground,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              FFButtonWidget(
                                onPressed: () async {
                                  logFirebaseEvent(
                                      'BINGO_CARD_V_I_P_COMP_WI_BTN_ON_TAP');
                                  final firestoreBatch =
                                      FirebaseFirestore.instance.batch();
                                  try {
                                    if (FFAppState().bingo.refGain == null) {
                                      logFirebaseEvent('Button_backend_call');

                                      var bingostatsRecordReference =
                                          BingostatsRecord.createDoc(
                                              FFAppState().bingo.doc!);
                                      firestoreBatch.set(
                                          bingostatsRecordReference,
                                          createBingostatsRecordData(
                                            user: currentUserReference?.id,
                                            gain: true,
                                          ));
                                      _model.bingolikeyes =
                                          BingostatsRecord.getDocumentFromData(
                                              createBingostatsRecordData(
                                                user: currentUserReference?.id,
                                                gain: true,
                                              ),
                                              bingostatsRecordReference);
                                      // Incrementation/decrementation
                                      logFirebaseEvent(
                                          'Button_Incrementationdecrementation');

                                      firestoreBatch.update(
                                          currentUserReference!,
                                          createUserRecordData(
                                            userStats: createUserStatsStruct(
                                              fieldValues: {
                                                'bingoGain':
                                                    FieldValue.increment(1),
                                              },
                                              clearUnsetFields: false,
                                            ),
                                          ));
                                      logFirebaseEvent(
                                          'Button_update_app_state');
                                      FFAppState().updateBingoStruct(
                                        (e) => e
                                          ..gagner = true
                                          ..refGain =
                                              _model.bingolikeyes?.reference,
                                      );
                                      safeSetState(() {});
                                      logFirebaseEvent('Button_show_snack_bar');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '🎉 FELISITASYON',
                                            style: TextStyle(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                            ),
                                          ),
                                          duration:
                                              Duration(milliseconds: 4000),
                                          backgroundColor: Color(0xFFA000D7),
                                        ),
                                      );
                                    } else if ((FFAppState().bingo.gagner ==
                                            true) &&
                                        (FFAppState().bingo.refGain != null)) {
                                      logFirebaseEvent('Button_backend_call');
                                      firestoreBatch
                                          .delete(FFAppState().bingo.refGain!);
                                      // Incrementation/decrementation
                                      logFirebaseEvent(
                                          'Button_Incrementationdecrementation');

                                      firestoreBatch.update(
                                          currentUserReference!,
                                          createUserRecordData(
                                            userStats: createUserStatsStruct(
                                              fieldValues: {
                                                'bingoGain':
                                                    FieldValue.increment(-(1)),
                                              },
                                              clearUnsetFields: false,
                                            ),
                                          ));
                                      logFirebaseEvent(
                                          'Button_update_app_state');
                                      FFAppState().updateBingoStruct(
                                        (e) => e
                                          ..gagner = null
                                          ..refGain = null,
                                      );
                                      safeSetState(() {});
                                    } else if ((FFAppState().bingo.gagner ==
                                            false) &&
                                        (FFAppState().bingo.refGain != null)) {
                                      logFirebaseEvent('Button_backend_call');

                                      firestoreBatch.update(
                                          FFAppState().bingo.refGain!,
                                          createBingostatsRecordData(
                                            gain: true,
                                          ));
                                      // Incrementation/decrementation
                                      logFirebaseEvent(
                                          'Button_Incrementationdecrementation');

                                      firestoreBatch.update(
                                          currentUserReference!,
                                          createUserRecordData(
                                            userStats: createUserStatsStruct(
                                              fieldValues: {
                                                'bingoGain':
                                                    FieldValue.increment(1),
                                                'bingoRater':
                                                    FieldValue.increment(-(1)),
                                              },
                                              clearUnsetFields: false,
                                            ),
                                          ));
                                      logFirebaseEvent(
                                          'Button_update_app_state');
                                      FFAppState().updateBingoStruct(
                                        (e) => e..gagner = true,
                                      );
                                      safeSetState(() {});
                                      logFirebaseEvent('Button_show_snack_bar');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '🎉 FELISITASYON',
                                            style: TextStyle(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                            ),
                                          ),
                                          duration:
                                              Duration(milliseconds: 4000),
                                          backgroundColor: Color(0xFFA000D7),
                                        ),
                                      );
                                    }
                                  } finally {
                                    await firestoreBatch.commit();
                                  }

                                  safeSetState(() {});
                                },
                                text: FFLocalizations.of(context).getText(
                                  'ksh6eozy' /* WI */,
                                ),
                                icon: Icon(
                                  Icons.thumb_up,
                                  size: 12.0,
                                ),
                                options: FFButtonOptions(
                                  height: 30.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      5.0, 0.0, 5.0, 0.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  iconColor: FFAppState().bingo.gagner == true
                                      ? FlutterFlowTheme.of(context).error
                                      : FlutterFlowTheme.of(context)
                                          .primaryText,
                                  color: Color(0x00F8BB00),
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Google sans flex',
                                        color: Colors.white,
                                        fontSize: 10.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                  elevation: 0.0,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                showLoadingIndicator: false,
                              ),
                              SizedBox(
                                height: 15.0,
                                child: VerticalDivider(
                                  thickness: 2.0,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                ),
                              ),
                              FFButtonWidget(
                                onPressed: () async {
                                  logFirebaseEvent(
                                      'BINGO_CARD_V_I_P_COMP_NON_BTN_ON_TAP');
                                  final firestoreBatch =
                                      FirebaseFirestore.instance.batch();
                                  try {
                                    if (FFAppState().bingo.refGain == null) {
                                      logFirebaseEvent('Button_backend_call');

                                      var bingostatsRecordReference =
                                          BingostatsRecord.createDoc(
                                              FFAppState().bingo.doc!);
                                      firestoreBatch.set(
                                          bingostatsRecordReference,
                                          createBingostatsRecordData(
                                            user: currentUserReference?.id,
                                            gain: false,
                                          ));
                                      _model.bingolikeyesCopy =
                                          BingostatsRecord.getDocumentFromData(
                                              createBingostatsRecordData(
                                                user: currentUserReference?.id,
                                                gain: false,
                                              ),
                                              bingostatsRecordReference);
                                      // Incrementation/decrementation
                                      logFirebaseEvent(
                                          'Button_Incrementationdecrementation');

                                      firestoreBatch.update(
                                          currentUserReference!,
                                          createUserRecordData(
                                            userStats: createUserStatsStruct(
                                              fieldValues: {
                                                'bingoRater':
                                                    FieldValue.increment(1),
                                              },
                                              clearUnsetFields: false,
                                            ),
                                          ));
                                      logFirebaseEvent(
                                          'Button_update_app_state');
                                      FFAppState().updateBingoStruct(
                                        (e) => e
                                          ..gagner = false
                                          ..refGain = _model
                                              .bingolikeyesCopy?.reference,
                                      );
                                      safeSetState(() {});
                                      logFirebaseEvent('Button_show_snack_bar');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'ESEYE PWOCHÈNN FWA',
                                            style: TextStyle(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                            ),
                                          ),
                                          duration:
                                              Duration(milliseconds: 4000),
                                          backgroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .tertiary,
                                        ),
                                      );
                                    } else if ((FFAppState().bingo.gagner ==
                                            false) &&
                                        (FFAppState().bingo.refGain != null)) {
                                      logFirebaseEvent('Button_backend_call');
                                      firestoreBatch
                                          .delete(FFAppState().bingo.refGain!);
                                      // Incrementation/decrementation
                                      logFirebaseEvent(
                                          'Button_Incrementationdecrementation');

                                      firestoreBatch.update(
                                          currentUserReference!,
                                          createUserRecordData(
                                            userStats: createUserStatsStruct(
                                              fieldValues: {
                                                'bingoRater':
                                                    FieldValue.increment(-(1)),
                                              },
                                              clearUnsetFields: false,
                                            ),
                                          ));
                                      logFirebaseEvent(
                                          'Button_update_app_state');
                                      FFAppState().updateBingoStruct(
                                        (e) => e
                                          ..gagner = null
                                          ..refGain = null,
                                      );
                                      safeSetState(() {});
                                    } else if ((FFAppState().bingo.gagner ==
                                            true) &&
                                        (FFAppState().bingo.refGain != null)) {
                                      logFirebaseEvent('Button_backend_call');

                                      firestoreBatch.update(
                                          FFAppState().bingo.refGain!,
                                          createBingostatsRecordData(
                                            gain: false,
                                          ));
                                      // Incrementation/decrementation
                                      logFirebaseEvent(
                                          'Button_Incrementationdecrementation');

                                      firestoreBatch.update(
                                          currentUserReference!,
                                          createUserRecordData(
                                            userStats: createUserStatsStruct(
                                              fieldValues: {
                                                'bingoRater':
                                                    FieldValue.increment(1),
                                                'bingoGain':
                                                    FieldValue.increment(-(1)),
                                              },
                                              clearUnsetFields: false,
                                            ),
                                          ));
                                      logFirebaseEvent(
                                          'Button_update_app_state');
                                      FFAppState().updateBingoStruct(
                                        (e) => e..gagner = false,
                                      );
                                      safeSetState(() {});
                                      logFirebaseEvent('Button_show_snack_bar');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'ESEYE PWOCHÈNN FWA',
                                            style: TextStyle(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                            ),
                                          ),
                                          duration:
                                              Duration(milliseconds: 4000),
                                          backgroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .tertiary,
                                        ),
                                      );
                                    }
                                  } finally {
                                    await firestoreBatch.commit();
                                  }

                                  safeSetState(() {});
                                },
                                text: FFLocalizations.of(context).getText(
                                  '7ccuyv05' /* NON */,
                                ),
                                icon: Icon(
                                  Icons.thumb_down_alt,
                                  size: 12.0,
                                ),
                                options: FFButtonOptions(
                                  height: 30.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      5.0, 0.0, 5.0, 0.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  iconColor: (FFAppState().bingo.gagner ==
                                              false) &&
                                          (FFAppState().bingo.refGain != null)
                                      ? FlutterFlowTheme.of(context).error
                                      : FlutterFlowTheme.of(context)
                                          .primaryText,
                                  color: Color(0x00F8BB00),
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Google sans flex',
                                        color: Colors.white,
                                        fontSize: 10.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                  elevation: 0.0,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                showLoadingIndicator: false,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ].divide(SizedBox(height: 10.0)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
