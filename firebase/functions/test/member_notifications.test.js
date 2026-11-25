const test = require("node:test");
const assert = require("node:assert/strict");
const {Timestamp} = require("firebase-admin/firestore");
const {createMemberNotificationHandlers} = require("../member_notifications");

const time = (ms) => Timestamp.fromMillis(ms);
const uid = "member";
const context = {eventId: "event", params: {userId: uid}};

function snapshot(fields) {
  return {
    exists: fields !== undefined,
    get: (key) => fields?.[key],
    updateTime: time(1000),
    readTime: time(1100),
  };
}

function fixture() {
  const deliveries = [];
  const handlers = createMemberNotificationHandlers({
    send: async (message) => deliveries.push(message),
  });
  async function update(before, after, latest = after) {
    const change = {before: snapshot(before), after: snapshot(after)};
    change.after.ref = {get: async () => snapshot(latest)};
    await handlers.onAccountActivated(change, context);
  }
  async function message(role, conversation, attachment) {
    const doc = snapshot({
      sender_role: role,
      sender_uid: "author",
      text: "private message",
      attachment_type: attachment,
    });
    doc.ref = {parent: {parent: {get: async () => snapshot(conversation)}}};
    await handlers.onAssistantReplyCreated(doc, context);
  }
  return {deliveries, update, message};
}

function assertDelivery(delivery, type, route) {
  assert.equal(delivery.userId, uid);
  assert.equal(delivery.eventId, context.eventId);
  assert.deepEqual(delivery.data, {type, route});
  assert.deepEqual(Object.keys(delivery.messages).sort(), ["cr", "en", "fr"]);
  for (const {title, body} of Object.values(delivery.messages)) {
    assert.ok(title && body);
  }
}

test("only the transition from free or expired to active VIP notifies the owner", async () => {
  const f = fixture();
  const profile = {uid, created_time: time(900), onboarding_pending: true};
  const completed = {
    ...profile,
    onboarding_pending: false,
    onboarding_completed_at: time(1000),
    end_sub: time(1000),
  };
  const active = {...completed, end_sub: time(5000), member_time: 1};
  await f.update(profile, completed);
  await f.update(completed, {...completed, device: "Web"});
  await f.update(completed, active);
  await f.update(active, {...active, end_sub: time(7000), member_time: 2});
  await f.update(active, profile);
  await f.update({end_sub: time(800)}, {end_sub: time(6000)});
  assert.equal(f.deliveries.length, 2);
  f.deliveries.forEach((d) => assertDelivery(d, "account_activated", "subscription"));
});

test("onboarding timestamps, malformed dates, foreign uid and revoked access do not notify", async () => {
  const f = fixture();
  const future = time(4000);
  for (const after of [
    {}, {end_sub: time(1000)}, {end_sub: "2099-01-01"},
    {end_sub: future, onboarding_completed_at: future},
    {end_sub: future, created_time: future},
    {end_sub: future, uid: "other"},
  ]) {
    await f.update({}, after);
  }
  await f.update({}, {end_sub: future}, {});
  assert.deepEqual(f.deliveries, []);
});

test("an admin reply targets the conversation owner for text, image and voice", async () => {
  const f = fixture();
  for (const attachment of [undefined, "image", "audio"]) {
    await f.message("admin", {user_uid: uid, status: "open"}, attachment);
  }
  assert.equal(f.deliveries.length, 3);
  f.deliveries.forEach((d) => {
    assertDelivery(d, "assistant_reply", "support");
    assert.ok(!JSON.stringify(d).includes("private message"));
  });
});

test("member messages, unlinked guests and missing or mismatched conversations do not notify", async () => {
  const f = fixture();
  await f.message("user", {user_uid: uid});
  await f.message("admin", undefined);
  await f.message("admin", {user_uid: "another-member"});
  await f.message("admin", {user_uid: uid, guest_access: true});
  await f.message("admin", {user_uid: uid, status: "deleting"});
  assert.deepEqual(f.deliveries, []);
});

test("registered triggers listen to profile updates and individual message creation", () => {
  process.env.GCLOUD_PROJECT = "demo-choloto";
  const {onAccountActivated, onAssistantReplyCreated} = require("../index");
  const triggers = [
    [onAccountActivated, "update", "user/{userId}"],
    [onAssistantReplyCreated, "create", "support_conversations/{userId}/messages/{messageId}"],
  ];
  for (const [fn, operation, path] of triggers) {
    const {eventType, resource} = fn.__trigger.eventTrigger;
    assert.equal(eventType, `providers/cloud.firestore/eventTypes/document.${operation}`);
    assert.equal(resource, `projects/demo-choloto/databases/(default)/documents/${path}`);
  }
});
