import '/components/welcome_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'authentification_widget.dart' show AuthentificationWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AuthentificationModel extends FlutterFlowModel<AuthentificationWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Welcome component.
  late WelcomeModel welcomeModel;

  @override
  void initState(BuildContext context) {
    welcomeModel = createModel(context, () => WelcomeModel());
  }

  @override
  void dispose() {
    welcomeModel.dispose();
  }
}
