import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {runInNewContext} from 'node:vm';
import test from 'node:test';

const source = readFileSync(new URL('../web/croix-ads.js', import.meta.url), 'utf8');

function browser() {
  const handlers = new Map(), results = [], slots = [];
  let consent, show, timeout, impressions = 0;
  const service = {
    addEventListener: (name, handler) => handlers.set(name, handler),
    removeEventListener: name => handlers.delete(name),
  };
  const window = {
    cholotoDrawAds: {watchConsent(callback) {
      consent = callback;
      callback(false);
      return () => { consent = undefined; };
    }},
    googletag: {
      apiReady: true, cmd: {push: fn => fn()}, pubads: () => service,
      enums: {OutOfPageFormat: {REWARDED: 'rewarded'}},
      defineOutOfPageSlot() {
        const slot = {addService() {}};
        slots.push(slot);
        return slot;
      },
      enableServices() {}, display() {}, destroySlots() {},
    },
  };
  runInNewContext(source, {window, setTimeout: fn => { timeout = fn; }, clearTimeout() {}});
  function emit(name, values) { handlers.get(name)?.({slot: slots.at(-1), ...values}); }
  return {
    slots, results, handlers, timeout: () => timeout(), consent: v => consent?.(v),
    open: () => window.cholotoCroixAds.prepare('/test/unit', fn => { show = fn; }, v => results.push(v)),
    ready: () => emit('rewardedSlotReady', {makeRewardedVisible() { impressions++; return true; }}),
    impressions: () => impressions, accept: () => show(), emit,
  };
}

test('each opening needs its own opt-in and grant; closing early forfeits access', () => {
  const b = browser();
  for (const complete of [true, false]) {
    b.open();
    b.consent(true);
    b.ready();
    const before = b.impressions();
    b.accept(); b.accept();
    assert.equal(b.impressions(), before + 1);
    b.emit('rewardedSlotGranted', {slot: {}});
    if (complete) b.emit('rewardedSlotGranted');
    b.emit('rewardedSlotClosed');
    assert.equal(b.results.at(-1), complete);
    assert.equal(b.handlers.size, 0);
  }
  assert.equal(b.slots.length, 2);
});

test('no consent, no fill and withdrawn consent release the page; exiting cancels callbacks', () => {
  const b = browser();
  b.open(); b.timeout();
  assert.equal(b.slots.length, 0);
  b.open(); b.consent(true); b.emit('slotRenderEnded', {isEmpty: true});
  b.open(); b.consent(true); b.ready(); b.consent(false); b.accept();
  const cancel = b.open(); b.consent(true); cancel(); b.emit('rewardedSlotClosed'); b.timeout();
  assert.equal(b.impressions(), 0);
  assert.deepEqual(b.results, [true, true, true]);
  assert.equal(b.handlers.size, 0);
});
