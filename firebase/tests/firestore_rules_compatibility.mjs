import assert from 'node:assert/strict';

const projectId = process.env.GCLOUD_PROJECT || 'demo-choloto';
const firestoreHost = process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:8080';
const authHost = process.env.FIREBASE_AUTH_EMULATOR_HOST || '127.0.0.1:9099';
const documentsUrl =
  `http://${firestoreHost}/v1/projects/${projectId}/databases/(default)/documents`;

async function createTestUser(label, email = `${label}@compatibility.test`) {
  const response = await fetch(
    `http://${authHost}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key`,
    {
      method: 'POST',
      headers: {'content-type': 'application/json'},
      body: JSON.stringify({
        email,
        password: 'compatibility-test-password',
        returnSecureToken: true,
      }),
    },
  );
  const body = await response.json();
  assert.equal(response.status, 200, JSON.stringify(body));
  return {uid: body.localId, token: body.idToken, email};
}

async function createAnonymousTestUser() {
  const response = await fetch(
    `http://${authHost}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key`,
    {
      method: 'POST',
      headers: {'content-type': 'application/json'},
      body: JSON.stringify({returnSecureToken: true}),
    },
  );
  const body = await response.json();
  assert.equal(response.status, 200, JSON.stringify(body));
  return {uid: body.localId, token: body.idToken};
}

async function signInTestUser(email) {
  const response = await fetch(
    `http://${authHost}/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=fake-api-key`,
    {
      method: 'POST',
      headers: {'content-type': 'application/json'},
      body: JSON.stringify({
        email,
        password: 'compatibility-test-password',
        returnSecureToken: true,
      }),
    },
  );
  const body = await response.json();
  assert.equal(response.status, 200, JSON.stringify(body));
  return {
    uid: body.localId,
    token: body.idToken,
    email,
  };
}

async function firestoreRequest(
  path,
  {method = 'GET', token, fields, updateMaskFields = []} = {},
) {
  const url = new URL(`${documentsUrl}/${path}`);
  for (const field of updateMaskFields) {
    url.searchParams.append('updateMask.fieldPaths', field);
  }
  const response = await fetch(url, {
    method,
    headers: {
      'content-type': 'application/json',
      ...(token ? {authorization: `Bearer ${token}`} : {}),
    },
    body: fields ? JSON.stringify({fields}) : undefined,
  });
  const text = await response.text();
  return {status: response.status, body: text};
}

async function firestoreCommit(writes, {token} = {}) {
  const response = await fetch(`${documentsUrl}:commit`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      ...(token ? {authorization: `Bearer ${token}`} : {}),
    },
    body: JSON.stringify({writes}),
  });
  return {status: response.status, body: await response.text()};
}

async function paymentTransactionsQuery({token, userUid} = {}) {
  const structuredQuery = {
    from: [{collectionId: 'payment_transactions'}],
    ...(userUid
      ? {
          where: {
            fieldFilter: {
              field: {fieldPath: 'user_uid'},
              op: 'EQUAL',
              value: {stringValue: userUid},
            },
          },
        }
      : {}),
  };
  const response = await fetch(`${documentsUrl}:runQuery`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      ...(token ? {authorization: `Bearer ${token}`} : {}),
    },
    body: JSON.stringify({structuredQuery}),
  });
  return {status: response.status, body: await response.text()};
}

async function supportConversationsQuery({token, userUid} = {}) {
  const structuredQuery = {
    from: [{collectionId: 'support_conversations'}],
    ...(userUid
      ? {
          where: {
            fieldFilter: {
              field: {fieldPath: 'user_uid'},
              op: 'EQUAL',
              value: {stringValue: userUid},
            },
          },
        }
      : {}),
  };
  const response = await fetch(`${documentsUrl}:runQuery`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      ...(token ? {authorization: `Bearer ${token}`} : {}),
    },
    body: JSON.stringify({structuredQuery}),
  });
  return {status: response.status, body: await response.text()};
}

async function supportMessagesQuery(conversationId, {token} = {}) {
  const response = await fetch(
    `${documentsUrl}/support_conversations/${conversationId}:runQuery`,
    {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        ...(token ? {authorization: `Bearer ${token}`} : {}),
      },
      body: JSON.stringify({
        structuredQuery: {from: [{collectionId: 'messages'}]},
      }),
    },
  );
  return {status: response.status, body: await response.text()};
}

function expectStatus(result, expected, label) {
  assert.equal(
    result.status,
    expected,
    `${label}: expected HTTP ${expected}, received ${result.status}\n${result.body}`,
  );
}

const stringValue = (value) => ({stringValue: value});
const boolValue = (value) => ({booleanValue: value});
const integerValue = (value) => ({integerValue: String(value)});
const doubleValue = (value) => ({doubleValue: value});
const timestampValue = (value = '2026-08-10T12:00:00Z') => ({timestampValue: value});
const referenceValue = (path) => ({
  referenceValue:
    `projects/${projectId}/databases/(default)/documents/${path}`,
});
const mapValue = (fields) => ({mapValue: {fields}});
const stringArray = (values) => ({
  arrayValue: {values: values.map(stringValue)},
});
const mapArray = (values) => ({
  arrayValue: {
    values: values.map((fields) => ({mapValue: {fields}})),
  },
});

const admin = await createTestUser('admin', 'sanonmaeva064@gmail.com');
const owner = await createTestUser('owner');
const other = await createTestUser('other');
const legacy = await createTestUser('legacy');
const anonymousGuest = await createAnonymousTestUser();
const emailAccount = await createTestUser('email-owner');
const emailOwner = await signInTestUser(emailAccount.email);
assert.equal(emailOwner.uid, emailAccount.uid);

// Public content stays readable, while unauthenticated publication is blocked.
const bingoFields = {
  date: timestampValue(),
  expiration: timestampValue('2026-08-11T12:00:00Z'),
  dataStack: mapArray([
    {
      valeur: stringValue('1'),
      tirage: stringValue('ny'),
      boul: stringValue('12'),
      periode: stringValue('soir'),
    },
  ]),
};
expectStatus(
  await firestoreRequest('bingo/public-bingo', {
    method: 'PATCH',
    fields: bingoFields,
  }),
  403,
  'unauthenticated bingo publication',
);
expectStatus(
  await firestoreRequest('bingo/public-bingo', {
    method: 'PATCH',
    token: admin.token,
    fields: bingoFields,
  }),
  200,
  'legacy authenticated bingo publication',
);
expectStatus(
  await firestoreRequest('bingo/regular-user-bingo', {
    method: 'PATCH',
    token: owner.token,
    fields: bingoFields,
  }),
  403,
  'regular user bingo publication',
);
expectStatus(
  await firestoreRequest('bingo/public-bingo'),
  200,
  'public bingo read',
);
expectStatus(
  await firestoreRequest('bingo/malformed-bingo', {
    method: 'PATCH',
    token: admin.token,
    fields: {...bingoFields, unexpected: stringValue('blocked')},
  }),
  403,
  'malformed bingo publication',
);

