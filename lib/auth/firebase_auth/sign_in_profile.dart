Future<TCredential?> signInAndEnsureUserProfile<TCredential, TUser>({
  required Future<TCredential?> Function() authenticate,
  required TUser? Function(TCredential credential) userFromCredential,
  required Future<void> Function(TUser user) ensureUserProfile,
}) async {
  final credential = await authenticate();
  if (credential == null) {
    return null;
  }

  final user = userFromCredential(credential);
  if (user != null) {
    await ensureUserProfile(user);
  }

  return credential;
}
