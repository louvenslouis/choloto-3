import 'package:flutter/material.dart';

import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'tirages_home_widget.dart' show TiragesHomeWidget;

class TiragesHomeModel extends FlutterFlowModel<TiragesHomeWidget> {
  late Future<List<ResultatsRecord>> newYork;
  late Future<List<ResultatsRecord>> florida;

  void loadDraws({bool refresh = false}) {
    Future<List<ResultatsRecord>> latest(String market) =>
        queryResultatsRecordOnce(
          queryBuilder: (query) => query
              .where('tirage', isEqualTo: market)
              .orderBy('date', descending: true),
          singleRecord: true,
        );
    newYork = FFAppState().newYorkTirage(
      overrideCache: refresh,
      requestFn: () => latest('ny'),
    );
    florida = FFAppState().floridaTirage(
      overrideCache: refresh,
      requestFn: () => latest('fl'),
    );
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
