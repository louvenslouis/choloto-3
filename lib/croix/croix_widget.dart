import '/backend/backend.dart';
import '/components/cross_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'croix_model.dart';
export 'croix_model.dart';

class CroixWidget extends StatefulWidget {
  const CroixWidget({super.key});

  static String routeName = 'croix';
  static String routePath = '/croix';

  @override
  State<CroixWidget> createState() => _CroixWidgetState();
}

class _CroixWidgetState extends State<CroixWidget> {
  late CroixModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CroixModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'croix'});
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CroixRecord>>(
      stream: queryCroixRecord(
        queryBuilder: (croixRecord) =>
            croixRecord.orderBy('date', descending: true),
        singleRecord: true,
      ),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }
        List<CroixRecord> croixCroixRecordList = snapshot.data!;
        final croixCroixRecord =
            croixCroixRecordList.isNotEmpty ? croixCroixRecordList.first : null;

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primary,
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
                  logFirebaseEvent('CROIX_PAGE_arrow_back_rounded_ICN_ON_TAP');
                  logFirebaseEvent('IconButton_navigate_back');
                  context.pop();
                },
              ),
              title: Align(
                alignment: AlignmentDirectional(-1.0, -1.0),
                child: Text(
                  FFLocalizations.of(context).getText(
                    '63dg2p5g' /* Croix de la Chance */,
                  ),
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        fontFamily: 'Google sans flex',
                        color: Colors.white,
                        fontSize: 22.0,
                        letterSpacing: 0.0,
                      ),
                ),
              ),
              actions: [],
              centerTitle: false,
              elevation: 2.0,
            ),
            body: SafeArea(
              top: true,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Opacity(
                        opacity: 0.0,
                        child: Align(
                          alignment: AlignmentDirectional(1.0, 0.0),
                          child: FlutterFlowIconButton(
                            borderRadius: 20.0,
                            buttonSize: 40.0,
                            fillColor: Color(0x3FF8BB00),
                            icon: Icon(
                              Icons.share,
                              color: FlutterFlowTheme.of(context).info,
                              size: 24.0,
                            ),
                            onPressed: () async {
                              logFirebaseEvent('CROIX_PAGE_share_ICN_ON_TAP');
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: wrapWithModel(
                      model: _model.crossModel,
                      updateCallback: () => safeSetState(() {}),
                      child: CrossWidget(
                        numbers: croixCroixRecord?.numeros,
                        date: croixCroixRecord?.date,
                      ),
                    ),
                  ),
                ]
                    .divide(SizedBox(height: 25.0))
                    .addToStart(SizedBox(height: 12.0)),
              ),
            ),
          ),
        );
      },
    );
  }
}
