const assert = require("node:assert/strict");
const {test} = require("node:test");
const {createGuestBingoPush} = require("../guest_bingo_push");

const token = "test_registration_token-0123456789:FAKE";

test("guest registration is a callable with bounded instances in the app's region", () => {
  process.env.GCLOUD_PROJECT = "demo-choloto";
  const endpoint = require("../index").registerGuestBingoPush.__endpoint;
  assert.deepEqual(endpoint.callableTrigger, {});
  assert.deepEqual(endpoint.region, ["northamerica-northeast1"]);
  assert.equal(endpoint.maxInstances, 3);
  assert.equal(endpoint.timeoutSeconds, 30);
});

test("guest opt-in registers one token on the server-selected BINGO topic", async () => {
  const calls = [];
  const push = createGuestBingoPush({messaging: {
    subscribeToTopic: async (...args) => {
      calls.push(args);
      return {successCount: 1, failureCount: 0, errors: []};
    },
  }});
  for (const locale of ["fr", "en", "cr"]) {
    assert.deepEqual(await push.register({token, locale}), {registered: true});
  }
  assert.deepEqual(calls, ["fr", "en", "cr"].map((locale) => [token, `guest_bingo_${locale}`]));
});

test("guest registration rejects batches, unknown topics, invalid locales and malformed tokens", async () => {
  const push = createGuestBingoPush({messaging: {subscribeToTopic: assert.fail}});
  for (const data of [
    null, {}, {token, locale: "en", topic: "vip"}, {token, locale: "xx"},
    {token, locale: "__proto__"}, {token, locale: ["en"]},
    ...[null, [token], "/topics/vip", "x".repeat(4097), "x", token + "\n", token + " " + token]
      .map((candidate) => ({token: candidate, locale: "fr"})),
  ]) {
    await assert.rejects(push.register(data), {code: "invalid-argument"});
  }
});

test("FCM refusal returns an error without echoing the device token", async () => {
  for (const [fcmCode, expected] of [
    ["messaging/registration-token-not-registered", "invalid-argument"],
    ["messaging/server-unavailable", "unavailable"],
  ]) {
    const push = createGuestBingoPush({messaging: {
      subscribeToTopic: async () => ({
        successCount: 0, failureCount: 1, errors: [{index: 0, error: {code: fcmCode, message: token}}],
      }),
    }});
    await assert.rejects(push.register({token, locale: "en"}), (error) =>
      error.code === expected && !error.message.includes(token));
  }
});

const notification = {
  eventId: "new-draw",
  data: {type: "new_bingo", route: "bingo", bingoId: "draw"},
  messages: Object.fromEntries(["fr", "en", "cr"].map((l) => [l, {title: l, body: l}])),
};

test("BINGO reaches historical member registrations and exactly three public language topics", async () => {
  const members = [], topics = [];
  const push = createGuestBingoPush({
    sendToSubscribers: async (notice) => members.push(notice),
    messaging: {send: async (payload) => topics.push(payload)},
  });
  await push.sendBingoToAll(notification);
  assert.deepEqual(members, [notification]);
  assert.deepEqual(topics, ["fr", "en", "cr"].map((locale) => ({
    topic: `guest_bingo_${locale}`,
    data: {...notification.data, eventId: "new-draw", locale, ...notification.messages[locale]},
    webpush: {headers: {TTL: "86400", Urgency: "high"}},
  })));
  await assert.rejects(push.sendBingoToAll({...notification, data: {type: "assistant_reply"}}));
  assert.equal(topics.length, 3);
});

test("one failing topic still allows the other deliveries to finish", async () => {
  let memberDone = false;
  let topicDone = 0;
  const push = createGuestBingoPush({
    sendToSubscribers: async () => {
      await new Promise((resolve) => setImmediate(resolve));
      memberDone = true;
    },
    messaging: {send: async ({topic}) => {
      if (topic === "guest_bingo_en") throw new Error("fcm-unavailable");
      await new Promise((resolve) => setImmediate(resolve));
      topicDone++;
    }},
  });
  await assert.rejects(push.sendBingoToAll(notification), /fcm-unavailable/);
  assert.ok(memberDone);
  assert.equal(topicDone, 2);
});
