import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'rappel_fin_abonnement_model.dart';
export 'rappel_fin_abonnement_model.dart';

class RappelFinAbonnementWidget extends StatefulWidget {
  const RappelFinAbonnementWidget({
    super.key,
    this.test2,
  });

  final Color? test2;

  @override
  State<RappelFinAbonnementWidget> createState() =>
      _RappelFinAbonnementWidgetState();
}

class _RappelFinAbonnementWidgetState extends State<RappelFinAbonnementWidget> {
  late RappelFinAbonnementModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RappelFinAbonnementModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('RAPPEL_FIN_ABONNEMENT_rappelFinAbonnemen');
      logFirebaseEvent('rappelFinAbonnement_update_component_sta');
      _model.link =
          'https://wa.me/50943560633?text=Bonswa.%20Mwen%20ta%20renmen%20renouvle%20plan%20VIP%20CHOLOTO%20mwen%20an.%0A%0AEMAIL%3A%20${currentUserEmail}%0AUSERNAME%3A%20${currentUserDisplayName}';
      safeSetState(() {});
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
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: FlutterFlowTheme.of(context).secondaryBackground,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: SafeArea(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.0),
          child: Container(
            height: 125.0,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 1.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(
                color: Color(0xFF8100FF),
                width: 3.0,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    FontAwesomeIcons.bell,
                    color: Color(0xFF8100FF),
                    size: 30.0,
                  ),
                  Flexible(
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 0.0, 0.0),
                      child: Container(
                        decoration: BoxDecoration(),
                        child: Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 15.0, 0.0),
                                child: Text(
                                  FFLocalizations.of(context).getText(
                                    '6wnv7a6z' /* Votre abonnement CHOLOTO VIP e... */,
                                  ),
                                  textAlign: TextAlign.start,
                                  maxLines: 4,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                              FFButtonWidget(
                                onPressed: () async {
                                  logFirebaseEvent(
                                      'RAPPEL_FIN_ABONNEMENT_CONTACTEZ_NOUS_BTN');
                                  logFirebaseEvent('Button_launch_u_r_l');
                                  await launchURL(_model.link!);
                                },
                                text: FFLocalizations.of(context).getText(
                                  'ppbj8s5f' /* Contactez-Nous */,
                                ),
                                icon: FaIcon(
                                  FontAwesomeIcons.whatsapp,
                                  size: 15.0,
                                ),
                                options: FFButtonOptions(
                                  height: 36.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: Color(0xFF8100FF),
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Google sans flex',
                                        color: Colors.white,
                                        fontSize: 12.0,
                                        letterSpacing: 0.0,
                                      ),
                                  elevation: 0.0,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ].divide(SizedBox(height: 10.0)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
