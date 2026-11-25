import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import 'jewel_poster.dart';

class CrossPosterSurface extends StatelessWidget {
  const CrossPosterSurface({super.key, required this.child});

  static const textureAsset = 'assets/images/home/brushed_gold.webp';
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final vip = theme.designToken.vip;
    final yellow = theme.primary;
    final highlight = Color.lerp(
        yellow.withValues(green: yellow.r), theme.onDecorative, .36)!;
    return JewelPosterFrame(
      rim: vip.gold,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              highlight,
              Color.lerp(yellow, highlight, .28)!,
              yellow,
              Color.lerp(yellow, theme.onPrimary, .10)!,
            ],
            stops: const [0, .40, .72, 1],
          ),
          image: DecorationImage(
            image: const AssetImage(textureAsset),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(yellow, BlendMode.color),
            opacity: .36,
          ),
        ),
        child: CustomPaint(
            painter: JewelPosterEngraving(vip.goldShade), child: child),
      ),
    );
  }
}
