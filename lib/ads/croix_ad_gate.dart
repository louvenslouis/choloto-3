import 'dart:async';

import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/croix/croix_page_layout.dart';
import 'draw_ad_eligibility.dart';

typedef PrepareCroixAd = VoidCallback Function(
    void Function(VoidCallback show) ready, void Function(bool open) done);

class CroixAdGate extends StatefulWidget {
  const CroixAdGate({
    super.key,
    required this.accounts,
    required this.prepare,
    required this.child,
  });

  final Stream<DrawAdAccount> Function() accounts;
  final PrepareCroixAd prepare;
  final Widget child;

  @override
  State<CroixAdGate> createState() => _CroixAdGateState();
}

class _CroixAdGateState extends State<CroixAdGate> {
  late final StreamSubscription<DrawAdAccount> _subscription;
  Timer? _profileTimeout;
  VoidCallback? _cancel;
  VoidCallback? _show;
  String? _uid;
  bool _opened = false;

  @override
  void initState() {
    super.initState();
    _profileTimeout = Timer(const Duration(seconds: 3), _open);
    _subscription = widget
        .accounts()
        .listen(_accountChanged, onError: (Object _) => _open());
  }

  void _accountChanged(DrawAdAccount account) {
    if (_opened) return;
    if (account.checking && _uid == null) return;
    _profileTimeout?.cancel();
    final uid = account.freeUid;
    if (uid == null || (_uid != null && _uid != uid)) {
      _open();
    } else if (_uid == null) {
      _uid = uid;
      try {
        _cancel = widget.prepare((show) {
          if (mounted && !_opened) setState(() => _show = show);
        }, (open) {
          if (!mounted || _opened) return;
          if (open) {
            _open();
          } else {
            context.safePop();
          }
        });
      } catch (_) {
        _open();
      }
    }
  }

  void _open() {
    if (!mounted || _opened) return;
    setState(() => _opened = true);
    _profileTimeout?.cancel();
    _cancel?.call();
  }

  @override
  void dispose() {
    _profileTimeout?.cancel();
    _subscription.cancel();
    _cancel?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_opened) return widget.child;
    final theme = FlutterFlowTheme.of(context);
    final token = theme.designToken;
    final strings = FFLocalizations.of(context);
    final show = _show;
    return CroixPageLayout(
      child: CroixStatusCard(
        child: show == null
            ? null
            : FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: theme.onPrimary,
                  foregroundColor: theme.primary,
                  minimumSize: const Size(48, 48),
                  padding: EdgeInsets.symmetric(
                      horizontal: token.spacing.md, vertical: token.spacing.sm),
                  textStyle: theme.titleSmall,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(token.radius.md)),
                ),
                onPressed: () {
                  if (_show == null) return;
                  setState(() => _show = null);
                  show();
                },
                child: Text(
                  strings.getVariableText(
                    frText: 'Voir une pub pour ouvrir la Croix',
                    enText: 'Watch an ad to open the Lucky Cross',
                    crText: 'Gade yon piblisite pou ouvri Kwa Lachans',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
      ),
    );
  }
}
