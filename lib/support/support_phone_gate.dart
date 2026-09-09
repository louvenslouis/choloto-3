import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'support_text.dart';

class SupportPhoneGate extends StatelessWidget {
  const SupportPhoneGate({super.key, required this.onAddPhone});

  final Future<void> Function() onAddPhone;

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
            key: const ValueKey('support-phone-gate'),
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
                    Icons.phone_outlined,
                    color: theme.primary,
                    size: 28.0,
                  ),
                ),
                SizedBox(height: tokens.spacing.md),
                Text(
                  supportText(context, 'phoneRequiredTitle'),
                  textAlign: TextAlign.center,
                  style: theme.titleLarge,
                ),
                SizedBox(height: tokens.spacing.sm),
                Text(
                  supportText(context, 'phoneRequiredBody'),
                  textAlign: TextAlign.center,
                  style: theme.bodyMedium.override(color: theme.secondaryText),
                ),
                SizedBox(height: tokens.spacing.lg),
                FFButtonWidget(
                  key: const ValueKey('support-add-phone-button'),
                  onPressed: onAddPhone,
                  text: supportText(context, 'phoneRequiredAction'),
                  icon: Icon(Icons.add_call, color: theme.onPrimary),
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 52.0,
                    padding: EdgeInsets.zero,
                    color: theme.primary,
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
