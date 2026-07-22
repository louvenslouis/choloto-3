import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'youtube_widget.dart' show YoutubeWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class YoutubeModel extends FlutterFlowModel<YoutubeWidget> {
  ///  Local state fields for this page.

  List<String> links = [];
  void addToLinks(String item) => links.add(item);
  void removeFromLinks(String item) => links.remove(item);
  void removeAtIndexFromLinks(int index) => links.removeAt(index);
  void insertAtIndexInLinks(int index, String item) =>
      links.insert(index, item);
  void updateLinksAtIndex(int index, Function(String) updateFn) =>
      links[index] = updateFn(links[index]);

  List<YoutubeItemStruct> videos = [];
  void addToVideos(YoutubeItemStruct item) => videos.add(item);
  void removeFromVideos(YoutubeItemStruct item) => videos.remove(item);
  void removeAtIndexFromVideos(int index) => videos.removeAt(index);
  void insertAtIndexInVideos(int index, YoutubeItemStruct item) =>
      videos.insert(index, item);
  void updateVideosAtIndex(int index, Function(YoutubeItemStruct) updateFn) =>
      videos[index] = updateFn(videos[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GetLatestVideos)] action in youtube widget.
  ApiCallResponse? apiResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
