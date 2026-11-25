const assert = require("node:assert/strict");
const {test} = require("node:test");

test("publications notify on document creation only, including the released VIP path", () => {
  process.env.GCLOUD_PROJECT = "demo-choloto";
  const deployed = require("../index");
  const paths = {
    onBingoCreated: "bingo/{bingoId}",
    onCroixCreated: "croix/{croixId}",
    onPredictionCreated: "prediction/{predictionId}",
  };
  for (const [name, path] of Object.entries(paths)) {
    assert.ok(deployed[name], name);
    const trigger = deployed[name].__trigger;
    assert.equal(trigger.eventTrigger.eventType, "providers/cloud.firestore/eventTypes/document.create");
    assert.equal(trigger.eventTrigger.resource, `projects/demo-choloto/databases/(default)/documents/${path}`);
    assert.deepEqual(trigger.regions, ["northamerica-northeast1"]);
  }
});

test("BINGO, Croix and VIP broadcast availability in three languages without publishing numbers", async () => {
  const {createPublicationHandlers} = require("../publication_notifications");
  const deliveries = [];
  const handlers = createPublicationHandlers(
    async (message) => {
      assert.notEqual(message.data.type, "new_bingo");
      deliveries.push(message);
    },
    async (message) => {
      assert.equal(message.data.type, "new_bingo");
      deliveries.push(message);
    },
  );

  const date = {toMillis: () => Date.now()};
  const expiration = {toMillis: () => Date.now() + 86400000};
  await handlers.onBingoCreated(
    {data: () => ({date, expiration, dataStack: [{boul: "96"}]})},
    {params: {bingoId: "suggested_draw"}, eventId: "bingo-event"},
  );
  await handlers.onCroixCreated(
    {data: () => ({created_by: "admin", numeros: ["15", "33"]})},
    {params: {croixId: "cross-id"}, eventId: "cross-event"},
  );
  await handlers.onPredictionCreated(
    {data: () => ({created_by: "admin", boloto: {boul: ["96"]}})},
    {params: {predictionId: "vip-id"}, eventId: "vip-event"},
  );
  assert.deepEqual(deliveries.map((message) => message.data), [
    {type: "new_bingo", route: "bingo", bingoId: "suggested_draw"},
    {type: "new_croix", route: "croix", croixId: "cross-id"},
    {type: "new_prediction", route: "vip", predictionId: "vip-id"},
  ]);
  assert.deepEqual(deliveries.map((message) => message.eventId), ["bingo-event", "cross-event", "vip-event"]);
  for (const {messages, userId} of deliveries) {
    assert.equal(userId, undefined);
    assert.deepEqual(Object.keys(messages).sort(), ["cr", "en", "fr"]);
    for (const {title, body} of Object.values(messages)) {
      assert.ok(title && body);
      assert.doesNotMatch(`${title} ${body}`, /15|33|96/);
    }
  }
});

test("an expired or undated BINGO does not announce an unavailable story", async () => {
  const {createPublicationHandlers} = require("../publication_notifications");
  const handlers = createPublicationHandlers(assert.fail, () => assert.fail("inactive BINGO"));
  const date = {toMillis: () => Date.now()};
  const expiration = {toMillis: () => Date.now() - 3600000};
  for (const fields of [{}, {expiration}, {date}, {date, expiration}]) {
    await handlers.onBingoCreated({data: () => fields}, {params: {bingoId: "old"}});
  }
});

test("the notification expires with a Bingo that has one minute left", async () => {
  const {createPublicationHandlers} = require("../publication_notifications");
  const expiresAt = Date.now() + 60000;
  const date = {toMillis: () => expiresAt - 86400000};
  const expiration = {toMillis: () => expiresAt};
  const {onBingoCreated} = createPublicationHandlers(assert.fail, (notice) => notice);
  const notice = await onBingoCreated({data: () => ({date, expiration})},
    {params: {bingoId: "soon"}, eventId: "one"});
  assert.ok(notice.ttlSeconds > 0 && notice.ttlSeconds <= 60);
});
