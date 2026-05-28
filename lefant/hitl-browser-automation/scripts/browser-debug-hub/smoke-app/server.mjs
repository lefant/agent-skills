#!/usr/bin/env node
import http from 'node:http';
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const args = new Map();
for (let i = 2; i < process.argv.length; i += 2) {
  args.set(process.argv[i], process.argv[i + 1]);
}

const host = args.get('--host') || process.env.BDH_SMOKE_HOST || '127.0.0.1';
const port = Number(args.get('--port') || process.env.BDH_SMOKE_PORT || 0);
const clickSequence = [];
const allowedChoices = new Set(['red', 'blue', 'green']);

function sendJson(res, status, body) {
  const payload = JSON.stringify(body, null, 2);
  res.writeHead(status, {
    'content-type': 'application/json; charset=utf-8',
    'cache-control': 'no-store',
    'content-length': Buffer.byteLength(payload),
  });
  res.end(payload);
}

async function readBody(req) {
  const chunks = [];
  for await (const chunk of req) chunks.push(chunk);
  return Buffer.concat(chunks).toString('utf8');
}

async function readJson(req) {
  const raw = await readBody(req);
  try {
    return raw ? JSON.parse(raw) : {};
  } catch {
    const error = new Error('invalid_json');
    error.rawLength = raw.length;
    throw error;
  }
}

function flowState() {
  return {
    ok: true,
    app: 'browser-debug-hub-smoke',
    state: 'ready',
    sequence: [...clickSequence],
    count: clickSequence.length,
    finalChoice: clickSequence[clickSequence.length - 1] || null,
  };
}

const server = http.createServer(async (req, res) => {
  try {
    const url = new URL(req.url || '/', `http://${host}:${port || 80}`);

    if (req.method === 'GET' && url.pathname === '/') {
      const html = await fs.readFile(path.join(__dirname, 'public/index.html'));
      res.writeHead(200, {
        'content-type': 'text/html; charset=utf-8',
        'cache-control': 'no-store',
        'set-cookie': 'bdh_smoke_session=demo; HttpOnly; SameSite=Lax',
      });
      res.end(html);
      return;
    }

    if (req.method === 'GET' && url.pathname === '/api/state') {
      sendJson(res, 200, flowState());
      return;
    }

    if (req.method === 'POST' && url.pathname === '/api/reset') {
      clickSequence.splice(0, clickSequence.length);
      sendJson(res, 200, flowState());
      return;
    }

    if (req.method === 'POST' && url.pathname === '/api/click') {
      let parsed;
      try {
        parsed = await readJson(req);
      } catch (error) {
        sendJson(res, 400, { ok: false, error: error.message, rawLength: error.rawLength });
        return;
      }

      const choice = String(parsed.choice || '').trim().toLowerCase();
      if (!allowedChoices.has(choice)) {
        sendJson(res, 422, { ok: false, error: 'invalid_choice', allowedChoices: [...allowedChoices] });
        return;
      }

      clickSequence.push(choice);
      sendJson(res, 200, flowState());
      return;
    }

    if (req.method === 'POST' && url.pathname === '/api/echo') {
      let parsed;
      try {
        parsed = await readJson(req);
      } catch (error) {
        sendJson(res, 400, { ok: false, error: error.message, rawLength: error.rawLength });
        return;
      }

      const message = String(parsed.message || '').trim();
      if (!message) {
        sendJson(res, 422, { ok: false, error: 'message_required' });
        return;
      }

      sendJson(res, 200, {
        ok: true,
        received: message,
        replayToken: `bdh-${Buffer.from(message).toString('hex').slice(0, 12)}`,
        timestampShape: 'iso8601',
      });
      return;
    }

    sendJson(res, 404, { ok: false, error: 'not_found', path: url.pathname });
  } catch (error) {
    sendJson(res, 500, { ok: false, error: 'server_error', message: error.message });
  }
});

server.listen(port, host, () => {
  const address = server.address();
  console.log(JSON.stringify({ ok: true, host, port: address.port, url: `http://${host}:${address.port}/` }));
});

process.on('SIGTERM', () => server.close(() => process.exit(0)));
process.on('SIGINT', () => server.close(() => process.exit(0)));
