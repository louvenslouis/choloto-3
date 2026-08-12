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
  return {uid: body.localId, token: body.idToken};
}

async function firestoreRequest(path, {method = 'GET', token, fields} = {}) {
  const response = await fetch(`${documentsUrl}/${path}`, {
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

function expectStatus(result, expected, label) {
  assert.equal(
    result.status,
    expected,
    `${label}: expected HTTP ${expected}, received ${result.status}\n${result.body}`,
  );
}

const stringValue = (value) => ({stringValue: value});
const boolValue = (value) => ({booleanValue: value});
const timestampValue = (value = '2026-08-10T12:00:00Z') => ({timestampValue: value});
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

// Predictions are reserved for administrators and users with an active VIP plan.
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
  403,
  'non-VIP prediction read',
);
expectStatus(
  await firestoreRequest('prediction/owner-prediction', {token: admin.token}),
  200,
  'admin prediction read',
);

// User documents keep the existing self-only access model.
const userFields = {
  uid: stringValue(owner.uid),
  email: stringValue('owner@compatibility.test'),
  end_sub: timestampValue('2099-12-31T23:59:59Z'),
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
  403,
  'expired VIP prediction read',
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

expectStatus(
  await firestoreRequest(votePath, {method: 'DELETE', token: owner.token}),
  200,
  'owner bingo vote deletion',
);

console.log('Firestore compatibility rules: all checks passed.');