// Released mobile clients can still create, update and remove their own vote.
const votePath = 'bingo/public-bingo/bingostats/owner-vote';
expectStatus(
  await firestoreRequest(votePath, {
    method: 'PATCH',
    fields: {user: stringValue(owner.uid), gain: boolValue(true)},
  }),
  403,
  'unauthenticated bingo vote',
);
expectStatus(
  await firestoreRequest(votePath, {
    method: 'PATCH',
    token: owner.token,
    fields: {user: stringValue(owner.uid), gain: boolValue(true)},
  }),
  200,
  'owner bingo vote creation',
);
expectStatus(
  await firestoreRequest(votePath, {
    method: 'PATCH',
    token: other.token,
    fields: {user: stringValue(owner.uid), gain: boolValue(false)},
  }),
  403,
  'foreign bingo vote update',
);
expectStatus(
  await firestoreRequest(votePath, {
    method: 'PATCH',
    token: owner.token,
    fields: {user: stringValue(owner.uid), gain: boolValue(false)},
  }),
  200,
  'owner bingo vote update',
);

// Released clients keep their uid document path. New clients use a distinct
// comment UUID for every submission so one owner can comment more than once.
const commentPath = `bingo/public-bingo/comments/${owner.uid}`;
const firstModernCommentPath =
  'bingo/public-bingo/comments/comment_a11ce000-0000-4000-8000-000000000001';
const secondModernCommentPath =
  'bingo/public-bingo/comments/comment_a11ce000-0000-4000-8000-000000000002';
const hiddenModernCommentPath =
  'bingo/public-bingo/hiddenComments/comment_a11ce000-0000-4000-8000-000000000001';
const commentFields = {
  user: stringValue(owner.uid),
  text: stringValue('Mwen te genyen avèk CHOLOTO.'),
  createdAt: timestampValue('2026-08-21T12:00:00Z'),
  updatedAt: timestampValue('2026-08-21T12:00:00Z'),
};
expectStatus(
  await firestoreRequest(commentPath, {
    method: 'PATCH',
    fields: commentFields,
  }),
  403,
  'unauthenticated Bingo comment creation',
);
expectStatus(
  await firestoreRequest(commentPath, {
    method: 'PATCH',
    token: other.token,
    fields: commentFields,
  }),
  403,
  'foreign Bingo comment creation',
);
expectStatus(
  await firestoreRequest(commentPath, {
    method: 'PATCH',
    token: owner.token,
    fields: commentFields,
  }),
  200,
  'legacy owner Bingo comment creation',
);
expectStatus(
  await firestoreRequest(firstModernCommentPath, {
    method: 'PATCH',
    token: owner.token,
    fields: {
      ...commentFields,
      text: stringValue('Premye kòmantè modèn.'),
      updatedAt: timestampValue('2026-08-21T12:01:00Z'),
    },
  }),
  200,
  'first modern Bingo comment creation',
);
expectStatus(
  await firestoreRequest(secondModernCommentPath, {
    method: 'PATCH',
    token: owner.token,
    fields: {
      ...commentFields,
      text: stringValue('Dezyèm kòmantè sou menm BINGO a.'),
      createdAt: timestampValue('2026-08-21T12:02:00Z'),
      updatedAt: timestampValue('2026-08-21T12:02:00Z'),
    },
  }),
  200,
  'second modern Bingo comment creation by the same owner',
);
expectStatus(
  await firestoreRequest(
    `bingo/public-bingo/comments/${other.uid}`,
    {
      method: 'PATCH',
      token: owner.token,
      fields: commentFields,
    },
  ),
  403,
  'modern owner cannot reserve another uid legacy comment path',
);
expectStatus(
  await firestoreRequest(
    'bingo/public-bingo/comments/comment_a11ce000-0000-4000-8000-000000000003',
    {
      method: 'PATCH',
      token: owner.token,
      fields: {...commentFields, user: stringValue(other.uid)},
    },
  ),
  403,
  'modern Bingo comment cannot spoof its owner field',
);
expectStatus(
  await firestoreRequest(commentPath, {token: owner.token}),
  200,
  'owner Bingo comment read',
);
expectStatus(
  await firestoreRequest(commentPath),
  200,
  'public Bingo comment read',
);
expectStatus(
  await firestoreRequest(commentPath, {token: other.token}),
  200,
  'authenticated public Bingo comment read',
);
expectStatus(
  await firestoreRequest(commentPath, {token: admin.token}),
  200,
  'admin Bingo comment read',
);
expectStatus(
  await firestoreRequest(commentPath, {
    method: 'PATCH',
    token: other.token,
    fields: {
      ...commentFields,
      text: stringValue('Tentative étrangère.'),
    },
  }),
  403,
  'foreign Bingo comment update',
);
expectStatus(
  await firestoreRequest(commentPath, {
    method: 'PATCH',
    token: owner.token,
    fields: {
      ...commentFields,
      text: stringValue('Mwen te genyen de fwa.'),
      updatedAt: timestampValue('2026-08-21T12:05:00Z'),
    },
  }),
  200,
  'owner Bingo comment update',
);
expectStatus(
  await firestoreRequest(secondModernCommentPath, {
    method: 'PATCH',
    token: other.token,
    fields: {
      ...commentFields,
      text: stringValue('Tentative étrangère sur un commentaire moderne.'),
      createdAt: timestampValue('2026-08-21T12:02:00Z'),
      updatedAt: timestampValue('2026-08-21T12:03:00Z'),
    },
  }),
  403,
  'foreign modern Bingo comment update',
);
expectStatus(
  await firestoreRequest(secondModernCommentPath, {
    method: 'PATCH',
    token: owner.token,
    fields: {
      ...commentFields,
      text: stringValue('Dezyèm kòmantè a korije.'),
      createdAt: timestampValue('2026-08-21T12:02:00Z'),
      updatedAt: timestampValue('2026-08-21T12:04:00Z'),
    },
  }),
  200,
  'owner modern Bingo comment update',
);
expectStatus(
  await firestoreRequest(commentPath, {
    method: 'PATCH',
    token: owner.token,
    fields: {
      ...commentFields,
      text: stringValue('x'.repeat(501)),
    },
  }),
  403,
  'oversized Bingo comment',
);
expectStatus(
  await firestoreRequest(commentPath, {
    method: 'PATCH',
    token: owner.token,
    fields: {
      ...commentFields,
      createdAt: timestampValue('2026-08-21T13:00:00Z'),
    },
  }),
  403,
  'Bingo comment creation date rewrite',
);
expectStatus(
  await firestoreRequest(secondModernCommentPath, {
    method: 'DELETE',
    token: other.token,
  }),
  403,
  'foreign modern Bingo comment deletion',
);
expectStatus(
  await firestoreRequest(secondModernCommentPath, {method: 'DELETE'}),
  403,
  'unauthenticated modern Bingo comment deletion',
);
expectStatus(
  await firestoreRequest(secondModernCommentPath, {
    method: 'DELETE',
    token: owner.token,
  }),
  200,
  'owner modern Bingo comment deletion',
);
expectStatus(
  await firestoreRequest(secondModernCommentPath),
  404,
  'deleted modern Bingo comment is absent',
);
expectStatus(
  await firestoreRequest(commentPath, {
    method: 'DELETE',
    token: other.token,
  }),
  403,
  'foreign legacy Bingo comment deletion',
);
expectStatus(
  await firestoreRequest(commentPath, {
    method: 'DELETE',
    token: owner.token,
  }),
  200,
  'owner legacy Bingo comment deletion',
);
expectStatus(
  await firestoreRequest(commentPath),
  404,
  'deleted legacy Bingo comment is absent',
);

