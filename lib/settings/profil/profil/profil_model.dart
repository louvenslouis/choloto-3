import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/settings/profil/edit_profil_texts/edit_profil_texts_widget.dart';
import 'dart:ui';
import 'profil_widget.dart' show ProfilWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class ProfilModel extends FlutterFlowModel<ProfilWidget> {
  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  /// Action blocks.
  Future edit(
    BuildContext context, {
    required int? champ,
  }) async {
    logFirebaseEvent('edit_bottom_sheet');
    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      context: context,
      builder: (context) {
        return WebViewAware(
          child: Padding(
            padding: MediaQuery.viewInsetsOf(context),
            child: Container(
              height: MediaQuery.sizeOf(context).height * 0.5,
              child: EditProfilTextsWidget(
                champ: champ!,
              ),
            ),
          ),
        );
      },
    );
  }
}
