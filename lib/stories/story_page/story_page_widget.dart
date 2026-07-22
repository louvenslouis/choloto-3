import '/autres/bingo/bingo/bingo_widget.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_web_view.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/stories/bule/bule_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Builder(
      builder: (context) {
        final stories = FFAppState().stories.toList();

        return Container(
          width: double.infinity,
          height: MediaQuery.sizeOf(context).height * 1.0,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 40.0),
                child: PageView.builder(
                  controller: _model.pageViewController ??= PageController(
                      initialPage: max(
                          0,
                          min(
                              valueOrDefault<int>(
                                widget!.id,
                                0,
                              ),
                              stories.length - 1))),
                  scrollDirection: Axis.horizontal,
                  itemCount: stories.length,
                  itemBuilder: (context, storiesIndex) {
                    final storiesItem = stories[storiesIndex];
                    return Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(-1.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 10.0, 0.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Hero(
                                    tag: 'bule',
                                    transitionOnUserGestures: true,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: BuleWidget(
                                        key: Key(
                                            'Key6ao_${storiesIndex}_of_${stories.length}'),
                                      ),
                                    ),
                                  ),
                                  FlutterFlowIconButton(
                                    borderRadius: 8.0,
                                    buttonSize: 40.0,
                                    icon: Icon(
                                      Icons.close_outlined,
                                      color: FlutterFlowTheme.of(context).info,
                                      size: 24.0,
                                    ),
                                    onPressed: () async {
                                      logFirebaseEvent(
                                          'STORY_close_outlined_ICN_ON_TAP');
                                      logFirebaseEvent(
                                          'IconButton_navigate_to');

                                      context.pushNamed(HomeWidget.routeName);
                                    },
                                  ),
                                  FlutterFlowIconButton(
                                    borderRadius: 8.0,
                                    buttonSize: 40.0,
                                    icon: Icon(
                                      Icons.refresh,
                                      color: FlutterFlowTheme.of(context).info,
                                      size: 24.0,
                                    ),
                                    onPressed: () async {
                                      logFirebaseEvent(
                                          'STORY_PAGE_COMP_refresh_ICN_ON_TAP');
                                      logFirebaseEvent(
                                          'IconButton_update_app_state');
                                      FFAppState().stories = [];
                                      safeSetState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Flexible(
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 10.0, 0.0, 10.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                ),
                                child: Builder(
                                  builder: (context) {
                                    if (storiesItem.hasBingo()) {
                                      return BingoWidget(
                                        key: Key(
                                            'Keynnk_${storiesIndex}_of_${stories.length}'),
                                      );
                                    } else if (storiesItem.hasYoutubeLinks()) {
                                      return StreamBuilder<YoutubeLinksRecord>(
                                        stream: YoutubeLinksRecord.getDocument(
                                            storiesItem.youtubeLinks!),
                                        builder: (context, snapshot) {
                                          // Customize what your widget looks like when it's loading.
                                          if (!snapshot.hasData) {
                                            return Center(
                                              child: SizedBox(
                                                width: 50.0,
                                                height: 50.0,
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }

                                          final youtubePostYoutubeLinksRecord =
                                              snapshot.data!;

                                          return Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                            ),
                                            child: FlutterFlowWebView(
                                              content:
                                                  '<!DOCTYPE html><html lang=\"fr\"><head><meta charset=\"UTF-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"><title>Carte YouTube</title><style>*{    margin:0;    padding:0;    box-sizing:border-box;    font-family:Arial, Helvetica, sans-serif;}body{    background:#f5f5f5;    display:flex;    justify-content:center;    align-items:center;    min-height:100vh;}.card{    width:350px;    background:#fff;    border-radius:18px;    overflow:hidden;    box-shadow:0 12px 30px rgba(0,0,0,.15);    transition:.3s;}.card:hover{    transform:translateY(-6px);    box-shadow:0 18px 40px rgba(0,0,0,.2);}.thumbnail{    position:relative;}.thumbnail img{    width:100%;    display:block;}.play-icon{    position:absolute;    top:50%;    left:50%;    transform:translate(-50%,-50%);    width:70px;    height:70px;    background:rgba(255,0,0,.9);    border-radius:50%;    display:flex;    justify-content:center;    align-items:center;    font-size:30px;    color:#fff;}.content{    padding:20px;}.content h2{    font-size:20px;    margin-bottom:10px;    color:#222;}.content p{    color:#666;    font-size:15px;    line-height:1.5;    margin-bottom:20px;}.button{    display:block;    text-align:center;    background:#ff0000;    color:#fff;    text-decoration:none;    padding:14px;    border-radius:12px;    font-weight:bold;    transition:.3s;}.button:hover{    background:#cc0000;}</style></head><body><div class=\"card\">    <div class=\"thumbnail\">        <img src=\"https://img.youtube.com/vi/${youtubePostYoutubeLinksRecord.id}/maxresdefault.jpg\" alt=\"Miniature YouTube\">        <div class=\"play-icon\">▶</div>    </div>    <div class=\"content\">        <h2>Regarder cette vidéo</h2>        <p>Cliquez sur le bouton ci-dessous pour ouvrir la vidéo sur YouTube.</p>        <a class=\"button\"           href=\"https://www.youtube.com/watch?v=${youtubePostYoutubeLinksRecord.id}\"           target=\"_blank\">            ▶ Regarder sur YouTube        </a>    </div></div></body></html>',
                                              height: MediaQuery.sizeOf(context)
                                                      .height *
                                                  1.0,
                                              verticalScroll: false,
                                              horizontalScroll: false,
                                              html: true,
                                            ),
                                          );
                                        },
                                      );
                                    } else if (storiesItem.hasPostText()) {
                                      return Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Container(
                                          width: double.infinity,
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.85,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: Padding(
                                            padding: EdgeInsets.all(10.0),
                                            child: AutoSizeText(
                                              FFLocalizations.of(context)
                                                  .getText(
                                                'hs9qcniz' /* TEST 1-2 */,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 8,
                                              minFontSize: 18.0,
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Text(
                                        FFLocalizations.of(context).getText(
                                          'gbh5c896' /* Hello World */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0.0, -1.0),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                  child: smooth_page_indicator.SmoothPageIndicator(
                    controller: _model.pageViewController ??= PageController(
                        initialPage: max(
                            0,
                            min(
                                valueOrDefault<int>(
                                  widget!.id,
                                  0,
                                ),
                                stories.length - 1))),
                    count: stories.length,
                    axisDirection: Axis.horizontal,
                    onDotClicked: (i) async {
                      await _model.pageViewController!.animateToPage(
                        i,
                        duration: Duration(milliseconds: 500),
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
      },
    );
  }
}
