import 'package:flutter/material.dart';
import '/backend/schema/structs/index.dart';
import '/components/draw_result_chip.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/internationalization.dart';

class BingoResultTile extends StatelessWidget {
  const BingoResultTile({super.key, required this.entry, required this.index});

  final DataStackStruct entry;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final title = entry.tirage.isEmpty
        ? FFLocalizations.of(context).getVariableText(
            frText: 'Bingo ${index + 1}',
            enText: 'Bingo ${index + 1}',
            crText: 'Bingo ${index + 1}',
          )
        : entry.tirage;
    final details = [entry.valeur, entry.periode]
        .where((value) => value.trim().isNotEmpty)
        .join('  •  ');

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: theme.designToken.home.panel,
      child: Row(
        children: [
          DrawResultChip(
              value: entry.boul.isEmpty ? '—' : entry.boul, size: 48),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.titleMedium.override(
                    fontFamily: 'Google sans flex',
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.0,
                  ),
                ),
                if (details.isNotEmpty) ...[
                  SizedBox(height: theme.designToken.spacing.xs),
                  Text(
                    details,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.labelMedium.override(
                      color: theme.designToken.home.mutedText,
                      letterSpacing: 0.0,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
