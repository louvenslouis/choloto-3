import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/support/support_bot.dart';
import '/support/support_text.dart';
import 'payment_text.dart';
import 'payment_widgets.dart';

/// Shows only the payment methods currently enabled in the dashboard.
class VipPaymentOptions extends StatelessWidget {
  const VipPaymentOptions({
    super.key,
    required this.config,
    this.onContact,
  });

  final Stream<SupportBotConfig> config;
  final VoidCallback? onContact;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;
    return StreamBuilder<SupportBotConfig>(
      stream: config,
      builder: (context, snapshot) {
        if (!snapshot.hasData && !snapshot.hasError) {
          return Center(child: CircularProgressIndicator(color: theme.primary));
        }
        final methods = snapshot.data?.paymentMethods
                .where((method) => method.enabled)
                .toList(growable: false) ??
            const <SupportBotPayment>[];
        if (snapshot.hasError || methods.isEmpty) {
          return PaymentSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  supportText(context, 'botPaymentUnavailable'),
                  style: theme.bodyMedium.override(color: theme.secondaryText),
                ),
                if (onContact != null)
                  TextButton.icon(
                    onPressed: onContact,
                    icon:
                        Icon(Icons.support_agent_rounded, color: theme.primary),
                    label: Text(
                      supportText(context, 'botContact'),
                      style:
                          theme.labelLarge.override(color: theme.primaryText),
                    ),
                  ),
              ],
            ),
          );
        }
        return Column(
          key: const ValueKey('vip-payment-options'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(paymentText(context, 'method'), style: theme.titleLarge),
            SizedBox(height: spacing.md),
            for (final method in methods) ...[
              PaymentSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(method.name, style: theme.titleMedium),
                    SizedBox(height: spacing.sm),
                    Text(
                      '${supportText(context, 'botPaymentPrice')} : ${method.price}',
                      style: theme.bodyLarge,
                    ),
                    Text(
                      '${supportText(context, 'botPaymentDuration')} : ${method.months} ${supportText(context, 'botPaymentMonths')}',
                      style: theme.bodyMedium,
                    ),
                    SizedBox(height: spacing.sm),
                    SelectableText(
                      '${supportText(context, 'botPaymentAccount')} : ${method.account}',
                      style: theme.bodyMedium,
                    ),
                    SelectableText(
                      '${supportText(context, 'botPaymentRecipient')} : ${method.recipient}',
                      style: theme.bodyMedium,
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing.sm),
            ],
          ],
        );
      },
    );
  }
}
