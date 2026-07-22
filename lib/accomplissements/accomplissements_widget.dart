import '/auth/firebase_auth/auth_util.dart';
import '/autres/calendrier/calendrier/calendrier_widget.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'accomplissements_model.dart';
export 'accomplissements_model.dart';

class AccomplissementsWidget extends StatefulWidget {
  const AccomplissementsWidget({super.key});

  static String routeName = 'Accomplissements';
  static String routePath = '/accomplissements';

  @override
  State<AccomplissementsWidget> createState() => _AccomplissementsWidgetState();
}

class _AccomplissementsWidgetState extends State<AccomplissementsWidget>
    with TickerProviderStateMixin {
  late AccomplissementsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AccomplissementsModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'Accomplissements'});
    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('ACCOMPLISSEMENTS_Accomplissements_ON_INI');
      logFirebaseEvent('Accomplissements_update_page_state');
      _model.secondes = currentUserDocument?.endSub?.secondsSinceEpoch;
      logFirebaseEvent('Accomplissements_update_page_state');
      _model.secondes = _model.secondes! + 86400;
      safeSetState(() {});
      logFirebaseEvent('Accomplissements_update_page_state');
      _model.expiration = dateTimeFromSecondsSinceEpoch(valueOrDefault<int>(
        _model.secondes,
        0,
      ));
      safeSetState(() {});
    });

    _model.tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: Color(0xFF1C1B1B),
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () async {
              logFirebaseEvent('ACCOMPLISSEMENTS_arrow_back_rounded_ICN_');
              logFirebaseEvent('IconButton_navigate_back');
              context.pop();
            },
          ),
          title: Text(
            FFLocalizations.of(context).getText(
              'aiyue31r' /* STATISTIQUES */,
            ),
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Google sans flex',
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            children: [
              Align(
                alignment: Alignment(0.0, 0),
                child: TabBar(
                  labelColor: FlutterFlowTheme.of(context).primaryText,
                  unselectedLabelColor:
                      FlutterFlowTheme.of(context).secondaryText,
                  labelStyle: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily: 'Google sans flex',
                        fontSize: 16.0,
                        letterSpacing: 0.0,
                      ),
                  unselectedLabelStyle:
                      FlutterFlowTheme.of(context).titleMedium.override(
                            fontFamily: 'Google sans flex',
                            letterSpacing: 0.0,
                          ),
                  indicatorColor: FlutterFlowTheme.of(context).primary,
                  tabs: [
                    Tab(
                      text: FFLocalizations.of(context).getText(
                        'o0ut0uym' /* Statistiques */,
                      ),
                    ),
                    Tab(
                      text: FFLocalizations.of(context).getText(
                        'exm1ba5v' /* Accomplissements */,
                      ),
                    ),
                  ],
                  controller: _model.tabBarController,
                  onTap: (i) async {
                    [() async {}, () async {}][i]();
                  },
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _model.tabBarController,
                  children: [
                    Visibility(
                      visible: currentUserEmail == 'louvenslouisl@gmail.com',
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(6.0, 6.0, 6.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: wrapWithModel(
                                model: _model.calendrierModel,
                                updateCallback: () => safeSetState(() {}),
                                child: CalendrierWidget(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        AuthUserStreamWidget(
                          builder: (context) => Material(
                            color: Colors.transparent,
                            child: ListTile(
                              title: Text(
                                FFLocalizations.of(context).getText(
                                  'safuzdxq' /* Gains déclarés */,
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .titleLarge
                                    .override(
                                      fontFamily: 'Google sans flex',
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              subtitle: Text(
                                currentUserDocument!.userStats.bingoGain
                                    .toString(),
                                style: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontStyle,
                                    ),
                              ),
                              tileColor: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              dense: false,
                              contentPadding: EdgeInsetsDirectional.fromSTEB(
                                  12.0, 0.0, 12.0, 0.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                        AuthUserStreamWidget(
                          builder: (context) => Material(
                            color: Colors.transparent,
                            child: ListTile(
                              title: Text(
                                FFLocalizations.of(context).getText(
                                  '5baauzd7' /* Gains ratés déclarés */,
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .titleLarge
                                    .override(
                                      fontFamily: 'Google sans flex',
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              subtitle: Text(
                                currentUserDocument!.userStats.bingoRater
                                    .toString(),
                                style: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontStyle,
                                    ),
                              ),
                              tileColor: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              dense: false,
                              contentPadding: EdgeInsetsDirectional.fromSTEB(
                                  12.0, 0.0, 12.0, 0.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Builder(
                              builder: (context) {
                                final aeffaacer = FFAppState().stories.toList();

                                return Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: List.generate(aeffaacer.length,
                                      (aeffaacerIndex) {
                                    final aeffaacerItem =
                                        aeffaacer[aeffaacerIndex];
                                    return Text(
                                      valueOrDefault<String>(
                                        aeffaacerItem.expiration?.toString(),
                                        'null',
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    );
                                  }),
                                );
                              },
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  FFLocalizations.of(context).getText(
                                    '4z7v1o5y' /* Hello World */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
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
                              ],
                            ),
                          ],
                        ),
                      ]
                          .divide(SizedBox(height: 6.0))
                          .addToStart(SizedBox(height: 8.0)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
