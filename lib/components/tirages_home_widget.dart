import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/tirages/fl/fl_widget.dart';
import '/tirages/new_yorkk/new_yorkk_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'tirages_home_model.dart';
export 'tirages_home_model.dart';

class TiragesHomeWidget extends StatefulWidget {
  const TiragesHomeWidget({super.key});

  @override
  State<TiragesHomeWidget> createState() => _TiragesHomeWidgetState();
}

class _TiragesHomeWidgetState extends State<TiragesHomeWidget> {
  late TiragesHomeModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TiragesHomeModel());

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
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          width: 2.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 0.0, 0.0),
                      child: Text(
                        FFLocalizations.of(context).getText(
                          'grf0e1nq' /* TIRAGES */,
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              fontSize: 13.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                    ),
                    Opacity(
                      opacity: 0.7,
                      child: FlutterFlowIconButton(
                        borderRadius: 8.0,
                        buttonSize: 35.0,
                        hoverIconColor: FlutterFlowTheme.of(context).primary,
                        icon: Icon(
                          Icons.refresh,
                          color: FlutterFlowTheme.of(context).info,
                          size: 16.0,
                        ),
                        showLoadingIndicator: true,
                        onPressed: () async {
                          logFirebaseEvent(
                              'TIRAGES_HOME_COMP_refresh_ICN_ON_TAP');
                          logFirebaseEvent('IconButton_update_component_state');
                          _model.refresh = true;
                          safeSetState(() {});
                        },
                      ),
                    ),
                  ],
                ),
                FFButtonWidget(
                  onPressed: () async {
                    logFirebaseEvent('TIRAGES_HOME_COMP_VOIR_TOUT_BTN_ON_TAP');
                    logFirebaseEvent('Button_navigate_to');

                    context.pushNamed(TiragesWidget.routeName);
                  },
                  text: FFLocalizations.of(context).getText(
                    'zljfxk4l' /* VOIR TOUT */,
                  ),
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 12.0,
                  ),
                  options: FFButtonOptions(
                    height: 27.0,
                    padding:
                        EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                    iconAlignment: IconAlignment.end,
                    iconPadding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    color: Color(0x00EDB900),
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Google sans flex',
                          color: FlutterFlowTheme.of(context).primary,
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                        ),
                    elevation: 0.0,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.sizeOf(context).width * 1.0,
            height: 175.0,
            decoration: BoxDecoration(),
            child: Container(
              width: double.infinity,
              height: 40.0,
              child: CarouselSlider(
                items: [
                  FutureBuilder<List<ResultatsRecord>>(
                    future: FFAppState().newYorkTirage(
                      overrideCache: _model.refresh,
                      requestFn: () => queryResultatsRecordOnce(
                        queryBuilder: (resultatsRecord) => resultatsRecord
                            .where(
                              'tirage',
                              isEqualTo: 'ny',
                            )
                            .orderBy('date', descending: true),
                        singleRecord: true,
                      ),
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
                      List<ResultatsRecord> newYorkkResultatsRecordList =
                          snapshot.data!;
                      // Return an empty Container when the item does not exist.
                      if (snapshot.data!.isEmpty) {
                        return Container();
                      }
                      final newYorkkResultatsRecord =
                          newYorkkResultatsRecordList.isNotEmpty
                              ? newYorkkResultatsRecordList.first
                              : null;

                      return wrapWithModel(
                        model: _model.newYorkkModel,
                        updateCallback: () => safeSetState(() {}),
                        child: NewYorkkWidget(
                          infos: newYorkkResultatsRecord!,
                        ),
                      );
                    },
                  ),
                  FutureBuilder<List<ResultatsRecord>>(
                    future: FFAppState().floridaTirage(
                      overrideCache: _model.refresh,
                      requestFn: () => queryResultatsRecordOnce(
                        queryBuilder: (resultatsRecord) => resultatsRecord
                            .where(
                              'tirage',
                              isEqualTo: 'fl',
                            )
                            .orderBy('date', descending: true),
                        singleRecord: true,
                      ),
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
                      List<ResultatsRecord> flResultatsRecordList =
                          snapshot.data!;
                      // Return an empty Container when the item does not exist.
                      if (snapshot.data!.isEmpty) {
                        return Container();
                      }
                      final flResultatsRecord = flResultatsRecordList.isNotEmpty
                          ? flResultatsRecordList.first
                          : null;

                      return wrapWithModel(
                        model: _model.flModel,
                        updateCallback: () => safeSetState(() {}),
                        child: FlWidget(
                          infos: flResultatsRecord!,
                        ),
                      );
                    },
                  ),
                ],
                carouselController: _model.carouselController ??=
                    CarouselSliderController(),
                options: CarouselOptions(
                  initialPage: 0,
                  viewportFraction: 1.0,
                  disableCenter: true,
                  enlargeCenterPage: false,
                  enlargeFactor: 0.0,
                  enableInfiniteScroll: true,
                  scrollDirection: Axis.horizontal,
                  autoPlay: true,
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayInterval: Duration(milliseconds: (800 + 4000)),
                  autoPlayCurve: Curves.linear,
                  pauseAutoPlayInFiniteScroll: true,
                  onPageChanged: (index, _) =>
                      _model.carouselCurrentIndex = index,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
