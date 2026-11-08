import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import { runInNewContext } from 'node:vm';

const source = readFileSync(new URL('../web/draw-ads.js', import.meta.url), 'utf8');

test('only an eligible subscriber starts Google and a confirmed choice permits a slot', () => {
  const scripts = [];
  const document = {
    head: {append: script => scripts.push(script)},
    createElement: () => ({}),
  };
  const window = {};
  runInNewContext(source, {document, window});
  assert.equal(scripts.length, 0);
  const states = [];
  const stop = window.cholotoDrawAds.watchConsent(value => states.push(value));
  assert.equal(scripts.length, 1);
  assert.equal(states.at(-1), false);
  let consent;
  window.__tcfapi = (command, version, callback) => { consent = callback; };
  window.googlefc.callbackQueue[0].CONSENT_API_READY();
  const accepted = {
    gdprApplies: true, eventStatus: 'useractioncomplete',
    purpose: {consents: {1: true}}, vendor: {consents: {755: true}},
  };
  for (const data of [undefined, {}, {...accepted, eventStatus:'cmpuishown'},
    {...accepted, vendor: {}}, {...accepted, purpose: {}}]) {
    consent(data, true);
    assert.equal(states.at(-1), false);
  }
  consent(accepted, true);
  assert.equal(states.at(-1), true);
  consent({...accepted, purpose: {}}, true);
  assert.equal(states.at(-1), false);
  consent({gdprApplies: false}, true);
  assert.equal(states.at(-1), true);
  consent(accepted, false);
  assert.equal(states.at(-1), false);
  stop();
  const count = states.length;
  consent(accepted, true);
  assert.equal(states.length, count);
  const detach = window.cholotoDrawAds.watchConsent(value => states.push(value));
  assert.equal(states.at(-1), true);
  assert.equal(scripts.length, 1);
  detach();
});