const hiddenCommentFields = {
  ...commentFields,
  text: stringValue('Premye kòmantè modèn.'),
  updatedAt: timestampValue('2026-08-21T12:01:00Z'),
  hiddenAt: timestampValue('2026-08-21T12:10:00Z'),
  hiddenBy: stringValue(admin.uid),
};
expectStatus(
  await firestoreRequest(hiddenModernCommentPath, {
    method: 'PATCH',
    token: other.token,
    fields: hiddenCommentFields,
  }),
  403,
  'non-admin cannot archive a Bingo comment',
);
expectStatus(
  await firestoreRequest(hiddenModernCommentPath, {
    method: 'PATCH',
    token: admin.token,
    fields: hiddenCommentFields,
  }),
  200,
  'admin archives a Bingo comment',
);
expectStatus(
  await firestoreRequest(firstModernCommentPath, {
    method: 'DELETE',
    token: admin.token,
  }),
  200,
  'admin removes an archived comment from the public collection',
);
expectStatus(
  await firestoreRequest(hiddenModernCommentPath, {token: admin.token}),
  200,
  'admin reads a hidden Bingo comment',
);
expectStatus(
  await firestoreRequest(hiddenModernCommentPath, {token: owner.token}),
  403,
  'owner cannot read the private Bingo moderation archive',
);
expectStatus(
  await firestoreRequest(hiddenModernCommentPath),
  403,
  'signed-out user cannot read the private Bingo moderation archive',
);
expectStatus(
  await firestoreRequest(firstModernCommentPath, {
    method: 'PATCH',
    token: admin.token,
    fields: {
      ...commentFields,
      text: stringValue('Premye kòmantè modèn.'),
      updatedAt: timestampValue('2026-08-21T12:01:00Z'),
    },
  }),
  200,
  'admin restores a hidden Bingo comment',
);
expectStatus(
  await firestoreRequest(hiddenModernCommentPath, {
    method: 'DELETE',
    token: admin.token,
  }),
  200,
  'admin clears the restored Bingo moderation archive',
);
expectStatus(
  await firestoreRequest(firstModernCommentPath),
  200,
  'restored Bingo comment is public again',
);

// Public lottery results preserve their old read contract and owner writes.
const resultFields = {
  date: timestampValue(),
  tirage: stringValue('ny'),
  periode: stringValue('soir'),
  created_by: stringValue(admin.uid),
  numeros: stringArray(['12', '34', '56']),
};
expectStatus(
  await firestoreRequest('resultats/owner-result', {
    method: 'PATCH',
    token: admin.token,
    fields: resultFields,
  }),
  200,
  'legacy owner result publication',
);
expectStatus(
  await firestoreRequest('resultats/owner-result'),
  200,
  'public result read',
);
expectStatus(
  await firestoreRequest('resultats/spoofed-result', {
    method: 'PATCH',
    token: other.token,
    fields: resultFields,
  }),
  403,
  'spoofed result owner',
);
expectStatus(
  await firestoreRequest('resultats/owner-result', {
    method: 'DELETE',
    token: other.token,
  }),
  403,
  'foreign result deletion',
);

// Prediction reads keep the released authenticated-client contract. The VIP
// screen still decides whether to query them from the user's subscription.
const predictionFields = {
  date: timestampValue(),
  periode: stringValue('soir'),
  pourcentage: {integerValue: '75'},
  created_by: stringValue(admin.uid),
  boloto: {mapValue: {fields: {name: stringValue('BOLOTO')}}},
};
expectStatus(
  await firestoreRequest('prediction/owner-prediction', {
    method: 'PATCH',
    token: admin.token,
    fields: predictionFields,
  }),
  200,
  'legacy prediction publication',
);
expectStatus(
  await firestoreRequest('prediction/owner-prediction'),
  403,
  'unauthenticated prediction read',
);
expectStatus(
  await firestoreRequest('prediction/owner-prediction', {token: other.token}),
  200,
  'authenticated prediction read',
);
expectStatus(
  await firestoreRequest('prediction/owner-prediction', {token: admin.token}),
  200,
  'admin prediction read',
);

// User documents keep the existing self-only access model. The first read of a
// missing profile must be allowed and return not-found: released clients use
// this read to decide whether they need to create the profile after Google Auth.
expectStatus(
  await firestoreRequest(`user/${owner.uid}`, {token: owner.token}),
  404,
  'first-login missing user document read',
);

const userFields = {
  uid: stringValue(owner.uid),
  email: stringValue('owner@compatibility.test'),
  end_sub: timestampValue('2099-12-31T23:59:59Z'),
  device: stringValue('Web'),
  userStats: mapValue({
    bingoGain: integerValue(2),
    bingoRater: integerValue(1),
  }),
};
expectStatus(
  await firestoreRequest(`user/${owner.uid}`, {
    method: 'PATCH',
    token: owner.token,
    fields: userFields,
  }),
  200,
  'owner user document creation',
);
expectStatus(
  await firestoreRequest(`user/${owner.uid}`, {token: other.token}),
  403,
  'foreign user document read',
);
expectStatus(
  await firestoreRequest(`user/${owner.uid}`, {token: admin.token}),
  200,
  'legacy admin user document read',
);
expectStatus(
  await firestoreRequest('prediction/owner-prediction', {token: owner.token}),
  200,
  'active VIP prediction read',
);

const registrationFields = {
  phone_number: stringValue('+50937000000'),
  preferred_language: stringValue('cr'),
  onboarding_pending: boolValue(false),
  onboarding_completed_at: timestampValue('2026-08-16T12:00:00Z'),
};
expectStatus(
  await firestoreRequest(`user/${owner.uid}`, {
    method: 'PATCH',
    token: owner.token,
    fields: registrationFields,
    updateMaskFields: [
      'phone_number',
      'preferred_language',
      'onboarding_pending',
      'onboarding_completed_at',
    ],
  }),
  200,
  'owner registration completion update',
);
const ownerAfterRegistration = await firestoreRequest(`user/${owner.uid}`, {
  token: owner.token,
});
expectStatus(
  ownerAfterRegistration,
  200,
  'owner profile after registration completion',
);
const ownerAfterRegistrationFields = JSON.parse(
  ownerAfterRegistration.body,
).fields;
assert.equal(ownerAfterRegistrationFields.uid.stringValue, owner.uid);
assert.equal(ownerAfterRegistrationFields.phone_number.stringValue, '+50937000000');
assert.equal(ownerAfterRegistrationFields.preferred_language.stringValue, 'cr');
assert.equal(ownerAfterRegistrationFields.onboarding_pending.booleanValue, false);
assert.ok(ownerAfterRegistrationFields.onboarding_completed_at.timestampValue);

