import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'support_text.dart';

class SupportGuestGate extends StatelessWidget {
  const SupportGuestGate({
    super.key,
    required this.onStart,
    required this.starting,
  });

  final Future<void> Function() onStart;
  final bool starting;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.spacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560.0),
          child: Container(
            key: const ValueKey('support-guest-gate'),
            padding: EdgeInsets.all(tokens.spacing.lg),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(tokens.radius.md),
              border: Border.all(
                color: theme.primary.withValues(alpha: 0.35),
              ),
              boxShadow: [tokens.shadow.sm],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56.0,
                  height: 56.0,
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(tokens.radius.full),
                  ),
                  child: Icon(
                    Icons.support_agent_rounded,
                    color: theme.primary,
                    size: 28.0,
                  ),
                ),
                SizedBox(height: tokens.spacing.md),
                Text(
                  supportText(context, 'guestStartTitle'),
                  textAlign: TextAlign.center,
                  style: theme.titleLarge,
                ),
                SizedBox(height: tokens.spacing.sm),
                Text(
                  supportText(context, 'guestStartBody'),
                  textAlign: TextAlign.center,
                  style: theme.bodyMedium.override(color: theme.secondaryText),
                ),
                SizedBox(height: tokens.spacing.lg),
                FFButtonWidget(
                  key: const ValueKey('support-start-guest-button'),
                  onPressed: starting ? null : onStart,
                  text: supportText(
                    context,
                    starting ? 'guestStarting' : 'guestStartAction',
                  ),
                  icon: Icon(
                    starting
                        ? Icons.hourglass_top_rounded
                        : Icons.forum_rounded,
                    color: theme.onPrimary,
                  ),
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 52.0,
                    padding: EdgeInsets.zero,
                    color: theme.primary,
                    disabledColor: theme.primary.withValues(alpha: 0.45),
                    textStyle: theme.titleSmall.copyWith(
                      color: theme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    elevation: 0.0,
                    borderRadius: BorderRadius.circular(tokens.radius.full),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
