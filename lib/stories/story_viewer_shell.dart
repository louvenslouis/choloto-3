import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const cholotoStoryAspectRatio = 9.0 / 16.0;
const cholotoStoryMobileBreakpoint = 600.0;

/// Shared CHOLOTO chrome for portrait Stories.
///
/// Content remains owned by each Story type, while navigation, progress,
/// keyboard support and the publication header stay visually consistent.
class StoryViewerShell extends StatefulWidget {
  const StoryViewerShell({
    super.key,
    required this.frameKey,
    required this.keyPrefix,
    required this.title,
    required this.avatar,
    required this.child,
    required this.storyCount,
    required this.currentStoryIndex,
    required this.progressAnimation,
    required this.onPreviousStory,
    required this.onNextStory,
    required this.onClose,
    required this.previousLabel,
    required this.nextLabel,
    required this.closeLabel,
    this.publishedAt,
    this.background,
    this.bottomOverlay,
    this.onPause,
    this.onResume,
    this.navigationEnabled = true,
    this.navigationAboveChild = false,
    this.showHeader = true,
    this.showClose = true,
    this.aspectRatio = cholotoStoryAspectRatio,
    this.mobileBreakpoint = cholotoStoryMobileBreakpoint,
  });

  final Key frameKey;
  final String keyPrefix;
  final String title;
  final Widget avatar;
  final Widget child;
  final Widget? background;
  final Widget? bottomOverlay;
  final DateTime? publishedAt;
  final int storyCount;
  final int currentStoryIndex;
  final Animation<double> progressAnimation;
  final VoidCallback onPreviousStory;
  final VoidCallback onNextStory;
  final VoidCallback onClose;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final bool navigationEnabled;
  final bool navigationAboveChild;
  final bool showHeader;
  final bool showClose;
  final String previousLabel;
  final String nextLabel;
  final String closeLabel;
  final double aspectRatio;
  final double mobileBreakpoint;

  @override
  State<StoryViewerShell> createState() => _StoryViewerShellState();
}

class _StoryViewerShellState extends State<StoryViewerShell> {
  final FocusNode _keyboardFocusNode = FocusNode(
    debugLabel: 'CHOLOTO Story keyboard navigation',
  );

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (widget.navigationEnabled &&
        event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      widget.onPreviousStory();
      return KeyEventResult.handled;
    }
    if (widget.navigationEnabled &&
        event.logicalKey == LogicalKeyboardKey.arrowRight) {
      widget.onNextStory();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onClose();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (!widget.navigationEnabled) return;
    final velocity = details.primaryVelocity ?? 0.0;
    if (velocity.abs() < 160.0) return;
    if (velocity < 0.0) {
      widget.onNextStory();
    } else {
      widget.onPreviousStory();
    }
  }

  Widget _buildNavigationOverlay() => Positioned.fill(
        top: 80.0,
        bottom: 80.0,
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                label: widget.previousLabel,
                button: true,
                child: GestureDetector(
                  key: ValueKey(
                    '${widget.keyPrefix}-story-previous-area',
                  ),
                  behavior: HitTestBehavior.translucent,
                  onTap: widget.onPreviousStory,
                ),
              ),
            ),
            Expanded(
              child: Semantics(
                label: widget.nextLabel,
                button: true,
                child: GestureDetector(
                  key: ValueKey(
                    '${widget.keyPrefix}-story-next-area',
                  ),
                  behavior: HitTestBehavior.translucent,
                  onTap: widget.onNextStory,
                ),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final frame = ColoredBox(
      color: theme.primaryBackground,
      child: Focus(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: _handleHorizontalDragEnd,
          onLongPressStart: (_) => widget.onPause?.call(),
          onLongPressEnd: (_) => widget.onResume?.call(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.background != null) widget.background!,
              if (widget.navigationEnabled && !widget.navigationAboveChild)
                _buildNavigationOverlay(),
              widget.child,
              if (widget.navigationEnabled && widget.navigationAboveChild)
                _buildNavigationOverlay(),
              if (widget.bottomOverlay != null) widget.bottomOverlay!,
              if (widget.showHeader)
                _StoryViewerHeader(
                  keyPrefix: widget.keyPrefix,
                  title: widget.title,
                  avatar: widget.avatar,
                  publishedAt: widget.publishedAt,
                ),
              if (widget.showClose)
                _StoryViewerCloseButton(
                  keyPrefix: widget.keyPrefix,
                  label: widget.closeLabel,
                  onClose: widget.onClose,
                ),
              if (widget.storyCount > 0)
                _StoryViewerProgress(
                  keyPrefix: widget.keyPrefix,
                  storyCount: widget.storyCount,
                  currentStoryIndex: widget.currentStoryIndex,
                  progressAnimation: widget.progressAnimation,
                ),
            ],
          ),
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final fillsMobileViewport =
            constraints.maxWidth <= widget.mobileBreakpoint &&
                constraints.maxHeight >= constraints.maxWidth;

        if (fillsMobileViewport) {
          return SizedBox.expand(key: widget.frameKey, child: frame);
        }

        return Center(
          child: AspectRatio(
            key: widget.frameKey,
            aspectRatio: widget.aspectRatio,
            child: frame,
          ),
        );
      },
    );
  }
}

