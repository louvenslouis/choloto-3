import '/backend/api_requests/api_manager.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<BingoStruct?> bingoScript(
  BuildContext context, {
  BingoStruct? data,
}) async {
  return BingoStruct(
    date: data?.date,
    vue: false,
    doc: data?.doc,
    expiration: data?.expiration,
    dataStack: data?.dataStack,
  );
}

Future aeffacer(BuildContext context) async {
  logFirebaseEvent('aeffacer_show_snack_bar');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'ok',
        style: TextStyle(),
      ),
      duration: Duration(milliseconds: 4000),
      backgroundColor: FlutterFlowTheme.of(context).secondary,
    ),
  );
}
