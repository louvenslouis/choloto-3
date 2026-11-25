// Preload only in the local Functions emulator. Capture its final FCM request
// so the real Firestore triggers can run without sending any device messages.
if (process.env.FUNCTIONS_EMULATOR === 'true') {
  const assert = require('node:assert/strict');
  assert.equal(process.env.GCLOUD_PROJECT, 'demo-choloto');
  assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
  const {createRequire} = require('node:module');
  const functionsRequire = createRequire(require.resolve('../functions/index.js'));
  const {Messaging} = functionsRequire('firebase-admin/messaging');
  const {getFirestore} = functionsRequire('firebase-admin/firestore');

  Messaging.prototype.sendEachForMulticast = async function (message) {
    await getFirestore().collection('test_push_deliveries').add(message);
    return {
      successCount: message.tokens.length, failureCount: 0,
      responses: message.tokens.map(() => ({success: true})),
    };
  };
  Messaging.prototype.subscribeToTopic = async function (token, topic) {
    await getFirestore().collection('test_push_subscriptions').add({token, topic});
    return {successCount: 1, failureCount: 0, errors: []};
  };
  Messaging.prototype.send = async function (message) {
    assert.ok(message.topic);
    const capture = await getFirestore().collection('test_push_deliveries').add(message);
    return capture.id;
  };
}
