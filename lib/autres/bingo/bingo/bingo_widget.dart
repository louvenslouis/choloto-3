import '/autres/bingo/stackbingo/stackbingo_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'bingo_model.dart';
export 'bingo_model.dart';

class BingoWidget extends StatefulWidget {
  const BingoWidget({super.key});

  @override
  State<BingoWidget> createState() => _BingoWidgetState();
}

class _BingoWidgetState extends State<BingoWidget>
    with TickerProviderStateMixin {
  late BingoModel _model;

  late AnimationController tapconfetiController;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BingoModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('BINGO_COMP_bingo_ON_INIT_STATE');
      logFirebaseEvent('bingo_wait__delay');
      await Future.delayed(
        Duration(
          milliseconds: 45,
        ),
      );
      logFirebaseEvent('bingo_haptic_feedback');
      HapticFeedback.mediumImpact();
    });

    tapconfetiController = AnimationController(vsync: this);
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

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 10.0, 0.0),
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () async {
          logFirebaseEvent('BINGO_COMP_Card_99wwwxl3_ON_TAP');
          await Future.wait([
            Future(() async {
              logFirebaseEvent('Card_lottie_animation');
              await tapconfetiController.forward();
              tapconfetiController.reset();
            }),
            Future(() async {
              logFirebaseEvent('Card_haptic_feedback');
              HapticFeedback.heavyImpact();
            }),
          ]);
        },
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          color: FlutterFlowTheme.of(context).primaryText,
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Container(
            width: 400.0,
            height: 400.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: Image.asset(
                  'assets/images/bg_bingo_-_Moyenne.jpeg',
                ).image,
              ),
            ),
            child: Stack(
              children: [
                Lottie.asset(
                  'assets/jsons/Confetti.json',
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  height: MediaQuery.sizeOf(context).height * 1.0,
                  fit: BoxFit.contain,
                  repeat: false,
                  animate: true,
                ),
                Lottie.asset(
                  'assets/jsons/Confetti.json',
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  height: MediaQuery.sizeOf(context).height * 1.0,
                  fit: BoxFit.contain,
                  controller: tapconfetiController,
                  onLoaded: (composition) =>
                      tapconfetiController.duration = composition.duration,
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, -0.85),
                  child: Lottie.asset(
                    'assets/jsons/Bingo_Animation.json',
                    width: MediaQuery.sizeOf(context).width * 1.65,
                    height: 170.0,
                    fit: BoxFit.contain,
                    animate: true,
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(1.0, -1.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 15.0, 0.0),
                    child: FlutterFlowIconButton(
                      borderRadius: 15.0,
                      buttonSize: 40.0,
                      fillColor: Color(0x7FFFFFFF),
                      icon: Icon(
                        Icons.close_outlined,
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        size: 24.0,
                      ),
                      onPressed: () async {
                        logFirebaseEvent(
                            'BINGO_COMP_close_outlined_ICN_ON_TAP');
                        logFirebaseEvent('IconButton_close_dialog_drawer_etc');
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, 1.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 30.0),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 1.0,
                      height: 125.3,
                      decoration: BoxDecoration(),
                      child: wrapWithModel(
                        model: _model.stackbingoModel,
                        updateCallback: () => safeSetState(() {}),
                        child: StackbingoWidget(),
                      ),
                    ),
                  ),
                ),
                if (FFAppState().bingo.dataStack.length > 1)
                  Align(
                    alignment: AlignmentDirectional(-0.01, 0.34),
                    child: Container(
                      width: 75.0,
                      height: 50.0,
                      decoration: BoxDecoration(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'x${FFAppState().bingo.dataStack.length.toString()}',
                            style: FlutterFlowTheme.of(context)
                                .displayLarge
                                .override(
                              font: GoogleFonts.raleway(
                                fontWeight: FontWeight.w900,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .displayLarge
                                    .fontStyle,
                              ),
                              color: Colors.white,
                              fontSize: 20.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w900,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .displayLarge
                                  .fontStyle,
                              shadows: [
                                Shadow(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 2.0,
                                )
                              ],
                            ),
                          ),
                          Icon(
                            Icons.swipe_sharp,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 12.0,
                          ),
                        ].divide(SizedBox(width: 10.0)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