// The new optional engagement aggregate is written as a partial, idempotent
// profile update. It must preserve all released-client fields and remain
// private to the path owner.
const engagementFields = mapValue({
  currentStreak: integerValue(1),
  longestStreak: integerValue(1),
  totalActiveDays: integerValue(1),
  lastActiveDay: stringValue('2026-08-14'),
  lastActiveAt: timestampValue('2026-08-14T12:00:00Z'),
  recentActiveDays: stringArray(['2026-08-14']),
  timeZoneOffsetMinutes: integerValue(-240),
});
expectStatus(
  await firestoreRequest(`user/${owner.uid}`, {
    method: 'PATCH',
    fields: {engagement: engagementFields},
    updateMaskFields: ['engagement'],
  }),
  403,
  'unauthenticated engagement update',
);
expectStatus(
  await firestoreRequest(`user/${owner.uid}`, {
    method: 'PATCH',
    token: other.token,
    fields: {engagement: engagementFields},
    updateMaskFields: ['engagement'],
  }),
  403,
  'foreign engagement update',
);
expectStatus(
  await firestoreRequest(`user/${owner.uid}`, {
    method: 'PATCH',
    token: owner.token,
    fields: {engagement: engagementFields},
    updateMaskFields: ['engagement'],
  }),
  200,
  'owner engagement update',
);
const ownerAfterEngagement = await firestoreRequest(`user/${owner.uid}`, {
  token: owner.token,
});
expectStatus(ownerAfterEngagement, 200, 'owner profile after engagement update');
const ownerAfterEngagementFields = JSON.parse(ownerAfterEngagement.body).fields;
assert.equal(ownerAfterEngagementFields.uid.stringValue, owner.uid);
assert.equal(ownerAfterEngagementFields.device.stringValue, 'Web');
assert.equal(
  ownerAfterEngagementFields.userStats.mapValue.fields.bingoGain.integerValue,
  '2',
);
assert.equal(
  ownerAfterEngagementFields.engagement.mapValue.fields.currentStreak.integerValue,
  '1',
);
expectStatus(
  await firestoreRequest(`user/${owner.uid}`, {
    method: 'PATCH',
    token: owner.token,
    fields: {userStats: mapValue({bingoGain: integerValue(3)})},
    updateMaskFields: ['userStats.bingoGain'],
  }),
  200,
  'released bingo counter update after engagement tracking',
);
const ownerAfterBingoUpdate = await firestoreRequest(`user/${owner.uid}`, {
  token: owner.token,
});
expectStatus(ownerAfterBingoUpdate, 200, 'owner profile after bingo counter update');
const ownerAfterBingoFields = JSON.parse(ownerAfterBingoUpdate.body).fields;
assert.equal(
  ownerAfterBingoFields.engagement.mapValue.fields.currentStreak.integerValue,
  '1',
);
assert.equal(
  ownerAfterBingoFields.userStats.mapValue.fields.bingoGain.integerValue,
  '3',
);

// Older released clients can use the uid document path without storing a uid
// field. Ownership remains tied to the authenticated path, so they cannot
// create or access another user's profile.
expectStatus(
  await firestoreRequest(`user/${legacy.uid}`, {
    method: 'PATCH',
    token: legacy.token,
    fields: {email: stringValue('legacy@compatibility.test')},
  }),
  200,
  'legacy uid-less user document creation',
);
expectStatus(
  await firestoreRequest(`user/${legacy.uid}`, {token: legacy.token}),
  200,
  'legacy uid-less user document read',
);
expectStatus(
  await firestoreRequest(`user/${legacy.uid}`, {
    method: 'PATCH',
    token: legacy.token,
    fields: {
      email: stringValue('legacy@compatibility.test'),
      device: stringValue('Android'),
    },
  }),
  200,
  'legacy uid-less user document update',
);
expectStatus(
  await firestoreRequest(`user/${legacy.uid}`, {
    method: 'PATCH',
    token: legacy.token,
    fields: {engagement: engagementFields},
    updateMaskFields: ['engagement'],
  }),
  200,
  'legacy uid-less engagement update',
);
const legacyAfterEngagement = await firestoreRequest(`user/${legacy.uid}`, {
  token: legacy.token,
});
expectStatus(legacyAfterEngagement, 200, 'legacy profile after engagement update');
const legacyAfterEngagementFields = JSON.parse(legacyAfterEngagement.body).fields;
assert.equal(legacyAfterEngagementFields.uid, undefined);
assert.equal(legacyAfterEngagementFields.email.stringValue, 'legacy@compatibility.test');
assert.equal(legacyAfterEngagementFields.device.stringValue, 'Android');
expectStatus(
  await firestoreRequest(`user/${other.uid}`, {
    method: 'PATCH',
    token: legacy.token,
    fields: {uid: stringValue(legacy.uid)},
  }),
  403,
  'foreign user document creation through spoofed uid field',
);

// Email authentication follows the same released-client profile sequence:
// authenticate, read the missing canonical document, create it with the email,
// then complete end_sub and device before navigating home.
expectStatus(
  await firestoreRequest(`user/${emailOwner.uid}`, {token: emailOwner.token}),
  404,
  'email first-login missing user document read',
);
const emailUserFields = {
  uid: stringValue(emailOwner.uid),
  email: stringValue(emailOwner.email),
  created_time: timestampValue(),
};
expectStatus(
  await firestoreRequest(`user/${emailOwner.uid}`, {
    method: 'PATCH',
    token: emailOwner.token,
    fields: emailUserFields,
  }),
  200,
  'email user document creation',
);
expectStatus(
  await firestoreRequest(`user/${emailOwner.uid}`, {
    method: 'PATCH',
    token: emailOwner.token,
    fields: {
      ...emailUserFields,
      end_sub: timestampValue('2026-08-14T12:00:00Z'),
    },
  }),
  200,
  'email user end_sub completion',
);
expectStatus(
  await firestoreRequest(`user/${emailOwner.uid}`, {
    method: 'PATCH',
    token: emailOwner.token,
    fields: {
      ...emailUserFields,
      end_sub: timestampValue('2026-08-14T12:00:00Z'),
      device: stringValue('Android'),
    },
  }),
  200,
  'email user device completion',
);
const emailProfileRead = await firestoreRequest(`user/${emailOwner.uid}`, {
  token: emailOwner.token,
});
expectStatus(
  emailProfileRead,
  200,
  'email user document read',
);
const emailProfileBody = JSON.parse(emailProfileRead.body);
assert.equal(emailProfileBody.fields.uid.stringValue, emailOwner.uid);
assert.equal(
  emailProfileBody.fields.email.stringValue,
  emailOwner.email,
);
expectStatus(
  await firestoreRequest(`user/${emailOwner.uid}`, {token: other.token}),
  403,
  'foreign email user document read',
);
expectStatus(
  await firestoreRequest(`user/${emailOwner.uid}`),
  403,
  'unauthenticated email user document read',
);

// Payment transactions remain immutable dashboard audit records, while the
// signed-in member can read only records whose user_uid matches their token.
const paymentTransactionId = 'owner-payment-transaction';
const paymentTransactionPath =
  `payment_transactions/${paymentTransactionId}`;
const paymentTransactionName =
  `projects/${projectId}/databases/(default)/documents/${paymentTransactionPath}`;
const paymentTransactionFields = {
  user_ref: referenceValue(`user/${owner.uid}`),
  user_uid: stringValue(owner.uid),
  receipt_code: stringValue(`CH-${paymentTransactionId}`),
  transaction_type: stringValue('renewal'),
  new_end_sub: timestampValue('2026-09-30T12:00:00Z'),
  payment_method: stringValue('moncash'),
  amount: doubleValue(40),
  currency: stringValue('USD'),
  member_time_before: integerValue(1),
  member_time_after: integerValue(2),
  created_by: stringValue(admin.uid),
};
expectStatus(
  await firestoreCommit(
    [
      {
        update: {
          name: paymentTransactionName,
          fields: paymentTransactionFields,
        },
        updateTransforms: [
          {fieldPath: 'created_at', setToServerValue: 'REQUEST_TIME'},
        ],
      },
    ],
    {token: admin.token},
  ),
  200,
  'admin payment transaction creation',
);
expectStatus(
  await firestoreRequest(paymentTransactionPath, {token: owner.token}),
  200,
  'owner payment transaction read',
);
expectStatus(
  await firestoreRequest(paymentTransactionPath, {token: admin.token}),
  200,
  'admin payment transaction read',
);
expectStatus(
  await firestoreRequest(paymentTransactionPath, {token: other.token}),
  403,
  'foreign payment transaction read',
);
expectStatus(
  await firestoreRequest(paymentTransactionPath),
  403,
  'unauthenticated payment transaction read',
);
expectStatus(
  await paymentTransactionsQuery({
    token: owner.token,
    userUid: owner.uid,
  }),
  200,
  'owner scoped payment transaction query',
);
expectStatus(
  await paymentTransactionsQuery({
    token: other.token,
    userUid: owner.uid,
  }),
  403,
  'foreign scoped payment transaction query',
);
expectStatus(
  await paymentTransactionsQuery({token: owner.token}),
  403,
  'owner unscoped payment transaction query',
);
expectStatus(
  await paymentTransactionsQuery({token: admin.token}),
  200,
  'admin unscoped payment transaction query',
);
expectStatus(
  await firestoreRequest(paymentTransactionPath, {
    method: 'DELETE',
    token: owner.token,
  }),
  403,
  'owner payment transaction deletion',
);

