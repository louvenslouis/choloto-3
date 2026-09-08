import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';

/// One entrance per mounted section, including sections delivered by a stream.
/// Rebuilds (theme, locale, subscription snapshots) never replay the entrance.
class VipEntrance extends StatefulWidget {
  const VipEntrance(
      {super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<VipEntrance> createState() => _VipEntranceState();
}

class _VipEntranceState extends State<VipEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    final total = widget.delay.inMilliseconds + 420;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: total),
    );
    _progress = _controller.drive(CurveTween(
      curve: Interval(widget.delay.inMilliseconds / total, 1,
          curve: Curves.easeOutCubic),
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _started = true;
      _controller.value = 1;
    } else if (!_started) {
      _started = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final distance = FlutterFlowTheme.of(context).designToken.spacing.sm;
    return FadeTransition(
      opacity: _progress,
      alwaysIncludeSemantics: true,
      child: AnimatedBuilder(
        animation: _progress,
        child: widget.child,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, distance * (1 - _progress.value)),
          child: child,
        ),
      ),
    );
  }
}

/// Visual feedback around an existing button: its gestures, focus, semantics
/// and action remain owned by the original Material control.
class VipActionFeedback extends StatefulWidget {
  const VipActionFeedback({super.key, required this.child});

  final Widget child;

  @override
  State<VipActionFeedback> createState() => _VipActionFeedbackState();
}

class _VipActionFeedbackState extends State<VipActionFeedback> {
  bool _hovered = false;
  int? _pointer;

  void _release() {
    if (_pointer != null) setState(() => _pointer = null);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pointer = null;
      }),
      child: Listener(
        onPointerDown: (event) {
          if (_pointer == null) setState(() => _pointer = event.pointer);
        },
        onPointerMove: (_) => _release(),
        onPointerUp: (event) {
          if (event.pointer == _pointer) _release();
        },
        onPointerCancel: (event) {
          if (event.pointer == _pointer) _release();
        },
        child: AnimatedScale(
          scale: reduceMotion
              ? 1
              : (_pointer != null ? 0.97 : (_hovered ? 1.025 : 1)),
          duration:
              reduceMotion ? Duration.zero : const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}

extension VipMotion on Widget {
  Widget vipEntrance({int delayMs = 0}) => VipEntrance(
        delay: Duration(milliseconds: delayMs),
        child: this,
      );

  Widget vipActionFeedback() => VipActionFeedback(child: this);
}
