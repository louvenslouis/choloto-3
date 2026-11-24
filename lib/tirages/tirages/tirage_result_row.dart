import 'dart:math' as math;

import 'package:flutter/material.dart';

import '/backend/schema/resultats_record.dart';
import '/components/draw_result_chip.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TirageResultRow extends StatefulWidget {
  const TirageResultRow({super.key, required this.result});

  final ResultatsRecord result;

  @override
  State<TirageResultRow> createState() => _TirageResultRowState();
}

class _TirageResultRowState extends State<TirageResultRow> {
  static const _markets = {
    'ny': (label: 'home_draw_new_york', logo: 'New_york'),
    'fl': (label: 'home_draw_florida', logo: 'Florida'),
    'tx': (label: 'draw_texas', logo: 'Texas'),
    'md': (label: 'draw_maryland', logo: 'Maryland'),
    'ga': (label: 'draw_georgia', logo: 'Georgia'),
    'tn': (label: 'draw_tennessee', logo: 'Tennessee'),
    'pa': (label: 'draw_pennsylvania', logo: 'Pennsylvania'),
    'nj': (label: 'draw_new_jersey', logo: 'NewJersey'),
  };

  @override
  void initState() {
    super.initState();
    if (widget.result.tirage != 'fl') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) logFirebaseEvent('NEW_YORKK_COMP_newYorkk_ON_INIT_STATE');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;
    final strings = FFLocalizations.of(context);
    final market = _markets[result.tirage];
    final title =
        market == null ? result.tirage : strings.getText(market.label);
    final period = switch (result.periode.trim().toLowerCase()) {
      'morning' || 'matin' => strings.getText('draw_morning'),
      'day' || 'journée' => strings.getText('draw_day'),
      'midday' || 'midi' => strings.getText('home_draw_midday'),
      'evening' || 'soir' => strings.getText('home_draw_evening'),
      'night' || 'nuit' => strings.getText('draw_night'),
      _ => result.periode.trim(),
    };
    final count = result.tirage == 'fl' ? 4 : 3;
    final textScale = MediaQuery.textScalerOf(context);
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 520;
      final logoSize = wide ? 52.0 : 40.0;
      // These six official marks contain dark lettering on transparent pixels.
      final logoNeedsBacking = result.tirage != 'ny' && result.tirage != 'fl';
      final chipSize = math.max(
        (constraints.maxWidth * .115).clamp(34.0, 52.0),
        textScale.scale(18) + 14,
      );
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: wide ? spacing.lg : spacing.md,
          vertical: wide ? spacing.md : spacing.sm + spacing.xs,
        ),
        child: MergeSemantics(
          child: OverflowBar(
            alignment: MainAxisAlignment.spaceBetween,
            spacing: spacing.sm,
            overflowSpacing: spacing.sm,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: logoSize,
                    height: logoSize,
                    padding:
                        logoNeedsBacking ? EdgeInsets.all(spacing.xs) : null,
                    decoration: logoNeedsBacking
                        ? BoxDecoration(
                            color: theme.designToken.home.mutedText,
                            borderRadius: BorderRadius.circular(
                                theme.designToken.radius.sm),
                          )
                        : null,
                    child: Image.asset(
                      'assets/images/${market?.logo ?? 'CHOLOTO_new_logo'}.png',
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                  ),
                  SizedBox(width: wide ? spacing.md : spacing.sm),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: theme.titleMedium.override(
                              fontSize: wide ? 22 : 17,
                              fontWeight: FontWeight.w700,
                              lineHeight: 1.1,
                            )),
                        if (period.isNotEmpty) ...[
                          SizedBox(height: spacing.xs),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.schedule_rounded,
                                  size: 14,
                                  color: theme.designToken.home.mutedText),
                              SizedBox(width: spacing.xs),
                              Flexible(
                                child: Text(period,
                                    style: theme.labelMedium.copyWith(
                                      color: theme.designToken.home.mutedText,
                                      fontSize: wide ? 16 : 14,
                                    )),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: wide ? spacing.sm : spacing.xs,
                runSpacing: spacing.xs,
                children: [
                  for (var i = 0; i < count; i++)
                    DrawResultChip(
                      value: valueOrDefault(
                          result.numeros.elementAtOrNull(i), '-'),
                      size: chipSize,
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