// Web push tokens are private and can only be managed by their owner.
const webPushTokenPath = `user/${owner.uid}/webPushTokens/browser-token`;
const webPushTokenFields = {
  token: stringValue('fcm-web-token'),
  userId: stringValue(owner.uid),
  locale: stringValue('cr'),
  createdAt: timestampValue(),
  updatedAt: timestampValue(),
};
expectStatus(
  await firestoreRequest(webPushTokenPath, {
    method: 'PATCH',
    fields: webPushTokenFields,
  }),
  403,
  'unauthenticated web push registration',
);
expectStatus(
  await firestoreRequest(webPushTokenPath, {
    method: 'PATCH',
    token: owner.token,
    fields: webPushTokenFields,
  }),
  200,
  'owner web push registration',
);
expectStatus(
  await firestoreRequest(webPushTokenPath, {token: other.token}),
  403,
  'foreign web push token read',
);
expectStatus(
  await firestoreRequest(`user/${owner.uid}/webPushTokens/spoofed-token`, {
    method: 'PATCH',
    token: other.token,
    fields: {
      ...webPushTokenFields,
      userId: stringValue(other.uid),
    },
  }),
  403,
  'foreign web push registration',
);

expectStatus(
  await firestoreRequest(`user/${other.uid}`, {
    method: 'PATCH',
    token: other.token,
    fields: {
      uid: stringValue(other.uid),
      email: stringValue('other@compatibility.test'),
      end_sub: timestampValue('2020-01-01T00:00:00Z'),
    },
  }),
  200,
  'expired VIP user document creation',
);
expectStatus(
  await firestoreRequest('prediction/owner-prediction', {token: other.token}),
  200,
  'expired VIP authenticated prediction read',
);

// Public configuration stays readable but can no longer be injected anonymously.
const settingsFields = {
  betaFeatures: {
    mapValue: {fields: {stories: boolValue(true), statsBingo: boolValue(true)}},
  },
};
expectStatus(
  await firestoreRequest('settings/public-settings', {
    method: 'PATCH',
    fields: settingsFields,
  }),
  403,
  'unauthenticated settings injection',
);
expectStatus(
  await firestoreRequest('settings/public-settings', {
    method: 'PATCH',
    token: admin.token,
    fields: settingsFields,
  }),
  200,
  'legacy authenticated settings publication',
);
expectStatus(
  await firestoreRequest('settings/public-settings'),
  200,
  'public settings read',
);

// The integrated subscription chat uses one private conversation per uid.
// The real first-message sequence reads the absent conversation, then commits
// its summary and immutable message atomically.
const supportConversationPath = `support_conversations/${owner.uid}`;
const firstSupportMessageId = 'message-owner-first';
const firstSupportMessagePath =
  `${supportConversationPath}/messages/${firstSupportMessageId}`;
const supportConversationName =
  `projects/${projectId}/databases/(default)/documents/${supportConversationPath}`;
const firstSupportMessageName =
  `projects/${projectId}/databases/(default)/documents/${firstSupportMessagePath}`;
expectStatus(
  await firestoreRequest(supportConversationPath, {token: owner.token}),
  404,
  'first support conversation read is missing rather than denied',
);

const firstSupportConversationFields = {
  user_uid: stringValue(owner.uid),
  user_email: stringValue(owner.email),
  user_display_name: stringValue('Owner'),
  topic: stringValue('subscription'),
  status: stringValue('open'),
  last_message: stringValue('Comment puis-je payer mon abonnement ?'),
  last_message_id: stringValue(firstSupportMessageId),
  last_sender_role: stringValue('user'),
};
const firstSupportMessageFields = {
  sender_uid: stringValue(owner.uid),
  sender_role: stringValue('user'),
  text: stringValue('Comment puis-je payer mon abonnement ?'),
};
const firstSupportCommit = [
  {
    update: {
      name: supportConversationName,
      fields: firstSupportConversationFields,
    },
    updateTransforms: [
      {fieldPath: 'created_at', setToServerValue: 'REQUEST_TIME'},
      {fieldPath: 'updated_at', setToServerValue: 'REQUEST_TIME'},
    ],
  },
  {
    update: {
      name: firstSupportMessageName,
      fields: firstSupportMessageFields,
    },
    updateTransforms: [
      {fieldPath: 'created_at', setToServerValue: 'REQUEST_TIME'},
    ],
  },
];
expectStatus(
  await firestoreRequest(`user/${owner.uid}`, {
    method: 'PATCH',
    token: owner.token,
    fields: {},
    updateMaskFields: ['phone_number'],
  }),
  200,
  'owner removes phone before starting support conversation',
);
expectStatus(
  await firestoreCommit(firstSupportCommit),
  403,
  'unauthenticated support conversation creation',
);
expectStatus(
  await firestoreCommit(firstSupportCommit, {token: other.token}),
  403,
  'foreign support conversation creation',
);
expectStatus(
  await firestoreCommit(firstSupportCommit, {token: owner.token}),
  200,
  'owner creates support conversation without phone',
);
expectStatus(
  await firestoreRequest(supportConversationPath, {token: owner.token}),
  200,
  'owner reads own support conversation',
);
expectStatus(
  await firestoreRequest(supportConversationPath, {token: admin.token}),
  200,
  'admin reads member support conversation',
);
expectStatus(
  await firestoreRequest(supportConversationPath, {token: other.token}),
  403,
  'foreign user cannot read support conversation',
);
expectStatus(
  await firestoreRequest(supportConversationPath),
  403,
  'signed-out user cannot read support conversation',
);
expectStatus(
  await firestoreRequest(firstSupportMessagePath, {token: owner.token}),
  200,
  'owner reads own support message',
);
expectStatus(
  await firestoreRequest(firstSupportMessagePath, {token: admin.token}),
  200,
  'admin reads member support message',
);
expectStatus(
  await firestoreRequest(firstSupportMessagePath, {token: other.token}),
  403,
  'foreign user cannot read support message',
);
expectStatus(
  await supportConversationsQuery({token: admin.token}),
  200,
  'admin lists support inbox',
);
expectStatus(
  await supportConversationsQuery({token: owner.token, userUid: owner.uid}),
  403,
  'member cannot list the support inbox',
);

