// Validate the production voice-only variant without enabling the unrelated,
// locally prepared image rules. All other compatibility assertions are kept.
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';

let source = await readFile(new URL('../../tests/firestore_rules_compatibility.mjs', import.meta.url), 'utf8');
for (const label of [
  'owner atomically sends a private support image',
  'owner reads own support image',
  'admin reads member support image',
  'visitor sends a private support image without authentication',
  'visitor reads the support image through the private conversation id',
  'admin reads visitor support image',
]) {
  const original = `  200,\n  '${label}',`;
  assert.equal(source.split(original).length, 2, `Image contract assertion changed: ${label}`);
  source = source.replace(original, `  403,\n  'voice-only deployment keeps images denied: ${label}',`);
}
const paymentTests = new URL('../../tests/payment_requests_rules.mjs', import.meta.url).href;
source = source.replace("import('./payment_requests_rules.mjs')", `import(${JSON.stringify(paymentTests)})`);
await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`);
