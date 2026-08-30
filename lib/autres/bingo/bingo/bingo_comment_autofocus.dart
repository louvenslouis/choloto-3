import 'package:flutter/widgets.dart';

typedef BingoCommentAutofocusScheduler = void Function(
  VoidCallback callback,
);

/// Requests focus only after the editable element is ready for interaction.
///
/// A Web platform view is created before its DOM element is attached to the
/// document. Retrying on subsequent frames avoids losing the autofocus request
/// during the bottom-sheet transition.
void scheduleBingoCommentAutofocus({
  required bool Function() shouldFocus,
  required bool Function() isReady,
  required VoidCallback requestFocus,
  BingoCommentAutofocusScheduler? scheduleFrame,
  int attemptsRemaining = 4,
}) {
  if (attemptsRemaining <= 0 || !shouldFocus()) return;

  final scheduler = scheduleFrame ??
      (callback) => WidgetsBinding.instance.addPostFrameCallback(
            (_) => callback(),
          );
  scheduler(() {
    if (!shouldFocus()) return;
    if (isReady()) {
      requestFocus();
      return;
    }

    scheduleBingoCommentAutofocus(
      shouldFocus: shouldFocus,
      isReady: isReady,
      requestFocus: requestFocus,
      scheduleFrame: scheduler,
      attemptsRemaining: attemptsRemaining - 1,
    );
  });
}