function supportReplyCommit({
  actor,
  messageId,
  role,
  text,
  senderUid = actor.uid,
  conversationPath = supportConversationPath,
  conversationName = supportConversationName,
  imageBase64,
  imageMimeType = 'image/jpeg',
  imageByteLength = 4,
  includeImageDocument = true,
  audioData,
  includeAudioDocument = true,
}) {
  const messagePath = `${conversationPath}/messages/${messageId}`;
  const writes = [
      {
        update: {
          name: conversationName,
          fields: {
            status: stringValue('open'),
            last_message: stringValue(text),
            last_message_id: stringValue(messageId),
            last_sender_role: stringValue(role),
          },
        },
        updateMask: {
          fieldPaths: [
            'status',
            'last_message',
            'last_message_id',
            'last_sender_role',
          ],
        },
        updateTransforms: [
          {fieldPath: 'updated_at', setToServerValue: 'REQUEST_TIME'},
        ],
      },
      {
        update: {
          name:
            `projects/${projectId}/databases/(default)/documents/${messagePath}`,
          fields: {
            sender_uid: stringValue(senderUid),
            sender_role: stringValue(role),
            text: stringValue(text),
            ...(imageBase64 === undefined
              ? {}
              : {attachment_type: stringValue('image')}),
            ...(audioData ? {attachment_type: stringValue('audio')} : {}),
          },
        },
        updateTransforms: [
          {fieldPath: 'created_at', setToServerValue: 'REQUEST_TIME'},
        ],
      },
    ];
  if (imageBase64 !== undefined && includeImageDocument) {
    writes.push({
      update: {
        name:
          `projects/${projectId}/databases/(default)/documents/${messagePath}/attachments/image`,
        fields: {
          base64: stringValue(imageBase64),
          mime_type: stringValue(imageMimeType),
          byte_length: integerValue(imageByteLength),
        },
      },
    });
  }
  if (audioData && includeAudioDocument) {
    writes.push({update: {
      name: `projects/${projectId}/databases/(default)/documents/${messagePath}/attachments/audio`,
      fields: audioData,
    }});
  }
  return firestoreCommit(writes, {token: actor.token});
}

const adminSupportReplyId = 'message-admin-reply';
expectStatus(
  await supportReplyCommit({
    actor: owner,
    messageId: 'message-owner-spoofed-admin',
    role: 'admin',
    text: 'Tentative de fausse réponse administrateur.',
  }),
  403,
  'member cannot send an admin support reply',
);
expectStatus(
  await supportReplyCommit({
    actor: other,
    messageId: 'message-foreign',
    role: 'user',
    text: 'Tentative étrangère.',
  }),
  403,
  'foreign user cannot write in another support conversation',
);
expectStatus(
  await supportReplyCommit({
    actor: admin,
    messageId: adminSupportReplyId,
    role: 'admin',
    text: 'Bonjour, nous pouvons vous accompagner pour le paiement.',
  }),
  200,
  'admin replies to support conversation',
);
expectStatus(
  await firestoreRequest(
    `${supportConversationPath}/messages/${adminSupportReplyId}`,
    {token: owner.token},
  ),
  200,
  'owner reads admin support reply',
);
expectStatus(
  await firestoreRequest(`user/${owner.uid}`, {
    method: 'PATCH',
    token: owner.token,
    fields: {},
    updateMaskFields: ['phone_number'],
  }),
  200,
  'owner removes phone after support conversation exists',
);
expectStatus(
  await supportReplyCommit({
    actor: owner,
    messageId: 'message-owner-second',
    role: 'user',
    text: 'Merci. Je souhaite payer par MonCash.',
  }),
  200,
  'released client continues existing support conversation without phone',
);
const ownerSupportImageId = 'message-owner-image';
const ownerSupportImagePath =
  `${supportConversationPath}/messages/${ownerSupportImageId}/attachments/image`;
expectStatus(
  await supportReplyCommit({
    actor: owner,
    messageId: ownerSupportImageId,
    role: 'user',
    text: 'Photo',
    imageBase64: '/9j/2Q==',
  }),
  200,
  'owner atomically sends a private support image',
);
expectStatus(
  await firestoreRequest(ownerSupportImagePath, {token: owner.token}),
  200,
  'owner reads own support image',
);
expectStatus(
  await firestoreRequest(ownerSupportImagePath, {token: admin.token}),
  200,
  'admin reads member support image',
);
expectStatus(
  await firestoreRequest(ownerSupportImagePath, {token: other.token}),
  403,
  'foreign member cannot read support image',
);
expectStatus(
  await firestoreRequest(ownerSupportImagePath),
  403,
  'signed-out visitor cannot read member support image',
);
expectStatus(
  await supportReplyCommit({
    actor: owner,
    messageId: 'message-owner-image-missing',
    role: 'user',
    text: 'Photo',
    imageBase64: '/9j/2Q==',
    includeImageDocument: false,
  }),
  403,
  'support image marker requires an atomic image document',
);
expectStatus(
  await supportReplyCommit({
    actor: owner,
    messageId: 'message-owner-image-invalid',
    role: 'user',
    text: 'Photo',
    imageBase64: '/9j/2Q==',
    imageMimeType: 'text/html',
  }),
  403,
  'support attachment rejects non-JPEG content metadata',
);
expectStatus(
  await firestoreRequest(
    `${firstSupportMessagePath}/attachments/image`,
    {
      method: 'PATCH',
      token: owner.token,
      fields: {
        base64: stringValue('/9j/2Q=='),
        mime_type: stringValue('image/jpeg'),
        byte_length: integerValue(4),
      },
    },
  ),
  403,
  'an image cannot be injected into a historical text-only message',
);

// A signed-out visitor receives a Firebase anonymous uid behind the scenes.
// The real flow creates a private profile, then starts a conversation without
// requiring a phone number. A phone can be included as ordinary message text.
const guestProfilePath = `user/${anonymousGuest.uid}`;
const guestConversationPath =
  `support_conversations/${anonymousGuest.uid}`;
const guestMessageId = 'message-anonymous-first';
const guestMessagePath =
  `${guestConversationPath}/messages/${guestMessageId}`;
const guestConversationName =
  `projects/${projectId}/databases/(default)/documents/${guestConversationPath}`;
const guestMessageName =
  `projects/${projectId}/databases/(default)/documents/${guestMessagePath}`;
const guestConversationFields = {
  user_uid: stringValue(anonymousGuest.uid),
  topic: stringValue('subscription'),
  status: stringValue('open'),
  last_message: stringValue(
    'Telefòn (opsyonèl): +50938000000\n\nMwen bezwen èd pou abònman an.',
  ),
  last_message_id: stringValue(guestMessageId),
  last_sender_role: stringValue('user'),
};
const guestMessageFields = {
  sender_uid: stringValue(anonymousGuest.uid),
  sender_role: stringValue('user'),
  text: stringValue(
    'Telefòn (opsyonèl): +50938000000\n\nMwen bezwen èd pou abònman an.',
  ),
};
const guestFirstCommit = [
  {
    update: {
      name: guestConversationName,
      fields: guestConversationFields,
    },
    updateTransforms: [
      {fieldPath: 'created_at', setToServerValue: 'REQUEST_TIME'},
      {fieldPath: 'updated_at', setToServerValue: 'REQUEST_TIME'},
    ],
  },
  {
    update: {
      name: guestMessageName,
      fields: guestMessageFields,
    },
    updateTransforms: [
      {fieldPath: 'created_at', setToServerValue: 'REQUEST_TIME'},
    ],
  },
];
expectStatus(
  await firestoreRequest(guestProfilePath, {token: anonymousGuest.token}),
  404,
  'anonymous guest reads missing own profile before creation',
);
expectStatus(
  await firestoreRequest(guestProfilePath, {
    method: 'PATCH',
    token: anonymousGuest.token,
    fields: {
      uid: stringValue(anonymousGuest.uid),
      onboarding_pending: boolValue(true),
      created_time: timestampValue(),
    },
  }),
  200,
  'anonymous guest creates private profile',
);
expectStatus(
  await firestoreRequest(guestConversationPath, {
    token: anonymousGuest.token,
  }),
  404,
  'anonymous guest reads missing own support conversation',
);
expectStatus(
  await firestoreCommit(guestFirstCommit, {token: anonymousGuest.token}),
  200,
  'anonymous guest starts support without profile phone',
);
expectStatus(
  await firestoreRequest(guestMessagePath, {token: anonymousGuest.token}),
  200,
  'anonymous guest reads own support message',
);
expectStatus(
  await firestoreRequest(guestConversationPath, {token: admin.token}),
  200,
  'admin reads anonymous guest support conversation',
);
const guestAdminReplyId = 'message-anonymous-admin-reply';
expectStatus(
  await supportReplyCommit({
    actor: admin,
    messageId: guestAdminReplyId,
    role: 'admin',
    text: 'Nou la pou ede w ak abònman an.',
    conversationPath: guestConversationPath,
    conversationName: guestConversationName,
  }),
  200,
  'admin replies to anonymous guest support conversation',
);
expectStatus(
  await firestoreRequest(
    `${guestConversationPath}/messages/${guestAdminReplyId}`,
    {token: anonymousGuest.token},
  ),
  200,
  'anonymous guest reads admin support reply',
);
expectStatus(
  await firestoreRequest(guestConversationPath, {token: other.token}),
  403,
  'other member cannot read anonymous guest support conversation',
);

