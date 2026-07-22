import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'bule_model.dart';
export 'bule_model.dart';

class BuleWidget extends StatefulWidget {
  const BuleWidget({
    super.key,
    this.type,
  });

  final String? type;

  @override
  State<BuleWidget> createState() => _BuleWidgetState();
}

class _BuleWidgetState extends State<BuleWidget> {
  late BuleModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BuleModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional(0.0, 1.0),
      children: [
        SafeArea(
          child: Container(
            width: 65.0,
            height: 65.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              shape: BoxShape.circle,
              border: Border.all(
                color: FlutterFlowTheme.of(context).primary,
                width: 5.0,
              ),
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Container(
            width: 48.0,
            height: 20.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary,
              borderRadius: BorderRadius.circular(6.0),
              border: Border.all(
                color: FlutterFlowTheme.of(context).primaryBackground,
                width: 2.0,
              ),
            ),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: AutoSizeText(
              () {
                if (widget!.type == StoryType.bingo.name) {
                  return 'BINGO';
                } else if (widget!.type == StoryType.youtube.name) {
                  return 'YTUBE';
                } else {
                  return '';
                }
              }(),
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    fontSize: 10.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
