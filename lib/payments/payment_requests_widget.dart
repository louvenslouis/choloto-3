import 'dart:typed_data';
import 'package:flutter/material.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'payment_request.dart';
import 'payment_text.dart';
import 'payment_widgets.dart';
import 'proof_image.dart';

class PaymentRequestsWidget extends StatelessWidget {
  const PaymentRequestsWidget({super.key});
  static const routeName = 'PaymentRequests';
  static const routePath = '/payment-requests';
  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Scaffold(
        backgroundColor: t.primaryBackground,
        appBar: AppBar(
            backgroundColor: t.primaryBackground,
            foregroundColor: t.primaryText,
            title: Text(paymentText(context, 'title'), style: t.headlineSmall)),
        body: SafeArea(child: AuthUserStreamWidget(builder: (context) {
          if (!loggedIn) {
            return Center(
                child:
                    Text(paymentText(context, 'signin'), style: t.bodyLarge));
          }
          return _PaymentRequestsBody(
              key: ValueKey(currentUserUid), userUid: currentUserUid);
        })));
  }
}

class _PaymentRequestsBody extends StatefulWidget {
  const _PaymentRequestsBody({super.key, required this.userUid});
  final String userUid;
  @override
  State<_PaymentRequestsBody> createState() => _PaymentRequestsBodyState();
}

class _PaymentRequestsBodyState extends State<_PaymentRequestsBody> {
  final _repository = PaymentRequestRepository();
  late Stream<List<PaymentRequest>> _history;
  String? _submissionId;
  @override
  void initState() {
    super.initState();
    _history = _repository.watch(userUid: widget.userUid);
  }

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    return Center(
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
                padding: EdgeInsets.all(t.designToken.spacing.md),
                children: [
                  PaymentSubmissionForm(onSubmit: (bytes, note) async {
                    _submissionId ??= _repository.newId();
                    await _repository.submit(
                        id: _submissionId!,
                        userUid: widget.userUid,
                        proof: bytes,
                        note: note);
                    _submissionId = null;
                  }),
                  SizedBox(height: t.designToken.spacing.lg),
                  Text(paymentText(context, 'history'), style: t.titleLarge),
                  SizedBox(height: t.designToken.spacing.md),
                  StreamBuilder<List<PaymentRequest>>(
                      stream: _history,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return PaymentSurface(
                              child: Column(children: [
                            Text(paymentText(context, 'error'),
                                style: t.bodyMedium),
                            TextButton(
                                onPressed: () => setState(() => _history =
                                    _repository.watch(userUid: widget.userUid)),
                                child: Text(paymentText(context, 'retry'))),
                          ]));
                        }
                        if (!snapshot.hasData) {
                          return Center(
                              child:
                                  CircularProgressIndicator(color: t.primary));
                        }
                        if (snapshot.data!.isEmpty) {
                          return PaymentSurface(
                              child: Text(paymentText(context, 'empty'),
                                  style: t.bodyMedium));
                        }
                        return Column(children: [
                          for (final request in snapshot.data!)
                            Padding(
                                padding: EdgeInsets.only(
                                    bottom: t.designToken.spacing.md),
                                child: PaymentRequestCard(
                                    request: request,
                                    onOpen: () => showPaymentProof(context,
                                        _repository.loadProof(request.id)))),
                        ]);
                      }),
                ])));
  }
}

typedef SubmitPaymentProof = Future<void> Function(Uint8List, String);

/// Callbacks keep form behavior testable without Firebase or a native picker.
class PaymentSubmissionForm extends StatefulWidget {
  const PaymentSubmissionForm(
      {super.key, required this.onSubmit, this.pickImage});
  final SubmitPaymentProof onSubmit;
  final Future<Uint8List?> Function()? pickImage;
  @override
  State<PaymentSubmissionForm> createState() => _PaymentSubmissionFormState();
}

class _PaymentSubmissionFormState extends State<PaymentSubmissionForm> {
  final _form = GlobalKey<FormState>();
  final _note = TextEditingController();
  Uint8List? _image;
  bool _busy = false;
  bool _preparing = false;
  String? _message;
  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    setState(() {
      _preparing = true;
      _message = null;
    });
    try {
      final bytes =
          await pickPreparedPrivateImage(pickImage: widget.pickImage);
      if (bytes == null) return;
      if (mounted) setState(() => _image = bytes);
    } catch (_) {
      if (mounted) setState(() => _message = 'imageError');
    } finally {
      if (mounted) setState(() => _preparing = false);
    }
  }

  Future<void> _send() async {
    if (_busy || _image == null || !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await widget.onSubmit(_image!, _note.text.trim());
      if (!mounted) return;
      _note.clear();
      setState(() {
        _image = null;
        _message = 'sent';
      });
    } catch (_) {
      if (mounted) setState(() => _message = 'error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = FlutterFlowTheme.of(context);
    final s = t.designToken.spacing;
    InputDecoration decoration(String key) => InputDecoration(
        labelText: paymentText(context, key),
        labelStyle: t.bodyMedium.override(color: t.primaryText),
        filled: true,
        fillColor: t.primaryBackground,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(t.designToken.radius.sm)),
        errorMaxLines: 3,
        counterStyle: t.bodySmall,
        errorStyle: t.bodySmall);
    return PaymentSurface(
        child: Form(
            key: _form,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_image != null) PaymentProofImage(bytes: _image!),
                  if (_preparing)
                    Center(child: CircularProgressIndicator(color: t.primary)),
                  OutlinedButton.icon(
                      key: const ValueKey('choose-proof'),
                      onPressed: _busy || _preparing ? null : _pick,
                      icon: Icon(Icons.add_photo_alternate_outlined,
                          color: t.primary),
                      label: Text(
                          paymentText(
                              context, _image == null ? 'choose' : 'replace'),
                          style: t.labelLarge.override(color: t.primaryText))),
                  SizedBox(height: s.md),
                  TextFormField(
                      key: const ValueKey('payment-message'),
                      controller: _note,
                      enabled: !_busy,
                      maxLength: 500,
                      minLines: 2,
                      maxLines: 4,
                      style: t.bodyLarge,
                      decoration: decoration('note')),
                  if (_message != null)
                    Padding(
                        padding: EdgeInsets.symmetric(vertical: s.md),
                        child: Semantics(
                            liveRegion: true,
                            child: Text(paymentText(context, _message!),
                                style: t.bodyMedium.override(
                                    color: _message == 'sent'
                                        ? t.success
                                        : t.error)))),
                  PaymentAction(
                      key: const ValueKey('send-proof'),
                      label: paymentText(context, _busy ? 'sending' : 'send'),
                      onPressed:
                          _busy || _preparing || _image == null ? null : _send),
                ])));
  }
}
