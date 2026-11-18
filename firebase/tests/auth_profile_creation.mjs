import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {setTimeout as delay} from 'node:timers/promises';

const require = createRequire(import.meta.url);
const admin = require('../functions/node_modules/firebase-admin');
const projectId = process.env.GCLOUD_PROJECT;
assert.equal(projectId, 'demo-choloto', 'This test only runs against demo-choloto');
assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
assert.ok(process.env.FIREBASE_AUTH_EMULATOR_HOST);
const {onAuthUserCreated} = require('../functions/index.js');
const db = admin.firestore();
const auth = admin.auth();
const authUrl = `http://${process.env.FIREBASE_AUTH_EMULATOR_HOST}/identitytoolkit.googleapis.com/v1`;
const firestoreUrl = `http://${process.env.FIRESTORE_EMULATOR_HOST}/v1/projects/${projectId}/databases/(default)/documents`;

async function authenticate(operation, body) {
  const response = await fetch(`${authUrl}/accounts:${operation}?key=fake-key`, {
    method: 'POST',
    headers: {'content-type': 'application/json'},
    body: JSON.stringify(body),
  });
  const result = await response.json();
  assert.equal(response.status, 200, JSON.stringify(result));
  return result;
}

async function clientRequest(uid, token, fields) {
  const url = new URL(`${firestoreUrl}/user/${uid}`);
  if (fields) {
    for (const field of Object.keys(fields)) url.searchParams.append('updateMask.fieldPaths', field);
  }
  return fetch(url, {
    method: fields ? 'PATCH' : 'GET',
    headers: {
      'content-type': 'application/json',
      ...(token ? {authorization: `Bearer ${token}`} : {}),
    },
    body: fields ? JSON.stringify({fields}) : undefined,
  });
}

async function waitForProfile(uid) {
  for (let attempt = 0; attempt < 100; attempt++) {
    const snapshot = await db.doc(`user/${uid}`).get();
    if (snapshot.exists) return snapshot.data();
    await delay(200);
  }
  assert.fail('Auth succeeded but the server never created the profile');
}

// No Firestore write by the client: reproduce closing the app immediately
// after Firebase Auth returns. The Auth emulator must dispatch the real trigger.
const emailUser = await authenticate('signUp', {
  email: 'interrupted-email@example.test', password: 'test-password', returnSecureToken: true,
});
const claims = {
  sub: 'interrupted-google', email: 'interrupted-google@example.test',
  email_verified: true, name: 'Interrupted Google Member',
  iss: 'https://accounts.google.com', aud: 'demo-client',
  iat: Math.floor(Date.now() / 1000), exp: Math.floor(Date.now() / 1000) + 3600,
};
const encode = (value) => Buffer.from(JSON.stringify(value)).toString('base64url');
const googleUser = await authenticate('signInWithIdp', {
  requestUri: 'http://localhost', returnSecureToken: true,
  postBody: new URLSearchParams({
    providerId: 'google.com',
    id_token: `${encode({alg: 'none'})}.${encode(claims)}.`,
  }).toString(),
});

for (const member of [emailUser, googleUser]) {
  const profile = await waitForProfile(member.localId);
  assert.equal(profile.uid, member.localId);
  assert.equal(profile.email, member.email);
  assert.equal(profile.onboarding_pending, true);
  assert.equal('end_sub' in profile, false, 'No VIP entitlement on signup');
  assert.equal('member_time' in profile, false);
  assert.ok(profile.created_time.toDate() instanceof Date);

  // Historical client flow: owner reads first, then sets end_sub/device.
  assert.equal((await clientRequest(member.localId, member.idToken)).status, 200);
  const completedAt = new Date().toISOString();
  assert.equal((await clientRequest(member.localId, member.idToken, {
    end_sub: {timestampValue: completedAt}, device: {stringValue: 'Web'},
  })).status, 200);
  // Current client completion still works with a server-created profile.
  assert.equal((await clientRequest(member.localId, member.idToken, {
    onboarding_pending: {booleanValue: false},
    onboarding_completed_at: {timestampValue: completedAt},
  })).status, 200);
  assert.equal((await clientRequest(member.localId)).status, 403);
}
assert.equal((await clientRequest(emailUser.localId, googleUser.idToken)).status, 403);
assert.equal((await clientRequest(emailUser.localId, googleUser.idToken, {
  display_name: {stringValue: 'Foreign write'},
})).status, 403);

// Preserve every existing field, including old profiles without uid. Re-deliver
// concurrently, as production event delivery can happen more than once.
assert.deepEqual(onAuthUserCreated.__trigger.failurePolicy, {retry: {}});
const legacyRef = db.doc(`user/${emailUser.localId}`);
await legacyRef.set({
  email: emailUser.email,
  end_sub: new Date('2027-01-01T00:00:00Z'),
  member_time: 3, onboarding_pending: false,
});
const before = (await legacyRef.get()).data();
const record = await auth.getUser(emailUser.localId);
await Promise.all([onAuthUserCreated.run(record), onAuthUserCreated.run(record)]);
assert.deepEqual((await legacyRef.get()).data(), before);

const guest = await authenticate('signUp', {returnSecureToken: true});
const guestRecord = await auth.getUser(guest.localId);
await onAuthUserCreated.run(guestRecord);
assert.equal((await db.doc(`user/${guest.localId}`).get()).exists, false);

await auth.deleteUser(googleUser.localId);
await db.doc(`user/${googleUser.localId}`).delete();
await onAuthUserCreated.run({uid: googleUser.localId, metadata: record.metadata});
assert.equal((await db.doc(`user/${googleUser.localId}`).get()).exists, false);

console.log('Auth profile creation: Google/email interruptions, retries, legacy/current clients, privacy, guests and deletion passed.');
await admin.app().delete();
