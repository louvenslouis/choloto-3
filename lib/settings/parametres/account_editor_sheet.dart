import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';

class AccountEditorSheet extends StatefulWidget {
  const AccountEditorSheet(
      {super.key,
      required this.title,
      required this.child,
      required this.onSave,
      this.validationError});

  final String title;
  final Widget child;
  final Future<void> Function() onSave;
  final String? Function()? validationError;

  @override
  State<AccountEditorSheet> createState() => _AccountEditorSheetState();
}

class _AccountEditorSheetState extends State<AccountEditorSheet> {
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    if (_saving) return;
    final error = widget.validationError?.call();
    setState(() {
      _error = error;
      _saving = error == null;
    });
    if (error != null) return;
    try {
      await widget.onSave();
      if (mounted && ModalRoute.isCurrentOf(context) == true) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = FFLocalizations.of(context).getText('profile_save_error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    return SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(tokens.spacing.md),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  Expanded(
                      child: Semantics(
                          header: true,
                          child: Text(widget.title, style: theme.titleLarge))),
                  const CloseButton(),
                ]),
                SizedBox(height: tokens.spacing.sm),
                AbsorbPointer(
                    absorbing: _saving,
                    child:
                        ExcludeFocus(excluding: _saving, child: widget.child)),
                if (_error != null)
                  Semantics(
                      liveRegion: true,
                      child: Text(_error!,
                          style:
                              theme.bodyMedium.copyWith(color: theme.error))),
                SizedBox(height: tokens.spacing.md),
                FFButtonWidget(
                  text: FFLocalizations.of(context).getText('prfsavebtn'),
                  onPressed: _saving ? null : _save,
                  options: FFButtonOptions(
                      height: 52,
                      color: theme.primary,
                      disabledColor: theme.alternate,
                      textStyle:
                          theme.titleSmall.copyWith(color: theme.onPrimary),
                      borderRadius: BorderRadius.circular(tokens.radius.full)),
                ),
              ]),
        ));
  }
}

Future<void> showAccountEditor(BuildContext context, Widget editor) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (context) =>
          Padding(padding: MediaQuery.viewInsetsOf(context), child: editor),
    );
