import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import 'support_text.dart';

class SubscriptionSupportCard extends StatelessWidget {
  const SubscriptionSupportCard({super.key, required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    return Container(
      key: const ValueKey('subscription-support-card'),
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: tokens.home.panel,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tokens.home.surface.colors.last,
              borderRadius: BorderRadius.circular(tokens.radius.md),
            ),
            child: Icon(Icons.support_agent_rounded,
                color: tokens.home.mutedText, size: 26),
          ),
          SizedBox(width: tokens.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(supportText(context, 'subscriptionTitle'),
                    style: theme.titleMedium),
                SizedBox(height: tokens.spacing.xs),
                Text(
                  supportText(context, 'subscriptionBody'),
                  style:
                      theme.bodyMedium.override(color: tokens.home.mutedText),
                ),
                SizedBox(height: tokens.spacing.sm),
                TextButton.icon(
                  key: const ValueKey('open-subscription-support'),
                  onPressed: onOpen,
                  style: TextButton.styleFrom(
                    foregroundColor: theme.primary,
                    textStyle: theme.labelLarge,
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spacing.sm,
                      vertical: tokens.spacing.sm,
                    ),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  label: Text(supportText(context, 'open')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
