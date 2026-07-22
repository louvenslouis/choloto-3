import '/backend/backend.dart';
import '/components/cross_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'croix_widget.dart' show CroixWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CroixModel extends FlutterFlowModel<CroixWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for cross component.
  late CrossModel crossModel;

  @override
  void initState(BuildContext context) {
    crossModel = createModel(context, () => CrossModel());
  }

  @override
  void dispose() {
    crossModel.dispose();
  }
}
