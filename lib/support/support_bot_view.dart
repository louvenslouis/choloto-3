import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/settings/parametres/settings_choice_sheet.dart';
import 'support_bot.dart';
import 'support_text.dart';

class SupportBotView extends StatefulWidget {
  const SupportBotView(
      {super.key,
      required this.config,
      required this.onContact,
      this.isSignedIn = true,
      this.onSignIn,
      this.onRequestImage,
      this.onPaymentProof,
      this.awaitingImageReview = false,
      this.path});
  final Stream<SupportBotConfig> config;
  final Future<void> Function(String) onContact;
  final bool isSignedIn;
  final VoidCallback? onSignIn;
  final VoidCallback? onRequestImage;
  final VoidCallback? onPaymentProof;
  final bool awaitingImageReview;
  final List<String>? path;
  @override
  State<SupportBotView> createState() => _SupportBotViewState();
}

class _SupportBotViewState extends State<SupportBotView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<String> _localPath = [];
  List<String> get _path => widget.path ?? _localPath;
  String? _selected;
  int? _revision;
  bool _busy = false;
  bool _contacted = false;
  String? _error;

  Future<void> _contact(SupportBotConfig? config) async {
    if (_busy || _contacted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final labels =
        _path.map((id) => config?.node(id)?.label).whereType<String>();
    final text =
        'Mwen bezwen pale ak ekip CHOLOTO a.${labels.isEmpty ? '' : '\n${labels.join(' → ')}'}';
    try {
      await widget.onContact(text);
      if (mounted) setState(() => _contacted = true);
    } catch (_) {
      if (mounted) {
        setState(() => _error = supportText(context, 'botSendError'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final spacing = tokens.spacing;
    return StreamBuilder<SupportBotConfig>(
      stream: widget.config,
      builder: (context, snapshot) {
        final config = snapshot.hasError ? null : snapshot.data;
        if (config != null && !config.enabled) return const SizedBox.shrink();
        if (config != null && config.revision != _revision) {
          if (_revision != null) _path.clear();
          _revision = config.revision;
          _selected = null;
        }
        if (config == null && !snapshot.hasError) {
          return Padding(
              padding: EdgeInsets.all(spacing.md),
              child: Center(
                  child: CircularProgressIndicator(color: theme.primary)));
        }
        if (config != null && _path.any((id) => config.node(id) == null)) {
          _path.clear();
        }
        final current = _path.isEmpty ? null : config?.node(_path.last);
        final requiresLogin = !widget.isSignedIn &&
            _path.any((id) =>
                config?.node(id)?.requiresAuth == true ||
                config?.node(id)?.requestsPaymentProof == true ||
                (config?.node(id)?.paymentMethodId.isNotEmpty ?? false));
        final paymentId = current?.paymentMethodId ?? '';
        final payment = config?.payment(paymentId);
        final paymentUnavailable =
            paymentId.isNotEmpty && payment?.enabled != true;
        if (widget.awaitingImageReview) {
          return _SupportBotPanel(
              child: Semantics(
                  liveRegion: true,
                  child: Text(supportText(context, 'botImageWaiting'))));
        }
        final choices =
            config?.children(current?.id ?? '') ?? <SupportBotNode>[];
        return _SupportBotPanel(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Icon(Icons.smart_toy_outlined,
                  size: 20, color: tokens.home.mutedText),
              SizedBox(width: spacing.sm),
              Expanded(
                  child: Text(supportText(context, 'botTitle'),
                      style: theme.titleMedium))
            ]),
            SizedBox(height: spacing.md),
            if (config == null) Text(supportText(context, 'botUnavailable')),
            if (config != null) ...[
              if (_path.isNotEmpty)
                Text(_path.map((id) => config.node(id)!.label).join(' › '),
                    style: theme.labelSmall
                        .copyWith(color: tokens.home.mutedText)),
              SizedBox(height: spacing.sm),
              Semantics(
                  liveRegion: true,
                  child: Text(requiresLogin
                      ? supportText(context, 'botLoginRequired')
                      : paymentUnavailable
                          ? supportText(context, 'botPaymentUnavailable')
                          : current?.answer ?? config.greeting)),
              if (!requiresLogin && !paymentUnavailable && payment != null)
                Container(
                    key: const ValueKey('bot-payment-details'),
                    margin: EdgeInsets.symmetric(vertical: spacing.md),
                    padding: EdgeInsets.all(spacing.md),
                    decoration: BoxDecoration(
                        border: Border.all(color: tokens.home.panelEdge),
                        borderRadius: BorderRadius.circular(tokens.radius.md)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(payment.name, style: theme.titleMedium),
                          SizedBox(height: spacing.sm),
                          SelectableText(
                              '${supportText(context, 'botPaymentPrice')}: ${payment.price}'),
                          Text(
                              '${supportText(context, 'botPaymentDuration')}: ${payment.months} ${supportText(context, 'botPaymentMonths')}'),
                          SizedBox(height: spacing.sm),
                          SelectableText(
                              '${supportText(context, 'botPaymentAccount')}: ${payment.account}'),
                          SelectableText(
                              '${supportText(context, 'botPaymentRecipient')}: ${payment.recipient}'),
                        ])),
              if (requiresLogin)
                FilledButton.icon(
                    onPressed: widget.onSignIn,
                    icon: const Icon(Icons.login),
                    label: Text(supportText(context, 'botSignIn'))),
              if (!requiresLogin &&
                  !paymentUnavailable &&
                  current?.requestsImage == true)
                OutlinedButton.icon(
                    key: const ValueKey('bot-image'),
                    onPressed: current?.requestsPaymentProof == true
                        ? widget.onPaymentProof
                        : widget.onRequestImage,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: Text(supportText(
                        context,
                        current?.requestsPaymentProof == true
                            ? 'botSendPaymentProof'
                            : 'botSendImage'))),
              if (!_contacted) ...[
                SizedBox(height: spacing.sm),
                ...(requiresLogin || current?.requestsImage == true
                        ? <SupportBotNode>[]
                        : choices)
                    .map((n) => SettingsChoiceTile(
                          key: ValueKey('bot-choice-${n.id}'),
                          label: n.label,
                          selected: _selected == n.id,
                          onTap: _busy
                              ? null
                              : () => setState(() =>
                                  _selected = _selected == n.id ? null : n.id),
                        )),
                if (choices.isNotEmpty &&
                    !requiresLogin &&
                    current?.requestsImage != true)
                  FilledButton(
                      key: const ValueKey('bot-continue'),
                      onPressed: _selected == null || _busy
                          ? null
                          : () => setState(() {
                                _path.add(_selected!);
                                _selected = null;
                              }),
                      child: Text(supportText(context, 'botContinue'))),
                if (_path.isNotEmpty)
                  Wrap(alignment: WrapAlignment.spaceBetween, children: [
                    TextButton(
                        onPressed: _busy
                            ? null
                            : () => setState(() {
                                  _path.removeLast();
                                  _selected = null;
                                }),
                        child: Text(supportText(context, 'botBack'))),
                    TextButton(
                        onPressed: _busy
                            ? null
                            : () => setState(() {
                                  _path.clear();
                                  _selected = null;
                                }),
                        child: Text(supportText(context, 'botRestart'))),
                  ]),
              ],
            ],
            if (_error != null)
              Text(_error!,
                  style: theme.bodyMedium.copyWith(color: theme.error)),
            if (_contacted)
              Text(supportText(context, 'botContacted'))
            else
              TextButton.icon(
                  key: const ValueKey('bot-contact'),
                  onPressed: _busy ? null : () => _contact(config),
                  icon: const Icon(Icons.support_agent),
                  label: Text(supportText(context, 'botContact'))),
          ],
        ));
      },
    );
  }
}

class _SupportBotPanel extends StatelessWidget {
  const _SupportBotPanel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final material = Theme.of(context);
    return Theme(
        data: material.copyWith(
            textTheme:
                material.textTheme.copyWith(labelLarge: theme.labelLarge)),
        child: Material(
          type: MaterialType.transparency,
          child: Ink(
            decoration: tokens.home.panel,
            padding: EdgeInsets.all(tokens.spacing.md),
            child:
                DefaultTextStyle.merge(style: theme.bodyMedium, child: child),
          ),
        ));
  }
}
