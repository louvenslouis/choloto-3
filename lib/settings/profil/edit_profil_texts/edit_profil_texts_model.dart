import '/flutter_flow/flutter_flow_util.dart';
import 'edit_profil_texts_widget.dart' show EditProfilTextsWidget;
import 'package:flutter/material.dart';

class EditProfilTextsModel extends FlutterFlowModel<EditProfilTextsWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    emailTextController?.dispose();
  }
}
