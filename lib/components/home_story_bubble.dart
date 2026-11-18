import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/internationalization.dart';
import 'vip_casino_card.dart';

/// The same engraved rim as the result chips frames each unread story.
class HomeStoryBubble extends StatelessWidget {
  const HomeStoryBubble({
    super.key,
    required this.id,
    required this.semanticLabel,
    required this.child,
    this.viewed,
    this.storyCount = 1,
    this.onTap,
  });

  static const diameter = 72.0;
  final String id;
  final String semanticLabel;

  /// Null for the loading and retry slots, which have no reading state.
  final bool? viewed;
  final int storyCount;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final unread = viewed == false;
    final rimWidth = unread ? tokens.spacing.xs : tokens.spacing.xs / 2;
    final face = Container(
      margin: EdgeInsets.all(rimWidth),
      // Both reading states leave the same space for the artwork and caption.
      padding: EdgeInsets.all(tokens.spacing.xs - rimWidth),
      decoration: BoxDecoration(
        gradient: tokens.home.surface,
        shape: BoxShape.circle,
      ),
      child: ClipOval(child: child),
    );
    final value = [
      if (viewed != null)
        FFLocalizations.of(context)
            .getText(unread ? 'home_story_unseen' : 'home_story_seen'),
      if (storyCount > 1) '$storyCount',
    ].join(', ');

    return Semantics(
      label: semanticLabel,
      value: value.isEmpty ? null : value,
      button: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          key: ValueKey('$id-button'),
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: EdgeInsets.all(tokens.spacing.xs),
            child: SizedBox.square(
              key: ValueKey('$id-circle'),
              dimension: diameter,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (unread) ...[
                    VipCasinoChip(child: face),
                    _StoryRimGlint(id: id),
                  ] else
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            tokens.home.mutedText.withValues(alpha: .75),
                            tokens.home.edge,
                            tokens.home.edge.withValues(alpha: .55),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: face,
                    ),
                  if (storyCount > 1)
                    PositionedDirectional(
                      top: 0,
                      end: 0,
                      child: Container(
                        key: ValueKey('$id-count'),
                        constraints:
                            const BoxConstraints(minHeight: 20, minWidth: 20),
                        padding:
                            EdgeInsets.symmetric(horizontal: tokens.spacing.xs),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: unread
                              ? tokens.home.membership
                              : tokens.home.surface,
                          borderRadius:
                              BorderRadius.circular(tokens.radius.full),
                          border: Border.all(
                              color: tokens.background.home, width: 1.5),
                        ),
                        child: Text(
                          '$storyCount',
                          style: theme.labelSmall.copyWith(
                            color: unread ? theme.onPrimary : theme.primaryText,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeStoryCover extends StatelessWidget {
  const HomeStoryCover({
    super.key,
    required this.id,
    required this.label,
    required this.asset,
    this.thumbnailUrl = '',
  });

  final String id;
  final String label;
  final String asset;
  final String thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final artwork = DecoratedBox(
      decoration: BoxDecoration(gradient: tokens.home.hero),
      child: Padding(
        padding: EdgeInsets.fromLTRB(tokens.spacing.sm, tokens.spacing.xs,
            tokens.spacing.sm, tokens.spacing.md),
        child:
            Image.asset(asset, fit: BoxFit.contain, excludeFromSemantics: true),
      ),
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        if (thumbnailUrl.isEmpty)
          artwork
        else
          CachedNetworkImage(
            key: ValueKey('$id-thumbnail'),
            imageUrl: thumbnailUrl,
            fit: BoxFit.cover,
            fadeInDuration: const Duration(milliseconds: 180),
            placeholder: (context, _) => artwork,
            errorWidget: (context, _, __) => artwork,
          ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                tokens.spacing.sm, 0, tokens.spacing.sm, tokens.spacing.sm),
            child: DecoratedBox(
              key: ValueKey('$id-caption'),
              decoration: BoxDecoration(
                color: theme.onPrimary.withValues(alpha: .85),
                borderRadius: BorderRadius.circular(tokens.radius.full),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: tokens.spacing.xs),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(label,
                      key: ValueKey('$id-label'),
                      style: theme.labelSmall.override(
                          color: theme.onDecorative,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StoryRimGlint extends StatefulWidget {
  const _StoryRimGlint({required this.id});
  final String id;

  @override
  State<_StoryRimGlint> createState() => _StoryRimGlintState();
}

class _StoryRimGlintState extends State<_StoryRimGlint>
    with SingleTickerProviderStateMixin {
  late final _travel = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1050),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _travel.value = 1;
    } else if (!TickerMode.valuesOf(context).enabled) {
      _travel.stop();
    } else if (!_travel.isCompleted && !_travel.isAnimating) {
      _travel.forward();
    }
  }

  @override
  void dispose() {
    _travel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: CustomPaint(
          key: ValueKey('${widget.id}-glint'),
          painter:
              _RimLight(_travel, FlutterFlowTheme.of(context).onDecorative),
        ),
      );
}

/// A single specular reflection travels along the metal rim. The story image,
/// count and hit target are stationary throughout.
class _RimLight extends CustomPainter {
  _RimLight(this.travel, this.light) : super(repaint: travel);
  final Animation<double> travel;
  final Color light;

  @override
  void paint(Canvas canvas, Size size) {
    final phase = travel.value;
    if (phase <= 0 || phase >= 1) return;
    final rim = (Offset.zero & size).deflate(2);
    final strength = math.sin(phase * math.pi);
    final glow = SweepGradient(
      colors: [
        light.withValues(alpha: 0),
        light.withValues(alpha: strength),
        light.withValues(alpha: 0),
      ],
      stops: const [0, .55, 1],
      endAngle: math.pi * .44,
      transform: GradientRotation(-math.pi + phase * math.pi * 1.6),
    );
    canvas.drawOval(
        rim,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..shader = glow.createShader(rim));
  }

  @override
  bool shouldRepaint(_RimLight old) =>
      old.travel != travel || old.light != light;
}
