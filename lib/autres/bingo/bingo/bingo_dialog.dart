import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

import 'bingo_widget.dart';

const bingoStatusAspectRatio = 9.0 / 16.0;
const bingoStatusMobileBreakpoint = 600.0;
// Original 400x400 card, including its 4px Card margin and 10px side padding.
const bingoCardPresentationSize = Size(428.0, 408.0);

class BingoStatusFrame extends StatelessWidget {
  const BingoStatusFrame({
    super.key,
    required this.child,
  });

  final Widget child;

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
          child: Center(
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
        child: BingoStatusFrame(
          child: content ?? const BingoWidget(),
        ),
      );
    },
  );
}
