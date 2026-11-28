// Run from firebase/ against fresh emulators:
// NODE_OPTIONS="--require \"$PWD/tests/capture_push.cjs\"" firebase emulators:exec --only functions,firestore,auth --project demo-choloto "node tests/notification_delivery.mjs"
import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {setTimeout as delay} from 'node:timers/promises';

const require = createRequire(new URL('../functions/index.js', import.meta.url));
const admin = require('firebase-admin');
assert.equal(process.env.GCLOUD_PROJECT, 'demo-choloto');
assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
assert.ok(process.env.NODE_OPTIONS?.includes('capture_push.cjs'));
admin.initializeApp({projectId: 'demo-choloto'});
const db = admin.firestore();
const now = admin.firestore.FieldValue.serverTimestamp();
const owner = db.doc('user/member');
const chat = db.doc('support_conversations/member');
const setup = db.batch();
setup.create(owner, {end_sub: new Date(0)}); // Historical profile without uid.
for (const [uid, id, token, locale] of [
  ['member', 'browser', 'member-token', 'cr'],
  ['member', 'duplicate', 'member-token', 'cr'],
  ['other', 'browser', 'other-token', 'en'],
  ['legacy', 'browser', 'legacy-token', null],
]) {
  setup.create(db.doc(`user/${uid}/webPushTokens/${id}`), {
    userId: uid, token, ...(locale && {locale}), createdAt: now, updatedAt: now,
  });
}
setup.create(chat, {
  user_uid: 'member', status: 'open', topic: 'subscription', last_sender_role: 'user',
  last_message: 'Question', last_message_id: 'question', created_at: now, updated_at: now,
});
setup.create(chat.collection('messages').doc('question'), {
  sender_role: 'user', sender_uid: 'member', text: 'Question', created_at: now,
});
await setup.commit();

// Exercise the browser's signed-out callable against the local Functions runtime.
const hub = await fetch(`http://${process.env.FIREBASE_EMULATOR_HUB}/emulators`);
assert.ok(hub.ok);
const {functions: runtime} = await hub.json();
const callable = `http://${runtime.host}:${runtime.port}/demo-choloto/northamerica-northeast1/registerGuestBingoPush`;
const guestToken = 'guestBrowser:eFM' + 'a'.repeat(140);
const registration = await fetch(callable, {
  method: 'POST', headers: {'Content-Type': 'application/json'},
  body: JSON.stringify({data: {token: guestToken, locale: 'cr'}}),
});
const registrationBody = await registration.json();
assert.equal(registration.status, 200, JSON.stringify(registrationBody));
assert.deepEqual(registrationBody.result, {registered: true});
assert.deepEqual((await db.collection('test_push_subscriptions').get()).docs.map((doc) => doc.data()),
  [{token: guestToken, topic: 'guest_bingo_cr'}]);

const publications = db.batch();
publications.create(db.doc('croix/today'), {
  date: now, created_by: 'operator', numeros: ['11', '12', '13', '21', '0', '22', '31', '32', '33'],
});
publications.create(db.doc('prediction/today'), {
  date: now, created_by: 'operator', periode: 'Soir', pourcentage: 80,
  favori: {name: 'FAVORI', boul: ['12', '34']},
});
await publications.commit();
const bingo = {
  date: new Date(), expiration: new Date(Date.now() + 3600_000),
  dataStack: [{valeur: '1', tirage: 'ny', boul: '12', periode: 'soir'}],
};
const manual = await db.collection('bingo').add(bingo);
const suggested = db.doc('bingo/suggested_source');
await db.runTransaction(async (tx) => {
  assert.equal((await tx.get(suggested)).exists, false);
  tx.set(suggested, bingo);
});
await manual.update({dataStack: [{...bingo.dataStack[0], boul: '48'}]});
await db.doc('bingo/archived').set({...bingo, date: new Date(0), expiration: new Date(1000)});
const reply = db.batch();
reply.create(chat.collection('messages').doc('answer'), {
  sender_role: 'admin', sender_uid: 'operator', text: 'Private reply', created_at: now,
});
reply.update(chat, {
  last_sender_role: 'admin', last_message_id: 'answer', last_message: 'Private reply', updated_at: now,
});
await reply.commit();
const receipt = db.doc('payment_transactions/activation');
await db.runTransaction(async (tx) => {
  assert.equal((await tx.get(receipt)).exists, false);
  const profile = await tx.get(owner);
  const end = new Date(Date.now() + 30 * 86400_000);
  tx.update(owner, {end_sub: end, method: 'cash', member_time: 1, updated_time: now});
  tx.create(receipt, {
    user_ref: owner, user_uid: owner.id, receipt_code: 'CH-activation', transaction_type: 'renewal',
    previous_end_sub: profile.get('end_sub'), new_end_sub: end, payment_method: 'cash',
    amount: 100, currency: 'GDS', member_time_before: 0, member_time_after: 1,
    created_at: now, created_by: 'operator',
  });
});

