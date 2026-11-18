const assert = require("node:assert/strict");
const {test} = require("node:test");
const {createUserProfileHandler} = require("../user_profile");

const user = {
  uid: "member",
  email: "member@example.test",
  displayName: "Member",
  providerData: [{providerId: "google.com"}],
  metadata: {creationTime: "Wed, 11 Nov 2026 19:00:00 GMT"},
};

function fixture({account = user, existing, readError, writeError} = {}) {
  let saved = existing;
  let writes = 0;
  const handler = createUserProfileHandler({
    auth: {getUser: async (uid) => {
      assert.equal(uid, user.uid);
      if (readError) throw readError;
      return account;
    }},
    firestore: {doc: (path) => {
      assert.equal(path, "user/member");
      return {create: async (data) => {
        writes++;
        if (writeError) throw writeError;
        if (saved) throw Object.assign(new Error("exists"), {code: 6});
        saved = data;
      }};
    }},
  });
  return {handler, profile: () => saved, writes: () => writes};
}

test("creates the canonical member after Auth, without any client write", async () => {
  const f = fixture();
  await f.handler(user);
  assert.deepEqual(f.profile(), {
    uid: user.uid,
    email: user.email,
    display_name: user.displayName,
    created_time: new Date(user.metadata.creationTime),
    onboarding_pending: true,
  });
});

test("duplicate and concurrent deliveries preserve the first profile", async () => {
  const f = fixture();
  await Promise.all([f.handler(user), f.handler(user)]);
  const first = f.profile();
  await f.handler(user);
  assert.equal(f.profile(), first);
});

test("accepts ISO event dates and UTC Admin dates for the same account", async () => {
  const f = fixture();
  await f.handler({...user, metadata: {creationTime: "2026-11-11T19:00:00.123Z"}});
  assert.equal(f.profile().uid, user.uid);
});

test("preserves existing legacy profiles, VIP, and completed onboarding", async () => {
  const existing = {
    email: "legacy@example.test",
    end_sub: new Date("2027-01-01"),
    member_time: 4,
    onboarding_pending: false,
    phone_number: "1234567890",
  };
  const f = fixture({existing});
  await f.handler(user);
  assert.equal(f.profile(), existing);
});

test("skips anonymous sessions", async () => {
  const f = fixture({account: {...user, email: undefined, providerData: []}});
  await f.handler(user);
  assert.equal(f.writes(), 0);
});

test("supports email/password accounts without a display name", async () => {
  const f = fixture({account: {...user, displayName: undefined, providerData: []}});
  await f.handler(user);
  assert.equal(f.profile().email, user.email);
  assert.equal("display_name" in f.profile(), false);
});

test("does not resurrect a deleted or replaced Auth account on retry", async () => {
  for (const options of [
    {readError: Object.assign(new Error("deleted"), {code: "auth/user-not-found"})},
    {account: {...user, metadata: {creationTime: "Thu, 12 Nov 2026 19:00:00 GMT"}}},
  ]) {
    const f = fixture(options);
    await f.handler(user);
    assert.equal(f.writes(), 0);
  }
});

test("propagates Auth and Firestore failures for platform retries", async () => {
  const failure = Object.assign(new Error("unavailable"), {code: 14});
  for (const options of [{readError: failure}, {writeError: failure}]) {
    const f = fixture(options);
    await assert.rejects(f.handler(user), (error) => error === failure);
  }
});
