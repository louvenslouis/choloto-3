import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import '/flutter_flow/flutter_flow_model.dart';
import 'stackbingo_widget.dart' show StackbingoWidget;

class StackbingoModel extends FlutterFlowModel<StackbingoWidget> {
  late final CardSwiperController swipeableStackController;

  @override
  void initState(BuildContext context) {
    swipeableStackController = CardSwiperController();
  }

  @override
  void dispose() => swipeableStackController.dispose();
}
