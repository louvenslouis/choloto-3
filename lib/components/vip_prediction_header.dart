import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import 'vip_casino_card.dart';

/// Presentational only: callers retain their existing date format and copy.
class VipPredictionHeader extends StatelessWidget {
  const VipPredictionHeader({
    super.key,
    required this.label,
    this.percentage,
  });

  final String label;
  final String? percentage;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    return VipCasinoCard(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: tokens.vip.numberText, size: 20),
            SizedBox(width: tokens.spacing.sm),
            Expanded(
              child: Text(
                label,
                style: theme.bodyMedium.override(
                  color: theme.primaryText,
                  fontWeight: FontWeight.w500,
                  lineHeight: 1.35,
                ),
              ),
            ),
            if (percentage != null) ...[
              SizedBox(width: tokens.spacing.sm),
              VipCasinoPlaque(
                child: Padding(
                  padding: EdgeInsets.all(tokens.spacing.sm),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timeline_sharp,
                          color: tokens.vip.numberText, size: 20),
                      SizedBox(width: tokens.spacing.xs),
                      Text(
                        percentage!,
                        style: theme.titleMedium.override(
                          color: tokens.vip.numberText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
