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
  const YoutubeWidget({super.key});

  static String routeName = 'youtube';
  static String routePath = '/youtube';

  @override
  State<YoutubeWidget> createState() => _YoutubeWidgetState();
}

class _YoutubeWidgetState extends State<YoutubeWidget> {
  static const String _channelUrl =
      'https://www.youtube.com/channel/UC6N0qcctRmlaUEYdzhR0-Hw';

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

  Future<void> _loadVideos({bool showLoader = true}) async {
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
      final videos = await loadYoutubeVideos(fallbackTitle: fallbackTitle);

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

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(
          backgroundColor: theme.secondaryBackground,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: theme.designToken.radius.full,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: theme.info,
              size: 28.0,
            ),
            onPressed: () async {
              logFirebaseEvent('YOUTUBE_arrow_back_rounded_ICN_ON_TAP');
              logFirebaseEvent('IconButton_navigate_back');
              context.pop();
            },
          ),
          title: Text(
            FFLocalizations.of(context).getText('ho2ij0yt'),
            style: theme.headlineMedium.override(
              fontFamily: 'Google sans flex',
              color: theme.info,
              fontSize: 22.0,
              letterSpacing: 0.0,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.only(
                end: theme.designToken.spacing.sm,
              ),
              child: FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: theme.designToken.radius.sm,
                buttonSize: 44.0,
                showLoadingIndicator: true,
                icon: Icon(
                  Icons.refresh_rounded,
                  color: theme.info,
                  size: 24.0,
                ),
                onPressed:
                    _isLoading ? null : () => _loadVideos(showLoader: false),
              ),
            ),
          ],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760.0),
              child: RefreshIndicator(
                color: theme.primary,
                backgroundColor: theme.secondaryBackground,
                onRefresh: () => _loadVideos(showLoader: false),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        theme.designToken.spacing.md,
                        theme.designToken.spacing.md,
                        theme.designToken.spacing.md,
                        0.0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _buildChannelCard(context),
                      ),
                    ),
                    if (_isLoading && _model.videos.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildLoadingState(context),
                      )
                    else if (_hasError && _model.videos.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildErrorState(context),
                      )
                    else if (_model.videos.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(context),
                      )
                    else ...[
                      if (_hasError)
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            theme.designToken.spacing.md,
                            theme.designToken.spacing.md,
                            theme.designToken.spacing.md,
                            0.0,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: _buildRefreshError(context),
                          ),
                        ),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          theme.designToken.spacing.md,
                          theme.designToken.spacing.lg,
                          theme.designToken.spacing.md,
                          theme.designToken.spacing.sm,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: _buildSectionHeader(context),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          theme.designToken.spacing.md,
                          0.0,
                          theme.designToken.spacing.md,
                          theme.designToken.spacing.md,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Padding(
                              padding: EdgeInsets.only(
                                bottom: theme.designToken.spacing.md,
                              ),
                              child: _buildVideoCard(
                                context,
                                _model.videos[index],
                                isLatest: index == 0,
                              ),
                            ),
                            childCount: _model.videos.length,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChannelCard(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      padding: EdgeInsets.all(theme.designToken.spacing.md),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(theme.designToken.radius.md),
        border: Border.all(color: theme.alternate.applyAlpha(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 56.0,
                height: 56.0,
                padding: EdgeInsets.all(theme.designToken.spacing.sm),
                decoration: BoxDecoration(
                  color: theme.primaryBackground,
                  borderRadius:
                      BorderRadius.circular(theme.designToken.radius.sm),
                ),
                child: Image.asset(
                  'assets/images/youtube_-_Moyenne.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: theme.designToken.spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FFLocalizations.of(context).getText('ytch4nel'),
                      style: theme.titleMedium,
                    ),
                    SizedBox(height: theme.designToken.spacing.xs),
                    Text(
                      FFLocalizations.of(context).getText('ytintr01'),
                      style: theme.bodySmall.override(
                        color: theme.secondaryText,
                        lineHeight: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: theme.designToken.spacing.md),
          FFButtonWidget(
            text: FFLocalizations.of(context).getText('ytchnbtn'),
            icon: Icon(
              Icons.subscriptions_outlined,
              color: theme.onPrimary,
              size: 20.0,
            ),
            onPressed: () async {
              logFirebaseEvent('YOUTUBE_PAGE_ChannelButton_ON_TAP');
              await launchURL(_channelUrl);
            },
            options: FFButtonOptions(
              height: 44.0,
              color: theme.primary,
              textStyle: theme.labelLarge.override(
                color: theme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
              elevation: 0.0,
              borderRadius: BorderRadius.circular(theme.designToken.radius.sm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final count = _model.videos.length;
    final countLabel = count == 1
        ? FFLocalizations.of(context).getText('ytvidone')
        : FFLocalizations.of(context).getText('ytvidmul');

    return Row(
      children: [
        Expanded(
          child: Text(
            FFLocalizations.of(context).getText('ytlatest'),
            style: theme.titleLarge,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: theme.designToken.spacing.sm,
            vertical: theme.designToken.spacing.xs,
          ),
          decoration: BoxDecoration(
            color: theme.primary.applyAlpha(0.14),
            borderRadius: BorderRadius.circular(theme.designToken.radius.full),
          ),
          child: Text(
            '$count $countLabel',
            style: theme.labelSmall.override(
              color: theme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoCard(
    BuildContext context,
    YoutubeItemStruct video, {
    required bool isLatest,
  }) {
    final theme = FlutterFlowTheme.of(context);
    final publishedLabel = _publishedLabel(context, video.pubDate);

    return Semantics(
      button: true,
      label:
          '${FFLocalizations.of(context).getText('ytwatch1')}: ${video.title}',
      child: Material(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(theme.designToken.radius.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: video.link.isEmpty ? null : () => _openVideo(video),
          splashColor: theme.primary.applyAlpha(0.12),
          highlightColor: theme.primary.applyAlpha(0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: video.thumbnail,
                      fadeInDuration: const Duration(milliseconds: 180),
                      fadeOutDuration: const Duration(milliseconds: 100),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: theme.primaryBackground,
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 28.0,
                          height: 28.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(theme.primary),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: theme.primaryBackground,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: theme.secondaryText,
                          size: 40.0,
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.38),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 52.0,
                        height: 52.0,
                        decoration: BoxDecoration(
                          color: theme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [theme.designToken.shadow.md],
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: theme.onPrimary,
                          size: 32.0,
                        ),
                      ),
                    ),
                    if (isLatest)
                      PositionedDirectional(
                        top: theme.designToken.spacing.sm,
                        start: theme.designToken.spacing.sm,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: theme.designToken.spacing.sm,
                            vertical: theme.designToken.spacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: theme.primary,
                            borderRadius: BorderRadius.circular(
                              theme.designToken.radius.full,
                            ),
                          ),
                          child: Text(
                            FFLocalizations.of(context).getText('ytnewest'),
                            style: theme.labelSmall.override(
                              color: theme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(theme.designToken.spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.titleMedium.override(lineHeight: 1.25),
                    ),
                    SizedBox(height: theme.designToken.spacing.sm),
                    Row(
                      children: [
                        if (publishedLabel.isNotEmpty) ...[
                          Icon(
                            Icons.calendar_today_outlined,
                            color: theme.secondaryText,
                            size: 16.0,
                          ),
                          SizedBox(width: theme.designToken.spacing.sm),
                          Expanded(
                            child: Text(
                              publishedLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.labelMedium.override(
                                color: theme.secondaryText,
                              ),
                            ),
                          ),
                        ] else
                          const Spacer(),
                        SizedBox(width: theme.designToken.spacing.sm),
                        Icon(
                          Icons.open_in_new_rounded,
                          color: theme.primary,
                          size: 19.0,
                        ),
                      ],
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
