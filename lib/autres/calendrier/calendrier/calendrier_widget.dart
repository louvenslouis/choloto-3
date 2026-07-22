import '/autres/calendrier/jour/jour_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'calendrier_model.dart';
export 'calendrier_model.dart';

class CalendrierWidget extends StatefulWidget {
  const CalendrierWidget({super.key});

  @override
  State<CalendrierWidget> createState() => _CalendrierWidgetState();
}

class _CalendrierWidgetState extends State<CalendrierWidget> {
  late CalendrierModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CalendrierModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(2.0),
      child: GridView(
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          crossAxisSpacing: 2.0,
          mainAxisSpacing: 2.0,
          childAspectRatio: 1.0,
        ),
        scrollDirection: Axis.vertical,
        children: [
          wrapWithModel(
            model: _model.jourModel1,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel2,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel3,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel4,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel5,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel6,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel7,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel8,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel9,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel10,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel11,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel12,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel13,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel14,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel15,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel16,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel17,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel18,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel19,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel20,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel21,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel22,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel23,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel24,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel25,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel26,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel27,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
          wrapWithModel(
            model: _model.jourModel28,
            updateCallback: () => safeSetState(() {}),
            child: JourWidget(),
          ),
        ],
      ),
    );
  }
}
