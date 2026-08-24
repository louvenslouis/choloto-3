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
    final spacing = theme.designToken.spacing;
    final radius = theme.designToken.radius;
    final localizations = FFLocalizations.of(context);
    final formattedExpiration = dateTimeFormat(
      'yMMMd',
      expiration,
      locale: localizations.languageCode,
    );

    return Material(
      key: const ValueKey('subscription-expiration-reminder'),
      color: theme.secondaryBackground,
      borderRadius: BorderRadius.circular(radius.md),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(spacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48.0,
                      height: 48.0,
                      decoration: BoxDecoration(
                        color: theme.primary,
                        borderRadius: BorderRadius.circular(radius.full),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.notifications_active_outlined,
                        color: theme.onPrimary,
                        size: 24.0,
                      ),
                    ),
                    SizedBox(width: spacing.md),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: spacing.xs),
                        child: Text(
                          localizations.getText(
                            'subscription_expiration_reminder_title',
                          ),
                          style: theme.titleLarge,
                        ),
                      ),
                    ),
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
                          color: theme.secondaryText,
                          size: 24.0,
                        ),
                        onPressed: onDismiss,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing.md),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.md,
                    vertical: spacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: theme.accent1,
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
                    borderRadius: BorderRadius.circular(radius.sm),
                  ),
                ),
                SizedBox(height: spacing.xs),
                TextButton(
                  key: const ValueKey('subscription-reminder-later'),
                  onPressed: onDismiss,
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(48.0),
                    foregroundColor: theme.secondaryText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radius.sm),
                    ),
                  ),
                  child: Text(
                    localizations.getText(
                      'subscription_expiration_reminder_later',
                    ),
                    style: theme.labelLarge.override(
                      color: theme.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
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
