import '/auth/base_auth_user_provider.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/autres/bingo/stackbingo/stackbingo_widget.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'bingo_card_v_i_p_widget.dart' show BingoCardVIPWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BingoCardVIPModel extends FlutterFlowModel<BingoCardVIPWidget> {
  ///  Local state fields for this component.

  bool minimise = false;

  ///  State fields for stateful widgets in this component.

  // Model for stackbingo component.
  late StackbingoModel stackbingoModel;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  BingostatsRecord? bingolikeyes;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  BingostatsRecord? bingolikeyesCopy;

  @override
  void initState(BuildContext context) {
    stackbingoModel = createModel(context, () => StackbingoModel());
  }

  @override
  void dispose() {
    stackbingoModel.dispose();
  }
}
