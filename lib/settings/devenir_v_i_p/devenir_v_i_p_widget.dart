import '/components/web_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/settings/customerservice/customerservice_widget.dart';
import '/support/support_text.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'devenir_v_i_p_model.dart';
export 'devenir_v_i_p_model.dart';

class DevenirVIPWidget extends StatefulWidget {
  const DevenirVIPWidget({super.key});

  @override
  State<DevenirVIPWidget> createState() => _DevenirVIPWidgetState();
}

class _DevenirVIPWidgetState extends State<DevenirVIPWidget> {
  late DevenirVIPModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DevenirVIPModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;

    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.secondaryBackground,
                  Color.alphaBlend(theme.primary.withValues(alpha: 0.12),
                      theme.secondaryBackground),
                  theme.secondaryBackground
                ],
                stops: [0.0, 0.6, 1.0],
                begin: AlignmentDirectional(0.0, -1.0),
                end: AlignmentDirectional(0, 1.0),
              ),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Align(
                    alignment: AlignmentDirectional(-1.0, -1.0),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 0.0, 25.0),
                      child: FlutterFlowIconButton(
                        borderRadius: 8.0,
                        buttonSize: 40.0,
                        icon: Icon(
                          Icons.close_sharp,
                          color: theme.primaryText,
                          size: 30.0,
                        ),
                        onPressed: () async {
                          logFirebaseEvent(
                              'DEVENIR_V_I_P_close_sharp_ICN_ON_TAP');
                          logFirebaseEvent('IconButton_navigate_back');
                          context.safePop();
                        },
                      ),
                    ),
                  ),
                  Text(
                    FFLocalizations.of(context).getText(
                      'c8ki06qv' /* Devenez un membre VIP */,
                    ),
                    style: theme.titleLarge.override(
                      fontSize: 20.0,
                      color: theme.primaryText,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                  ),
                  Text(
                    FFLocalizations.of(context).getText(
                      'imcn98qf' /* ak CHOLOTO VIP, miltipliye cha... */,
                    ),
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          letterSpacing: 0.0,
                          color: theme.primaryText,
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ].divide(SizedBox(height: 15.0)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 15.0, 0.0, 15.0),
            child: Container(
              decoration: BoxDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width:
                              (MediaQuery.sizeOf(context).width - 20.0) * 0.6,
                          decoration: BoxDecoration(),
                          child: Text(
                            FFLocalizations.of(context).getText(
                              '99kfebqb' /* WHAT'S INCLUDED */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ),
                        Container(
                          width:
                              (MediaQuery.sizeOf(context).width - 20.0) * 0.2,
                          decoration: BoxDecoration(),
                          child: Text(
                            FFLocalizations.of(context).getText(
                              'juufc32a' /* GRATUIT */,
                            ),
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ),
                        Container(
                          width:
                              (MediaQuery.sizeOf(context).width - 20.0) * 0.2,
                          decoration: BoxDecoration(),
                          child: Text(
                            FFLocalizations.of(context).getText(
                              'zpnlwhem' /* VIP */,
                            ),
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  color: theme.primary,
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width:
                              (MediaQuery.sizeOf(context).width - 20.0) * 0.1,
                          decoration: BoxDecoration(),
                          child: Icon(
                            Icons.request_page,
                            color: theme.primaryText,
                            size: 24.0,
                          ),
                        ),
                        Container(
                          width:
                              (MediaQuery.sizeOf(context).width - 20.0) * 0.5,
                          decoration: BoxDecoration(),
                          child: Text(
                            FFLocalizations.of(context).getText(
                              'tv8dp8zl' /* Resultats lotteries */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ),
                        Container(
                          width:
                              (MediaQuery.sizeOf(context).width - 20.0) * 0.2,
                          decoration: BoxDecoration(),
                          child: Icon(
                            Icons.minimize_outlined,
                            color: theme.primaryText,
                            size: 24.0,
                          ),
                        ),
                        Container(
                          width:
                              (MediaQuery.sizeOf(context).width - 20.0) * 0.2,
                          decoration: BoxDecoration(),
                          child: Icon(
                            Icons.check,
                            color: theme.primary,
                            size: 24.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width:
                              (MediaQuery.sizeOf(context).width - 20.0) * 0.1,
                          decoration: BoxDecoration(),
                          child: Icon(
                            Icons.request_page,
                            color: theme.primaryText,
                            size: 24.0,
                          ),
                        ),
                        Container(
                          width:
                              (MediaQuery.sizeOf(context).width - 20.0) * 0.5,
                          decoration: BoxDecoration(),
                          child: Text(
                            FFLocalizations.of(context).getText(
                              'jekwx2fb' /* Resultats lotteries */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ),
                        Container(
                          width:
                              (MediaQuery.sizeOf(context).width - 20.0) * 0.2,
                          decoration: BoxDecoration(),
                          child: Icon(
                            Icons.minimize_outlined,
                            color: theme.primaryText,
                            size: 24.0,
                          ),
                        ),
                        Container(
                          width:
                              (MediaQuery.sizeOf(context).width - 20.0) * 0.2,
                          decoration: BoxDecoration(),
                          child: Icon(
                            Icons.check,
                            color: theme.primary,
                            size: 24.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width:
                              (MediaQuery.sizeOf(context).width - 20.0) * 0.1,
                          decoration: BoxDecoration(),
                          child: Icon(
                            Icons.request_page,
                            color: theme.primaryText,
                            size: 24.0,
                          ),
                        ),
                        Container(
                          width:
                              (MediaQuery.sizeOf(context).width - 20.0) * 0.5,
                          decoration: BoxDecoration(),
                          child: Text(
                            FFLocalizations.of(context).getText(
                              'j59fr62k' /* Resultats lotteries */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ),
                        Container(
                          width:
                              (MediaQuery.sizeOf(context).width - 20.0) * 0.2,
                          decoration: BoxDecoration(),
                          child: Icon(
                            Icons.minimize_outlined,
                            color: theme.primaryText,
                            size: 24.0,
                          ),
                        ),
                        Container(
                          width:
                              (MediaQuery.sizeOf(context).width - 20.0) * 0.2,
                          decoration: BoxDecoration(),
                          child: Icon(
                            Icons.check,
                            color: theme.primary,
                            size: 24.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width:
                              (MediaQuery.sizeOf(context).width - 20.0) * 0.1,
                          decoration: BoxDecoration(),
                          child: Icon(
                            Icons.request_page,
                            color: theme.primaryText,
                            size: 24.0,
                          ),
                        ),
                        Container(
                          width:
                              (MediaQuery.sizeOf(context).width - 20.0) * 0.5,
                          decoration: BoxDecoration(),
                          child: Text(
                            FFLocalizations.of(context).getText(
                              '96ad4c5w' /* Resultats lotteries */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ),
                        Container(
                          width:
                              (MediaQuery.sizeOf(context).width - 20.0) * 0.2,
                          decoration: BoxDecoration(),
                          child: Icon(
                            Icons.minimize_outlined,
                            color: theme.primaryText,
                            size: 24.0,
                          ),
                        ),
                        Container(
                          width:
                              (MediaQuery.sizeOf(context).width - 20.0) * 0.2,
                          decoration: BoxDecoration(),
                          child: Icon(
                            Icons.check,
                            color: theme.primary,
                            size: 24.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 10.0, 0.0),
                    child: Card(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      color: theme.primaryBackground,
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(tokens.radius.md),
                        side: BorderSide(
                            color: theme.primary.withValues(alpha: 0.35)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    FFLocalizations.of(context).getText(
                                      'bl4kupme' /* 1 Mois */,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontSize: 20.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                  Text(
                                    FFLocalizations.of(context).getText(
                                      'r11k1q8q' /* USD $ 40.00 ou GDS 2,000.00 */,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontSize: 17.0,
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
                                  ),
                                ].divide(SizedBox(height: 8.0)),
                              ),
                            ),
                            Tooltip(
                              message: supportText(context, 'open'),
                              child: FlutterFlowIconButton(
                                key: const ValueKey(
                                    'open-subscription-support-legacy'),
                                borderRadius: FlutterFlowTheme.of(context)
                                    .designToken
                                    .radius
                                    .full,
                                buttonSize: 48.0,
                                fillColor: FlutterFlowTheme.of(context).primary,
                                icon: Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: FlutterFlowTheme.of(context).onPrimary,
                                  size: 23.0,
                                ),
                                onPressed: () => context.pushNamed(
                                  CustomerserviceWidget.routeName,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ].divide(SizedBox(height: 8.0)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: FFButtonWidget(
              onPressed: () async {
                logFirebaseEvent('DEVENIR_V_I_P_DEVENIR_V_I_P_BTN_ON_TAP');
                logFirebaseEvent('Button_bottom_sheet');
                await showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  useSafeArea: true,
                  context: context,
                  builder: (context) {
                    return WebViewAware(
                      child: Padding(
                        padding: MediaQuery.viewInsetsOf(context),
                        child: WebWidget(),
                      ),
                    );
                  },
                ).then((value) => safeSetState(() {}));
              },
              text: FFLocalizations.of(context).getText(
                'i0zhxntw' /* Devenir VIP */,
              ),
              icon: Icon(
                Icons.workspace_premium,
                size: 25.0,
              ),
              options: FFButtonOptions(
                width: double.infinity,
                height: 55.0,
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                color: theme.primary,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily: 'Google sans flex',
                      color: theme.onPrimary,
                      fontSize: 20.0,
                      letterSpacing: 0.0,
                    ),
                elevation: 0.0,
                borderRadius: BorderRadius.circular(tokens.radius.md),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
