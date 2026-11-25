import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

@JS('navigator.locks')
external web.LockManager? get _locks;

// All tabs share one FCM address and must finish rotating it before the next
// tab reads the persisted owner or guest language.
Future<void> withPushRegistrationLock(Future<void> Function() operation) async {
  final locks = _locks;
  if (locks == null) return operation();
  Object? failure;
  StackTrace? trace;
  final run = Zone.current.bindCallback(() async {
    try {
      await operation();
    } catch (error, stack) {
      failure = error;
      trace = stack;
    }
  });
  await locks
      .request('choloto-web-push', ((JSAny? _) => run().toJS).toJS)
      .toDart;
  if (failure != null) Error.throwWithStackTrace(failure!, trace!);
}
