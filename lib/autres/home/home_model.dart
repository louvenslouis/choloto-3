import '/auth/firebase_auth/auth_util.dart';
import '/autres/bingo/bingo/bingo_widget.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/components/rappel_fin_abonnement_widget.dart';
import '/components/tirages_home_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'home_widget.dart' show HomeWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class HomeModel extends FlutterFlowModel<HomeWidget> {
  ///  Local state fields for this page.

  BingoStruct? bingo;
  void updateBingoStruct(Function(BingoStruct) updateFn) {
    updateFn(bingo ??= BingoStruct());
  }

  DateTime? preex;

  bool rappelAbonnement = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Firestore Query - Query a collection] action in Home widget.
  BingoRecord? bingooutput;
  // Stores action output result for [Firestore Query - Query a collection] action in Home widget.
  SettingsRecord? beta;
  // Model for rappelFinAbonnement component.
  late RappelFinAbonnementModel rappelFinAbonnementModel;
  // Model for tiragesHome component.
  late TiragesHomeModel tiragesHomeModel;

  @override
  void initState(BuildContext context) {
    rappelFinAbonnementModel =
        createModel(context, () => RappelFinAbonnementModel());
    tiragesHomeModel = createModel(context, () => TiragesHomeModel());
  }

  @override
  void dispose() {
    rappelFinAbonnementModel.dispose();
    tiragesHomeModel.dispose();
  }
}
