#!/usr/bin/env node
// Upload a run's folder to the personal site's /e2e/ section and print the walkthrough's URL.
//
//   node publish.mjs .e2e/runs/<run>
//
// Settings come from ~/.config/mj-e2e.env (KEY=value lines), overridden by the environment:
//   E2E_API_URL     where to upload (e.g. the site's service on this box, http://127.0.0.1:8095)
//   E2E_PUBLIC_URL  the site's address for the link you open (defaults to E2E_API_URL)
//   E2E_TOKEN_FILE  file holding the site's API token (default ~/.config/personal-api-token)

import { readFile, readdir } from 'node:fs/promises';
import { homedir } from 'node:os';
import { extname, join } from 'node:path';

const dir = process.argv[2];
if (!dir) { console.error('usage: publish.mjs RUN_DIR'); process.exit(2); }

const env = { ...Object.fromEntries((await readFile(join(homedir(), '.config/mj-e2e.env'), 'utf8').catch(() => ''))
  .split('\n').map((l) => /^\s*([A-Z0-9_]+)=(.*)$/.exec(l)).filter(Boolean).map((m) => [m[1], m[2].trim()])), ...process.env };
const api = (env.E2E_API_URL || '').replace(/\/$/, '');
const site = (env.E2E_PUBLIC_URL || api).replace(/\/$/, '');
if (!api) { console.error('Set E2E_API_URL (in ~/.config/mj-e2e.env).'); process.exit(2); }
const token = (await readFile(env.E2E_TOKEN_FILE || join(homedir(), '.config/personal-api-token'), 'utf8')).trim();

const run = JSON.parse(await readFile(join(dir, 'run.json'), 'utf8'));
const SLUG = /^[a-z0-9][a-z0-9-]{0,79}$/;
if (!SLUG.test(run.app) || !SLUG.test(run.feature) || !/^\d{8}-\d{6}$/.test(run.run)) {
  console.error('run.json: app and feature must be lowercase slugs ([a-z0-9-]), run YYYYMMDD-HHMMSS'); process.exit(2);
}
const TYPES = { '.html': 'text/html', '.json': 'application/json', '.png': 'image/png', '.jpg': 'image/jpeg', '.webp': 'image/webp', '.txt': 'text/plain', '.yaml': 'text/plain', '.mjs': 'text/plain', '.diff': 'text/plain' };
// Server logs stay local: they can hold paths and environment details.
const files = (await readdir(dir)).filter((f) => TYPES[extname(f)] && !f.endsWith('-server.log') && /^[a-z0-9][a-z0-9._-]*$/.test(f));
if (!files.includes('index.html')) { console.error(`${dir}/index.html is missing: run report.mjs first`); process.exit(2); }

const prefix = `${run.app}/${run.feature}/${run.run}`;
// index.html last, so the page only appears once its screenshots are there.
for (const f of [...files.filter((f) => f !== 'index.html'), 'index.html']) {
  const r = await fetch(`${api}/e2e/api/files/${prefix}/${f}`, {
    method: 'PUT', body: await readFile(join(dir, f)),
    headers: { authorization: `Bearer ${token}`, 'content-type': TYPES[extname(f)] },
  });
  if (!r.ok) { console.error(`upload ${f}: HTTP ${r.status} ${await r.text()}`); process.exit(1); }
}
console.log(`${site}/e2e/${prefix}/`);
