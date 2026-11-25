import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test from 'node:test';
import {runInNewContext} from 'node:vm';

const source = readFileSync(new URL('../web/firebase-messaging-sw.js', import.meta.url), 'utf8');
const base = 'https://example.test/choloto/';

function browser() {
  let background, click, user;
  const notifications = [], opened = [];
  const self = {
    indexedDB: {open(name) {
      assert.equal(name, 'firebaseLocalStorageDb');
      const open = {result: {
        transaction(store) {
          assert.equal(store, 'firebaseLocalStorage');
          return {objectStore: () => ({get(key) {
            assert.equal(key, 'firebase:authUser:test-key:[DEFAULT]');
            const read = {result: user && {value: user}};
            queueMicrotask(() => read.onsuccess());
            return read;
          }})};
        },
        close() {},
      }};
      queueMicrotask(() => open.onsuccess());
      return open;
    }},
    registration: {
      scope: base + 'firebase-cloud-messaging-push-scope/',
      showNotification(title, options) { notifications.push({title, ...options}); },
    },
    addEventListener(type, fn) { if (type === 'notificationclick') click = fn; },
  };
  const firebase = {
    initializeApp() {},
    messaging: () => ({onBackgroundMessage(fn) { background = fn; }}),
    app: () => ({name: '[DEFAULT]', options: {apiKey: 'test-key'}}),
  };
  const clients = {matchAll: async () => [], openWindow: (url) => opened.push(url)};
  runInNewContext(source, {URL, self, firebase, clients, importScripts() {}});
  return {
    notifications, opened, setUser: (value) => { user = value; },
    receive: (data) => background({data}),
    tap(data) {
      return new Promise((resolve) => click({
        notification: {data, close() {}}, waitUntil: resolve,
      }));
    },
  };
}

test('a historical VIP message, an existing notification and a Croix use their normal routes', async () => {
  const app = browser();
  await app.receive({type: 'new_prediction', predictionId: 'p', locale: 'cr'});
  assert.equal(app.notifications[0].title, 'Nouvo prediksyon disponib');
  assert.equal(app.notifications[0].tag, 'prediction-p');
  await app.tap(app.notifications[0].data);
  await app.tap({url: base + 'vip'});
  await app.receive({type: 'new_croix', croixId: 'c', eventId: 'one', title: 'Croix de la chance'});
  await app.tap(app.notifications[1].data);
  assert.deepEqual(app.opened, [base + 'vip', base + 'vip', base + 'croix']);
  await app.receive({type: 'unknown', title: 'ignored'});
  await app.tap({url: 'https://example.invalid/'});
  assert.equal(app.notifications.length, 2);
  assert.equal(app.opened.length, 3);
});

for (const [type, route] of [['assistant_reply', 'customerservice'], ['account_activated', 'upgrade']]) {
  test(type + ' checks the recipient on display and again on click', async () => {
    const app = browser();
    const data = {type, recipientUid: 'owner', title: 'CHOLOTO', body: 'Message', eventId: 'one'};
    for (const session of [null, {uid: 'other', isAnonymous: false}, {uid: 'owner', isAnonymous: true}]) {
      app.setUser(session);
      await app.receive(data);
      await app.tap(data);
    }
    assert.equal(app.notifications.length, 0);
    assert.equal(app.opened.length, 0);
    app.setUser({uid: 'owner', isAnonymous: false});
    await app.receive({...data, recipientUid: undefined});
    await app.receive(data);
    assert.equal(app.notifications.length, 1);
    assert.equal(app.notifications[0].tag, type + '-one');
    await app.tap(app.notifications[0].data);
    app.setUser({uid: 'other', isAnonymous: false});
    await app.tap(app.notifications[0].data);
    assert.deepEqual(app.opened, [base + route]);
  });
}

test('Bingo opens the published story without a session', async () => {
  const app = browser();
  const bingoId = 'suggested_1 ?&=é';
  await app.receive({type: 'new_bingo', bingoId, eventId: 'bingo-event', title: 'Nouveau BINGO'});
  assert.equal(app.notifications.length, 1);
  const notification = app.notifications[0];
  await app.tap(notification.data);
  const opened = new URL(app.opened[0]);
  assert.equal(opened.origin + opened.pathname, base + 'home');
  assert.equal(opened.searchParams.get('bingoId'), bingoId);
  assert.equal([...opened.searchParams].length, 1);
  for (const invalid of [undefined, '', '/', 'bingo/other']) {
    await app.receive({type: 'new_bingo', bingoId: invalid, title: 'BINGO'});
    await app.tap({type: 'new_bingo', bingoId: invalid});
  }
  assert.equal(app.notifications.length, 1);
  assert.equal(app.opened.length, 1);
});
