import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { createHash } from 'node:crypto';
const hashSource = (text: string) => createHash('sha256').update(text.replaceAll('\r\n', '\n')).digest('hex').slice(0, 16);

const root = join(process.cwd(), 'docs-site');
const ledger = JSON.parse(execFileSync('git', ['show', '2f021a3308d9880826c4127d10c942ac66f14304:docs-site/blume.translations.json'], {encoding:'utf8'}));
const allowed = new Set(['title', 'description', 'type', 'sidebar', 'mode', 'related', 'search']);
let reviewed = 0;
for (const [source, stamps] of Object.entries(ledger.files)) {
  const current = await readFile(join(root, source), 'utf8');
  const match = current.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
  assert(match, `${source}: expected generated JSON-valued frontmatter`);
  const data = Object.fromEntries(match[1].split('\n').map(line => { const colon = line.indexOf(':'); assert(colon > 0); return [line.slice(0, colon), JSON.parse(line.slice(colon + 1))]; }));
  const content = match[2];
  assert(Object.keys(data).every(key => allowed.has(key)), `${source}: unreviewed metadata`);
  for (const key of ['title', 'description', 'type']) assert.equal(typeof data[key], 'string');
  const original = `---\ntitle: ${JSON.stringify(data.title)}\ndescription: ${JSON.stringify(data.description)}\ntype: ${data.type}\n${data.sidebar ? `sidebar:\n  label: ${JSON.stringify(data.sidebar.label)}\n` : ''}---\n${content}`;
  for (const [locale, stamp] of Object.entries(stamps)) {
    assert.equal(hashSource(original), stamp, `${source}/${locale}: source prose or translated fields changed`);
    const target = source.replace(/^content\//, `content/${locale}/`);
    assert((await readFile(join(root, target), 'utf8')).length > 0);
    reviewed++;
  }
}
console.log(`PASS: ${reviewed} existing translation stamps match reconstructed previous source exactly; changes limited to mode/related/search plus YAML serialization`);
