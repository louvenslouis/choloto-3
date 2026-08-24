import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

const youtubeStoryAspectRatio = 9.0 / 16.0;
const youtubeStoryMobileBreakpoint = 600.0;
const youtubeStoryDuration = Duration(seconds: 15);

class YoutubeStoryButton extends StatelessWidget {
  const YoutubeStoryButton({
    super.key,
    required this.video,
    required this.onTap,
  });

  final YoutubeItemStruct video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;
    final localizations = FFLocalizations.of(context);

    return Semantics(
      label: '${localizations.getText('youtube_story_open')}: ${video.title}',
      button: true,
      excludeSemantics: true,
      child: InkWell(
        key: const ValueKey('youtube-story-button'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(theme.designToken.radius.md),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.sm,
            vertical: spacing.xs,
          ),
          child: SizedBox(
            width: 80.0,
            child: Center(
              child: Container(
                key: const ValueKey('youtube-story-circle'),
                width: 72.0,
                height: 72.0,
                padding: EdgeInsets.all(spacing.xs),
                decoration: BoxDecoration(
                  color: theme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [theme.designToken.shadow.sm],
                ),
                child: ClipOval(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        key: const ValueKey('youtube-story-thumbnail'),
                        imageUrl: video.thumbnail,
                        fit: BoxFit.cover,
                        fadeInDuration: const Duration(milliseconds: 180),
                        placeholder: (context, _) => ColoredBox(
                          color: theme.secondaryBackground,
                        ),
                        errorWidget: (context, _, __) => ColoredBox(
                          color: theme.secondaryBackground,
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: theme.primary,
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.bottomCenter,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: spacing.xs),
                          color: theme.primary.applyAlpha(0.92),
                          child: Text(
                            localizations.getText('youtube_story_label'),
                            key: const ValueKey('youtube-story-label'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: theme.labelSmall.copyWith(
                              color: theme.onPrimary,
                              fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }
}

class YoutubeStoryViewer extends StatefulWidget {
  const YoutubeStoryViewer({
    super.key,
    required this.videos,
    this.onClose,
    this.onOpenVideo,
    this.storyDuration = youtubeStoryDuration,
  }) : assert(videos.length > 0);

  final List<YoutubeItemStruct> videos;
  final VoidCallback? onClose;
  final Future<void> Function(YoutubeItemStruct video)? onOpenVideo;
  final Duration storyDuration;

  @override
  State<YoutubeStoryViewer> createState() => _YoutubeStoryViewerState();
}

class _YoutubeStoryViewerState extends State<YoutubeStoryViewer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  var _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: widget.storyDuration,
    )..addStatusListener(_onProgressStatusChanged);
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController
      ..removeStatusListener(_onProgressStatusChanged)
      ..dispose();
    super.dispose();
  }

  void _onProgressStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _showNextStory();
    }
  }

  void _selectStory(int index) {
    setState(() => _currentIndex = index);
    _progressController.forward(from: 0.0);
  }

  void _showPreviousStory() {
    if (_currentIndex == 0) {
      _progressController.forward(from: 0.0);
      return;
    }
    _selectStory(_currentIndex - 1);
  }

  void _showNextStory() {
    if (!mounted) {
      return;
    }
    if (_currentIndex >= widget.videos.length - 1) {
      _close();
      return;
    }
    _selectStory(_currentIndex + 1);
  }

  void _close() {
    _progressController.stop();
    if (widget.onClose != null) {
      widget.onClose!();
      return;
    }
    Navigator.of(context).maybePop();
  }

  Future<void> _openVideo(YoutubeItemStruct video) async {
    if (video.link.isEmpty) {
      return;
    }

    _progressController.stop();
    try {
      if (widget.onOpenVideo != null) {
        await widget.onOpenVideo!(video);
      } else {
        await launchURL(video.link);
      }
    } finally {
      if (mounted) {
        _progressController.forward(from: 0.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final video = widget.videos[_currentIndex];
    final publishedAt = DateTime.tryParse(video.pubDate);
    final frame = ColoredBox(
      color: theme.primaryBackground,
      child: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                theme.designToken.spacing.md,
                76.0,
                theme.designToken.spacing.md,
                theme.designToken.spacing.lg,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    image: true,
                    label: FFLocalizations.of(context)
                        .getText('youtube_story_thumbnail'),
                    child: AspectRatio(
                      aspectRatio: 16.0 / 9.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          theme.designToken.radius.md,
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              key: ValueKey(
                                'youtube-story-viewer-thumbnail-$_currentIndex',
                              ),
                              imageUrl: video.thumbnail,
                              fit: BoxFit.cover,
                              placeholder: (context, _) => ColoredBox(
                                color: theme.secondaryBackground,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: theme.primary,
                                    strokeWidth: 3.0,
                                  ),
                                ),
                              ),
                              errorWidget: (context, _, __) => ColoredBox(
                                color: theme.secondaryBackground,
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: theme.secondaryText,
                                  size: 48.0,
                                ),
                              ),
                            ),
                            Center(
                              child: Container(
                                width: 56.0,
                                height: 56.0,
                                decoration: BoxDecoration(
                                  color: theme.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [theme.designToken.shadow.md],
                                ),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: theme.onPrimary,
                                  size: 36.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: theme.designToken.spacing.lg),
                  Text(
                    video.title,
                    key: const ValueKey('youtube-story-title'),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: theme.designToken.spacing.lg),
                  FFButtonWidget(
                    key: const ValueKey('youtube-story-watch-button'),
                    text: FFLocalizations.of(context).getText('ytwatch1'),
                    icon: Icon(
                      Icons.open_in_new_rounded,
                      color: theme.onPrimary,
                      size: 20.0,
                    ),
                    onPressed: video.link.isEmpty
                        ? null
                        : () async => _openVideo(video),
                    options: FFButtonOptions(
                      height: 48.0,
                      color: theme.primary,
                      textStyle: theme.labelLarge.copyWith(
                        color: theme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(
                        theme.designToken.radius.sm,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            top: 76.0,
            bottom: 96.0,
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: FFLocalizations.of(context)
                        .getText('youtube_story_previous'),
                    button: true,
                    child: GestureDetector(
                      key: const ValueKey('youtube-story-previous-area'),
                      behavior: HitTestBehavior.translucent,
                      onTap: _showPreviousStory,
                    ),
                  ),
                ),
                Expanded(
                  child: Semantics(
                    label: FFLocalizations.of(context)
                        .getText('youtube_story_next'),
                    button: true,
                    child: GestureDetector(
                      key: const ValueKey('youtube-story-next-area'),
                      behavior: HitTestBehavior.translucent,
                      onTap: _showNextStory,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _YoutubeStoryHeader(publishedAt: publishedAt),
          _YoutubeStoryCloseButton(onClose: _close),
          _YoutubeStoryProgress(
            storyCount: widget.videos.length,
            currentStoryIndex: _currentIndex,
            progressAnimation: _progressController,
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final fillsMobileViewport =
            constraints.maxWidth <= youtubeStoryMobileBreakpoint &&
                constraints.maxHeight >= constraints.maxWidth;

        if (fillsMobileViewport) {
          return SizedBox.expand(
            key: const ValueKey('youtube-story-viewer'),
            child: frame,
          );
        }

        return Center(
          child: AspectRatio(
            key: const ValueKey('youtube-story-viewer'),
            aspectRatio: youtubeStoryAspectRatio,
            child: frame,
          ),
        );
      },
    );
  }
}

class _YoutubeStoryHeader extends StatelessWidget {
  const _YoutubeStoryHeader({required this.publishedAt});

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
            key: const ValueKey('youtube-story-header'),
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                padding: EdgeInsets.all(spacing.xs),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/youtube_-_Moyenne.png',
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.getText('youtube_story_label'),
                      key: const ValueKey('youtube-story-header-title'),
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
                        key: const ValueKey('youtube-story-published-age'),
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

class _YoutubeStoryCloseButton extends StatelessWidget {
  const _YoutubeStoryCloseButton({required this.onClose});

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
            message: FFLocalizations.of(context).getText('youtube_story_close'),
            child: FlutterFlowIconButton(
              key: const ValueKey('youtube-story-close-button'),
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

class _YoutubeStoryProgress extends StatelessWidget {
  const _YoutubeStoryProgress({
    required this.storyCount,
    required this.currentStoryIndex,
    required this.progressAnimation,
  });

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
              key: const ValueKey('youtube-story-progress'),
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
                      borderRadius:
                          BorderRadius.circular(theme.designToken.radius.full),
                      child: Container(
                        key: ValueKey('youtube-story-progress-track-$index'),
                        height: 3.0,
                        color: theme.secondaryText.withValues(alpha: 0.35),
                        alignment: AlignmentDirectional.centerStart,
                        child: FractionallySizedBox(
                          key: ValueKey('youtube-story-progress-fill-$index'),
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

Future<T?> showYoutubeStoryDialog<T>({
  required BuildContext context,
  required List<YoutubeItemStruct> videos,
  Duration storyDuration = youtubeStoryDuration,
}) {
  if (videos.isEmpty) {
    return Future<T?>.value();
  }

  return showDialog<T>(
    context: context,
    useSafeArea: false,
    builder: (dialogContext) {
      final theme = FlutterFlowTheme.of(dialogContext);

      return Dialog.fullscreen(
        key: const ValueKey('youtube-story-dialog'),
        backgroundColor: theme.primaryBackground,
        child: YoutubeStoryViewer(
          videos: videos,
          storyDuration: storyDuration,
        ),
      );
    },
  );
}
