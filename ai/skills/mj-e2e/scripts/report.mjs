#!/usr/bin/env node
// Build a run's walkthrough page: <run dir>/index.html, from run.json (the manifest and review,
// written by the skill) and after.json / before.json (screenshots and errors, written by run.mjs).
// A static page with no scripts and relative image links, so it works wherever the folder is served.
//
//   node report.mjs .e2e/runs/<run>

import { readFile, writeFile } from 'node:fs/promises';
import { join } from 'node:path';

const dir = process.argv[2];
if (!dir) { console.error('usage: report.mjs RUN_DIR'); process.exit(2); }
const readJson = async (f) => { try { return JSON.parse(await readFile(join(dir, f), 'utf8')); } catch { return null; } };

const run = await readJson('run.json');
if (!run) { console.error(`${dir}/run.json is missing or not JSON`); process.exit(2); }
const sides = { after: await readJson('after.json'), before: run.compare ? await readJson('before.json') : null };

const esc = (s) => String(s ?? '').replace(/[&<>"']/g, (c) => `&#${c.charCodeAt(0)};`);
const VERDICTS = { pass: 'Pass', unsure: 'Unsure', fail: 'Fail' };
const badge = (v) => (v ? `<span class="badge ${esc(v)}">${esc(VERDICTS[v] || v)}</span>` : '');
const when = (r) => (/^\d{8}-\d{6}$/.test(r || '') ? `${r.slice(6, 8)}/${r.slice(4, 6)}/${r.slice(0, 4)} ${r.slice(9, 11)}:${r.slice(11, 13)}` : '');
const shotFor = (side, id) => sides[side]?.steps.find((s) => s.id === id);

function shot(side, id) {
  const s = shotFor(side, id);
  const label = side === 'before' ? `Before (${esc(run.base || 'base')})` : `After (${esc(run.branch || 'branch')})`;
  if (!s) return `<figure class="shot missing"><figcaption>${label}</figcaption><div class="none">Not reached${sides[side]?.error ? `: ${esc(sides[side].error)}` : ''}</div></figure>`;
  return `<figure class="shot"><figcaption>${label}${s.ok ? '' : ' <span class="err">step failed</span>'}</figcaption>
    <a href="${esc(s.file)}"><img src="${esc(s.file)}" alt="${esc(`${label}: ${s.title}`)}" loading="lazy"></a>
    ${s.error ? `<pre class="error">${esc(s.error)}</pre>` : ''}
    ${s.console?.length ? `<details><summary>${s.console.length} console message${s.console.length > 1 ? 's' : ''}</summary><pre>${esc(s.console.join('\n'))}</pre></details>` : ''}
  </figure>`;
}

const steps = (run.steps || []).map((st, i) => `
  <section class="step" id="${esc(st.id)}">
    <header><span class="n">${i + 1}</span><h2>${esc(st.title || st.id)}</h2>${badge(st.verdict)}</header>
    <dl>
      ${st.do ? `<dt>Do</dt><dd>${esc(st.do)}</dd>` : ''}
      ${st.expect ? `<dt>Expect</dt><dd>${esc(st.expect)}</dd>` : ''}
      ${st.note ? `<dt>Review</dt><dd>${esc(st.note)}</dd>` : ''}
    </dl>
    <div class="shots ${run.compare ? 'two' : 'one'}">${run.compare ? shot('before', st.id) : ''}${shot('after', st.id)}</div>
  </section>`).join('');

const review = run.review || {};
const meta = [
  run.app && `<b>${esc(run.app)}</b>`,
  run.branch && `branch <code>${esc(run.branch)}</code>${run.commit ? ` @ <code>${esc(run.commit)}</code>` : ''}`,
  run.compare && run.base && `compared with <code>${esc(run.base)}</code>`,
  when(run.run),
  run.viewport,
  run.pr && `<a href="${esc(run.pr)}">pull request</a>`,
].filter(Boolean).join(' · ');

const html = `<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>${esc(run.title || run.feature)} · e2e</title>
<style>
:root{color-scheme:light dark;--bg:#fafaf9;--card:#fff;--fg:#1c1917;--mute:#78716c;--line:#e7e5e4;--code:#f5f5f4;
  --pass:#15803d;--pass-bg:#dcfce7;--fail:#b91c1c;--fail-bg:#fee2e2;--unsure:#a16207;--unsure-bg:#fef3c7}
@media (prefers-color-scheme:dark){:root{--bg:#1c1917;--card:#292524;--fg:#f5f5f4;--mute:#a8a29e;--line:#44403c;--code:#1c1917;
  --pass:#4ade80;--pass-bg:#14532d;--fail:#fca5a5;--fail-bg:#7f1d1d;--unsure:#fcd34d;--unsure-bg:#713f12}}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--fg);font:16px/1.55 system-ui,-apple-system,sans-serif}
main{max-width:1100px;margin:0 auto;padding:24px 16px 64px}
a{color:inherit}code{background:var(--code);border:1px solid var(--line);border-radius:4px;padding:0 4px;font-size:.9em}
h1{font-size:1.7rem;line-height:1.25;margin:0 0 6px}.meta{color:var(--mute);font-size:.9rem;margin-bottom:20px}
.badge{display:inline-block;font-size:.75rem;font-weight:700;letter-spacing:.04em;text-transform:uppercase;padding:2px 8px;border-radius:999px;vertical-align:middle;margin-left:8px}
.badge.pass{color:var(--pass);background:var(--pass-bg)}.badge.fail{color:var(--fail);background:var(--fail-bg)}.badge.unsure{color:var(--unsure);background:var(--unsure-bg)}
.card{background:var(--card);border:1px solid var(--line);border-radius:12px;padding:16px 18px;margin:0 0 16px}
.card h3{margin:0 0 6px;font-size:.8rem;text-transform:uppercase;letter-spacing:.05em;color:var(--mute)}
.card p{margin:0 0 8px}.card ul{margin:0;padding-left:20px}
.grid{display:grid;gap:16px;grid-template-columns:1fr}@media (min-width:760px){.grid{grid-template-columns:1fr 1fr}}
.step{border-top:1px solid var(--line);padding-top:20px;margin-top:28px}
.step header{display:flex;align-items:center;gap:10px}.step h2{font-size:1.2rem;margin:0}
.n{flex:none;width:28px;height:28px;border-radius:50%;background:var(--fg);color:var(--bg);display:grid;place-items:center;font-weight:700;font-size:.9rem}
dl{display:grid;grid-template-columns:auto 1fr;gap:4px 12px;margin:12px 0}dt{color:var(--mute);font-size:.85rem;padding-top:2px}dd{margin:0}
.shots{display:grid;gap:16px;align-items:start}.shots.one{max-width:460px}
.shots.two{grid-template-columns:1fr}@media (min-width:640px){.shots.two{grid-template-columns:1fr 1fr}}
figure{margin:0}figcaption{font-size:.8rem;color:var(--mute);margin-bottom:6px}
.shot img{display:block;width:100%;height:auto;border:1px solid var(--line);border-radius:10px}
.none{border:1px dashed var(--line);border-radius:10px;padding:32px 12px;text-align:center;color:var(--mute);font-size:.9rem}
pre{white-space:pre-wrap;word-break:break-word;font-size:.8rem;background:var(--code);border:1px solid var(--line);border-radius:6px;padding:8px;margin:8px 0 0}
pre.error,.err{color:var(--fail)}details{margin-top:6px;font-size:.85rem;color:var(--mute)}
</style></head>
<body><main>
<h1>${esc(run.title || run.feature)}${badge(review.verdict)}</h1>
<div class="meta">${meta}</div>
<div class="grid">
  <div class="card"><h3>What this PR does</h3><p>${esc(run.summary)}</p>
    ${run.changed?.length ? `<h3>What changed</h3><ul>${run.changed.map((c) => `<li>${esc(c)}</li>`).join('')}</ul>` : ''}</div>
  <div class="card"><h3>Review</h3><p>${esc(review.summary || 'No review written.')}</p>
    ${review.issues?.length ? `<h3>Issues</h3><ul>${review.issues.map((c) => `<li>${esc(c)}</li>`).join('')}</ul>` : ''}</div>
</div>
${steps}
</main></body></html>
`;

await writeFile(join(dir, 'index.html'), html);
console.log(join(dir, 'index.html'));
