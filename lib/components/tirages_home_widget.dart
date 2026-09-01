import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/tirages/fl/fl_widget.dart';
import '/tirages/new_yorkk/new_yorkk_widget.dart';
import '/index.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
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
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;
    final radius = theme.designToken.radius;
    final gradientEnd = Color.lerp(
      theme.secondaryBackground,
      theme.primary,
      Theme.of(context).brightness == Brightness.dark ? 0.14 : 0.08,
    )!;

    return Container(
      key: const ValueKey('home-draws-gradient-card'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.secondaryBackground, gradientEnd],
        ),
        borderRadius: BorderRadius.circular(radius.lg),
        border: Border.all(
          color: theme.primary.withValues(alpha: 0.18),
        ),
        boxShadow: [theme.designToken.shadow.sm],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              spacing.md,
              spacing.sm,
              spacing.sm,
              spacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(radius.full),
                      ),
                      child: Icon(
                        Icons.casino_outlined,
                        color: theme.primary,
                        size: 20.0,
                      ),
                    ),
                    SizedBox(width: spacing.sm),
                    Text(
                      FFLocalizations.of(context).getText(
                        'grf0e1nq' /* TIRAGES */,
                      ),
                      style: theme.titleSmall.override(
                        color: theme.primaryText,
                        fontSize: 15.0,
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: spacing.xs),
                    FlutterFlowIconButton(
                      borderRadius: radius.full,
                      buttonSize: 36.0,
                      fillColor: theme.primaryText.withValues(alpha: 0.06),
                      hoverColor: theme.primary.withValues(alpha: 0.12),
                      hoverIconColor: theme.primary,
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: theme.primaryText.withValues(alpha: 0.72),
                        size: 18.0,
                      ),
                      showLoadingIndicator: true,
                      onPressed: () async {
                        logFirebaseEvent(
                          'TIRAGES_HOME_COMP_refresh_ICN_ON_TAP',
                        );
                        logFirebaseEvent('IconButton_update_component_state');
                        _model.refresh = true;
                        safeSetState(() {});
                      },
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
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16.0,
                  ),
                  options: FFButtonOptions(
                    height: 36.0,
                    padding: EdgeInsetsDirectional.fromSTEB(
                      spacing.md,
                      0.0,
                      spacing.md,
                      0.0,
                    ),
                    iconAlignment: IconAlignment.end,
                    iconPadding: EdgeInsetsDirectional.only(start: spacing.xs),
                    color: theme.primary.withValues(alpha: 0.12),
                    hoverColor: theme.primary.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(radius.full),
                    textStyle: theme.labelMedium.override(
                      color: theme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                    elevation: 0.0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 175.0,
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
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayInterval: const Duration(milliseconds: 4800),
                autoPlayCurve: Curves.linear,
                pauseAutoPlayInFiniteScroll: true,
                onPageChanged: (index, _) =>
                    _model.carouselCurrentIndex = index,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