// New clients do not authenticate visitors. A random UUID stored on the
// device is the private capability for one guest conversation. It remains in
// the existing support collection so the administrator receives it normally.
const unauthenticatedGuestId = '123e4567-e89b-42d3-a456-426614174000';
const unauthenticatedGuestConversationPath =
  `support_conversations/${unauthenticatedGuestId}`;
const unauthenticatedGuestMessageId = 'message-no-auth-first';
const unauthenticatedGuestMessagePath =
  `${unauthenticatedGuestConversationPath}/messages/${unauthenticatedGuestMessageId}`;
const unauthenticatedGuestConversationName =
  `projects/${projectId}/databases/(default)/documents/${unauthenticatedGuestConversationPath}`;
const unauthenticatedGuestMessageName =
  `projects/${projectId}/databases/(default)/documents/${unauthenticatedGuestMessagePath}`;
const unauthenticatedGuestText =
  'Telefòn (opsyonèl): +50939000000\n\nMwen vle abòne.';
const unauthenticatedGuestCommit = [
  {
    update: {
      name: unauthenticatedGuestConversationName,
      fields: {
        user_uid: stringValue(unauthenticatedGuestId),
        guest_access: boolValue(true),
        topic: stringValue('subscription'),
        status: stringValue('open'),
        last_message: stringValue(unauthenticatedGuestText),
        last_message_id: stringValue(unauthenticatedGuestMessageId),
        last_sender_role: stringValue('user'),
      },
    },
    updateTransforms: [
      {fieldPath: 'created_at', setToServerValue: 'REQUEST_TIME'},
      {fieldPath: 'updated_at', setToServerValue: 'REQUEST_TIME'},
    ],
  },
  {
    update: {
      name: unauthenticatedGuestMessageName,
      fields: {
        sender_uid: stringValue(unauthenticatedGuestId),
        sender_role: stringValue('user'),
        text: stringValue(unauthenticatedGuestText),
      },
    },
    updateTransforms: [
      {fieldPath: 'created_at', setToServerValue: 'REQUEST_TIME'},
    ],
  },
];
expectStatus(
  await firestoreRequest(unauthenticatedGuestConversationPath),
  404,
  'visitor reads missing private conversation without authentication',
);
expectStatus(
  await supportMessagesQuery(unauthenticatedGuestId),
  200,
  'visitor watches empty private chat before sending the first message',
);
expectStatus(
  await firestoreCommit(unauthenticatedGuestCommit),
  200,
  'visitor starts support chat without authentication or profile',
);
expectStatus(
  await firestoreRequest(unauthenticatedGuestConversationPath),
  200,
  'visitor reads private conversation without authentication',
);
expectStatus(
  await firestoreRequest(unauthenticatedGuestMessagePath),
  200,
  'visitor reads private message without authentication',
);
expectStatus(
  await supportMessagesQuery(unauthenticatedGuestId),
  200,
  'visitor watches private chat messages without authentication',
);
const unauthenticatedGuestImageId = 'message-no-auth-image';
const unauthenticatedGuestImagePath =
  `${unauthenticatedGuestConversationPath}/messages/${unauthenticatedGuestImageId}/attachments/image`;
expectStatus(
  await supportReplyCommit({
    actor: {uid: unauthenticatedGuestId},
    messageId: unauthenticatedGuestImageId,
    role: 'user',
    text: 'Foto',
    imageBase64: '/9j/2Q==',
    conversationPath: unauthenticatedGuestConversationPath,
    conversationName: unauthenticatedGuestConversationName,
  }),
  200,
  'visitor sends a private support image without authentication',
);
expectStatus(
  await firestoreRequest(unauthenticatedGuestImagePath),
  200,
  'visitor reads the support image through the private conversation id',
);
expectStatus(
  await firestoreRequest(unauthenticatedGuestImagePath, {token: admin.token}),
  200,
  'admin reads visitor support image',
);
expectStatus(
  await firestoreRequest(unauthenticatedGuestConversationPath, {
    token: other.token,
  }),
  403,
  'signed-in foreign member cannot read visitor conversation',
);
expectStatus(
  await firestoreRequest('support_conversations/not-a-private-id'),
  403,
  'visitor cannot use a predictable conversation id',
);
expectStatus(
  await supportConversationsQuery(),
  403,
  'visitor cannot list support conversations',
);
expectStatus(
  await supportConversationsQuery({token: admin.token}),
  200,
  'admin receives authenticated and unauthenticated conversations together',
);
const unauthenticatedGuestAdminReplyId = 'message-no-auth-admin-reply';
expectStatus(
  await supportReplyCommit({
    actor: admin,
    messageId: unauthenticatedGuestAdminReplyId,
    role: 'admin',
    text: 'Nou resevwa mesaj ou a.',
    conversationPath: unauthenticatedGuestConversationPath,
    conversationName: unauthenticatedGuestConversationName,
  }),
  200,
  'admin replies to visitor without changing the guest contract',
);
expectStatus(
  await firestoreRequest(
    `${unauthenticatedGuestConversationPath}/messages/${unauthenticatedGuestAdminReplyId}`,
  ),
  200,
  'visitor reads admin reply without authentication',
);
expectStatus(
  await supportReplyCommit({
    actor: owner,
    messageId: 'message-owner-too-long',
    role: 'user',
    text: 'x'.repeat(1001),
  }),
  403,
  'oversized support message',
);
expectStatus(
  await firestoreRequest(firstSupportMessagePath, {
    method: 'PATCH',
    token: owner.token,
    fields: {
      ...firstSupportMessageFields,
      text: stringValue('Message réécrit.'),
      created_at: timestampValue(),
    },
  }),
  403,
  'support messages are immutable',
);
expectStatus(
  await firestoreRequest(firstSupportMessagePath, {
    method: 'DELETE',
    token: owner.token,
  }),
  403,
  'member cannot delete support history',
);
expectStatus(
  await firestoreRequest(firstSupportMessagePath, {
    method: 'DELETE',
    token: admin.token,
  }),
  200,
  'admin can delete expired support history',
);

