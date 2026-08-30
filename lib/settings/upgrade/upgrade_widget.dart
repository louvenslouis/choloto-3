import '/auth/firebase_auth/auth_util.dart';
import '/components/web_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

import 'subscription_transaction.dart';
import 'subscription_transactions_panel.dart';
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
  final SubscriptionTransactionRepository _transactionsRepository =
      SubscriptionTransactionRepository();

  String? _transactionsUserUid;
  Stream<List<SubscriptionTransaction>>? _transactionsStream;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, UpgradeModel.new);

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'upgrade'});
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Stream<List<SubscriptionTransaction>> _streamForUser(String userUid) {
    if (_transactionsStream == null || _transactionsUserUid != userUid) {
      _transactionsUserUid = userUid;
      _transactionsStream = _transactionsRepository.watchForUser(userUid);
    }
    return _transactionsStream!;
  }

  Future<void> _openSubscriptionFlow() async {
    logFirebaseEvent('UPGRADE_SUBSCRIPTION_ACTION_ON_TAP');
    await showModalBottomSheet<void>(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      context: context,
      builder: (context) {
        return WebViewAware(
          child: Padding(
            padding: MediaQuery.viewInsetsOf(context),
            child: const WebWidget(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(
          backgroundColor: theme.primaryBackground,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderRadius: tokens.radius.sm,
            buttonSize: 40.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: theme.primaryText,
              size: 24.0,
            ),
            onPressed: context.safePop,
          ),
          title: Text(
            FFLocalizations.of(context).getText('eywbwq85'),
            style: theme.headlineMedium.override(
              fontFamily: 'Google sans flex',
              color: theme.primaryText,
              fontSize: 22.0,
              letterSpacing: 0.0,
            ),
          ),
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: false,
          child: AuthUserStreamWidget(
            builder: (context) {
              if (loggedIn && currentUserDocument == null) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(tokens.spacing.lg),
                    child: CircularProgressIndicator(color: theme.primary),
                  ),
                );
              }

              final stream = _streamForUser(currentUserUid);
              return StreamBuilder<List<SubscriptionTransaction>>(
                stream: stream,
                builder: (context, snapshot) {
                  final latestRecordedEnd = snapshot.hasData
                      ? latestRecordedSubscriptionEnd(snapshot.data!)
                      : null;
                  final latestTransactionIsCancellation = snapshot.hasData &&
                      latestSubscriptionTransactionIsCancellation(
                          snapshot.data!);
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760.0),
                      child: ListView(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          tokens.spacing.md,
                          tokens.spacing.sm,
                          tokens.spacing.md,
                          tokens.spacing.xl,
                        ),
                        children: [
                          SubscriptionTransactionsPanel(
                            transactions: snapshot.data ??
                                const <SubscriptionTransaction>[],
                            subscriptionEnd: effectiveSubscriptionEnd(
                              profileEnd: currentUserDocument?.endSub,
                              latestRecordedEnd: latestRecordedEnd,
                              latestTransactionIsCancellation:
                                  latestTransactionIsCancellation,
                            ),
                            loading: snapshot.connectionState ==
                                    ConnectionState.waiting &&
                                !snapshot.hasData,
                            loadFailed: snapshot.hasError,
                            onRenew: _openSubscriptionFlow,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