// Wait for Functions to consume the writes and for all locale batches to arrive.
const captures = db.collection('test_push_deliveries');
const expectedCount = 20; // Eight existing deliveries, plus six for each new Bingo.
let messages = [];
for (let attempt = 0; attempt < 120; attempt++) {
  messages = (await captures.get()).docs.map((doc) => doc.data());
  if (messages.length >= expectedCount) break;
  await delay(250);
}
assert.equal(messages.length, expectedCount, JSON.stringify(messages));
for (const type of ['new_croix', 'new_prediction', 'assistant_reply', 'account_activated']) {
  const deliveries = messages.filter((m) => m.data.type === type);
  const isPrivate = ['assistant_reply', 'account_activated'].includes(type);
  assert.deepEqual(deliveries.flatMap((m) => m.tokens).sort(),
    isPrivate ? ['member-token'] : ['legacy-token', 'member-token', 'other-token']);
  for (const {data, tokens} of deliveries) {
    assert.equal(data.locale, {'member-token': 'cr', 'legacy-token': 'fr', 'other-token': 'en'}[tokens[0]]);
    assert.equal(data.recipientUid, isPrivate ? 'member' : undefined);
    assert.ok(data.eventId && data.title && data.body);
    assert.ok(!JSON.stringify(data).includes('Private reply'));
  }
}
for (const bingoId of [manual.id, suggested.id]) {
  const deliveries = messages.filter((m) => m.data.type === 'new_bingo' && m.data.bingoId === bingoId);
  const individual = deliveries.filter((m) => m.tokens);
  const topics = deliveries.filter((m) => m.topic);
  assert.deepEqual(individual.flatMap((m) => m.tokens).sort(), ['legacy-token', 'member-token', 'other-token']);
  assert.deepEqual(topics.map((m) => m.topic).sort(), ['guest_bingo_cr', 'guest_bingo_en', 'guest_bingo_fr']);
  assert.equal(new Set(deliveries.map((m) => m.data.eventId)).size, 1);
  for (const topicMessage of topics) {
    const multicast = individual.find((m) => m.data.locale === topicMessage.data.locale);
    assert.equal(topicMessage.topic, 'guest_bingo_' + multicast.data.locale);
    assert.equal(multicast.data.recipientUid, undefined);
    assert.deepEqual(topicMessage.data, multicast.data);
    assert.deepEqual(topicMessage.webpush.headers, multicast.webpush.headers);
    const ttl = Number(multicast.webpush.headers.TTL);
    assert.ok(ttl > 0 && ttl <= 3600, 'queued BINGO expires with the story');
  }
}
// Run each sender against the real emulator after the account changes its choices.
// Await the sender itself so a negative assertion cannot pass before delivery completes.
const {createWebPushSender} = require('./web_push');
const received = [];
const sender = createWebPushSender({firestore: db, logger: {info() {}}, messaging: {
  sendEachForMulticast: async ({tokens}) => {
    received.push(...tokens);
    return {responses: tokens.map(() => ({success: true}))};
  },
}});
for (const type of ['new_bingo', 'new_croix', 'new_prediction', 'assistant_reply', 'account_activated']) {
  const targeted = type === 'assistant_reply' || type === 'account_activated';
  const send = () => (targeted ? sender.sendToUser : sender.sendToSubscribers)({
    eventId: 'preferences', userId: owner.id, data: {type},
    messages: {fr: {title: 'test', body: 'test'}},
  });
  await owner.update({[`web_push_preferences.${type}`]: false});
  received.length = 0;
  await send();
  assert.deepEqual(received.sort(), targeted ? [] : ['legacy-token', 'other-token'], type);
  await owner.update({[`web_push_preferences.${type}`]: true});
  received.length = 0;
  await send();
  assert.deepEqual(received.sort(), targeted ? ['member-token'] : ['legacy-token', 'member-token', 'other-token'], type);
}
console.log('All five notifications passed, including manual and suggested Bingo for members and guests.');
await admin.app().delete();
