import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/internationalization.dart';
import 'home_feature_card.dart';

class VipPageHeader extends StatelessWidget {
  const VipPageHeader({
    super.key,
    required this.avatar,
    required this.inset,
    required this.onProfile,
    this.onBack,
    this.memberName,
    this.badgeName,
    this.memberMedal,
  });

  final Widget avatar;
  final double inset;
  final String? memberName;
  final String? badgeName;
  final Widget? memberMedal;
  final VoidCallback onProfile;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final typography = tokens.vip.typography;
    final strings = FFLocalizations.of(context);
    final spacing = tokens.spacing;
    final name = memberName?.trim();
    final accountTitle = strings.getText('gfj3b9xn');

    Widget command(
            String key, String tooltip, IconData icon, VoidCallback tap) =>
        IconButton(
          key: ValueKey(key),
          tooltip: tooltip,
          onPressed: tap,
          style: IconButton.styleFrom(
            minimumSize: const Size.square(kMinInteractiveDimension),
            foregroundColor: tokens.home.historyAccent,
          ),
          icon: Icon(icon, size: 19),
        );

    return Container(
      padding: EdgeInsets.fromLTRB(inset, inset, inset, spacing.sm),
      decoration: tokens.background.pageHeader(vip: true),
      child: LayoutBuilder(builder: (context, bounds) {
        final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
        final width = bounds.maxWidth;
        final portraitSize = width < 340 ? 48.0 : 56.0;
        final medalSize = (width * .20).clamp(56.0, 80.0).toDouble();
        final hasName = name != null && name.isNotEmpty;
        final artwork = name == null
            ? SizedBox.square(
                dimension: medalSize,
                child: HomeRaisedArtwork(
                    asset: 'assets/images/home/vip_amethyst_medal.webp',
                    imageKey: const ValueKey('vip-page-medal'),
                    width: medalSize,
                    fallback: Icons.workspace_premium_rounded,
                    foreground: tokens.vip.goldLight))
            : memberMedal;
        final medal = artwork == null
            ? null
            : ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: medalSize, maxHeight: medalSize),
                child: artwork,
              );
        final back = strings.getVariableText(
            frText: 'Retour', enText: 'Back', crText: 'Retounen');
        final portrait = Tooltip(
          message: strings.getText('ey6ffs78'),
          child: DecoratedBox(
            decoration: BoxDecoration(
                shape: BoxShape.circle, gradient: tokens.vip.gold),
            child: Padding(
              padding: const EdgeInsets.all(1.5),
              child: Material(
                shape: const CircleBorder(),
                color: tokens.vip.felt.colors.last,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  key: const ValueKey('vip-profile-button'),
                  onTap: onProfile,
                  customBorder: const CircleBorder(),
                  child: SizedBox.square(
                    dimension: portraitSize,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: ExcludeSemantics(child: ClipOval(child: avatar)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        final identity = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              header: true,
              child: Text(
                hasName ? name : badgeName ?? accountTitle,
                style: typography
                    .heading(width >= 340 ? 34 : 30)
                    .copyWith(color: theme.primaryText),
              ),
            ),
            if (hasName && badgeName != null) ...[
              SizedBox(height: spacing.xs),
              Text(badgeName!,
                  style: typography.supporting
                      .copyWith(color: tokens.home.amethystGlow)),
            ],
          ],
        );
        // Keep the name and badge together when large text needs the full width.
        final identityBelow = name != null && width / scale < 260;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (name != null) ...[
                  portrait,
                  SizedBox(width: width < 340 ? spacing.sm : spacing.md),
                ],
                if (identityBelow)
                  const Spacer()
                else
                  Expanded(child: identity),
                if (medal != null) ...[
                  SizedBox(width: spacing.sm),
                  if (name == null || badgeName != null)
                    CustomPaint(
                      key: const ValueKey('vip-medal-frame'),
                      painter: _MedalEngraving(
                        foil: tokens.vip.goldLight,
                        lavender: tokens.home.amethystGlow,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(
                            width < 340 ? spacing.sm : spacing.sm + spacing.xs),
                        child: medal,
                      ),
                    )
                  else
                    medal,
                ],
              ],
            ),
            if (identityBelow) ...[
              SizedBox(height: spacing.sm),
              identity,
            ],
            if (onBack != null || name == null) ...[
              SizedBox(height: spacing.sm),
              Wrap(spacing: spacing.xs, children: [
                if (onBack != null)
                  command('vip-back-button', back, Icons.arrow_back_rounded,
                      onBack!),
                if (name == null)
                  command('vip-profile-button', strings.getText('ey6ffs78'),
                      Icons.person_outline_rounded, onProfile),
              ]),
            ],
          ],
        );
      }),
    );
  }
}

class _MedalEngraving extends CustomPainter {
  const _MedalEngraving({required this.foil, required this.lavender});

  final Color foil;
  final Color lavender;

  static const _petals = 6;
  static const _strands = 4;
  static final _rosette = _engravedPath();
  static Path _engravedPath() {
    final path = Path();
    for (var i = 0; i < 360; i++) {
      final angle = 2 * math.pi * i / 360;
      final r = .87 + .13 * math.cos(_petals * angle);
      final x = r * math.cos(angle);
      final y = r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide / 2 - 1) / 1.08;
    final pen = Paint()..style = PaintingStyle.stroke;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(radius);
    pen.strokeWidth = .85 / radius;
    pen.color = lavender.withValues(alpha: .72);
    for (var i = 0; i < _strands; i++) {
      canvas.drawPath(_rosette, pen);
      canvas.rotate(2 * math.pi / (_petals * _strands));
    }
    pen.strokeWidth = .65 / radius;
    pen.color = foil.withValues(alpha: .37);
    canvas.drawCircle(Offset.zero, 1.035, pen);
    canvas.drawCircle(Offset.zero, 1.08, pen);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MedalEngraving old) =>
      foil != old.foil || lavender != old.lavender;
}

class VipHeaderAvatar extends StatelessWidget {
  const VipHeaderAvatar(
      {super.key, required this.name, required this.photoUrl});

  final String name;
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final words = name.trim().split(RegExp(r'\s+'));
    final initials = name.trim().isEmpty
        ? ''
        : (words.first.characters.first +
                (words.length > 1 ? words.last.characters.first : ''))
            .toUpperCase();
    final fallback = initials.isEmpty
        ? Icon(Icons.person_outline_rounded, color: theme.primaryText)
        : Center(
            child: Padding(
            padding: EdgeInsets.all(theme.designToken.spacing.xs),
            child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(initials,
                    style: theme.designToken.vip.typography
                        .heading(24)
                        .copyWith(color: theme.onDecorative))),
          ));
    if (photoUrl.isEmpty) return fallback;
    return CachedNetworkImage(
      key: ValueKey(photoUrl),
      imageUrl: photoUrl,
      fit: BoxFit.cover,
      placeholder: (_, __) => fallback,
      errorWidget: (_, __, ___) => fallback,
    );
  }
}
