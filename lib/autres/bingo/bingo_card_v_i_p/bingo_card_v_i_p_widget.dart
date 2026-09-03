import '/auth/base_auth_user_provider.dart';
import '/autres/bingo/bingo/bingo_reaction_service.dart';
import '/autres/bingo/stackbingo/stackbingo_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
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
  var _reactionPending = false;

  Future<void> _react(BingoReaction requestedReaction) async {
    if (_reactionPending) return;

    safeSetState(() => _reactionPending = true);
    try {
      final reaction = await toggleCurrentBingoReaction(requestedReaction);
      if (!mounted || reaction == null) return;

      final isPositive = reaction == BingoReaction.positive;
      final theme = FlutterFlowTheme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            FFLocalizations.of(context)
                .getText(isPositive ? 'bngsuccess' : 'bngtryagain'),
            style: TextStyle(
              color: isPositive ? theme.onPrimary : theme.primaryText,
            ),
          ),
          duration: const Duration(milliseconds: 4000),
          backgroundColor: isPositive ? theme.primary : theme.tertiary,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            FFLocalizations.of(context).getText('bingo_story_reaction_error'),
          ),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    } finally {
      if (mounted) safeSetState(() => _reactionPending = false);
    }
  }

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
                        text: FFLocalizations.of(context).getText(
                          _model.minimise == false ? 'bngreduce' : 'bngexpand',
                        ),
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
                                onPressed: _reactionPending
                                    ? null
                                    : () async {
                                        logFirebaseEvent(
                                          'BINGO_CARD_V_I_P_COMP_WI_BTN_ON_TAP',
                                        );
                                        await _react(BingoReaction.positive);
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
                                onPressed: _reactionPending
                                    ? null
                                    : () async {
                                        logFirebaseEvent(
                                          'BINGO_CARD_V_I_P_COMP_NON_BTN_ON_TAP',
                                        );
                                        await _react(BingoReaction.negative);
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
