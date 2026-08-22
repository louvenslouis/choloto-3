import '/autres/bingo/bingo/bingo_widget.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/stories/bule/bule_widget.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;

import 'story_page_model.dart';
export 'story_page_model.dart';

class StoryPageWidget extends StatefulWidget {
  const StoryPageWidget({
    super.key,
    required this.id,
  });

  final int? id;

  @override
  State<StoryPageWidget> createState() => _StoryPageWidgetState();
}

class _StoryPageWidgetState extends State<StoryPageWidget> {
  late StoryPageModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StoryPageModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final stories = FFAppState().stories.toList();
    final initialPage = stories.isEmpty
        ? 0
        : max(
            0,
            min(
              valueOrDefault<int>(widget.id, 0),
              stories.length - 1,
            ),
          );
    _model.pageViewController ??= PageController(initialPage: initialPage);

    return Container(
      width: double.infinity,
      height: MediaQuery.sizeOf(context).height,
      color: FlutterFlowTheme.of(context).primaryBackground,
      child: Stack(
        children: [
          if (stories.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 40.0),
              child: Column(
                children: [
                  _buildHeader(context, 0, 0),
                  const Expanded(child: _UnavailableStory()),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 40.0),
              child: PageView.builder(
                controller: _model.pageViewController,
                itemCount: stories.length,
                itemBuilder: (context, index) {
                  final story = stories[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        _buildHeader(context, index, stories.length),
                        const SizedBox(height: 10.0),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                            ),
                            child: _buildStoryContent(
                              context,
                              story,
                              index,
                              stories.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          if (stories.length > 1)
            Align(
              alignment: const AlignmentDirectional(0.0, -1.0),
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: smooth_page_indicator.SmoothPageIndicator(
                  controller: _model.pageViewController!,
                  count: stories.length,
                  axisDirection: Axis.horizontal,
                  onDotClicked: (index) async {
                    await _model.pageViewController!.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease,
                    );
                    safeSetState(() {});
                  },
                  effect: smooth_page_indicator.SlideEffect(
                    spacing: 8.0,
                    radius: 8.0,
                    dotWidth: 40.0,
                    dotHeight: 8.0,
                    dotColor: FlutterFlowTheme.of(context).accent1,
                    activeDotColor: FlutterFlowTheme.of(context).primary,
                    paintStyle: PaintingStyle.fill,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int index, int storyCount) {
    final localizations = FFLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Hero(
            tag: 'bule',
            transitionOnUserGestures: true,
            child: Material(
              color: Colors.transparent,
              child: BuleWidget(
                key: Key('story_bubble_${index}_of_$storyCount'),
              ),
            ),
          ),
          Tooltip(
            message: localizations.getVariableText(
              frText: 'Actualiser',
              enText: 'Refresh',
              crText: 'Aktyalize',
            ),
            child: FlutterFlowIconButton(
              borderRadius: 8.0,
              buttonSize: 40.0,
              icon: Icon(
                Icons.refresh,
                color: FlutterFlowTheme.of(context).onDecorative,
                size: 24.0,
              ),
              onPressed: () {
                logFirebaseEvent('STORY_PAGE_COMP_refresh_ICN_ON_TAP');
                logFirebaseEvent('IconButton_update_app_state');
                FFAppState().stories = [];
                safeSetState(() {});
              },
            ),
          ),
          FlutterFlowIconButton(
            key: const ValueKey('story-close-button'),
            borderRadius: 8.0,
            buttonSize: 40.0,
            icon: Icon(
              Icons.close_outlined,
              color: FlutterFlowTheme.of(context).onDecorative,
              size: 24.0,
            ),
            onPressed: () {
              logFirebaseEvent('STORY_close_outlined_ICN_ON_TAP');
              logFirebaseEvent('IconButton_navigate_to');
              context.pushNamed(HomeWidget.routeName);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStoryContent(
    BuildContext context,
    StoriesStruct story,
    int index,
    int storyCount,
  ) {
    if (story.hasBingo()) {
      return BingoWidget(key: Key('story_bingo_${index}_of_$storyCount'));
    }
    if (story.hasYoutubeLinks()) {
      return StreamBuilder<YoutubeLinksRecord>(
        stream: YoutubeLinksRecord.getDocument(story.youtubeLinks!),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _UnavailableStory();
          }
          if (!snapshot.hasData) {
            return Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            );
          }
          return _YouTubeStoryCard(record: snapshot.data!);
        },
      );
    }

    final text = story.postText.trim();
    if (text.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AutoSizeText(
            text,
            textAlign: TextAlign.center,
            maxLines: 12,
            minFontSize: 18.0,
            overflow: TextOverflow.ellipsis,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  color: FlutterFlowTheme.of(context).primaryText,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      );
    }

    return const _UnavailableStory();
  }
}

class _YouTubeStoryCard extends StatelessWidget {
  const _YouTubeStoryCard({required this.record});

  final YoutubeLinksRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final localizations = FFLocalizations.of(context);
    final videoId = _youtubeVideoId(record);
    final videoUrl = record.link.trim().isNotEmpty
        ? record.link.trim()
        : videoId.isNotEmpty
            ? 'https://www.youtube.com/watch?v=$videoId'
            : '';

    if (videoUrl.isEmpty) {
      return const _UnavailableStory();
    }

    final title = localizations.getVariableText(
      frText: 'Regarder cette vidéo',
      enText: 'Watch this video',
      crText: 'Gade videyo sa a',
    );
    final description = localizations.getVariableText(
      frText: 'Ouvrez cette vidéo sur YouTube pour la regarder.',
      enText: 'Open this video on YouTube to watch it.',
      crText: 'Louvri videyo sa a sou YouTube pou gade li.',
    );
    final buttonLabel = localizations.getVariableText(
      frText: 'Regarder sur YouTube',
      enText: 'Watch on YouTube',
      crText: 'Gade sou YouTube',
    );
    final thumbnailLabel = localizations.getVariableText(
      frText: 'Miniature de la vidéo YouTube',
      enText: 'YouTube video thumbnail',
      crText: 'Ti imaj videyo YouTube la',
    );

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420.0),
          child: Material(
            color: theme.secondaryBackground,
            elevation: 4.0,
            borderRadius: BorderRadius.circular(18.0),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  image: true,
                  label: thumbnailLabel,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: videoId.isEmpty
                        ? _YouTubeThumbnailFallback(theme: theme)
                        : Image.network(
                            'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _YouTubeThumbnailFallback(theme: theme),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.titleLarge.override(
                          fontFamily: 'Google sans flex',
                          color: theme.primaryText,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.0,
                        ),
                      ),
                      if (record.caption.trim().isNotEmpty) ...[
                        const SizedBox(height: 8.0),
                        Text(
                          record.caption.trim(),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.bodyMedium.override(
                            color: theme.primaryText,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8.0),
                      Text(
                        description,
                        style: theme.bodyMedium.override(
                          color: theme.secondaryText,
                          letterSpacing: 0.0,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => launchURL(videoUrl),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(buttonLabel),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _YouTubeThumbnailFallback extends StatelessWidget {
  const _YouTubeThumbnailFallback({required this.theme});

  final FlutterFlowTheme theme;

  @override
  Widget build(BuildContext context) => Container(
        color: theme.alternate,
        alignment: Alignment.center,
        child: Icon(
          Icons.play_circle_fill_rounded,
          color: theme.primary,
          size: 72.0,
        ),
      );
}

class _UnavailableStory extends StatelessWidget {
  const _UnavailableStory();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final localizations = FFLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.hide_image_outlined,
              color: theme.secondaryText,
              size: 48.0,
            ),
            const SizedBox(height: 12.0),
            Text(
              localizations.getVariableText(
                frText: 'Contenu indisponible',
                enText: 'Content unavailable',
                crText: 'Kontni an pa disponib',
              ),
              textAlign: TextAlign.center,
              style: theme.titleMedium.override(
                fontFamily: 'Google sans flex',
                color: theme.primaryText,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.0,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              localizations.getVariableText(
                frText: 'Cette actualité n’est plus disponible.',
                enText: 'This story is no longer available.',
                crText: 'Aktyalite sa a pa disponib ankò.',
              ),
              textAlign: TextAlign.center,
              style: theme.bodyMedium.override(
                color: theme.secondaryText,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _youtubeVideoId(YoutubeLinksRecord record) {
  final storedId = record.id.trim();
  if (storedId.isNotEmpty) {
    return storedId;
  }

  final uri = Uri.tryParse(record.link.trim());
  if (uri == null) {
    return '';
  }
  final queryId = uri.queryParameters['v']?.trim() ?? '';
  if (queryId.isNotEmpty) {
    return queryId;
  }
  if (uri.host.contains('youtu.be') && uri.pathSegments.isNotEmpty) {
    return uri.pathSegments.first.trim();
  }
  return '';
}
