import '/autres/bingo/stackbingo/stackbingo_widget.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'bingo_model.dart';
export 'bingo_model.dart';

class BingoWidget extends StatefulWidget {
  const BingoWidget({
    super.key,
    this.dataStack,
    this.showStackLayer = true,
  });

  final List<DataStackStruct>? dataStack;
  final bool showStackLayer;

  @override
  State<BingoWidget> createState() => _BingoWidgetState();
}

class _BingoWidgetState extends State<BingoWidget>
    with SingleTickerProviderStateMixin {
  late final BingoModel _model;
  late final AnimationController _confetti;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BingoModel());
    _confetti = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _confetti.dispose();
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data =
        widget.dataStack ?? context.watch<FFAppState>().bingo.dataStack;
    final theme = FlutterFlowTheme.of(context);
    final animate = !MediaQuery.disableAnimationsOf(context);
    return _BingoCardBounds(
      child: Material(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(theme.designToken.radius.lg),
        clipBehavior: Clip.antiAlias,
        child: GestureDetector(
          onTap: () {
            logFirebaseEvent('BINGO_COMP_Card_99wwwxl3_ON_TAP');
            SystemSound.play(SystemSoundType.click);
            if (animate && _confetti.duration != null) {
              _confetti.forward(from: 0);
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/bingo/story_backdrop.webp',
                  fit: BoxFit.contain, excludeFromSemantics: true),
              if (animate) ...[
                IgnorePointer(
                  child: Lottie.asset('assets/jsons/Confetti.json',
                      fit: BoxFit.contain, repeat: false),
                ),
                IgnorePointer(
                  child: Lottie.asset('assets/jsons/Confetti.json',
                      fit: BoxFit.contain,
                      controller: _confetti,
                      onLoaded: (composition) =>
                          _confetti.duration = composition.duration),
                ),
              ],
              if (widget.showStackLayer)
                wrapWithModel(
                  model: _model.stackbingoModel,
                  updateCallback: () {},
                  child: StackbingoWidget(dataStack: data),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The dialog places the ticket above its navigation targets so a gesture
/// starting on the ticket turns the lot while one on the balls turns the story.
class BingoStackLayer extends StatelessWidget {
  const BingoStackLayer({super.key, required this.dataStack});
  final List<DataStackStruct> dataStack;

  @override
  Widget build(BuildContext context) => _BingoCardBounds(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
              FlutterFlowTheme.of(context).designToken.radius.lg),
          child: StackbingoWidget(dataStack: dataStack),
        ),
      );
}

/// Backdrop and gesture layers share the same square even on short screens.
class _BingoCardBounds extends StatelessWidget {
  const _BingoCardBounds({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
            child: AspectRatio(aspectRatio: 1, child: child),
          ),
        ),
      );
}
