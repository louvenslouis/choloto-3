import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'tirages_widget.dart' show TiragesWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TiragesModel extends FlutterFlowModel<TiragesWidget> {
  ///  Local state fields for this page.

  List<NewYorkPick3DrawStruct> newYorkApiResults = [];
  void addToNewYorkApiResults(NewYorkPick3DrawStruct item) =>
      newYorkApiResults.add(item);
  void removeFromNewYorkApiResults(NewYorkPick3DrawStruct item) =>
      newYorkApiResults.remove(item);
  void removeAtIndexFromNewYorkApiResults(int index) =>
      newYorkApiResults.removeAt(index);
  void insertAtIndexInNewYorkApiResults(
          int index, NewYorkPick3DrawStruct item) =>
      newYorkApiResults.insert(index, item);
  void updateNewYorkApiResultsAtIndex(
          int index, Function(NewYorkPick3DrawStruct) updateFn) =>
      newYorkApiResults[index] = updateFn(newYorkApiResults[index]);

  List<FloridaPick4DrawStruct> floridaApiResults = [];
  void addToFloridaApiResults(FloridaPick4DrawStruct item) =>
      floridaApiResults.add(item);
  void removeFromFloridaApiResults(FloridaPick4DrawStruct item) =>
      floridaApiResults.remove(item);
  void removeAtIndexFromFloridaApiResults(int index) =>
      floridaApiResults.removeAt(index);
  void insertAtIndexInFloridaApiResults(
          int index, FloridaPick4DrawStruct item) =>
      floridaApiResults.insert(index, item);
  void updateFloridaApiResultsAtIndex(
          int index, Function(FloridaPick4DrawStruct) updateFn) =>
      floridaApiResults[index] = updateFn(floridaApiResults[index]);

  List<FloridaPick4DrawStruct> floridaPick2ApiResults = [];
  void addToFloridaPick2ApiResults(FloridaPick4DrawStruct item) =>
      floridaPick2ApiResults.add(item);
  void removeFromFloridaPick2ApiResults(FloridaPick4DrawStruct item) =>
      floridaPick2ApiResults.remove(item);
  void removeAtIndexFromFloridaPick2ApiResults(int index) =>
      floridaPick2ApiResults.removeAt(index);
  void insertAtIndexInFloridaPick2ApiResults(
          int index, FloridaPick4DrawStruct item) =>
      floridaPick2ApiResults.insert(index, item);
  void updateFloridaPick2ApiResultsAtIndex(
          int index, Function(FloridaPick4DrawStruct) updateFn) =>
      floridaPick2ApiResults[index] = updateFn(floridaPick2ApiResults[index]);

  List<FloridaPick4DrawStruct> floridaPick3ApiResults = [];
  void addToFloridaPick3ApiResults(FloridaPick4DrawStruct item) =>
      floridaPick3ApiResults.add(item);
  void removeFromFloridaPick3ApiResults(FloridaPick4DrawStruct item) =>
      floridaPick3ApiResults.remove(item);
  void removeAtIndexFromFloridaPick3ApiResults(int index) =>
      floridaPick3ApiResults.removeAt(index);
  void insertAtIndexInFloridaPick3ApiResults(
          int index, FloridaPick4DrawStruct item) =>
      floridaPick3ApiResults.insert(index, item);
  void updateFloridaPick3ApiResultsAtIndex(
          int index, Function(FloridaPick4DrawStruct) updateFn) =>
      floridaPick3ApiResults[index] = updateFn(floridaPick3ApiResults[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GetNewYorkPick3)] action in Tirages widget.
  ApiCallResponse? newYorkLoadResult;
  // Stores action output result for [Backend Call - API (GetFloridaPick2)] action in Tirages widget.
  ApiCallResponse? floridaPick2LoadResult;
  // Stores action output result for [Backend Call - API (GetFloridaPick3)] action in Tirages widget.
  ApiCallResponse? floridaPick3LoadResult;
  // Stores action output result for [Backend Call - API (GetFloridaPick4)] action in Tirages widget.
  ApiCallResponse? floridaLoadResult;
  // Stores action output result for [Backend Call - API (GetNewYorkPick3)] action in RefreshLotteryResults widget.
  ApiCallResponse? newYorkRefreshResult;
  // Stores action output result for [Backend Call - API (GetFloridaPick2)] action in RefreshLotteryResults widget.
  ApiCallResponse? floridaPick2RefreshResult;
  // Stores action output result for [Backend Call - API (GetFloridaPick3)] action in RefreshLotteryResults widget.
  ApiCallResponse? floridaPick3RefreshResult;
  // Stores action output result for [Backend Call - API (GetFloridaPick4)] action in RefreshLotteryResults widget.
  ApiCallResponse? floridaRefreshResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
