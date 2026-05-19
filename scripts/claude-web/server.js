const http = require('http');
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const PORT = process.env.PORT || 3000;
const SESSION = process.env.TMUX_SESSION || 'claude-remote';
const LOG_FILE = '/tmp/claude-remote/responses.jsonl';

function serveFile(res, filePath, contentType) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    res.writeHead(200, { 'Content-Type': contentType });
    res.end(content);
  } catch {
    res.writeHead(404);
    res.end('Not found');
  }
}

function readBody(req) {
  return new Promise((resolve) => {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => resolve(body));
  });
}

function sendToTmux(message) {
  // Escape single quotes for shell, use send-keys with literal flag
  const escaped = message.replace(/'/g, "'\\''");
  execSync(`tmux send-keys -t ${SESSION} -l '${escaped}'`);
  execSync(`tmux send-keys -t ${SESSION} Enter`);
}

function getResponses(afterId) {
  if (!fs.existsSync(LOG_FILE)) return [];

  const lines = fs.readFileSync(LOG_FILE, 'utf8').trim().split('\n').filter(Boolean);
  const responses = lines.map(line => {
    try { return JSON.parse(line); }
    catch { return null; }
  }).filter(Boolean);

  if (!afterId) return responses;

  const idx = responses.findIndex(r => r.id === afterId);
  if (idx === -1) return responses;
  return responses.slice(idx + 1);
}

function isClaudeBusy() {
  // Check if claude appears to be processing by looking at the pane
  try {
    const output = execSync(`tmux capture-pane -t ${SESSION} -p -S -5`, { encoding: 'utf8' });
    // If the last non-empty line contains a prompt indicator, claude is idle
    const lines = output.trim().split('\n').filter(Boolean);
    const lastLine = lines[lines.length - 1] || '';
    // Claude shows ">" or "❯" when waiting for input
    return !lastLine.match(/^[>❯]\s*$/);
  } catch {
    return false;
  }
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://localhost:${PORT}`);

  // CORS headers for local dev
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  if (req.method === 'GET' && url.pathname === '/') {
    serveFile(res, path.join(__dirname, 'index.html'), 'text/html');
    return;
  }

  if (req.method === 'POST' && url.pathname === '/send') {
    const body = await readBody(req);
    try {
      const { message } = JSON.parse(body);
      if (!message) throw new Error('No message');
      sendToTmux(message);
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ ok: true }));
    } catch (err) {
      res.writeHead(400, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: err.message }));
    }
    return;
  }

  if (req.method === 'GET' && url.pathname === '/poll') {
    const afterId = url.searchParams.get('after');
    const responses = getResponses(afterId);
    const busy = isClaudeBusy();
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ responses, busy }));
    return;
  }

  if (req.method === 'GET' && url.pathname === '/health') {
    let tmuxOk = false;
    try {
      execSync(`tmux has-session -t ${SESSION} 2>/dev/null`);
      tmuxOk = true;
    } catch {}
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ ok: true, tmux: tmuxOk, session: SESSION }));
    return;
  }

  res.writeHead(404);
  res.end('Not found');
});

server.listen(PORT, () => {
  console.log(`Claude Web UI running at http://localhost:${PORT}`);
  console.log(`tmux session: ${SESSION}`);
  console.log(`Log file: ${LOG_FILE}`);
});
