import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'fl_widget.dart' show FlWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FlModel extends FlutterFlowModel<FlWidget> {
  ///  Local state fields for this component.

  bool? aEffacer = true;

  ResultatsHomePageStruct? resultats;
  void updateResultatsStruct(Function(ResultatsHomePageStruct) updateFn) {
    updateFn(resultats ??= ResultatsHomePageStruct());
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