class _StoryViewerHeader extends StatelessWidget {
  const _StoryViewerHeader({
    required this.keyPrefix,
    required this.title,
    required this.avatar,
    required this.publishedAt,
  });

  final String keyPrefix;
  final String title;
  final Widget avatar;
  final DateTime? publishedAt;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;
    final localizations = FFLocalizations.of(context);

    return SafeArea(
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            spacing.md,
            spacing.md,
            72.0,
            spacing.md,
          ),
          child: Row(
            key: ValueKey('$keyPrefix-story-header'),
            children: [
              SizedBox.square(dimension: 44.0, child: avatar),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      key: ValueKey('$keyPrefix-story-header-title'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (publishedAt != null)
                      Text(
                        dateTimeFormat(
                          'relative',
                          publishedAt!,
                          locale: localizations.languageCode,
                        ),
                        key: ValueKey('$keyPrefix-story-published-age'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.labelMedium.copyWith(
                          color: theme.secondaryText,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoryViewerCloseButton extends StatelessWidget {
  const _StoryViewerCloseButton({
    required this.keyPrefix,
    required this.label,
    required this.onClose,
  });

  final String keyPrefix;
  final String label;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return SafeArea(
      child: Align(
        alignment: AlignmentDirectional.topEnd,
        child: Padding(
          padding: EdgeInsets.all(theme.designToken.spacing.md),
          child: Tooltip(
            message: label,
            child: FlutterFlowIconButton(
              key: ValueKey('$keyPrefix-story-close-button'),
              borderRadius: theme.designToken.radius.sm,
              buttonSize: 40.0,
              icon: Icon(
                Icons.close_outlined,
                color: theme.primaryText,
                size: 24.0,
              ),
              onPressed: onClose,
            ),
          ),
        ),
      ),
    );
  }
}

class _StoryViewerProgress extends StatelessWidget {
  const _StoryViewerProgress({
    required this.keyPrefix,
    required this.storyCount,
    required this.currentStoryIndex,
    required this.progressAnimation,
  });

  final String keyPrefix;
  final int storyCount;
  final int currentStoryIndex;
  final Animation<double> progressAnimation;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;

    return SafeArea(
      child: Align(
        alignment: AlignmentDirectional.topCenter,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            spacing.sm,
            spacing.xs,
            spacing.sm,
            0.0,
          ),
          child: AnimatedBuilder(
            animation: progressAnimation,
            builder: (context, _) => Row(
              key: ValueKey('$keyPrefix-story-progress'),
              children: List.generate(storyCount, (index) {
                final progress = index < currentStoryIndex
                    ? 1.0
                    : index == currentStoryIndex
                        ? progressAnimation.value
                        : 0.0;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      end: index == storyCount - 1 ? 0.0 : spacing.xs,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        theme.designToken.radius.full,
                      ),
                      child: Container(
                        key: ValueKey(
                          '$keyPrefix-story-progress-track-$index',
                        ),
                        height: 3.0,
                        color: theme.secondaryText.withValues(alpha: 0.35),
                        alignment: AlignmentDirectional.centerStart,
                        child: FractionallySizedBox(
                          key: ValueKey(
                            '$keyPrefix-story-progress-fill-$index',
                          ),
                          widthFactor: progress,
                          heightFactor: 1.0,
                          child: ColoredBox(color: theme.primary),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
