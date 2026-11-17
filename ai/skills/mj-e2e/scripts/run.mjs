#!/usr/bin/env node
// Run a walkthrough script in headless Chrome and screenshot each step.
//
//   node run.mjs --script e2e/<feature>/walkthrough.mjs --base http://127.0.0.1:8080 \
//     --label after --out .e2e/runs/<run> [--viewport phone|desktop] [--headed]
//
// The script's default export gets { page, step, baseURL, label, expect }. step(id, title, fn, opts)
// runs fn, then saves <out>/<label>-NN-<id>.png (opts.fullPage for the whole page). The first failing
// step is screenshotted with its error and ends the run. Results go to <out>/<label>.json:
// { label, baseURL, viewport, ok, steps: [{ n, id, title, ok, error, file, url, ms, console }] }.
// Exits 0 if every step passed, 1 if one failed, 2 on a usage or browser error.

import { mkdir, writeFile } from 'node:fs/promises';
import { resolve, join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { parseArgs } from 'node:util';
import { chromium, expect } from '@playwright/test';

const VIEWPORTS = {
  phone: { viewport: { width: 390, height: 844 }, deviceScaleFactor: 2, isMobile: true, hasTouch: true },
  desktop: { viewport: { width: 1280, height: 800 }, deviceScaleFactor: 1 },
};

const { values: a } = parseArgs({
  options: {
    script: { type: 'string' }, base: { type: 'string' }, label: { type: 'string', default: 'after' },
    out: { type: 'string' }, viewport: { type: 'string', default: 'phone' }, headed: { type: 'boolean', default: false },
    timeout: { type: 'string', default: '15000' },
  },
});
if (!a.script || !a.base || !a.out || !VIEWPORTS[a.viewport] || !/^[a-z0-9-]+$/.test(a.label)) {
  console.error('usage: run.mjs --script FILE --base URL --out DIR [--label after|before] [--viewport phone|desktop] [--headed]');
  process.exit(2);
}

const out = resolve(a.out);
await mkdir(out, { recursive: true });
const walkthrough = (await import(pathToFileURL(resolve(a.script)).href)).default;
if (typeof walkthrough !== 'function') { console.error(`${a.script} has no default export function`); process.exit(2); }

// The system's Chrome, so no browser download is needed.
const browser = await chromium.launch({ channel: 'chrome', headless: !a.headed });
const context = await browser.newContext({ ...VIEWPORTS[a.viewport], locale: 'en-GB', timezoneId: 'Europe/London' });
context.setDefaultTimeout(Number(a.timeout));
const page = await context.newPage();
let consoleLines = [];
page.on('console', (m) => { if (m.type() === 'error' || m.type() === 'warning') consoleLines.push(`${m.type()}: ${m.text()}`.slice(0, 300)); });
page.on('pageerror', (e) => consoleLines.push(`pageerror: ${e.message}`.slice(0, 300)));

// Playwright colours its messages for terminals; the report wants plain text.
const plain = (e) => String(e?.message || e).replace(/\x1b\[[0-9;]*m/g, '').split('\n').slice(0, 6).join('\n');

const result = { label: a.label, baseURL: a.base, viewport: a.viewport, ok: true, steps: [] };
class StepFailed extends Error {}

async function step(id, title, fn, opts = {}) {
  const n = result.steps.length + 1;
  const file = `${a.label}-${String(n).padStart(2, '0')}-${id.replace(/[^a-z0-9-]/gi, '-').toLowerCase()}.png`;
  const started = Date.now();
  consoleLines = [];
  let error = null;
  try { await fn(); } catch (e) { error = plain(e); }
  await page.waitForLoadState('networkidle', { timeout: 3000 }).catch(() => {});
  await page.screenshot({ path: join(out, file), fullPage: !!opts.fullPage, animations: 'disabled' }).catch(() => {});
  const s = { n, id, title, ok: !error, error, file, url: page.url(), ms: Date.now() - started, console: consoleLines };
  result.steps.push(s);
  console.log(`${s.ok ? 'ok  ' : 'FAIL'} ${a.label} ${n} ${id}${error ? `: ${error.split('\n')[0]}` : ''}`);
  if (error) { result.ok = false; throw new StepFailed(error); }
}

let code = 0;
try {
  await walkthrough({ page, step, baseURL: a.base.replace(/\/$/, ''), label: a.label, expect });
} catch (e) {
  code = 1;
  if (!(e instanceof StepFailed)) {
    // Thrown outside any step: record it so the report shows why the run stopped.
    result.ok = false;
    result.error = plain(e);
    console.error(`walkthrough error: ${result.error}`);
  }
} finally {
  await writeFile(join(out, `${a.label}.json`), `${JSON.stringify(result, null, 2)}\n`);
  await browser.close();
}
process.exit(code);
