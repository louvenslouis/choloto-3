Future<void> withPushRegistrationLock(Future<void> Function() operation) =>
    operation();
