import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'chiffres_model.dart';
export 'chiffres_model.dart';

class ChiffresWidget extends StatefulWidget {
  const ChiffresWidget({
    super.key,
    this.chiffre,
  });

  final int? chiffre;

  @override
  State<ChiffresWidget> createState() => _ChiffresWidgetState();
}

class _ChiffresWidgetState extends State<ChiffresWidget> {
  late ChiffresModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChiffresModel());

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
      width: 50.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primary,
        shape: BoxShape.circle,
      ),
      child: Align(
        alignment: AlignmentDirectional(0.0, 0.0),
        child: AnimatedDefaultTextStyle(
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                ),
                letterSpacing: 0.0,
                fontWeight: FontWeight.bold,
                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              ),
          duration: Duration(milliseconds: 600),
          curve: Curves.easeIn,
          child: Text(
            valueOrDefault<String>(
              widget!.chiffre?.toString(),
              '00',
            ),
          ),
        ),
      ),
    );
  }
}
