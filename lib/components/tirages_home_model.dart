import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/tirages/fl/fl_widget.dart';
import '/tirages/new_yorkk/new_yorkk_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'tirages_home_widget.dart' show TiragesHomeWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TiragesHomeModel extends FlutterFlowModel<TiragesHomeWidget> {
  ///  Local state fields for this component.

  bool refresh = false;

  ///  State fields for stateful widgets in this component.

  // State field(s) for Carousel widget.
  CarouselSliderController? carouselController;
  int carouselCurrentIndex = 0;

  // Model for newYorkk component.
  late NewYorkkModel newYorkkModel;
  // Model for FL component.
  late FlModel flModel;

  @override
  void initState(BuildContext context) {
    newYorkkModel = createModel(context, () => NewYorkkModel());
    flModel = createModel(context, () => FlModel());
  }

  @override
  void dispose() {
    newYorkkModel.dispose();
    flModel.dispose();
  }
}
