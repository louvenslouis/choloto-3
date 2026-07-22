import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_swipeable_stack.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'stackbingo_model.dart';
export 'stackbingo_model.dart';

class StackbingoWidget extends StatefulWidget {
  const StackbingoWidget({
    super.key,
    this.dataStack,
  });

  final List<DataStackStruct>? dataStack;

  @override
  State<StackbingoWidget> createState() => _StackbingoWidgetState();
}

class _StackbingoWidgetState extends State<StackbingoWidget>
    with TickerProviderStateMixin {
  late StackbingoModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StackbingoModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('STACKBINGO_COMP_stackbingo_ON_INIT_STATE');
      while (widget!.dataStack!.length > 1) {
        logFirebaseEvent('stackbingo_wait__delay');
        await Future.delayed(
          Duration(
            milliseconds: 3000,
          ),
        );
        logFirebaseEvent('stackbingo_swipeable_stack');
        _model.swipeableStackController.swipeRight();
      }
    });

    animationsMap.addAll({
      'swipeableStackOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.elasticOut,
            delay: 100.0.ms,
            duration: 800.0.ms,
            begin: Offset(0.0, -15.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.95,
      height: 126.0,
      decoration: BoxDecoration(),
      child: StreamBuilder<List<BingoRecord>>(
        stream: queryBingoRecord(
          queryBuilder: (bingoRecord) =>
              bingoRecord.orderBy('date', descending: true),
          singleRecord: true,
        ),
        builder: (context, snapshot) {
          // Customize what your widget looks like when it's loading.
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
          List<BingoRecord> swipeableStackBingoRecordList = snapshot.data!;
          // Return an empty Container when the item does not exist.
          if (snapshot.data!.isEmpty) {
            return Container();
          }
          final swipeableStackBingoRecord =
              swipeableStackBingoRecordList.isNotEmpty
                  ? swipeableStackBingoRecordList.first
                  : null;

          return Builder(
            builder: (context) {
              final datastacklist =
                  swipeableStackBingoRecord?.dataStack?.toList() ?? [];

              return FlutterFlowSwipeableStack(
                onSwipeFn: (datastacklistIndex) {},
                onLeftSwipe: (datastacklistIndex) {},
                onRightSwipe: (datastacklistIndex) {},
                onUpSwipe: (datastacklistIndex) {},
                onDownSwipe: (datastacklistIndex) {},
                itemBuilder: (context, datastacklistIndex) {
                  final datastacklistItem = datastacklist[datastacklistIndex];
                  return Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    color: FlutterFlowTheme.of(context).primaryText,
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).primary,
                          width: 4.0,
                        ),
                      ),
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(3.0, 6.0, 3.0, 6.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GradientText(
                              valueOrDefault<String>(
                                datastacklistItem.boul,
                                '-',
                              ),
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .displayLarge
                                  .override(
                                    font: GoogleFonts.raleway(
                                      fontWeight: FontWeight.w900,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .displayLarge
                                          .fontStyle,
                                    ),
                                    color: Color(0xFFFF3900),
                                    fontSize: 40.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w900,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .displayLarge
                                        .fontStyle,
                                  ),
                              colors: [Color(0xFFED2800), Color(0xFFF7681C)],
                              gradientDirection: GradientDirection.ltr,
                              gradientType: GradientType.linear,
                            ),
                            SizedBox(
                              height: 40.0,
                              child: VerticalDivider(
                                thickness: 2.0,
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (datastacklistItem.periode != null &&
                                    datastacklistItem.periode != '')
                                  Builder(
                                    builder: (context) {
                                      if (datastacklistItem.valeur ==
                                          '1er lot') {
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(0.0),
                                          child: Image.asset(
                                            'assets/images/game-2.png',
                                            height: 24.0,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      } else {
                                        return Icon(
                                          Icons.arrow_back,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 0.0,
                                        );
                                      }
                                    },
                                  ),
                                AutoSizeText(
                                  datastacklistItem.valeur,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.changaOne(
                                          fontWeight: FontWeight.normal,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 40.0,
                              child: VerticalDivider(
                                thickness: 2.0,
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (datastacklistItem.periode != null &&
                                    datastacklistItem.periode != '')
                                  Builder(
                                    builder: (context) {
                                      if (datastacklistItem.periode == 'Midi') {
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(0.0),
                                          child: Image.asset(
                                            'assets/images/sun.png',
                                            height: 24.0,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      } else if (datastacklistItem.periode ==
                                          'Soir') {
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.asset(
                                            'assets/images/moon.png',
                                            height: 24.0,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      } else {
                                        return Icon(
                                          Icons.arrow_back,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 0.0,
                                        );
                                      }
                                    },
                                  ),
                                AutoSizeText(
                                  datastacklistItem.tirage,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.changaOne(
                                          fontWeight: FontWeight.normal,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                itemCount: datastacklist.length,
                controller: _model.swipeableStackController,
                loop: true,
                cardDisplayCount: 3,
                scale: 1.0,
                backCardOffset: const Offset(0.0, 4.0),
              ).animateOnPageLoad(
                  animationsMap['swipeableStackOnPageLoadAnimation']!);
            },
          );
        },
      ),
    );
  }
}
