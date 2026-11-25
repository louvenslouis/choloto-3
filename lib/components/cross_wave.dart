part of 'cross_widget.dart';

class _CrossWave {
  _CrossWave(List<Offset> centers, this.startRadius)
      : assert(centers.length == 9),
        assert(startRadius >= 0),
        centers = List.unmodifiable(centers);

  final List<Offset> centers;
  final double startRadius;
  Offset get origin => centers[4];

  // The ring crosses the board in the first 410 ms. Each medallion then
  // finishes its own short oscillation independently.
  static const _travelEnd = .5;
  late final double endRadius = math.max(
      startRadius + 1,
      1.18 *
          [0, 2, 6, 8]
              .map((index) => (centers[index] - origin).distance)
              .reduce(math.max));

  Widget shake(int index, double progress, Widget child) {
    final fromOrigin = centers[index] - origin;
    final distance = fromOrigin.distance;
    if (distance == 0) return child;
    final arrival = _travelEnd *
        ((distance - startRadius) / (endRadius - startRadius)).clamp(0.0, 1.0);
    final phase = (progress - arrival) / .46;
    if (phase <= 0 || phase >= 1) return child;

    final decay = 1 - phase;
    final oscillation = math.sin(phase * 4 * math.pi) * decay * decay;
    final direction = fromOrigin / distance;
    final slant = direction.dx == 0 ? direction.dy : direction.dx;
    return Transform.translate(
      offset: direction * (7.5 * oscillation),
      child: Transform.rotate(angle: .038 * slant * oscillation, child: child),
    );
  }
}

class _CrossWavePainter extends CustomPainter {
  _CrossWavePainter(this.wave, this.progress, this.dark, this.light)
      : super(repaint: progress);

  final _CrossWave wave;
  final Animation<double> progress;
  final Color dark;
  final Color light;

  @override
  void paint(Canvas canvas, Size size) {
    final travel = progress.value / _CrossWave._travelEnd;
    if (travel <= 0 || travel >= 1) return;
    final radius =
        wave.startRadius + (wave.endRadius - wave.startRadius) * travel;
    final visibility =
        math.min(1.0, travel / .10) * math.min(1.0, (1 - travel) / .28);
    final stroke = Paint()..style = PaintingStyle.stroke;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final lightRadius = math.max(0.0, radius - 1.65);
    if (lightRadius > 0) {
      final width = math.min(8.0, lightRadius);
      final innerStop = 1 - width / lightRadius;
      final trail = RadialGradient(
        colors: [
          light.withValues(alpha: 0),
          light.withValues(alpha: light.a * .11 * visibility),
          light.withValues(alpha: light.a * .46 * visibility),
        ],
        stops: [innerStop, (innerStop + 1) / 2, 1],
      );
      canvas.drawCircle(
          wave.origin,
          lightRadius - width / 2,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = width
            ..shader = trail.createShader(
                Rect.fromCircle(center: wave.origin, radius: lightRadius)));
    }
    canvas.drawCircle(
        wave.origin,
        radius,
        stroke
          ..strokeWidth = 1.8
          ..color = dark.withValues(alpha: dark.a * .76 * visibility));
    canvas.drawCircle(
        wave.origin,
        lightRadius,
        stroke
          ..strokeWidth = 1.25
          ..color = light.withValues(alpha: light.a * .91 * visibility));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CrossWavePainter old) =>
      wave != old.wave ||
      progress != old.progress ||
      dark != old.dark ||
      light != old.light;
}
