import 'package:flutter/material.dart';

import '/autres/bingo/bingo_card_v_i_p/bingo_card_v_i_p_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/settings/devenir_v_i_p/devenir_v_i_p_widget.dart';
import 'vip_widget.dart' show VipWidget;

class VipModel extends FlutterFlowModel<VipWidget> {
  late BingoCardVIPModel bingoCardVIPModel;
  late DevenirVIPModel devenirVIPModel;

  @override
  void initState(BuildContext context) {
    bingoCardVIPModel = createModel(context, () => BingoCardVIPModel());
    devenirVIPModel = createModel(context, () => DevenirVIPModel());
  }

  @override
  void dispose() {
    bingoCardVIPModel.dispose();
    devenirVIPModel.dispose();
  }
}
