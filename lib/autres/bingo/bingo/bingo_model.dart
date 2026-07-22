import '/autres/bingo/stackbingo/stackbingo_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'bingo_widget.dart' show BingoWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class BingoModel extends FlutterFlowModel<BingoWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for stackbingo component.
  late StackbingoModel stackbingoModel;

  @override
  void initState(BuildContext context) {
    stackbingoModel = createModel(context, () => StackbingoModel());
  }

  @override
  void dispose() {
    stackbingoModel.dispose();
  }
}
