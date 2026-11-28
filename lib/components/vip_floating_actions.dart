import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/internationalization.dart';

class VipFloatingActions extends StatelessWidget {
  const VipFloatingActions({
    super.key,
    required this.onHistory,
    required this.onTip,
  });

  static const height = 56.0;
  final VoidCallback onHistory;
  final VoidCallback onTip;

  @override
  Widget build(BuildContext context) {
    final strings = FFLocalizations.of(context);
    final spacing = FlutterFlowTheme.of(context).designToken.spacing;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: _VipFab(
            key: const ValueKey('vip-history-button'),
            label: strings.getVariableText(
                frText: 'Historique', enText: 'History', crText: 'Istorik'),
            tooltip: strings.getText('viphsttip'),
            jewel: FFVipJewel.amethyst,
            asset: 'assets/images/home/shortcut_history.webp',
            fallback: Icons.history_rounded,
            onPressed: onHistory,
          ),
        ),
        SizedBox(width: spacing.sm),
        Flexible(
          child: _VipFab(
            key: const ValueKey('vip-tip-button'),
            label: strings.getVariableText(
                frText: 'Pourboire', enText: 'Tip', crText: 'Poubwa'),
            jewel: FFVipJewel.amber,
            asset: 'assets/images/vip_tip_cup.png',
            fallback: Icons.local_cafe_outlined,
            onPressed: onTip,
          ),
        ),
      ],
    );
  }
}

class _VipFab extends StatelessWidget {
  const _VipFab({
    super.key,
    required this.label,
    this.tooltip,
    required this.jewel,
    required this.asset,
    required this.fallback,
    required this.onPressed,
  });

  final String label;
  final String? tooltip;
  final FFVipJewel jewel;
  final String asset;
  final IconData fallback;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final vip = tokens.vip;
    final spacing = tokens.spacing;
    final style =
        vip.typography.action.copyWith(color: theme.primaryText, fontSize: 15);
    return LayoutBuilder(builder: (context, bounds) {
      final narrow = bounds.maxWidth < 150;
      final artSize = narrow ? spacing.xl : spacing.xl + spacing.sm;
      final inset = EdgeInsetsDirectional.only(
        start: spacing.xs,
        end: narrow ? spacing.sm : spacing.md,
      );
      // At normal text size both extended buttons fit on a 320-wide phone.
      // For larger text keep the illustrated target and the full tooltip.
      final scale = MediaQuery.textScalerOf(context).scale(15) / 15;
      final showLabel = bounds.maxWidth >= 132 * scale &&
          scale * 15 * (style.height ?? 1) <=
              VipFloatingActions.height - spacing.sm;
      final width = showLabel ? null : VipFloatingActions.height;
      final edge = Color.lerp(
          jewel.light, vip.goldLight, jewel == FFVipJewel.amber ? .52 : .18)!;
      return SizedBox(
        height: VipFloatingActions.height,
        width: width,
        child: FloatingActionButton.extended(
          heroTag: null,
          tooltip: tooltip ?? label,
          backgroundColor: vip.posterGround(jewel),
          foregroundColor: theme.primaryText,
          onPressed: onPressed,
          shape: StadiumBorder(side: BorderSide(color: edge, width: 1.5)),
          clipBehavior: Clip.antiAlias,
          extendedPadding: EdgeInsets.zero,
          label: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: bounds.maxWidth),
            child: Ink(
              height: VipFloatingActions.height,
              width: width,
              padding: showLabel ? inset : EdgeInsets.zero,
              decoration: BoxDecoration(gradient: vip.posterLight(jewel)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(asset,
                      width: artSize,
                      height: artSize,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                      errorBuilder: (_, __, ___) =>
                          Icon(fallback, color: vip.goldLight)),
                  if (showLabel) ...[
                    SizedBox(width: spacing.xs),
                    Flexible(
                        child: ExcludeSemantics(
                            child: Text(label, style: style, maxLines: 2))),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
