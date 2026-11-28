import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';

class SettingsChoiceSheet<T> extends StatelessWidget {
  const SettingsChoiceSheet({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding:
            EdgeInsets.fromLTRB(spacing.sm, spacing.sm, spacing.sm, spacing.md),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: EdgeInsetsDirectional.only(start: spacing.md),
            child: Row(children: [
              Expanded(
                  child: Semantics(
                      header: true,
                      child: Text(title, style: theme.titleLarge))),
              const CloseButton(),
            ]),
          ),
          for (final option in options.entries)
            SettingsChoiceTile(
              label: option.value,
              selected: selected == option.key,
              onTap: () => onSelected(option.key),
            ),
        ]),
      ),
    );
  }
}

class SettingsChoiceTile extends StatelessWidget {
  const SettingsChoiceTile(
      {super.key,
      required this.label,
      required this.selected,
      required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return ListTile(
      selected: selected,
      enabled: onTap != null,
      selectedColor: theme.primary,
      title: Text(label, style: theme.bodyLarge),
      trailing:
          selected ? Icon(Icons.check_rounded, color: theme.primary) : null,
      onTap: onTap,
    );
  }
}
