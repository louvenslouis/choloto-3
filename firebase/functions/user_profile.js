/**
 * Auth and Firestore are separate writes. Complete registration even when the
 * client closes after Auth succeeds. Never replace a profile written by a
 * released client, an administrator, or a previous delivery of this event.
 */
function createUserProfileHandler({auth, firestore}) {
  return async (createdUser) => {
    let user;
    try {
      user = await auth.getUser(createdUser.uid);
    } catch (error) {
      // A delayed/retried event must not recreate a deleted account's profile.
      if (error.code === "auth/user-not-found") return;
      throw error;
    }

    // Auth events use ISO timestamps; the Admin SDK returns UTC strings with
    // second precision. Compare instants, not their serialized representation.
    const creationSecond = (value) => Math.floor(Date.parse(value) / 1000);
    if (creationSecond(user.metadata.creationTime) !==
        creationSecond(createdUser.metadata.creationTime)) return;
    // Guest sessions are not members. Account linking still uses maybeCreateUser.
    if (!user.email && !user.phoneNumber && !user.providerData.length) return;

    const profile = {
      uid: user.uid,
      created_time: new Date(user.metadata.creationTime),
      onboarding_pending: true,
    };
    for (const [field, value] of Object.entries({
      email: user.email,
      display_name: user.displayName,
      photo_url: user.photoURL,
      phone_number: user.phoneNumber,
    })) {
      if (value) profile[field] = value;
    }

    try {
      await firestore.doc(`user/${user.uid}`).create(profile);
    } catch (error) {
      // Atomic create handles client/server races without resetting VIP or
      // onboarding fields. All other failures propagate so Firebase retries.
      if (error.code !== 6 && error.code !== "already-exists") throw error;
    }
  };
}

module.exports = {createUserProfileHandler};
