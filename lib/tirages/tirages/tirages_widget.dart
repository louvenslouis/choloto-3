import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'tirages_model.dart';
export 'tirages_model.dart';

class TiragesWidget extends StatefulWidget {
  const TiragesWidget({super.key});

  static String routeName = 'Tirages';
  static String routePath = '/resultats';

  @override
  State<TiragesWidget> createState() => _TiragesWidgetState();
}

class _TiragesWidgetState extends State<TiragesWidget> {
  late TiragesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TiragesModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Tirages'});
    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('TIRAGES_PAGE_Tirages_ON_INIT_STATE');
      await Future.wait([
        Future(() async {
          logFirebaseEvent('Tirages_backend_call');
          _model.newYorkLoadResult = await GetNewYorkPick3Call.call();

          if ((_model.newYorkLoadResult?.succeeded ?? true)) {
            logFirebaseEvent('Tirages_update_page_state');
            _model.newYorkApiResults =
                ((_model.newYorkLoadResult?.jsonBody ?? '')
                        .toList()
                        .map<NewYorkPick3DrawStruct?>(
                            NewYorkPick3DrawStruct.maybeFromMap)
                        .toList() as Iterable<NewYorkPick3DrawStruct?>)
                    .withoutNulls
                    .toList()
                    .cast<NewYorkPick3DrawStruct>();
            safeSetState(() {});
          } else {
            logFirebaseEvent('Tirages_show_snack_bar');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Impossible de charger les resultats New York',
                  style: TextStyle(),
                ),
                duration: Duration(milliseconds: 4000),
              ),
            );
          }
        }),
        Future(() async {
          logFirebaseEvent('Tirages_backend_call');
          _model.floridaPick2LoadResult = await GetFloridaPick2Call.call();

          if ((_model.floridaPick2LoadResult?.succeeded ?? true)) {
            logFirebaseEvent('Tirages_update_page_state');
            _model.floridaPick2ApiResults =
                ((_model.floridaPick2LoadResult?.jsonBody ?? '')
                        .toList()
                        .map<FloridaPick4DrawStruct?>(
                            FloridaPick4DrawStruct.maybeFromMap)
                        .toList() as Iterable<FloridaPick4DrawStruct?>)
                    .withoutNulls
                    .toList()
                    .cast<FloridaPick4DrawStruct>();
            safeSetState(() {});
          } else {
            logFirebaseEvent('Tirages_show_snack_bar');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Impossible de charger Florida Pick 2',
                  style: TextStyle(),
                ),
                duration: Duration(milliseconds: 4000),
              ),
            );
          }
        }),
        Future(() async {
          logFirebaseEvent('Tirages_backend_call');
          _model.floridaPick3LoadResult = await GetFloridaPick3Call.call();

          if ((_model.floridaPick3LoadResult?.succeeded ?? true)) {
            logFirebaseEvent('Tirages_update_page_state');
            _model.floridaPick3ApiResults =
                ((_model.floridaPick3LoadResult?.jsonBody ?? '')
                        .toList()
                        .map<FloridaPick4DrawStruct?>(
                            FloridaPick4DrawStruct.maybeFromMap)
                        .toList() as Iterable<FloridaPick4DrawStruct?>)
                    .withoutNulls
                    .toList()
                    .cast<FloridaPick4DrawStruct>();
            safeSetState(() {});
          } else {
            logFirebaseEvent('Tirages_show_snack_bar');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Impossible de charger Florida Pick 3',
                  style: TextStyle(),
                ),
                duration: Duration(milliseconds: 4000),
              ),
            );
          }
        }),
        Future(() async {
          logFirebaseEvent('Tirages_backend_call');
          _model.floridaLoadResult = await GetFloridaPick4Call.call();

          if ((_model.floridaLoadResult?.succeeded ?? true)) {
            logFirebaseEvent('Tirages_update_page_state');
            _model.floridaApiResults =
                ((_model.floridaLoadResult?.jsonBody ?? '')
                        .toList()
                        .map<FloridaPick4DrawStruct?>(
                            FloridaPick4DrawStruct.maybeFromMap)
                        .toList() as Iterable<FloridaPick4DrawStruct?>)
                    .withoutNulls
                    .toList()
                    .cast<FloridaPick4DrawStruct>();
            safeSetState(() {});
          } else {
            logFirebaseEvent('Tirages_show_snack_bar');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Impossible de charger les resultats Floride',
                  style: TextStyle(),
                ),
                duration: Duration(milliseconds: 4000),
              ),
            );
          }
        }),
      ]);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          title: Text(
            FFLocalizations.of(context).getText(
              'hfwdp6xo' /* Tirages */,
            ),
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Google sans flex',
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                ),
          ),
          actions: [
            FlutterFlowIconButton(
              buttonSize: 40.0,
              icon: Icon(
                Icons.refresh,
                size: 24.0,
              ),
              onPressed: () async {
                logFirebaseEvent('TIRAGES_RefreshLotteryResults_ON_TAP');
                await Future.wait([
                  Future(() async {
                    logFirebaseEvent('RefreshLotteryResults_backend_call');
                    _model.newYorkRefreshResult =
                        await GetNewYorkPick3Call.call();

                    if ((_model.newYorkRefreshResult?.succeeded ?? true)) {
                      logFirebaseEvent(
                          'RefreshLotteryResults_update_page_state');
                      _model.newYorkApiResults =
                          ((_model.newYorkRefreshResult?.jsonBody ?? '')
                                      .toList()
                                      .map<NewYorkPick3DrawStruct?>(
                                          NewYorkPick3DrawStruct.maybeFromMap)
                                      .toList()
                                  as Iterable<NewYorkPick3DrawStruct?>)
                              .withoutNulls
                              .toList()
                              .cast<NewYorkPick3DrawStruct>();
                      safeSetState(() {});
                    } else {
                      logFirebaseEvent('RefreshLotteryResults_show_snack_bar');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Echec de la mise a jour New York',
                            style: TextStyle(),
                          ),
                          duration: Duration(milliseconds: 4000),
                        ),
                      );
                    }
                  }),
                  Future(() async {
                    logFirebaseEvent('RefreshLotteryResults_backend_call');
                    _model.floridaPick2RefreshResult =
                        await GetFloridaPick2Call.call();

                    if ((_model.floridaPick2RefreshResult?.succeeded ?? true)) {
                      logFirebaseEvent(
                          'RefreshLotteryResults_update_page_state');
                      _model.floridaPick2ApiResults =
                          ((_model.floridaPick2RefreshResult?.jsonBody ?? '')
                                      .toList()
                                      .map<FloridaPick4DrawStruct?>(
                                          FloridaPick4DrawStruct.maybeFromMap)
                                      .toList()
                                  as Iterable<FloridaPick4DrawStruct?>)
                              .withoutNulls
                              .toList()
                              .cast<FloridaPick4DrawStruct>();
                      safeSetState(() {});
                    } else {
                      logFirebaseEvent('RefreshLotteryResults_show_snack_bar');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Echec de la mise a jour Florida Pick 2',
                            style: TextStyle(),
                          ),
                          duration: Duration(milliseconds: 4000),
                        ),
                      );
                    }
                  }),
                  Future(() async {
                    logFirebaseEvent('RefreshLotteryResults_backend_call');
                    _model.floridaPick3RefreshResult =
                        await GetFloridaPick3Call.call();

                    if ((_model.floridaPick3RefreshResult?.succeeded ?? true)) {
                      logFirebaseEvent(
                          'RefreshLotteryResults_update_page_state');
                      _model.floridaPick3ApiResults =
                          ((_model.floridaPick3RefreshResult?.jsonBody ?? '')
                                      .toList()
                                      .map<FloridaPick4DrawStruct?>(
                                          FloridaPick4DrawStruct.maybeFromMap)
                                      .toList()
                                  as Iterable<FloridaPick4DrawStruct?>)
                              .withoutNulls
                              .toList()
                              .cast<FloridaPick4DrawStruct>();
                      safeSetState(() {});
                    } else {
                      logFirebaseEvent('RefreshLotteryResults_show_snack_bar');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Echec de la mise a jour Florida Pick 3',
                            style: TextStyle(),
                          ),
                          duration: Duration(milliseconds: 4000),
                        ),
                      );
                    }
                  }),
                  Future(() async {
                    logFirebaseEvent('RefreshLotteryResults_backend_call');
                    _model.floridaRefreshResult =
                        await GetFloridaPick4Call.call();

                    if ((_model.floridaRefreshResult?.succeeded ?? true)) {
                      logFirebaseEvent(
                          'RefreshLotteryResults_update_page_state');
                      _model.floridaApiResults =
                          ((_model.floridaRefreshResult?.jsonBody ?? '')
                                      .toList()
                                      .map<FloridaPick4DrawStruct?>(
                                          FloridaPick4DrawStruct.maybeFromMap)
                                      .toList()
                                  as Iterable<FloridaPick4DrawStruct?>)
                              .withoutNulls
                              .toList()
                              .cast<FloridaPick4DrawStruct>();
                      safeSetState(() {});
                    } else {
                      logFirebaseEvent('RefreshLotteryResults_show_snack_bar');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Echec de la mise a jour Floride',
                            style: TextStyle(),
                          ),
                          duration: Duration(milliseconds: 4000),
                        ),
                      );
                    }
                  }),
                ]);

                safeSetState(() {});
              },
            ),
          ],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_city,
                        color: FlutterFlowTheme.of(context).primary,
                        size: 42.0,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FFLocalizations.of(context).getText(
                              'nwse7gnu' /* NEW YORK */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  fontFamily: 'Google sans flex',
                                  letterSpacing: 0.0,
                                ),
                          ),
                          Text(
                            FFLocalizations.of(context).getText(
                              '688llz6y' /* Pick 3 officiel */,
                            ),
                            style:
                                FlutterFlowTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .fontStyle,
                                    ),
                          ),
                        ].divide(SizedBox(height: 2.0)),
                      ),
                    ].divide(SizedBox(width: 10.0)),
                  ),
                  Builder(
                    builder: (context) {
                      final newYorkApiResult =
                          _model.newYorkApiResults.toList();

                      return ListView.separated(
                        padding: EdgeInsets.zero,
                        primary: false,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: newYorkApiResult.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.0),
                        itemBuilder: (context, newYorkApiResultIndex) {
                          final newYorkApiResultItem =
                              newYorkApiResult[newYorkApiResultIndex];
                          return Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 1.0,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(14.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        FFLocalizations.of(context).getText(
                                          '16bznwfv' /* Dernier tirage */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                      Text(
                                        newYorkApiResultItem.drawDate,
                                        maxLines: 1,
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall
                                                      .fontStyle,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ].divide(SizedBox(height: 3.0)),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                FFLocalizations.of(context)
                                                    .getText(
                                                  'xqa3sjic' /* MIDDAY */,
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmall
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmall
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmall
                                                                  .fontStyle,
                                                        ),
                                              ),
                                              Text(
                                                newYorkApiResultItem
                                                    .middayDaily,
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .headlineSmall
                                                        .override(
                                                          fontFamily:
                                                              'Google sans flex',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primary,
                                                          letterSpacing: 0.0,
                                                        ),
                                              ),
                                            ].divide(SizedBox(height: 4.0)),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                FFLocalizations.of(context)
                                                    .getText(
                                                  '9hcsnfjs' /* EVENING */,
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmall
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmall
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmall
                                                                  .fontStyle,
                                                        ),
                                              ),
                                              Text(
                                                newYorkApiResultItem
                                                    .eveningDaily,
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .headlineSmall
                                                        .override(
                                                          fontFamily:
                                                              'Google sans flex',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primary,
                                                          letterSpacing: 0.0,
                                                        ),
                                              ),
                                            ].divide(SizedBox(height: 4.0)),
                                          ),
                                        ),
                                      ),
                                    ].divide(SizedBox(width: 10.0)),
                                  ),
                                ].divide(SizedBox(height: 12.0)),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  Divider(
                    thickness: 1.0,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wb_sunny,
                        color: FlutterFlowTheme.of(context).warning,
                        size: 42.0,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FFLocalizations.of(context).getText(
                              'vho2s2ds' /* FLORIDA */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  fontFamily: 'Google sans flex',
                                  letterSpacing: 0.0,
                                ),
                          ),
                          Text(
                            FFLocalizations.of(context).getText(
                              'jc5kkpyj' /* Pick 2, Pick 3 et Pick 4 offic... */,
                            ),
                            maxLines: 2,
                            style:
                                FlutterFlowTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .fontStyle,
                                    ),
                          ),
                        ].divide(SizedBox(height: 2.0)),
                      ),
                    ].divide(SizedBox(width: 10.0)),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FFLocalizations.of(context).getText(
                          'mevtoovb' /* PICK 2 */,
                        ),
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily: 'Google sans flex',
                              letterSpacing: 0.0,
                            ),
                      ),
                      Builder(
                        builder: (context) {
                          final floridaPick2ApiResult =
                              _model.floridaPick2ApiResults.toList();

                          return ListView.separated(
                            padding: EdgeInsets.zero,
                            primary: false,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: floridaPick2ApiResult.length,
                            separatorBuilder: (_, __) => SizedBox(height: 10.0),
                            itemBuilder: (context, floridaPick2ApiResultIndex) {
                              final floridaPick2ApiResultItem =
                                  floridaPick2ApiResult[
                                      floridaPick2ApiResultIndex];
                              return Container(
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    width: 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(14.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            floridaPick2ApiResultItem.drawType,
                                            style: FlutterFlowTheme.of(context)
                                                .labelMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMedium
                                                            .fontStyle,
                                                  ),
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                          Text(
                                            floridaPick2ApiResultItem.drawDate,
                                            maxLines: 1,
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ].divide(SizedBox(height: 3.0)),
                                      ),
                                      Container(
                                        height: 52.0,
                                        child: Builder(
                                          builder: (context) {
                                            final item =
                                                floridaPick2ApiResultItem
                                                    .drawNumbers
                                                    .toList();

                                            return ListView.separated(
                                              padding: EdgeInsets.zero,
                                              primary: false,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: item.length,
                                              separatorBuilder: (_, __) =>
                                                  SizedBox(width: 10.0),
                                              itemBuilder:
                                                  (context, itemIndex) {
                                                final itemItem =
                                                    item[itemIndex];
                                                return Visibility(
                                                  visible:
                                                      !(itemItem.numberType ==
                                                          'fb'),
                                                  child: Container(
                                                    width: 48.0,
                                                    height: 48.0,
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .primaryBackground,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              24.0),
                                                      border: Border.all(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 2.0,
                                                      ),
                                                    ),
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Text(
                                                      itemItem.numberPick
                                                          .toString(),
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleLarge
                                                              .override(
                                                                fontFamily:
                                                                    'Google sans flex',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                                letterSpacing:
                                                                    0.0,
                                                              ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ].divide(SizedBox(height: 12.0)),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ].divide(SizedBox(height: 8.0)),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FFLocalizations.of(context).getText(
                          'ccu2gg3x' /* PICK 3 */,
                        ),
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily: 'Google sans flex',
                              letterSpacing: 0.0,
                            ),
                      ),
                      Builder(
                        builder: (context) {
                          final floridaPick3ApiResult =
                              _model.floridaPick3ApiResults.toList();

                          return ListView.separated(
                            padding: EdgeInsets.zero,
                            primary: false,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: floridaPick3ApiResult.length,
                            separatorBuilder: (_, __) => SizedBox(height: 10.0),
                            itemBuilder: (context, floridaPick3ApiResultIndex) {
                              final floridaPick3ApiResultItem =
                                  floridaPick3ApiResult[
                                      floridaPick3ApiResultIndex];
                              return Container(
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    width: 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(14.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            floridaPick3ApiResultItem.drawType,
                                            style: FlutterFlowTheme.of(context)
                                                .labelMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMedium
                                                            .fontStyle,
                                                  ),
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                          Text(
                                            floridaPick3ApiResultItem.drawDate,
                                            maxLines: 1,
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ].divide(SizedBox(height: 3.0)),
                                      ),
                                      Container(
                                        height: 52.0,
                                        child: Builder(
                                          builder: (context) {
                                            final item =
                                                floridaPick3ApiResultItem
                                                    .drawNumbers
                                                    .toList();

                                            return ListView.separated(
                                              padding: EdgeInsets.zero,
                                              primary: false,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: item.length,
                                              separatorBuilder: (_, __) =>
                                                  SizedBox(width: 10.0),
                                              itemBuilder:
                                                  (context, itemIndex) {
                                                final itemItem =
                                                    item[itemIndex];
                                                return Visibility(
                                                  visible:
                                                      !(itemItem.numberType ==
                                                          'fb'),
                                                  child: Container(
                                                    width: 48.0,
                                                    height: 48.0,
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .primaryBackground,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              24.0),
                                                      border: Border.all(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 2.0,
                                                      ),
                                                    ),
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Text(
                                                      itemItem.numberPick
                                                          .toString(),
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleLarge
                                                              .override(
                                                                fontFamily:
                                                                    'Google sans flex',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                                letterSpacing:
                                                                    0.0,
                                                              ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ].divide(SizedBox(height: 12.0)),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ].divide(SizedBox(height: 8.0)),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FFLocalizations.of(context).getText(
                          'ov51axfz' /* PICK 4 */,
                        ),
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily: 'Google sans flex',
                              letterSpacing: 0.0,
                            ),
                      ),
                      Builder(
                        builder: (context) {
                          final floridaApiResult =
                              _model.floridaApiResults.toList();

                          return ListView.separated(
                            padding: EdgeInsets.zero,
                            primary: false,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: floridaApiResult.length,
                            separatorBuilder: (_, __) => SizedBox(height: 10.0),
                            itemBuilder: (context, floridaApiResultIndex) {
                              final floridaApiResultItem =
                                  floridaApiResult[floridaApiResultIndex];
                              return Container(
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    width: 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(14.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            floridaApiResultItem.drawType,
                                            style: FlutterFlowTheme.of(context)
                                                .labelMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMedium
                                                            .fontStyle,
                                                  ),
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                          Text(
                                            floridaApiResultItem.drawDate,
                                            maxLines: 1,
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ].divide(SizedBox(height: 3.0)),
                                      ),
                                      Container(
                                        height: 52.0,
                                        child: Builder(
                                          builder: (context) {
                                            final item = floridaApiResultItem
                                                .drawNumbers
                                                .toList();

                                            return ListView.separated(
                                              padding: EdgeInsets.zero,
                                              primary: false,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: item.length,
                                              separatorBuilder: (_, __) =>
                                                  SizedBox(width: 10.0),
                                              itemBuilder:
                                                  (context, itemIndex) {
                                                final itemItem =
                                                    item[itemIndex];
                                                return Visibility(
                                                  visible:
                                                      !(itemItem.numberType ==
                                                          'fb'),
                                                  child: Container(
                                                    width: 48.0,
                                                    height: 48.0,
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .primaryBackground,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              24.0),
                                                      border: Border.all(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 2.0,
                                                      ),
                                                    ),
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Text(
                                                      itemItem.numberPick
                                                          .toString(),
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleLarge
                                                              .override(
                                                                fontFamily:
                                                                    'Google sans flex',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                                letterSpacing:
                                                                    0.0,
                                                              ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ].divide(SizedBox(height: 12.0)),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ].divide(SizedBox(height: 8.0)),
                  ),
                  Text(
                    FFLocalizations.of(context).getText(
                      'cd9jjqv4' /* Sources: New York State Gaming... */,
                    ),
                    maxLines: 2,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodySmall
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodySmall
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                          fontWeight:
                              FlutterFlowTheme.of(context).bodySmall.fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodySmall.fontStyle,
                        ),
                  ),
                ].divide(SizedBox(height: 16.0)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
