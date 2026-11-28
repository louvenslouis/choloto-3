import 'package:flutter/material.dart';

import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'account_editor_sheet.dart';
import 'settings_tile.dart';

enum MemberNotification {
  bingo('new_bingo'),
  cross('new_croix'),
  prediction('new_prediction'),
  reply('assistant_reply'),
  activation('account_activated');

  const MemberNotification(this.type);
  final String type;
}

class MemberNotificationSettings extends StatelessWidget {
  const MemberNotificationSettings({super.key, required this.profile});
  final UserRecord? profile;

  @override
  Widget build(BuildContext context) {
    final t = FFLocalizations.of(context);
    final owner = profile;
    final stored = owner?.snapshotData['web_push_preferences'];
    final selected = {
      for (final category in MemberNotification.values)
        if (stored is! Map || stored[category.type] != false) category,
    };
    final count = selected.length;
    final total = MemberNotification.values.length;
    return SettingsTile(
      icon: Icons.notifications_outlined,
      title: t.getText('push_categories'),
      detail: owner == null
          ? null
          : t.getVariableText(
              frText: '$count sur $total',
              enText: '$count of $total',
              crText: '$count sou $total'),
      onTap: owner == null
          ? null
          : () => showAccountEditor(
              context,
              MemberNotificationEditor(
                initial: selected,
                onSave: (changes) => updateOwnProfile(owner, {
                  for (final entry in changes.entries)
                    'web_push_preferences.${entry.key.type}': entry.value,
                }),
              )),
    );
  }
}

class MemberNotificationEditor extends StatefulWidget {
  const MemberNotificationEditor(
      {super.key, required this.initial, required this.onSave});
  final Set<MemberNotification> initial;
  final Future<void> Function(Map<MemberNotification, bool>) onSave;
  @override
  State<MemberNotificationEditor> createState() =>
      _MemberNotificationEditorState();
}

class _MemberNotificationEditorState extends State<MemberNotificationEditor> {
  late final _selected = {...widget.initial};
  @override
  Widget build(BuildContext context) {
    final t = FFLocalizations.of(context);
    final theme = FlutterFlowTheme.of(context);
    return AccountEditorSheet(
        title: t.getText('push_categories'),
        onSave: () async {
          // Update only edited categories so another device can change the others independently.
          final changes = {
            for (final category in MemberNotification.values)
              if (widget.initial.contains(category) !=
                  _selected.contains(category))
                category: _selected.contains(category)
          };
          if (changes.isNotEmpty) await widget.onSave(changes);
        },
        child: Column(children: [
          for (final category in MemberNotification.values)
            SwitchListTile(
              activeThumbColor: theme.primary,
              activeTrackColor: theme.primary.withValues(alpha: 0.45),
              key: ValueKey(category),
              contentPadding: EdgeInsets.zero,
              title: Text(t.getText('push_${category.type}'),
                  style: theme.bodyLarge),
              value: _selected.contains(category),
              onChanged: (on) => setState(() {
                if (on) {
                  _selected.add(category);
                } else {
                  _selected.remove(category);
                }
              }),
            ),
        ]));
  }
}
