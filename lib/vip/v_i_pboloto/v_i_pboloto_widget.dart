import '/components/vip_casino_card.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'v_i_pboloto_model.dart';
export 'v_i_pboloto_model.dart';

class VIPbolotoWidget extends StatefulWidget {
  const VIPbolotoWidget({
    super.key,
    this.chiffre,
    required this.name,
    this.autre,
    this.ref,
  });

  final List<String>? chiffre;
  final String? name;
  final String? autre;
  final DocumentReference? ref;

  @override
  State<VIPbolotoWidget> createState() => _VIPbolotoWidgetState();
}

class _VIPbolotoWidgetState extends State<VIPbolotoWidget> {
  late VIPbolotoModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VIPbolotoModel());

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

    return VipCasinoCard(
      child: Container(
        height: 170.0,
        decoration: BoxDecoration(),
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
                  FaIcon(
                    FontAwesomeIcons.bowlingBall,
                    color: FlutterFlowTheme.of(context).primary,
                    size: 24.0,
                  ),
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
                          fontWeight: FontWeight.w700,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: tokens.spacing.sm,
              child: Center(
                  child: Container(
                height: 1,
                decoration: BoxDecoration(gradient: tokens.vip.gold),
              )),
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
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(tokens.radius.sm),
                      ),
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Builder(
                        builder: (context) {
                          final bouls = widget!.chiffre?.toList() ?? [];

                          return Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(bouls.length, (boulsIndex) {
                              final boulsItem = bouls[boulsIndex];
                              return Visibility(
                                visible: boulsItem != null && boulsItem != '',
                                child: Container(
                                  width: 50.0,
                                  height: 50.0,
                                  child: VipCasinoChip(
                                      child: Visibility(
                                    visible:
                                        boulsItem != null && boulsItem != '',
                                    child: Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Padding(
                                        padding: EdgeInsets.all(1.0),
                                        child: AutoSizeText(
                                          boulsItem,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          minFontSize: 25.0,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                color: theme.onPrimary,
                                                fontSize: 32.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w900,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                          overflow: TextOverflow.fade,
                                        ),
                                      ),
                                    ),
                                  )),
                                ),
                              );
                            }),
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
