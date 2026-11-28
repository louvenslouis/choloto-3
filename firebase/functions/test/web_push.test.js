const assert = require("node:assert/strict");
const {test} = require("node:test");
const {createWebPushSender} = require("../web_push");

const notice = {
  eventId: "publication", data: {type: "new_croix"},
  messages: {fr: {title: "Croix", body: "Disponible"}},
};

function registration(token, onDelete = assert.fail, uid = "owner") {
  const fields = {token, locale: "fr", userId: uid};
  return {
    get: (key) => fields[key], updateTime: 123,
    ref: {parent: {parent: {id: uid}}, delete: (precondition) => {
      assert.deepEqual(precondition, {lastUpdateTime: 123});
      return onDelete();
    }},
  };
}

function fixture(docs, sendEachForMulticast, muted = []) {
  return createWebPushSender({
    firestore: {collection: (name) => {
      assert.equal(name, "user");
      return {where: (field, op, value) => {
        assert.deepEqual([field, op, value], ["web_push_preferences.new_croix", "==", false]);
        return {select: () => ({get: async () => ({docs: muted.map((id) => ({id}))})})};
      }};
    }, collectionGroup: (name) => {
      assert.equal(name, "webPushTokens");
      return {get: async () => ({docs})};
    }},
    messaging: {sendEachForMulticast},
    logger: {info() {}},
  });
}

test("FCM batches contain at most 500 unique nonempty registration tokens", async () => {
  const docs = Array.from({length: 501}, (_, n) => registration(String(n)));
  docs.push(registration("0"), registration(""), registration(undefined));
  const batches = [];
  const sender = fixture(docs, async ({tokens}) => {
    batches.push(tokens);
    return {responses: tokens.map(() => ({success: true}))};
  });
  await sender.sendToSubscribers(notice);
  assert.deepEqual(batches.map((b) => b.length), [500, 1]);
  assert.equal(new Set(batches.flat()).size, 501);
  assert.throws(() => sender.sendToUser(notice), /recipient UID/);
});

test("empty audience skips FCM", async () => {
  await fixture([], assert.fail).sendToSubscribers(notice);
});

test("retries only temporary failures and removes only unchanged invalid registrations", async () => {
  const removed = [];
  const docs = [
    registration("ok"), registration("temporary"), registration("config"),
    registration("invalid", () => removed.push("old")),
    registration("invalid", () => { throw Object.assign(new Error("refreshed"), {code: 9}); }),
  ];
  const calls = [];
  const errors = {
    temporary: "messaging/server-unavailable",
    config: "messaging/mismatched-credential",
    invalid: "messaging/registration-token-not-registered",
  };
  const sender = fixture(docs, async ({tokens}) => {
    calls.push(tokens);
    return {responses: tokens.map((token) => {
      const code = calls.length === 1 && errors[token];
      return code ? {success: false, error: {code}} : {success: true};
    })};
  });
  await sender.sendToSubscribers(notice);
  assert.deepEqual(calls, [["ok", "temporary", "config", "invalid"], ["temporary"]]);
  assert.deepEqual(removed, ["old"]);
});

test("a muted account skips every browser and duplicate, preserving other accounts", async () => {
  const docs = [registration("shared"), registration("other"),
    registration("shared", assert.fail, "muted"), registration("second", assert.fail, "muted")];
  const delivered = [];
  await fixture(docs, async ({tokens}) => {
    delivered.push(...tokens);
    return {responses: tokens.map(() => ({success: true}))};
  }, ["muted"]).sendToSubscribers(notice);
  assert.deepEqual(delivered, ["other"]);
});
