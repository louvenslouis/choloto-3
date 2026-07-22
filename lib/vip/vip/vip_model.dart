import '/auth/firebase_auth/auth_util.dart';
import '/autres/bingo/bingo_card_v_i_p/bingo_card_v_i_p_widget.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/settings/devenir_v_i_p/devenir_v_i_p_widget.dart';
import '/vip/universal_v_i_p/universal_v_i_p_widget.dart';
import '/vip/v_i_pboloto/v_i_pboloto_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'vip_widget.dart' show VipWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class VipModel extends FlutterFlowModel<VipWidget> {
  ///  Local state fields for this page.

  List<int> bingos = [0, 0, 0];
  void addToBingos(int item) => bingos.add(item);
  void removeFromBingos(int item) => bingos.remove(item);
  void removeAtIndexFromBingos(int index) => bingos.removeAt(index);
  void insertAtIndexInBingos(int index, int item) => bingos.insert(index, item);
  void updateBingosAtIndex(int index, Function(int) updateFn) =>
      bingos[index] = updateFn(bingos[index]);

  bool overrideCache = false;

  bool? pourboireHide = false;

  ///  State fields for stateful widgets in this page.

  // Model for bingoCardVIP component.
  late BingoCardVIPModel bingoCardVIPModel;
  // Model for favori.
  late UniversalVIPModel favoriModel;
  // Model for soutni.
  late UniversalVIPModel soutniModel;
  // Model for VIPboloto component.
  late VIPbolotoModel vIPbolotoModel;
  // Model for mariage.
  late UniversalVIPModel mariageModel;
  // Model for chif3.
  late UniversalVIPModel chif3Model;
  // Model for chif4.
  late UniversalVIPModel chif4Model;
  // Model for extra.
  late UniversalVIPModel extraModel;
  // Model for devenirVIP component.
  late DevenirVIPModel devenirVIPModel;

  @override
  void initState(BuildContext context) {
    bingoCardVIPModel = createModel(context, () => BingoCardVIPModel());
    favoriModel = createModel(context, () => UniversalVIPModel());
    soutniModel = createModel(context, () => UniversalVIPModel());
    vIPbolotoModel = createModel(context, () => VIPbolotoModel());
    mariageModel = createModel(context, () => UniversalVIPModel());
    chif3Model = createModel(context, () => UniversalVIPModel());
    chif4Model = createModel(context, () => UniversalVIPModel());
    extraModel = createModel(context, () => UniversalVIPModel());
    devenirVIPModel = createModel(context, () => DevenirVIPModel());
  }

  @override
  void dispose() {
    bingoCardVIPModel.dispose();
    favoriModel.dispose();
    soutniModel.dispose();
    vIPbolotoModel.dispose();
    mariageModel.dispose();
    chif3Model.dispose();
    chif4Model.dispose();
    extraModel.dispose();
    devenirVIPModel.dispose();
  }
}
