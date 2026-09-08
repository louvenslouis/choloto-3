import '/auth/base_auth_user_provider.dart';
import '/autres/bingo/bingo/bingo_reaction_service.dart';
import '/autres/bingo/stackbingo/stackbingo_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bingo_card_v_i_p_model.dart';
export 'bingo_card_v_i_p_model.dart';

class BingoCardVIPWidget extends StatefulWidget {
  const BingoCardVIPWidget({super.key});

  @override
  State<BingoCardVIPWidget> createState() => _BingoCardVIPWidgetState();
}

class _BingoCardVIPWidgetState extends State<BingoCardVIPWidget> {
  late BingoCardVIPModel _model;
  var _reactionPending = false;

  Future<void> _react(BingoReaction requestedReaction) async {
    if (_reactionPending) return;

    safeSetState(() => _reactionPending = true);
    try {
      final reaction = await toggleCurrentBingoReaction(requestedReaction);
      if (!mounted || reaction == null) return;

      final isPositive = reaction == BingoReaction.positive;
      final theme = FlutterFlowTheme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            FFLocalizations.of(context)
                .getText(isPositive ? 'bngsuccess' : 'bngtryagain'),
            style: TextStyle(
              color: isPositive ? theme.onPrimary : theme.primaryText,
            ),
          ),
          duration: const Duration(milliseconds: 4000),
          backgroundColor: isPositive ? theme.primary : theme.tertiary,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            FFLocalizations.of(context).getText('bingo_story_reaction_error'),
          ),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    } finally {
      if (mounted) safeSetState(() => _reactionPending = false);
    }
  }

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BingoCardVIPModel());

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
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final toggleLabel = FFLocalizations.of(context)
        .getText(_model.minimise ? 'bngexpand' : 'bngreduce');

    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.spacing.xs,
        tokens.spacing.sm,
        tokens.spacing.xs,
        0,
      ),
      child: Material(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        clipBehavior: Clip.antiAlias,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          curve: Curves.easeInOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                expanded: !_model.minimise,
                child: InkWell(
                  onTap: () {
                    logFirebaseEvent('BINGO_CARD_V_I_P_Button_vv92t9cq_ON_TAP');
                    logFirebaseEvent('Button_update_component_state');
                    safeSetState(() => _model.minimise = !_model.minimise);
                  },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.spacing.md,
                        vertical: tokens.spacing.sm,
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/bingo-2.png',
                            height: tokens.spacing.lg,
                            width: tokens.spacing.lg,
                            fit: BoxFit.contain,
                            excludeFromSemantics: true,
                          ),
                          SizedBox(width: tokens.spacing.sm),
                          Text(
                            FFLocalizations.of(context)
                                .getText('bingo_story_label'),
                            style: theme.labelLarge
                                .override(color: theme.primaryText),
                          ),
                          SizedBox(width: tokens.spacing.sm),
                          Expanded(
                            child: Text(
                              toggleLabel,
                              textAlign: TextAlign.end,
                              style: theme.labelMedium.override(
                                color:
                                    theme.primaryText.withValues(alpha: 0.75),
                              ),
                            ),
                          ),
                          SizedBox(width: tokens.spacing.xs),
                          Icon(
                            _model.minimise
                                ? Icons.expand_more_rounded
                                : Icons.expand_less_rounded,
                            color: theme.primaryText.withValues(alpha: 0.75),
                            size: tokens.spacing.lg,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (!_model.minimise)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    tokens.spacing.sm,
                    0,
                    tokens.spacing.sm,
                    tokens.spacing.sm,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      wrapWithModel(
                        model: _model.stackbingoModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const StackbingoWidget(),
                      ),
                      if (loggedIn) ...[
                        SizedBox(height: tokens.spacing.sm),
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: tokens.spacing.sm,
                          children: [
                            Text(
                              FFLocalizations.of(context).getText('ch00aogu'),
                              style: theme.bodyMedium,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _reactionButton(BingoReaction.positive),
                                _reactionButton(BingoReaction.negative),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reactionButton(BingoReaction reaction) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final positive = reaction == BingoReaction.positive;
    final bingo = FFAppState().bingo;
    final selected = positive
        ? bingo.gagner == true
        : bingo.gagner == false && bingo.refGain != null;
    final color = selected ? theme.error : theme.primaryText;

    return FFButtonWidget(
      onPressed: _reactionPending
          ? null
          : () async {
              logFirebaseEvent(positive
                  ? 'BINGO_CARD_V_I_P_COMP_WI_BTN_ON_TAP'
                  : 'BINGO_CARD_V_I_P_COMP_NON_BTN_ON_TAP');
              await _react(reaction);
            },
      text: FFLocalizations.of(context)
          .getText(positive ? 'ksh6eozy' : '7ccuyv05'),
      icon: Icon(positive ? Icons.thumb_up : Icons.thumb_down_alt, size: 16),
      options: FFButtonOptions(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: tokens.spacing.sm),
        iconColor: color,
        color: theme.secondaryBackground,
        textStyle: theme.labelMedium.override(color: color),
        elevation: 0,
        borderRadius: BorderRadius.circular(tokens.radius.sm),
      ),
      showLoadingIndicator: false,
    );
  }
}