expectStatus(
  await firestoreRequest(votePath, {method: 'DELETE', token: owner.token}),
  200,
  'owner bingo vote deletion',
);
expectStatus(
  await firestoreRequest(webPushTokenPath, {
    method: 'DELETE',
    token: owner.token,
  }),
  200,
  'owner web push token deletion',
);

console.log('Firestore compatibility rules: all checks passed.');

const {testPaymentRequests} = await import('./payment_requests_rules.mjs');
await testPaymentRequests({admin});

// Complete voice-note read-before-write sequence, including absent documents.
const audioFields = {
  base64: stringValue(Buffer.alloc(16044).toString('base64')),
  mime_type: stringValue('audio/wav'),
  byte_length: integerValue(16044),
  duration_ms: integerValue(1000),
};
for (const guest of [false, true]) {
  const actor = guest ? {uid: '00b18a16-4935-4de7-9bc5-dfa33bc8a644'} : await createTestUser('voice-first');
  const path = `support_conversations/${actor.uid}`;
  const messagePath = `${path}/messages/voice-first`;
  const attachmentPath = `${messagePath}/attachments/audio`;
  const name = `projects/${projectId}/databases/(default)/documents/${path}`;
  if (!guest) {
    expectStatus(await firestoreRequest(`user/${actor.uid}`, {token: actor.token}), 404, 'voice first login reads absent profile');
    expectStatus(await firestoreRequest(`user/${actor.uid}`, {method: 'PATCH', token: actor.token, fields: {email: stringValue(actor.email)}}), 200, 'voice legacy profile without uid/phone');
  }
  expectStatus(await supportMessagesQuery(actor.uid, {token: actor.token}), 200, 'voice watches empty conversation');
  for (const read of [path, messagePath, attachmentPath]) {
    expectStatus(await firestoreRequest(read, {token: actor.token}), 404, `voice pre-read ${read}`);
  }
  if (!guest) expectStatus(await firestoreRequest(`user/${actor.uid}`, {token: actor.token}), 200, 'voice transaction reads historical profile');
  const writes = [
    {update: {name, fields: {
      user_uid: stringValue(actor.uid), ...(guest ? {guest_access: boolValue(true)} : {}),
      topic: stringValue('subscription'), status: stringValue('open'),
      last_message: stringValue('Note vocale'), last_message_id: stringValue('voice-first'), last_sender_role: stringValue('user'),
    }}, updateTransforms: [{fieldPath: 'created_at', setToServerValue: 'REQUEST_TIME'}, {fieldPath: 'updated_at', setToServerValue: 'REQUEST_TIME'}]},
    {update: {name: `${name}/messages/voice-first`, fields: {
      sender_uid: stringValue(actor.uid), sender_role: stringValue('user'), text: stringValue('Note vocale'), attachment_type: stringValue('audio'),
    }}, updateTransforms: [{fieldPath: 'created_at', setToServerValue: 'REQUEST_TIME'}]},
    {update: {name: `${name}/messages/voice-first/attachments/audio`, fields: audioFields}},
  ];
  expectStatus(await firestoreCommit(writes, {token: actor.token}), 200, 'first voice atomically creates conversation, message and attachment');
  for (const read of [path, messagePath, attachmentPath]) {
    expectStatus(await firestoreRequest(read, {token: actor.token}), 200, 'voice retry reads committed document');
  }
  expectStatus(await firestoreRequest(attachmentPath, {token: admin.token}), 200, 'admin reads voice note');
  expectStatus(await firestoreRequest(attachmentPath, {token: other.token}), 403, 'foreign member cannot read voice note');
  if (!guest) expectStatus(await firestoreRequest(attachmentPath), 403, 'signed-out visitor cannot read member voice note');
  expectStatus(await firestoreRequest(attachmentPath, {method: 'PATCH', token: actor.token, fields: audioFields}), 403, 'voice attachment is immutable');
  expectStatus(await firestoreRequest(attachmentPath, {method: 'DELETE', token: actor.token}), 403, 'voice attachment cannot be deleted');
  expectStatus(await supportReplyCommit({actor: admin, conversationPath: path, conversationName: name, messageId: 'admin-voice', role: 'admin', text: 'Note vocale', audioData: audioFields}), 200, 'admin voice works in member and guest conversations');
}
for (const [label, changes] of [
  ['wrong MIME', {mime_type: stringValue('text/html')}],
  ['oversize', {byte_length: integerValue(480046)}],
  ['duration zero', {duration_ms: integerValue(0)}],
  ['duration too long', {duration_ms: integerValue(30001)}],
  ['duration inconsistent', {duration_ms: integerValue(999)}],
  ['invalid base64', {base64: stringValue('!invalid')}],
  ['extra field', {public: boolValue(true)}],
]) {
  expectStatus(await supportReplyCommit({actor: owner, messageId: `invalid-audio-${label.replaceAll(' ', '-')}`, role: 'user', text: 'Note vocale', audioData: {...audioFields, ...changes}}), 403, `voice rejects ${label}`);
}
expectStatus(await supportReplyCommit({actor: owner, messageId: 'audio-missing-document', role: 'user', text: 'Note vocale', audioData: audioFields, includeAudioDocument: false}), 403, 'audio marker requires attachment in same commit');
for (const actor of [other, {uid: owner.uid}]) {
  expectStatus(await supportReplyCommit({actor, messageId: 'foreign-audio', role: 'user', text: 'Note vocale', audioData: audioFields}), 403, 'foreign or unauthenticated audio write refused');
}
expectStatus(await supportReplyCommit({actor: owner, messageId: 'spoofed-admin-audio', role: 'admin', text: 'Note vocale', audioData: audioFields}), 403, 'voice cannot spoof admin role');
expectStatus(await firestoreRequest(`${firstSupportMessagePath}/attachments/audio`, {method: 'PATCH', token: owner.token, fields: audioFields}), 403, 'audio cannot be injected into historical text message');

const unauthenticatedGuestImageMessagePath =
  `${unauthenticatedGuestConversationPath}/messages/${unauthenticatedGuestImageId}`;
const unauthenticatedGuestAdminReplyPath =
  `${unauthenticatedGuestConversationPath}/messages/${unauthenticatedGuestAdminReplyId}`;
expectStatus(await firestoreRequest(unauthenticatedGuestImagePath, {method: 'DELETE'}), 403, 'visitor cannot delete a support attachment');
expectStatus(await firestoreRequest(unauthenticatedGuestImagePath, {method: 'DELETE', token: admin.token}), 200, 'admin cleanup deletes a support attachment');
expectStatus(await firestoreRequest(unauthenticatedGuestImageMessagePath, {method: 'DELETE', token: admin.token}), 200, 'admin cleanup deletes an image message');
expectStatus(await firestoreRequest(unauthenticatedGuestMessagePath, {method: 'DELETE', token: admin.token}), 200, 'admin cleanup deletes a guest message');
expectStatus(await firestoreRequest(unauthenticatedGuestAdminReplyPath, {method: 'DELETE', token: admin.token}), 200, 'admin cleanup deletes an admin reply');
expectStatus(await firestoreRequest(unauthenticatedGuestConversationPath, {method: 'DELETE'}), 403, 'visitor cannot delete a support conversation');
expectStatus(await firestoreRequest(unauthenticatedGuestConversationPath, {method: 'DELETE', token: admin.token}), 200, 'admin cleanup deletes an empty support conversation');
expectStatus(await firestoreRequest(unauthenticatedGuestConversationPath, {token: admin.token}), 404, 'expired support conversation is gone after cleanup');
console.log('Voice-note compatibility checks passed.');
