import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'youtube_widget.dart' show YoutubeWidget;
import 'package:flutter/material.dart';

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

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
