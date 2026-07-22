import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/settings/devenir_v_i_p/devenir_v_i_p_widget.dart';
import 'upgrade_widget.dart' show UpgradeWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class UpgradeModel extends FlutterFlowModel<UpgradeWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for devenirVIP component.
  late DevenirVIPModel devenirVIPModel;

  @override
  void initState(BuildContext context) {
    devenirVIPModel = createModel(context, () => DevenirVIPModel());
  }

  @override
  void dispose() {
    devenirVIPModel.dispose();
  }
}
