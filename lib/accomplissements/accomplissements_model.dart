import '/autres/calendrier/calendrier/calendrier_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'accomplissements_widget.dart' show AccomplissementsWidget;
import 'package:flutter/material.dart';

class AccomplissementsModel extends FlutterFlowModel<AccomplissementsWidget> {
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
