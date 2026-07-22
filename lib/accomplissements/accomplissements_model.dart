import '/auth/firebase_auth/auth_util.dart';
import '/autres/calendrier/calendrier/calendrier_widget.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'accomplissements_widget.dart' show AccomplissementsWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AccomplissementsModel extends FlutterFlowModel<AccomplissementsWidget> {
  ///  Local state fields for this page.

  int? secondes;

  int? secondesAdd;

  DateTime? expiration;

  ///  State fields for stateful widgets in this page.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // Model for calendrier component.
  late CalendrierModel calendrierModel;

  @override
  void initState(BuildContext context) {
    calendrierModel = createModel(context, () => CalendrierModel());
  }

  @override
  void dispose() {
    tabBarController?.dispose();
    calendrierModel.dispose();
  }
}
