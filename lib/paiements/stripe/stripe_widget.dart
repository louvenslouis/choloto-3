import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'stripe_model.dart';
export 'stripe_model.dart';

/// Stripe paiment page, to pay a subscription with Card or Paypall
class StripeWidget extends StatefulWidget {
  const StripeWidget({super.key});

  static String routeName = 'Stripe';
  static String routePath = '/stripe';

  @override
  State<StripeWidget> createState() => _StripeWidgetState();
}

class _StripeWidgetState extends State<StripeWidget> {
  late StripeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StripeModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Stripe'});
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
      ),
    );
  }
}
