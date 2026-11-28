import 'dart:math' as math;
import '/components/home_page_scaffold.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/backend/schema/structs/youtube_item_struct.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'youtube_feed_service.dart';
import 'youtube_model.dart';
export 'youtube_model.dart';

class YoutubeWidget extends StatefulWidget {
  const YoutubeWidget({super.key, this.loadVideos = loadYoutubeVideos});

  final Future<List<YoutubeItemStruct>> Function(
      {required String fallbackTitle}) loadVideos;

  static String routeName = 'youtube';
  static String routePath = '/youtube';

  @override
  State<YoutubeWidget> createState() => _YoutubeWidgetState();
}

class _YoutubeWidgetState extends State<YoutubeWidget> {
  Future<void>? _refresh;
  late YoutubeModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => YoutubeModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'youtube'});
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadVideos());
  }

  Future<void> _loadVideos({bool showLoader = true}) =>
      _refresh ??= _fetchVideos(showLoader).whenComplete(() => _refresh = null);

  Future<void> _fetchVideos(bool showLoader) async {
    if (!mounted) {
      return;
    }
    final fallbackTitle = FFLocalizations.of(context).getText('ytfallback');

    safeSetState(() {
      _isLoading = showLoader || _model.videos.isEmpty;
      _hasError = false;
    });

    logFirebaseEvent('YOUTUBE_PAGE_youtube_ON_INIT_STATE');
    logFirebaseEvent('youtube_backend_call');

    try {
      final videos = await widget.loadVideos(fallbackTitle: fallbackTitle);

      if (!mounted) {
        return;
      }

      logFirebaseEvent('youtube_update_page_state');
      safeSetState(() {
        _model.videos = videos;
        _isLoading = false;
        _hasError = false;
      });
    } catch (error) {
      debugPrint('YouTube feed error: $error');
      if (!mounted) {
        return;
      }

      safeSetState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _openVideo(YoutubeItemStruct video) async {
    if (video.link.isEmpty) {
      return;
    }
    logFirebaseEvent('YOUTUBE_PAGE_VideoCard_ON_TAP');
    logFirebaseEvent('VideoCard_launch_u_r_l');
    await launchURL(video.link);
  }

  String _publishedLabel(BuildContext context, String rawDate) {
    if (rawDate.trim().isEmpty) {
      return '';
    }

    final parsedDate = DateTime.tryParse(rawDate);
    final languageCode = FFLocalizations.of(context).languageCode;
    final dateLocale = languageCode == 'cr' ? 'fr' : languageCode;
    final formattedDate = parsedDate == null
        ? rawDate.trim()
        : dateTimeFormat(
            'd MMM y',
            parsedDate.toLocal(),
            locale: dateLocale,
          );

    return '${FFLocalizations.of(context).getText('ytd7pub1')} $formattedDate';
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    final tokens = theme.designToken;
    final spacing = tokens.spacing;
    final videos = _model.videos;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, bounds) {
          final inset = math.max(spacing.md,
              (bounds.maxWidth - HomePageScaffold.maxContentWidth) / 2);
          final width = bounds.maxWidth - inset * 2;
          final scaledWidth =
              width / (MediaQuery.textScalerOf(context).scale(16) / 16);
          final columns = scaledWidth >= 1000
              ? 3
              : scaledWidth >= 600
                  ? 2
                  : 1;
          return RefreshIndicator(
            color: theme.primary,
            backgroundColor: tokens.home.surface.colors.last,
            onRefresh: () => _loadVideos(showLoader: false),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                PinnedHeaderSliver(child: _buildHeader(context, inset)),
                SliverPadding(
                  padding:
                      EdgeInsets.fromLTRB(inset, spacing.sm, inset, spacing.sm),
                  sliver:
                      SliverToBoxAdapter(child: _buildSectionHeader(context)),
                ),
                if (_hasError && videos.isNotEmpty)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(inset, 0, inset, spacing.md),
                    sliver:
                        SliverToBoxAdapter(child: _buildRefreshError(context)),
                  ),
                if (videos.isEmpty)
                  SliverToBoxAdapter(
                    child: _isLoading
                        ? _buildLoadingState(context)
                        : _hasError
                            ? _buildErrorState(context)
                            : _buildEmptyState(context),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(inset, 0, inset, spacing.lg),
                    sliver: SliverList.separated(
                      itemCount: (videos.length / columns).ceil(),
                      separatorBuilder: (_, __) => SizedBox(height: spacing.md),
                      itemBuilder: (context, row) => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var col = 0; col < columns; col++) ...[
                            if (col > 0) SizedBox(width: spacing.md),
                            Expanded(
                              child: row * columns + col >= videos.length
                                  ? const SizedBox.shrink()
                                  : _buildVideoCard(
                                      context, videos[row * columns + col],
                                      isLatest: row == 0 && col == 0,
                                      compact: columns == 1 &&
                                          row > 0 &&
                                          scaledWidth >= 270),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double inset) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final strings = FFLocalizations.of(context);
    return ColoredBox(
      color: theme.primaryBackground,
      child: DecoratedBox(
        decoration: tokens.background.pageHeader(),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: inset, vertical: tokens.spacing.sm),
          child: Row(children: [
            BackButton(
                color: theme.primaryText,
                onPressed: () {
                  logFirebaseEvent('YOUTUBE_arrow_back_rounded_ICN_ON_TAP');
                  logFirebaseEvent('IconButton_navigate_back');
                  context.safePop();
                }),
            Expanded(
                child: Semantics(
                    header: true,
                    child: Text(strings.getText('youtube_story_label'),
                        style: theme.headlineMedium
                            .copyWith(fontWeight: FontWeight.w700)))),
          ]),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final count = _model.videos.length;
    final strings = FFLocalizations.of(context);
    return Row(children: [
      Expanded(
          child: Semantics(
              header: true,
              child:
                  Text(strings.getText('ytlatest'), style: theme.titleLarge))),
      if (count > 0)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: tokens.spacing.sm),
          child: Text(
              '$count ${strings.getText(count == 1 ? 'ytvidone' : 'ytvidmul')}',
              style: theme.labelMedium.copyWith(color: tokens.home.mutedText)),
        ),
      IconButton(
        tooltip: strings.getVariableText(
            frText: 'Actualiser les vidéos',
            enText: 'Refresh videos',
            crText: 'Rafrechi videyo yo'),
        onPressed: _isLoading ? null : () => _loadVideos(showLoader: false),
        icon: Icon(Icons.refresh_rounded, color: tokens.home.mutedText),
      ),
    ]);
  }

  Widget _buildVideoCard(BuildContext context, YoutubeItemStruct video,
      {required bool isLatest, required bool compact}) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final published = _publishedLabel(context, video.pubDate);
    final radius = BorderRadius.circular(tokens.radius.md);
    final details = Padding(
      padding: EdgeInsets.all(compact ? tokens.spacing.sm : tokens.spacing.md),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(video.title,
            style: theme.titleMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis),
        if (published.isNotEmpty) ...[
          SizedBox(height: tokens.spacing.xs),
          Text(published,
              style: theme.labelMedium.copyWith(color: tokens.home.mutedText)),
        ],
      ]),
    );

    final thumbnail = AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(fit: StackFit.expand, children: [
        ColoredBox(
          color: tokens.home.surface.colors.first,
          child: Center(
              child: Icon(Icons.video_library_outlined,
                  color: tokens.home.mutedText, size: compact ? 24 : 36)),
        ),
        if (video.thumbnail.isNotEmpty)
          CachedNetworkImage(
              imageUrl: video.thumbnail,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => const SizedBox.shrink()),
        if (isLatest)
          PositionedDirectional(
              top: tokens.spacing.sm,
              start: tokens.spacing.sm,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: theme.primary,
                    borderRadius: BorderRadius.circular(tokens.radius.full)),
                child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: tokens.spacing.sm,
                        vertical: tokens.spacing.xs),
                    child: Text(FFLocalizations.of(context).getText('ytnewest'),
                        style: theme.labelSmall.copyWith(
                            color: theme.onPrimary,
                            fontWeight: FontWeight.w700))),
              )),
        Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing.sm),
              child: DecoratedBox(
                  decoration: BoxDecoration(
                      color: tokens.background.home, shape: BoxShape.circle),
                  child: Icon(Icons.play_arrow_rounded,
                      size: compact ? 24 : 32, color: theme.primaryText)),
            )),
      ]),
    );
    return Semantics(
      button: true,
      enabled: video.link.isNotEmpty,
      label: [
        FFLocalizations.of(context).getText('ytwatch1'),
        video.title,
        published
      ].where((part) => part.isNotEmpty).join(', '),
      child: Material(
        color: theme.primaryBackground,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: tokens.home.panel,
          child: InkWell(
            onTap: video.link.isEmpty ? null : () => _openVideo(video),
            child: ExcludeSemantics(
                child: compact
                    ? Row(children: [
                        SizedBox(width: 112, child: thumbnail),
                        Expanded(child: details)
                      ])
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [thumbnail, details])),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(theme.designToken.spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40.0,
              height: 40.0,
              child: CircularProgressIndicator(
                strokeWidth: 3.0,
                valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
              ),
            ),
            SizedBox(height: theme.designToken.spacing.md),
            Text(
              FFLocalizations.of(context).getText('ytloading'),
              style: theme.bodyMedium.override(color: theme.secondaryText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return _buildMessageState(
      context,
      icon: Icons.wifi_off_rounded,
      title: FFLocalizations.of(context).getText('yterrttl'),
      description: FFLocalizations.of(context).getText('yterrdsc'),
      buttonText: FFLocalizations.of(context).getText('ytretry1'),
      onPressed: _loadVideos,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return _buildMessageState(
      context,
      icon: Icons.video_library_outlined,
      title: FFLocalizations.of(context).getText('ytemptyt'),
      description: FFLocalizations.of(context).getText('ytemptyd'),
      buttonText: FFLocalizations.of(context).getText('ytretry1'),
      onPressed: _loadVideos,
    );
  }

  Widget _buildMessageState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required Future<void> Function() onPressed,
  }) {
    final theme = FlutterFlowTheme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(theme.designToken.spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.0,
              height: 64.0,
              decoration: BoxDecoration(
                color: theme.primary.applyAlpha(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.primary, size: 30.0),
            ),
            SizedBox(height: theme.designToken.spacing.md),
            Text(
              title,
              style: theme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: theme.designToken.spacing.sm),
            Text(
              description,
              style: theme.bodyMedium.override(color: theme.secondaryText),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: theme.designToken.spacing.lg),
            FFButtonWidget(
              text: buttonText,
              icon: Icon(
                Icons.refresh_rounded,
                color: theme.onPrimary,
                size: 20.0,
              ),
              onPressed: onPressed,
              options: FFButtonOptions(
                height: 44.0,
                padding: EdgeInsets.symmetric(
                  horizontal: theme.designToken.spacing.lg,
                ),
                color: theme.primary,
                textStyle: theme.labelLarge.override(
                  color: theme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
                elevation: 0.0,
                borderRadius:
                    BorderRadius.circular(theme.designToken.radius.sm),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefreshError(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      padding: EdgeInsets.all(theme.designToken.spacing.sm),
      decoration: BoxDecoration(
        color: theme.error.applyAlpha(0.10),
        borderRadius: BorderRadius.circular(theme.designToken.radius.sm),
        border: Border.all(color: theme.error.applyAlpha(0.28)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: theme.error, size: 20.0),
          SizedBox(width: theme.designToken.spacing.sm),
          Expanded(
            child: Text(
              FFLocalizations.of(context).getText('ytrefrer'),
              style: theme.bodySmall,
            ),
          ),
          FlutterFlowIconButton(
            buttonSize: 36.0,
            borderRadius: theme.designToken.radius.sm,
            icon: Icon(Icons.refresh_rounded, color: theme.primary, size: 20.0),
            onPressed: () => _loadVideos(showLoader: false),
          ),
        ],
      ),
    );
  }
}
