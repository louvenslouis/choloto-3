import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    this.tileKey,
    required this.icon,
    required this.title,
    this.detail,
    required this.onTap,
    this.actionIcon = Icons.chevron_right_rounded,
  });

  final Key? tileKey;
  final IconData icon;
  final String title;
  final String? detail;
  final VoidCallback? onTap;
  final IconData actionIcon;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    return ListTile(
      key: tileKey,
      leading: Icon(icon, color: theme.primary),
      title: Text(title, style: theme.titleMedium),
      subtitle: detail == null
          ? null
          : Text(detail!,
              style: theme.bodyMedium.copyWith(color: tokens.home.mutedText)),
      trailing: onTap == null
          ? null
          : Icon(actionIcon, color: tokens.home.mutedText, size: 20),
      contentPadding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.md, vertical: tokens.spacing.xs),
      onTap: onTap,
    );
  }
}
