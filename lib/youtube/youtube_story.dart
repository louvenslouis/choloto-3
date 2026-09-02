import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/stories/story_viewer_shell.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

const youtubeStoryAspectRatio = cholotoStoryAspectRatio;
const youtubeStoryMobileBreakpoint = cholotoStoryMobileBreakpoint;
const youtubeStoryDuration = Duration(seconds: 15);

class YoutubeStoryButton extends StatelessWidget {
  const YoutubeStoryButton({
    super.key,
    required this.video,
    required this.onTap,
    this.viewed = false,
    this.storyCount = 1,
  });

  final YoutubeItemStruct video;
  final VoidCallback onTap;
  final bool viewed;
  final int storyCount;

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
              child: SizedBox(
                key: const ValueKey('youtube-story-circle'),
                width: 72.0,
                height: 72.0,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 72.0,
                      height: 72.0,
                      padding: EdgeInsets.all(spacing.xs),
                      decoration: BoxDecoration(
                        color: viewed ? theme.alternate : theme.primary,
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
                                padding: EdgeInsets.symmetric(
                                  vertical: spacing.xs,
                                ),
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
                    if (storyCount > 1)
                      PositionedDirectional(
                        top: 0.0,
                        end: 0.0,
                        child: Container(
                          key: const ValueKey('youtube-story-count'),
                          constraints: const BoxConstraints(
                            minWidth: 20.0,
                            minHeight: 20.0,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing.xs,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: theme.primary,
                            borderRadius: BorderRadius.circular(
                              theme.designToken.radius.full,
                            ),
                            border: Border.all(
                              color: theme.primaryBackground,
                              width: 2.0,
                            ),
                          ),
                          child: Text(
                            '$storyCount',
                            style: theme.labelSmall.copyWith(
                              color: theme.onPrimary,
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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _progressController;
  var _currentIndex = 0;
  var _lifecyclePaused = false;
  var _accessibilityPaused = false;
  var _thumbnailFailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _progressController = AnimationController(
      vsync: this,
      duration: widget.storyDuration,
    )..addStatusListener(_onProgressStatusChanged);
    _progressController.forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _progressController
      ..removeStatusListener(_onProgressStatusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.maybeOf(context);
    final shouldPause = mediaQuery?.accessibleNavigation == true ||
        mediaQuery?.disableAnimations == true;
    if (_accessibilityPaused == shouldPause) return;
    _accessibilityPaused = shouldPause;
    if (shouldPause) {
      _pauseProgress();
    } else {
      _resumeProgress();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecyclePaused = state != AppLifecycleState.resumed;
    if (_lifecyclePaused) {
      _pauseProgress();
    } else {
      _resumeProgress();
    }
  }

  void _pauseProgress() => _progressController.stop();

  void _resumeProgress() {
    if (mounted && !_lifecyclePaused && !_accessibilityPaused) {
      _progressController.forward();
    }
  }

  void _onProgressStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _showNextStory();
    }
  }

  void _selectStory(int index) {
    setState(() {
      _currentIndex = index;
      _thumbnailFailed = false;
    });
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
      _resumeProgress();
    }
  }

  Future<void> _retryThumbnail(String imageUrl) async {
    if (imageUrl.isNotEmpty) {
      await CachedNetworkImage.evictFromCache(imageUrl);
    }
    if (mounted) setState(() => _thumbnailFailed = false);
  }

  void _markThumbnailFailed() {
    if (_thumbnailFailed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_thumbnailFailed) {
        setState(() => _thumbnailFailed = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final spacing = theme.designToken.spacing;
    final localizations = FFLocalizations.of(context);
    final video = widget.videos[_currentIndex];
    final publishedAt = DateTime.tryParse(video.pubDate);

    return StoryViewerShell(
      frameKey: const ValueKey('youtube-story-viewer'),
      keyPrefix: 'youtube',
      title: localizations.getText('youtube_story_label'),
      publishedAt: publishedAt,
      storyCount: widget.videos.length,
      currentStoryIndex: _currentIndex,
      progressAnimation: _progressController,
      onPreviousStory: _showPreviousStory,
      onNextStory: _showNextStory,
      onClose: _close,
      onPause: _pauseProgress,
      onResume: _resumeProgress,
      previousLabel: localizations.getText('youtube_story_previous'),
      nextLabel: localizations.getText('youtube_story_next'),
      closeLabel: localizations.getText('youtube_story_close'),
      avatar: Container(
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
      background: _YoutubeStoryBackdrop(imageUrl: video.thumbnail),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            spacing.md,
            76.0,
            spacing.md,
            spacing.lg,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IgnorePointer(
                child: Semantics(
                  image: true,
                  label: localizations.getText('youtube_story_thumbnail'),
                  child: AspectRatio(
                    aspectRatio: 16.0 / 9.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        theme.designToken.radius.md,
                      ),
                      child: CachedNetworkImage(
                        key: ValueKey(
                          'youtube-story-viewer-thumbnail-$_currentIndex',
                        ),
                        imageUrl: video.thumbnail,
                        fit: BoxFit.cover,
                        fadeInDuration: const Duration(milliseconds: 180),
                        placeholder: (context, _) => _YoutubeThumbnailLoading(
                          key: const ValueKey(
                            'youtube-story-thumbnail-loading',
                          ),
                          theme: theme,
                        ),
                        errorWidget: (context, _, __) {
                          _markThumbnailFailed();
                          return const _YoutubeThumbnailError();
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: spacing.md),
              Container(
                padding: EdgeInsets.all(spacing.md),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(
                    theme.designToken.radius.md,
                  ),
                  border: Border.all(
                    color: theme.primaryText.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      video.title,
                      key: const ValueKey('youtube-story-title'),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: theme.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: spacing.md),
                    if (_thumbnailFailed) ...[
                      OutlinedButton.icon(
                        key: const ValueKey('youtube-story-thumbnail-retry'),
                        onPressed: () => _retryThumbnail(video.thumbnail),
                        icon: const Icon(Icons.refresh_rounded, size: 18.0),
                        label: Text(localizations.getText('story_retry')),
                      ),
                      SizedBox(height: spacing.sm),
                    ],
                    FFButtonWidget(
                      key: const ValueKey('youtube-story-watch-button'),
                      text: localizations.getText('ytwatch1'),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _YoutubeStoryBackdrop extends StatelessWidget {
  const _YoutubeStoryBackdrop({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    if (imageUrl.isEmpty) return ColoredBox(color: theme.primaryBackground);

    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 22.0, sigmaY: 22.0),
          child: Transform.scale(
            scale: 1.16,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 180),
              placeholder: (_, __) => ColoredBox(
                color: theme.secondaryBackground,
              ),
              errorWidget: (_, __, ___) => ColoredBox(
                color: theme.primaryBackground,
              ),
            ),
          ),
        ),
        ColoredBox(
          color: theme.primaryBackground.withValues(alpha: 0.72),
        ),
      ],
    );
  }
}

class _YoutubeThumbnailLoading extends StatelessWidget {
  const _YoutubeThumbnailLoading({super.key, required this.theme});

  final FlutterFlowTheme theme;

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: theme.secondaryBackground,
        child: Center(
          child: SizedBox.square(
            dimension: 30.0,
            child: CircularProgressIndicator(
              color: theme.primary,
              strokeWidth: 3.0,
            ),
          ),
        ),
      );
}

class _YoutubeThumbnailError extends StatelessWidget {
  const _YoutubeThumbnailError();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return ColoredBox(
      color: theme.secondaryBackground,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: theme.secondaryText,
          size: 40.0,
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
