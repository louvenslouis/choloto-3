import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

import 'bingo_reaction_service.dart';
import 'bingo_widget.dart';

const bingoStatusAspectRatio = 9.0 / 16.0;
const bingoStatusMobileBreakpoint = 600.0;
// Original 400x400 card, including its 4px Card margin and 10px side padding.
const bingoCardPresentationSize = Size(428.0, 408.0);

class BingoStatusFrame extends StatelessWidget {
  const BingoStatusFrame({
    super.key,
    required this.child,
    this.publishedAt,
    this.selectedReaction,
    this.onReaction,
    this.reactionPending = false,
  });

  final Widget child;
  final DateTime? publishedAt;
  final BingoReaction? selectedReaction;
  final ValueChanged<BingoReaction>? onReaction;
  final bool reactionPending;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final frame = ColoredBox(
      color: theme.primaryBackground,
      child: WebViewAware(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    key: const ValueKey('bingo-status-content-area'),
                    width: bingoCardPresentationSize.width,
                    height: bingoCardPresentationSize.height,
                    child: child,
                  ),
                ),
              ),
              if (publishedAt != null)
                _BingoStoryHeader(publishedAt: publishedAt!),
              if (onReaction != null)
                _BingoStoryReactionControls(
                  selectedReaction: selectedReaction,
                  enabled: !reactionPending,
                  onReaction: onReaction!,
                ),
            ],
          ),
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final fillsMobileViewport =
            constraints.maxWidth <= bingoStatusMobileBreakpoint &&
                constraints.maxHeight >= constraints.maxWidth;

        if (fillsMobileViewport) {
          return SizedBox.expand(
            key: const ValueKey('bingo-status-frame'),
            child: frame,
          );
        }

        return Center(
          child: AspectRatio(
            key: const ValueKey('bingo-status-frame'),
            aspectRatio: bingoStatusAspectRatio,
            child: frame,
          ),
        );
      },
    );
  }
}

class _BingoStoryHeader extends StatelessWidget {
  const _BingoStoryHeader({required this.publishedAt});

  final DateTime publishedAt;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final localizations = FFLocalizations.of(context);

    return SafeArea(
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.md),
          child: Row(
            key: const ValueKey('bingo-story-header'),
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                padding: EdgeInsets.all(tokens.spacing.xs),
                decoration: BoxDecoration(
                  color: theme.primary,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/bg_bingo_-_Moyenne.jpeg',
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
              SizedBox(width: tokens.spacing.sm),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.getText('bingo_story_label'),
                    key: const ValueKey('bingo-story-header-title'),
                    style: theme.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    dateTimeFormat(
                      'relative',
                      publishedAt,
                      locale: localizations.languageCode,
                    ),
                    key: const ValueKey('bingo-story-published-age'),
                    style: theme.labelMedium.copyWith(
                      color: theme.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BingoStoryReactionControls extends StatelessWidget {
  const _BingoStoryReactionControls({
    required this.selectedReaction,
    required this.enabled,
    required this.onReaction,
  });

  final BingoReaction? selectedReaction;
  final bool enabled;
  final ValueChanged<BingoReaction> onReaction;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;
    final localizations = FFLocalizations.of(context);

    Widget reactionButton({
      required BingoReaction reaction,
      required IconData icon,
      required String labelKey,
      required Key key,
    }) {
      final selected = selectedReaction == reaction;

      return Semantics(
        label: localizations.getText(labelKey),
        button: true,
        selected: selected,
        child: FlutterFlowIconButton(
          key: key,
          borderRadius: tokens.radius.full,
          buttonSize: 48.0,
          fillColor: selected ? theme.primary : theme.secondaryBackground,
          disabledColor: theme.secondaryBackground,
          disabledIconColor: theme.secondaryText,
          icon: Icon(
            icon,
            color: selected ? theme.onPrimary : theme.primaryText,
            size: 24.0,
          ),
          onPressed: enabled ? () => onReaction(reaction) : null,
        ),
      );
    }

    return SafeArea(
      child: Align(
        alignment: AlignmentDirectional.bottomEnd,
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.md),
          child: Row(
            key: const ValueKey('bingo-story-reactions'),
            mainAxisSize: MainAxisSize.min,
            children: [
              reactionButton(
                reaction: BingoReaction.positive,
                icon: Icons.thumb_up_alt_outlined,
                labelKey: 'bingo_story_like',
                key: const ValueKey('bingo-story-like'),
              ),
              SizedBox(width: tokens.spacing.sm),
              reactionButton(
                reaction: BingoReaction.negative,
                icon: Icons.thumb_down_alt_outlined,
                labelKey: 'bingo_story_dislike',
                key: const ValueKey('bingo-story-dislike'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BingoStatusDialogBody extends StatefulWidget {
  const _BingoStatusDialogBody({
    required this.content,
    this.publishedAt,
  });

  final Widget content;
  final DateTime? publishedAt;

  @override
  State<_BingoStatusDialogBody> createState() => _BingoStatusDialogBodyState();
}

class _BingoStatusDialogBodyState extends State<_BingoStatusDialogBody> {
  late BingoReaction? _selectedReaction;
  var _reactionPending = false;

  @override
  void initState() {
    super.initState();
    _selectedReaction = bingoReactionFromState(FFAppState().bingo);
  }

  Future<void> _react(BingoReaction reaction) async {
    if (_reactionPending) {
      return;
    }

    setState(() => _reactionPending = true);
    try {
      final nextReaction = await toggleCurrentBingoReaction(reaction);
      if (mounted) {
        setState(() => _selectedReaction = nextReaction);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              FFLocalizations.of(context).getText('bingo_story_reaction_error'),
            ),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _reactionPending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BingoStatusFrame(
      publishedAt: widget.publishedAt,
      selectedReaction: _selectedReaction,
      reactionPending: _reactionPending,
      onReaction: _react,
      child: widget.content,
    );
  }
}

Future<T?> showBingoDialog<T>({
  required BuildContext context,
  Widget? content,
}) {
  return showDialog<T>(
    context: context,
    useSafeArea: false,
    builder: (dialogContext) {
      final theme = FlutterFlowTheme.of(dialogContext);

      return Dialog.fullscreen(
        key: const ValueKey('bingo-status-dialog'),
        backgroundColor: theme.primaryBackground,
        child: _BingoStatusDialogBody(
          publishedAt: FFAppState().bingo.date,
          content: content ?? const BingoWidget(),
        ),
      );
    },
  );
}
