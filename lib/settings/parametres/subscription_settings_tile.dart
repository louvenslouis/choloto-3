import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SubscriptionSettingsTile extends StatelessWidget {
  const SubscriptionSettingsTile({
    super.key,
    required this.expiration,
    required this.onTap,
  });

  final DateTime? expiration;
  final VoidCallback onTap;

  String _statusText(BuildContext context, DateTime expiration) {
    final localizations = FFLocalizations.of(context);
    if (expiration <= getCurrentTimestamp) {
      return localizations.getVariableText(
        frText: 'Votre abonnement est expiré',
        enText: 'Your subscription has expired',
        crText: 'Abònman ou ekspire',
      );
    }

    final formattedDate = dateTimeFormat(
      'yMMMd',
      expiration,
      locale: localizations.languageShortCode ?? localizations.languageCode,
    );
    return localizations.getVariableText(
      frText: 'Votre abonnement expire le $formattedDate',
      enText: 'Your subscription expires on $formattedDate',
      crText: 'Abònman ou ap ekspire $formattedDate',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Material(
      color: theme.secondaryBackground,
      borderRadius: BorderRadius.circular(theme.designToken.radius.sm),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        key: const ValueKey('subscription-settings-menu'),
        leading: FaIcon(FontAwesomeIcons.award, color: theme.alternate),
        title: Text(
          FFLocalizations.of(context).getText('eywbwq85'),
          style: theme.titleLarge,
        ),
        subtitle: expiration == null
            ? null
            : Text(
                _statusText(context, expiration!),
                style: theme.labelMedium.override(color: theme.primaryText),
              ),
        trailing: Icon(
          Icons.arrow_right_rounded,
          color: theme.primaryText,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: theme.designToken.spacing.md,
          vertical: theme.designToken.spacing.xs,
        ),
        onTap: onTap,
      ),
    );
  }
}
