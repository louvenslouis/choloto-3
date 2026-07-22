import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/settings/devenir_v_i_p/devenir_v_i_p_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'upgrade_model.dart';
export 'upgrade_model.dart';

class UpgradeWidget extends StatefulWidget {
  const UpgradeWidget({super.key});

  static String routeName = 'upgrade';
  static String routePath = '/upgrade';

  @override
  State<UpgradeWidget> createState() => _UpgradeWidgetState();
}

class _UpgradeWidgetState extends State<UpgradeWidget> {
  late UpgradeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UpgradeModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'upgrade'});
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: wrapWithModel(
            model: _model.devenirVIPModel,
            updateCallback: () => safeSetState(() {}),
            child: DevenirVIPWidget(),
          ),
        ),
      ),
    );
  }
}
