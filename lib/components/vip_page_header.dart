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
    required this.onProfile,
    required this.onHistory,
    required this.onTip,
    this.onBack,
    this.memberName,
    this.memberMedal,
  });

  final Widget avatar;
  final String? memberName;
  final Widget? memberMedal;
  final VoidCallback onProfile;
  final VoidCallback onHistory;
  final VoidCallback onTip;
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
    final radius = BorderRadius.circular(tokens.radius.lg);

    Widget command(String key, String tooltip, IconData icon, VoidCallback tap,
        {String? label}) {
      final style = TextButton.styleFrom(
        foregroundColor: theme.primaryText,
        overlayColor: tokens.home.amethystGlow,
        minimumSize: const Size.square(kMinInteractiveDimension),
        padding: EdgeInsets.symmetric(horizontal: spacing.sm),
        tapTargetSize: MaterialTapTargetSize.padded,
        textStyle: typography.action.copyWith(color: theme.primaryText),
      );
      return Tooltip(
        message: tooltip,
        child: TextButton(
          key: ValueKey(key),
          onPressed: tap,
          style: style,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 19, color: tokens.home.historyAccent),
            if (label != null) ...[
              SizedBox(width: spacing.sm),
              Flexible(child: Text(label)),
            ],
          ]),
        ),
      );
    }

    return LayoutBuilder(builder: (context, bounds) {
      final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
      final width = bounds.maxWidth;
      final inset = width >= 400 ? spacing.lg : spacing.md;
      final portraitSize = width < 340 ? 48.0 : 56.0;
      final medalSize = (width * .26).clamp(56.0, 116.0).toDouble();
      final faceHeight = (width * .40).clamp(132.0, 182.0).toDouble();
      final hasName = name != null && name.isNotEmpty;
      final medal = name == null
          ? SizedBox.square(
              dimension: medalSize,
              child: HomeRaisedArtwork(
                  asset: 'assets/images/home/vip_amethyst_medal.webp',
                  imageKey: const ValueKey('vip-page-medal'),
                  width: medalSize,
                  fallback: Icons.workspace_premium_rounded,
                  foreground: tokens.vip.goldLight))
          : memberMedal;
      final compactTools = width < (name == null ? 332 : 248) * scale ||
          (onBack != null && width < 340 * scale);
      final back = strings.getVariableText(
          frText: 'Retour', enText: 'Back', crText: 'Retounen');
      final tip = strings.getVariableText(
          frText: 'Pourboire', enText: 'Tip', crText: 'Poubwa');
      final tools = [
        if (onBack != null)
          command('vip-back-button', back, Icons.arrow_back_rounded, onBack!),
        command('vip-history-button', strings.getText('viphsttip'),
            Icons.history_rounded, onHistory,
            label: compactTools
                ? null
                : strings.getVariableText(
                    frText: 'Historique',
                    enText: 'History',
                    crText: 'Istorik')),
        command('vip-tip-button', strings.getText('isn2t0tf'),
            Icons.local_cafe_outlined, onTip,
            label: compactTools ? null : tip),
        if (name == null)
          command('vip-profile-button', strings.getText('ey6ffs78'),
              Icons.person_outline_rounded, onProfile),
      ];
      final portrait = Tooltip(
        message: strings.getText('ey6ffs78'),
        child: DecoratedBox(
          decoration:
              BoxDecoration(shape: BoxShape.circle, gradient: tokens.vip.gold),
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
          if (name != null) ...[
            Row(children: [
              portrait,
              if (hasName) ...[
                SizedBox(width: spacing.sm),
                Expanded(
                    child: Text(accountTitle,
                        style: typography.supporting
                            .copyWith(color: tokens.vip.goldLight))),
              ],
            ]),
            SizedBox(height: spacing.sm),
          ],
          Semantics(
              header: true,
              child: Text(
                hasName ? name : accountTitle,
                style: typography
                    .heading(width >= 340 ? 36 : 30)
                    .copyWith(color: theme.onDecorative),
              )),
        ],
      );
      return DecoratedBox(
        key: const ValueKey('vip-member-pass'),
        decoration: tokens.vip.pass,
        child: Padding(
            padding: const EdgeInsets.all(1),
            child: ClipRRect(
              borderRadius: radius,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomPaint(
                    painter: _PassEngraving(
                      foil: tokens.vip.goldLight,
                      lavender: tokens.home.amethystGlow,
                      inset: inset,
                      medalSize: medalSize,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: faceHeight),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: inset, vertical: spacing.md),
                        child: Row(children: [
                          Expanded(child: identity),
                          if (medal != null) ...[
                            SizedBox(width: spacing.sm),
                            ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxWidth: medalSize, maxHeight: medalSize),
                                child: medal),
                          ],
                        ]),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: tokens.background.home.withValues(alpha: .69),
                      border: Border(
                          top: BorderSide(
                              color: tokens.home.amethystGlow
                                  .withValues(alpha: .35))),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing.xs),
                      child: Wrap(
                        alignment: WrapAlignment.spaceAround,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: tools,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      );
    });
  }
}

/// The fine intersecting curves form a guilloché around the member's actual seal.
/// The unit path is shared by every pass; only its scale follows the card.
class _PassEngraving extends CustomPainter {
  const _PassEngraving(
      {required this.foil,
      required this.lavender,
      required this.inset,
      required this.medalSize});
  final Color foil;
  final Color lavender;
  final double inset;
  final double medalSize;

  static final _rosette = _engravedPath();
  static Path _engravedPath() {
    final path = Path();
    for (var i = 0; i < 360; i++) {
      final angle = 2 * math.pi * i / 360;
      final r = .83 + .17 * math.cos(10 * angle);
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
    final center = Offset(size.width - inset - medalSize / 2, size.height / 2);
    final radius = medalSize * .89;
    final pen = Paint()..style = PaintingStyle.stroke;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(radius);
    pen.strokeWidth = .65 / radius;
    pen.color = lavender.withValues(alpha: .56);
    for (var i = 0; i < 12; i++) {
      canvas.drawPath(_rosette, pen);
      canvas.rotate(math.pi / 60);
    }
    pen.color = foil.withValues(alpha: .37);
    canvas.drawCircle(Offset.zero, 1.035, pen);
    canvas.drawCircle(Offset.zero, 1.08, pen);
    canvas.restore();

    final parallel = Rect.fromCenter(
      center: Offset(-size.width * .28, size.height * 2.35),
      width: size.width * 2,
      height: size.height * 3.05,
    );
    pen.strokeWidth = .65;
    pen.color = foil.withValues(alpha: .22);
    for (var i = 0; i < 5; i++) {
      canvas.drawOval(parallel.inflate(i * 3.0), pen);
    }
  }

  @override
  bool shouldRepaint(_PassEngraving old) =>
      foil != old.foil ||
      lavender != old.lavender ||
      inset != old.inset ||
      medalSize != old.medalSize;
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
