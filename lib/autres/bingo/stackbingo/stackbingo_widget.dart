import 'dart:async';
import 'dart:math' as math;

import '/autres/bingo/bingo_result_tile.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_swipeable_stack.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'bingo_story_result_ticket.dart';
import 'stackbingo_model.dart';
export 'stackbingo_model.dart';

class StackbingoWidget extends StatefulWidget {
  const StackbingoWidget({
    super.key,
    this.dataStack,
    this.vipResults = false,
  });

  final List<DataStackStruct>? dataStack;
  final bool vipResults;

  @override
  State<StackbingoWidget> createState() => _StackbingoWidgetState();
}

class _StackbingoWidgetState extends State<StackbingoWidget> {
  late final StackbingoModel _model;
  late final _entrance = AnimationInfo(
    trigger: AnimationTrigger.onPageLoad,
    effectsBuilder: () => [
      MoveEffect(
        curve: Curves.elasticOut,
        delay: 100.ms,
        duration: 800.ms,
        begin: const Offset(0, -15),
        end: Offset.zero,
      ),
    ],
  );
  Timer? _rotation;
  double? _dragStart;
  double _distance = 0;
  int _front = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StackbingoModel());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleRotation();
  }

  @override
  void didUpdateWidget(StackbingoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dataStack?.length != oldWidget.dataStack?.length) {
      _front = 0;
      _scheduleRotation();
    }
  }

  void _scheduleRotation() {
    _rotation?.cancel();
    if ((widget.dataStack?.length ?? 0) < 2 ||
        MediaQuery.disableAnimationsOf(context) ||
        _dragStart != null) {
      return;
    }
    _rotation = Timer(
        const Duration(seconds: 3), _model.swipeableStackController.swipeRight);
  }

  void _finishDrag([DragEndDetails? details]) {
    final distance = _distance;
    final velocity = details?.primaryVelocity ?? 0;
    _dragStart = null;
    _distance = 0;
    _scheduleRotation();
    if (details == null || (distance.abs() < 18 && velocity.abs() < 160)) {
      return;
    }
    final direction = distance.abs() >= 18 ? distance : velocity;
    if (direction < 0) {
      _model.swipeableStackController.swipeLeft();
    } else {
      _model.swipeableStackController.swipeRight();
    }
  }

  @override
  void dispose() {
    _rotation?.cancel();
    _model.maybeDispose();
    super.dispose();
  }

  Widget _story(List<DataStackStruct> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();
    if (entries.length == 1) {
      return BingoStoryResultTicket(entry: entries.single, count: 1);
    }
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    // Ignore the swiper's full-square pan recognizer. Only the ticket intercepts
    // a drag; the fixed BINGO balls remain part of story/page navigation.
    return Stack(fit: StackFit.expand, children: [
      IgnorePointer(
        child: CardSwiper(
          key: ValueKey((entries.length, reducedMotion)),
          controller: _model.swipeableStackController,
          initialIndex: _front,
          cardsCount: entries.length,
          numberOfCardsDisplayed: math.min(3, entries.length),
          scale: 1,
          padding: EdgeInsets.zero,
          backCardOffset: Offset.zero,
          duration:
              reducedMotion ? Duration.zero : const Duration(milliseconds: 200),
          onSwipe: (_, next, __) {
            if (next != null && mounted) {
              setState(() => _front = next);
              _scheduleRotation();
            }
            return true;
          },
          cardBuilder: (_, index, __, ___) {
            final depth = (index - _front) % entries.length;
            return ExcludeSemantics(
              excluding: depth > 0,
              child: Transform.rotate(
                alignment: const Alignment(-.8, .72),
                angle: depth * .035,
                child: BingoStoryResultTicket(
                  entry: entries[index],
                  count: depth == 0 ? entries.length : 1,
                ),
              ),
            );
          },
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          widthFactor: 1,
          heightFactor: .56,
          child: Semantics(
            onIncrease: _model.swipeableStackController.swipeRight,
            onDecrease: _model.swipeableStackController.swipeLeft,
            child: GestureDetector(
              key: const ValueKey('bingo-story-ticket-gesture'),
              behavior: HitTestBehavior.opaque,
              onHorizontalDragDown: (details) {
                _rotation?.cancel();
                _dragStart = details.globalPosition.dx;
                _distance = 0;
              },
              onHorizontalDragUpdate: (details) {
                _distance = details.globalPosition.dx -
                    (_dragStart ?? details.globalPosition.dx);
              },
              onHorizontalDragEnd: _finishDrag,
              onHorizontalDragCancel: _finishDrag,
            ),
          ),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.vipResults && widget.dataStack != null) {
      return _story(widget.dataStack!);
    }
    final theme = FlutterFlowTheme.of(context);
    return SizedBox(
      width: double.infinity,
      height: widget.vipResults
          ? 56 + MediaQuery.textScalerOf(context).scale(72)
          : null,
      child: StreamBuilder<List<BingoRecord>>(
        stream: widget.dataStack == null
            ? queryBingoRecord(
                queryBuilder: (query) =>
                    query.orderBy('date', descending: true),
                singleRecord: true,
              )
            : null,
        builder: (context, snapshot) {
          if (widget.dataStack == null && !snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(color: theme.primary));
          }
          final entries = widget.dataStack ??
              snapshot.data?.firstOrNull?.dataStack ??
              const <DataStackStruct>[];
          if (entries.isEmpty) return const SizedBox.shrink();
          if (!widget.vipResults) return _story(entries);
          final stack = FlutterFlowSwipeableStack(
            key: ValueKey(entries.length),
            itemBuilder: (_, index) =>
                BingoResultTile(entry: entries[index], index: index),
            itemCount: entries.length,
            controller: _model.swipeableStackController,
            onSwipeFn: (_) {},
            onLeftSwipe: (_) {},
            onRightSwipe: (_) {},
            onUpSwipe: (_) {},
            onDownSwipe: (_) {},
            loop: true,
            cardDisplayCount: 3,
            cardPadding: EdgeInsets.all(theme.designToken.spacing.sm),
            scale: 1,
            backCardOffset: const Offset(0, 4),
          );
          return MediaQuery.disableAnimationsOf(context)
              ? stack
              : stack.animateOnPageLoad(_entrance);
        },
      ),
    );
  }
}
