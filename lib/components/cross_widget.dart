import 'dart:math' as math;

import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import 'cross_poster_heading.dart';
import 'cross_poster_surface.dart';

export 'cross_model.dart';

class CrossWidget extends StatelessWidget {
  const CrossWidget({super.key, this.numbers, this.date});

  static const artworkAsset = 'assets/images/home/lucky_cross_3d_x.png';
  static const textureAsset = CrossPosterSurface.textureAsset;

  final List<String>? numbers;
  final DateTime? date;

  Widget? _slot(int index, double cellWidth) {
    if (index == 4) return _CrossEmblem(size: cellWidth * .9);
    final entries = numbers;
    if (entries == null || index >= entries.length) return null;
    final value = entries[index];
    if (value.trim().isEmpty) return null;
    return _NumberMedallion(value: value, cellWidth: cellWidth);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final spacing = tokens.spacing;

    return LayoutBuilder(builder: (context, constraints) {
      final width = math.min(constraints.maxWidth, 500.0);
      final cellWidth = (width - spacing.sm * 2) / 3;
      return SizedBox(
        width: width,
        child: CrossPosterSurface(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CrossPosterHeading(date: date),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    spacing.sm, spacing.sm, spacing.sm, spacing.md),
                child: Column(
                  children: [
                    for (var row = 0; row < 3; row++)
                      CustomPaint(
                        painter: _CrossSpokes(
                          row: row,
                          diagonal: theme.onPrimary.withValues(alpha: .43),
                          axis: theme.onPrimary.withValues(alpha: .21),
                        ),
                        child: Row(
                          children: [
                            for (var index = row * 3;
                                index < row * 3 + 3;
                                index++)
                              Expanded(
                                child: ConstrainedBox(
                                  key: ValueKey('croix-slot-$index'),
                                  constraints: BoxConstraints(
                                      minHeight: cellWidth * .81),
                                  child: Center(child: _slot(index, cellWidth)),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _NumberMedallion extends StatelessWidget {
  const _NumberMedallion({required this.value, required this.cellWidth});

  final String value;
  final double cellWidth;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final vip = tokens.vip;
    final faceSize = cellWidth * .57;
    // Give longer entries the full width of their cell and let the row grow
    // when they wrap. The user's text scale still applies to every figure.
    final size = switch (value.characters.length) {
      <= 2 => (cellWidth * .32).clamp(23.0, 44.0),
      <= 4 => (cellWidth * .25).clamp(20.0, 34.0),
      _ => (cellWidth * .19).clamp(17.0, 25.0),
    };
    return Padding(
      padding: EdgeInsets.all(tokens.spacing.xs),
      child: Container(
        constraints: BoxConstraints(minWidth: faceSize, minHeight: faceSize),
        padding: EdgeInsets.all(tokens.spacing.xs),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(theme.secondaryBackground, vip.goldLight, .13)!,
              theme.secondaryBackground,
              theme.onPrimary
            ],
          ),
          borderRadius: BorderRadius.circular(faceSize / 2),
          border: Border.all(color: vip.goldLight.withValues(alpha: .68)),
          boxShadow: [tokens.shadow.sm],
        ),
        child: Align(
          widthFactor: 1,
          heightFactor: 1,
          child: Text(value,
              textAlign: TextAlign.center,
              style: vip.typography
                  .numeral(size)
                  .copyWith(color: theme.primaryText)),
        ),
      ),
    );
  }
}

class _CrossEmblem extends StatelessWidget {
  const _CrossEmblem({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final vip = tokens.vip;
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: [
              vip.goldShade,
              theme.primary,
              vip.illustrationInk,
              theme.primary,
              vip.goldLight,
              vip.goldShade,
            ],
            stops: const [0, .18, .36, .58, .67, 1],
          ),
          boxShadow: [
            BoxShadow(
              color: theme.onPrimary.withValues(alpha: .24),
              blurRadius: size * .19,
              spreadRadius: size * .018,
            ),
            tokens.shadow.md,
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all((size * .026).clamp(2.0, 3.5)),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-.27, -.32),
                radius: .92,
                colors: [
                  Color.lerp(theme.secondaryBackground, vip.goldLight, .14)!,
                  theme.onPrimary,
                ],
              ),
              border: Border.all(color: theme.onPrimary),
            ),
            child: Padding(
              padding: EdgeInsets.all(size * .065),
              child: Image.asset(CrossWidget.artworkAsset,
                  fit: BoxFit.contain, excludeFromSemantics: true),
            ),
          ),
        ),
      ),
    );
  }
}

// Each third owns its spokes, so even a wrapped value on a taller row stays
// exactly on its axis.
class _CrossSpokes extends CustomPainter {
  const _CrossSpokes(
      {required this.row, required this.diagonal, required this.axis});

  final int row;
  final Color diagonal;
  final Color axis;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final paint = Paint()
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..color = axis;
    final yStart = row == 0 ? height / 2 : 0.0;
    final yEnd = row == 2 ? height / 2 : height;
    canvas.drawLine(Offset(width / 2, yStart), Offset(width / 2, yEnd), paint);
    if (row == 1) {
      canvas.drawLine(Offset(width / 6, height / 2),
          Offset(width * 5 / 6, height / 2), paint);
    }
    final xStart = [1 / 6, 1 / 3, 2 / 3][row];
    final xEnd = [1 / 3, 2 / 3, 5 / 6][row];
    paint.color = diagonal;
    canvas.drawLine(
        Offset(width * xStart, yStart), Offset(width * xEnd, yEnd), paint);
    canvas.drawLine(Offset(width * (1 - xStart), yStart),
        Offset(width * (1 - xEnd), yEnd), paint);
  }

  @override
  bool shouldRepaint(_CrossSpokes old) =>
      row != old.row || diagonal != old.diagonal || axis != old.axis;
}
