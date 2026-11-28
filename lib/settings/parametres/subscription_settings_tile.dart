import 'settings_tile.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) => SettingsTile(
        tileKey: const ValueKey('subscription-settings-menu'),
        icon: Icons.workspace_premium_outlined,
        title: FFLocalizations.of(context).getText('eywbwq85'),
        detail: expiration == null ? null : _statusText(context, expiration!),
        onTap: onTap,
      );
}
