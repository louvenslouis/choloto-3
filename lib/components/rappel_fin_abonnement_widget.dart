import 'vip_membership_medal.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';

const subscriptionExpirationReminderWindow = Duration(days: 2);

bool shouldShowSubscriptionExpirationReminder({
  required DateTime? expiration,
  required DateTime now,
}) {
  if (expiration == null || !expiration.isAfter(now)) {
    return false;
  }

  return !expiration.isAfter(now.add(subscriptionExpirationReminderWindow));
}

bool isSubscriptionExpired({
  required DateTime? expiration,
  required DateTime now,
}) =>
    expiration != null && !expiration.isAfter(now);

class RappelFinAbonnementWidget extends StatelessWidget {
  const RappelFinAbonnementWidget({
    super.key,
    required this.expiration,
    required this.onRenew,
    required this.onDismiss,
  });

  final DateTime expiration;
  final VoidCallback onRenew;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final spacing = tokens.spacing;
    final radius = tokens.radius;
    final localizations = FFLocalizations.of(context);
    final formattedExpiration = dateTimeFormat(
      'yMMMd',
      expiration,
      locale: localizations.languageCode,
    );

    return Material(
      key: const ValueKey('subscription-expiration-reminder'),
      type: MaterialType.transparency,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420.0),
        child: Ink(
          decoration: tokens.vip.pass,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(spacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const VipMembershipMedal(size: 56),
                      Tooltip(
                        message: localizations.getText(
                          'subscription_expiration_reminder_close',
                        ),
                        child: FlutterFlowIconButton(
                          key: const ValueKey('subscription-reminder-close'),
                          buttonSize: 48.0,
                          borderRadius: radius.full,
                          icon: Icon(
                            Icons.close_rounded,
                            color: tokens.home.mutedText,
                            size: 24.0,
                          ),
                          onPressed: onDismiss,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing.md),
                  Text(
                    localizations
                        .getText('subscription_expiration_reminder_title'),
                    style: tokens.vip.typography.heading(24),
                  ),
                  SizedBox(height: spacing.md),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.md,
                      vertical: spacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.vip.illustrationInk.withValues(alpha: .65),
                      borderRadius: BorderRadius.circular(radius.sm),
                    ),
                    child: Text(
                      '${localizations.getText('subscription_expiration_reminder_date')} '
                      '$formattedExpiration',
                      style: theme.labelLarge.override(
                        color: theme.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: spacing.md),
                  Text(
                    localizations.getText(
                      'subscription_expiration_reminder_message',
                    ),
                    style: theme.bodyMedium,
                  ),
                  SizedBox(height: spacing.lg),
                  FFButtonWidget(
                    key: const ValueKey('subscription-reminder-renew'),
                    onPressed: onRenew,
                    text: localizations.getText(
                      'subscription_expiration_reminder_renew',
                    ),
                    icon: Icon(
                      Icons.workspace_premium_outlined,
                      color: theme.onPrimary,
                      size: 20.0,
                    ),
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 48.0,
                      color: theme.primary,
                      textStyle: theme.titleSmall.override(
                        color: theme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(radius.full),
                    ),
                  ),
                  SizedBox(height: spacing.xs),
                  TextButton(
                    key: const ValueKey('subscription-reminder-later'),
                    onPressed: onDismiss,
                    style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(48.0),
                      foregroundColor: tokens.home.mutedText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(radius.sm),
                      ),
                    ),
                    child: Text(
                      localizations.getText(
                        'subscription_expiration_reminder_later',
                      ),
                      style: theme.labelLarge.override(
                        color: tokens.home.mutedText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ExpiredSubscriptionCard extends StatelessWidget {
  const ExpiredSubscriptionCard({
    super.key,
    required this.onRenew,
  });

  final VoidCallback onRenew;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final spacing = tokens.spacing;
    final localizations = FFLocalizations.of(context);
    final radius = BorderRadius.circular(tokens.radius.md);

    return DecoratedBox(
      key: const ValueKey('expired-subscription-card'),
      decoration: tokens.home.panel,
      child: Material(
        type: MaterialType.transparency,
        child: Semantics(
          button: true,
          child: InkWell(
            key: const ValueKey('expired-subscription-renew'),
            onTap: onRenew,
            borderRadius: radius,
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(minHeight: kMinInteractiveDimension),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.md,
                  vertical: spacing.sm,
                ),
                child: Row(
                  children: [
                    const VipMembershipMedal(size: 28),
                    SizedBox(width: spacing.sm),
                    Expanded(
                      child: OverflowBar(
                        alignment: MainAxisAlignment.spaceBetween,
                        overflowAlignment: OverflowBarAlignment.start,
                        spacing: spacing.md,
                        overflowSpacing: spacing.xs,
                        children: [
                          Text(
                            localizations
                                .getText('subscription_expired_card_title'),
                            style: theme.titleSmall,
                          ),
                          Text(
                            localizations
                                .getText('subscription_expired_card_renew'),
                            style: theme.labelLarge.copyWith(
                              color: tokens.vip.goldLight,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: spacing.sm),
                    Icon(Icons.chevron_right_rounded,
                        color: tokens.vip.goldLight),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
