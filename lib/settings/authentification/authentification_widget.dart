import '/components/welcome_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'authentification_model.dart';
export 'authentification_model.dart';

class AuthentificationWidget extends StatefulWidget {
  const AuthentificationWidget({super.key});

  static String routeName = 'Authentification';
  static String routePath = '/authentification';

  @override
  State<AuthentificationWidget> createState() => _AuthentificationWidgetState();
}

class _AuthentificationWidgetState extends State<AuthentificationWidget> {
  late AuthentificationModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AuthentificationModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'Authentification'});
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
            model: _model.welcomeModel,
            updateCallback: () => safeSetState(() {}),
            child: WelcomeWidget(),
          ),
        ),
      ),
    );
  }
}
