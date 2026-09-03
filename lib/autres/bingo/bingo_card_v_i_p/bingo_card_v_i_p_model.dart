import '/autres/bingo/stackbingo/stackbingo_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'bingo_card_v_i_p_widget.dart' show BingoCardVIPWidget;
import 'package:flutter/material.dart';

class BingoCardVIPModel extends FlutterFlowModel<BingoCardVIPWidget> {
  ///  Local state fields for this component.

  bool minimise = false;

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
