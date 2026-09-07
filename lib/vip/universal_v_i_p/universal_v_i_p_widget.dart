import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math';
import 'dart:ui';
import 'package:styled_divider/styled_divider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'universal_v_i_p_model.dart';
export 'universal_v_i_p_model.dart';

class UniversalVIPWidget extends StatefulWidget {
  const UniversalVIPWidget({
    super.key,
    this.chiffre,
    required this.name,
    this.autre,
    this.ref,
    this.icon,
  });

  final List<String>? chiffre;
  final String? name;
  final String? autre;
  final DocumentReference? ref;
  final Widget? icon;

  @override
  State<UniversalVIPWidget> createState() => _UniversalVIPWidgetState();
}

class _UniversalVIPWidgetState extends State<UniversalVIPWidget>
    with TickerProviderStateMixin {
  late UniversalVIPModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UniversalVIPModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('UNIVERSAL_V_I_P_universalVIP_ON_INIT_STA');
    });

    animationsMap.addAll({
      'iconOnPageLoadAnimation': AnimationInfo(
        loop: true,
        reverse: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          RotateEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 1100.0.ms,
            begin: -0.06,
            end: 0.06,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 1100.0.ms,
            begin: Offset(0.85, 0.85),
            end: Offset(1.0, 1.0),
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 1100.0.ms,
            begin: Offset(0.0, 0.1),
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
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: FlutterFlowTheme.of(context).secondaryBackground,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: theme.primary.withValues(alpha: 0.22)),
      ),
      child: Container(
        height: 170.0,
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                  tokens.spacing.sm, tokens.spacing.xs, tokens.spacing.sm, 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  widget!.icon!,
                  Align(
                    alignment: AlignmentDirectional(-1.0, 1.0),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(tokens.spacing.xs,
                          tokens.spacing.xs, 0.0, tokens.spacing.xs),
                      child: Text(
                        valueOrDefault<String>(
                          widget!.name,
                          'null',
                        ),
                        style: theme.titleSmall.override(
                          color: theme.primaryText,
                          fontSize: 15.0,
                          letterSpacing: 0.4,
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            StyledDivider(
              height: 8.0,
              thickness: 1.0,
              color: theme.primary.withValues(alpha: 0.20),
              lineStyle: DividerLineStyle.solid,
            ),
            Flexible(
              child: Align(
                alignment: AlignmentDirectional(0.0, 0.0),
                child: Padding(
                  padding: EdgeInsets.all(tokens.spacing.sm),
                  child: Material(
                    color: Colors.transparent,
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(tokens.radius.sm),
                    ),
                    child: Container(
                      height: 200.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(tokens.radius.sm),
                      ),
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Builder(
                        builder: (context) {
                          final chiffress = (widget!.chiffre?.toList() ?? [])
                              .take(2)
                              .toList();

                          return Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(chiffress.length,
                                (chiffressIndex) {
                              final chiffressItem = chiffress[chiffressIndex];
                              return Container(
                                decoration: BoxDecoration(
                                  color: theme.primaryBackground,
                                  borderRadius:
                                      BorderRadius.circular(tokens.radius.md),
                                  border: Border.all(
                                    color:
                                        theme.primary.withValues(alpha: 0.20),
                                    width: 1.0,
                                  ),
                                ),
                                child: Builder(
                                  builder: (context) {
                                    if (widget!.name == 'FAVORI') {
                                      return Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Padding(
                                          padding:
                                              EdgeInsets.all(tokens.spacing.xs),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              if (chiffressItem != null &&
                                                  chiffressItem != '')
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: AutoSizeText(
                                                    chiffressItem,
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    minFontSize: 25.0,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          color:
                                                              theme.primaryText,
                                                          fontSize: 32.0,
                                                          lineHeight: 1.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                    overflow: TextOverflow.fade,
                                                  ),
                                                ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(
                                                      tokens.spacing.xs),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    1.5,
                                                                    0.0),
                                                        child: FaIcon(
                                                          FontAwesomeIcons.fire,
                                                          color:
                                                              theme.primaryText,
                                                          size: 15.0,
                                                        ).animateOnPageLoad(
                                                            animationsMap[
                                                                'iconOnPageLoadAnimation']!),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(4.0),
                                                        child: Text(
                                                          FFLocalizations.of(
                                                                  context)
                                                              .getText(
                                                            'xm4yj0vd' /* FLO-NY */,
                                                          ),
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                color: theme
                                                                    .primaryText,
                                                                fontSize: 11.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else if (widget!.name == 'SOUTNI') {
                                      return Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Padding(
                                          padding:
                                              EdgeInsets.all(tokens.spacing.xs),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              if (chiffressItem != null &&
                                                  chiffressItem != '')
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: AutoSizeText(
                                                    chiffressItem,
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    minFontSize: 25.0,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontSize: 32.0,
                                                          lineHeight: 1.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                    overflow: TextOverflow.fade,
                                                  ),
                                                ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(
                                                      tokens.spacing.xs),
                                                  child: Text(
                                                    () {
                                                      if (chiffressIndex == 0) {
                                                        return 'GG-NY';
                                                      } else if (chiffressIndex ==
                                                          1) {
                                                        return 'FLO-NY';
                                                      } else {
                                                        return '-';
                                                      }
                                                    }(),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          color:
                                                              theme.primaryText,
                                                          fontSize: 11.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Visibility(
                                        visible: chiffressItem != null &&
                                            chiffressItem != '',
                                        child: Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                                tokens.spacing.xs),
                                            child: AutoSizeText(
                                              chiffressItem,
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              minFontSize: 25.0,
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontSize: 32.0,
                                                        lineHeight: 1.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                              overflow: TextOverflow.fade,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            }).divide(SizedBox(height: 8.0)),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
