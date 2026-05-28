#!/usr/bin/env node
import fs from 'node:fs/promises';
import path from 'node:path';
import net from 'node:net';
import crypto from 'node:crypto';

class MinimalWebSocket {
  constructor(url) {
    this.url = new URL(url);
    this.listeners = { open: [], message: [], error: [], close: [] };
    this.buffer = Buffer.alloc(0);
    this.socket = net.createConnection({ host: this.url.hostname, port: Number(this.url.port || 80) }, () => this.handshake());
    this.socket.on('data', (chunk) => this.onData(chunk));
    this.socket.on('error', (error) => this.emit('error', error));
    this.socket.on('close', () => this.emit('close', {}));
  }

  addEventListener(type, fn, options = {}) {
    const wrapped = options.once ? (event) => { this.listeners[type] = this.listeners[type].filter((item) => item !== wrapped); fn(event); } : fn;
    this.listeners[type].push(wrapped);
  }

  emit(type, event) {
    for (const fn of this.listeners[type] || []) fn(event);
  }

  handshake() {
    const key = crypto.randomBytes(16).toString('base64');
    const pathWithQuery = `${this.url.pathname || '/'}${this.url.search || ''}`;
    this.socket.write([
      `GET ${pathWithQuery} HTTP/1.1`,
      `Host: ${this.url.host}`,
      'Upgrade: websocket',
      'Connection: Upgrade',
      `Sec-WebSocket-Key: ${key}`,
      'Sec-WebSocket-Version: 13',
      '\r\n'
    ].join('\r\n'));
  }

  onData(chunk) {
    this.buffer = Buffer.concat([this.buffer, chunk]);
    const headerEnd = this.buffer.indexOf('\r\n\r\n');
    if (headerEnd !== -1 && !this.opened) {
      const header = this.buffer.subarray(0, headerEnd).toString('utf8');
      if (!header.includes('101')) {
        this.emit('error', new Error(`WebSocket handshake failed: ${header.split('\r\n')[0]}`));
        return;
      }
      this.opened = true;
      this.buffer = this.buffer.subarray(headerEnd + 4);
      this.emit('open', {});
    }
    if (!this.opened) return;
    this.readFrames();
  }

  readFrames() {
    while (this.buffer.length >= 2) {
      const first = this.buffer[0];
      const second = this.buffer[1];
      const opcode = first & 0x0f;
      let length = second & 0x7f;
      let offset = 2;
      if (length === 126) {
        if (this.buffer.length < offset + 2) return;
        length = this.buffer.readUInt16BE(offset);
        offset += 2;
      } else if (length === 127) {
        if (this.buffer.length < offset + 8) return;
        const high = this.buffer.readUInt32BE(offset);
        const low = this.buffer.readUInt32BE(offset + 4);
        length = high * 2 ** 32 + low;
        offset += 8;
      }
      if (this.buffer.length < offset + length) return;
      const payload = this.buffer.subarray(offset, offset + length);
      this.buffer = this.buffer.subarray(offset + length);
      if (opcode === 1) this.emit('message', { data: payload.toString('utf8') });
      if (opcode === 8) this.close();
    }
  }

  send(data) {
    const payload = Buffer.from(data);
    let header;
    if (payload.length < 126) {
      header = Buffer.alloc(2);
      header[1] = 0x80 | payload.length;
    } else if (payload.length < 65536) {
      header = Buffer.alloc(4);
      header[1] = 0x80 | 126;
      header.writeUInt16BE(payload.length, 2);
    } else {
      header = Buffer.alloc(10);
      header[1] = 0x80 | 127;
      header.writeUInt32BE(0, 2);
      header.writeUInt32BE(payload.length, 6);
    }
    header[0] = 0x81;
    const mask = crypto.randomBytes(4);
    const masked = Buffer.alloc(payload.length);
    for (let i = 0; i < payload.length; i++) masked[i] = payload[i] ^ mask[i % 4];
    this.socket.write(Buffer.concat([header, mask, masked]));
  }

  close() {
    this.socket.end();
  }
}

const WebSocketImpl = globalThis.WebSocket || MinimalWebSocket;

function parseArgs(argv) {
  const args = new Map();
  for (let i = 2; i < argv.length; i++) {
    const key = argv[i];
    if (!key.startsWith('--')) continue;
    const next = argv[i + 1];
    if (!next || next.startsWith('--')) args.set(key, 'true');
    else {
      args.set(key, next);
      i++;
    }
  }
  return args;
}

const args = parseArgs(process.argv);
const cdpUrl = args.get('--cdp-url') || process.env.BDH_CDP_URL || 'http://127.0.0.1:9222';
const outDir = args.get('--out-dir') || process.env.BDH_TRACE_DIR;
const sessionId = args.get('--session-id') || process.env.BDH_SESSION_ID || new Date().toISOString().replace(/[:.]/g, '-');
const targetHint = args.get('--target-url') || '';
const reloadOnStart = args.get('--reload-on-start') === 'true';

if (!outDir) {
  console.error('missing --out-dir');
  process.exit(2);
}

await fs.mkdir(outDir, { recursive: true });
await fs.mkdir(path.join(outDir, 'screenshots'), { recursive: true });

const requests = new Map();
const events = [];
const omissions = [];
const screenshots = [];
let ws;
let nextId = 1;
const pending = new Map();

async function fetchJson(url) {
  const response = await fetch(url);
  if (!response.ok) throw new Error(`${url} -> ${response.status}`);
  return response.json();
}

async function resolveWebSocketUrl() {
  const version = await fetchJson(`${cdpUrl.replace(/\/$/, '')}/json/version`);
  if (version.webSocketDebuggerUrl) return version.webSocketDebuggerUrl;
  throw new Error('CDP /json/version did not include webSocketDebuggerUrl');
}

function send(method, params = {}, session = undefined) {
  const id = nextId++;
  const payload = { id, method, params };
  if (session) payload.sessionId = session;
  ws.send(JSON.stringify(payload));
  return new Promise((resolve, reject) => {
    pending.set(id, { resolve, reject });
    setTimeout(() => {
      if (pending.has(id)) {
        pending.delete(id);
        reject(new Error(`CDP timeout for ${method}`));
      }
    }, 10000).unref?.();
  });
}

function recordEvent(method, params) {
  events.push({ ts: new Date().toISOString(), method, params });
}

async function chooseTarget() {
  const targets = await send('Target.getTargets');
  const pages = targets.targetInfos.filter((target) => target.type === 'page');
  if (targetHint) {
    const hinted = pages.find((target) => target.url.includes(targetHint));
    if (hinted) return hinted;
  }
  const nonBlank = [...pages].reverse().find((target) => target.url && target.url !== 'about:blank');
  return nonBlank || pages[pages.length - 1];
}

async function takeScreenshot(session, label) {
  try {
    const result = await send('Page.captureScreenshot', { format: 'png', captureBeyondViewport: true }, session);
    const file = path.join(outDir, 'screenshots', `${Date.now()}-${label}.png`);
    await fs.writeFile(file, Buffer.from(result.data, 'base64'));
    screenshots.push({ label, path: path.relative(outDir, file), ts: new Date().toISOString() });
  } catch (error) {
    omissions.push({ kind: 'screenshot', label, reason: error.message, ts: new Date().toISOString() });
  }
}

function sanitizeHeaders(headers = {}) {
  const redacted = {};
  for (const [key, value] of Object.entries(headers)) {
    if (/authorization|authentication|cookie|csrf|xsrf|token|secret|session|api[-_]?key|request[-_]?key|(^|[-_])key($|[-_])/i.test(key)) redacted[key] = '[REDACTED]';
    else redacted[key] = value;
  }
  return redacted;
}

async function readCheckpointLabel() {
  const labelPath = path.join(outDir, 'checkpoint-label.txt');
  try {
    const label = (await fs.readFile(labelPath, 'utf8')).trim();
    await fs.unlink(labelPath).catch(() => {});
    return label.replace(/[^a-zA-Z0-9_.-]+/g, '-').replace(/^-+|-+$/g, '') || 'checkpoint';
  } catch {
    return 'checkpoint';
  }
}

async function writeArtifacts(final = false) {
  const entries = [...requests.values()].map((request) => ({
    startedDateTime: request.startedDateTime,
    request: {
      method: request.method,
      url: request.url,
      headers: sanitizeHeaders(request.requestHeaders || {}),
      postData: request.postData,
    },
    response: request.response ? {
      status: request.response.status,
      statusText: request.response.statusText,
      headers: sanitizeHeaders(request.response.headers || {}),
      mimeType: request.response.mimeType,
      body: request.responseBody,
      bodyOmissionReason: request.responseBodyOmissionReason,
    } : undefined,
    timings: request.timings || {},
  }));

  const har = {
    log: {
      version: '1.2-ish',
      creator: { name: 'browser-debug-hub-cdp-recorder', version: '0.1.0' },
      pages: [],
      entries,
    },
  };

  const metadata = {
    sessionId,
    cdpUrl,
    targetHint,
    final,
    updatedAt: new Date().toISOString(),
    requestCount: entries.length,
    screenshotCount: screenshots.length,
    omissions,
    screenshots,
  };

  await fs.writeFile(path.join(outDir, 'network.har.json'), JSON.stringify(har, null, 2));
  await fs.writeFile(path.join(outDir, 'events.jsonl'), events.map((event) => JSON.stringify(event)).join('\n') + (events.length ? '\n' : ''));
  await fs.writeFile(path.join(outDir, 'metadata.json'), JSON.stringify(metadata, null, 2));
  await fs.writeFile(path.join(outDir, 'summary.md'), `# Browser Debug Hub Trace\n\n- Session: ${sessionId}\n- Requests: ${entries.length}\n- Screenshots: ${screenshots.length}\n- Omissions: ${omissions.length}\n\nRaw artifacts may contain sensitive data. Review and redact before committing or sharing.\n`);
}

const browserWs = await resolveWebSocketUrl();
ws = new WebSocketImpl(browserWs);

await new Promise((resolve, reject) => {
  ws.addEventListener('open', resolve, { once: true });
  ws.addEventListener('error', reject, { once: true });
});

ws.addEventListener('message', async (message) => {
  const data = JSON.parse(message.data.toString());
  if (data.id && pending.has(data.id)) {
    const { resolve, reject } = pending.get(data.id);
    pending.delete(data.id);
    if (data.error) reject(new Error(data.error.message || JSON.stringify(data.error)));
    else resolve(data.result || {});
    return;
  }

  if (!data.method) return;
  recordEvent(data.method, data.params || {});

  const params = data.params || {};
  if (data.method === 'Network.requestWillBeSent') {
    requests.set(params.requestId, {
      id: params.requestId,
      startedDateTime: new Date((params.wallTime || Date.now() / 1000) * 1000).toISOString(),
      method: params.request?.method,
      url: params.request?.url,
      requestHeaders: params.request?.headers || {},
      postData: params.request?.postData,
    });
  }

  if (data.method === 'Network.responseReceived') {
    const req = requests.get(params.requestId) || { id: params.requestId };
    req.response = params.response;
    requests.set(params.requestId, req);
  }
});

const target = await chooseTarget();
if (!target) throw new Error('No page target available for recording');
const attached = await send('Target.attachToTarget', { targetId: target.targetId, flatten: true });
const session = attached.sessionId;
await send('Network.enable', {}, session);
await send('Page.enable', {}, session);
if (reloadOnStart) {
  await send('Page.reload', { ignoreCache: true }, session);
  await new Promise((resolve) => setTimeout(resolve, 750));
}
await takeScreenshot(session, 'start');
await writeArtifacts(false);
console.log(JSON.stringify({ ok: true, sessionId, targetId: target.targetId, targetUrl: target.url, outDir }));

let checkpointRunning = false;
let shutdownRunning = false;

async function hydrateResponseBodies() {
  for (const [requestId, req] of requests.entries()) {
    if (!req.response || req.responseBody || req.responseBodyOmissionReason) continue;
    try {
      const body = await send('Network.getResponseBody', { requestId }, session);
      req.responseBody = body.base64Encoded ? { base64Encoded: true, body: body.body } : body.body;
    } catch (error) {
      req.responseBodyOmissionReason = error.message;
      omissions.push({ kind: 'responseBody', requestId, url: req.url, reason: error.message, ts: new Date().toISOString() });
    }
  }
}

async function checkpoint() {
  if (checkpointRunning || shutdownRunning) return;
  checkpointRunning = true;
  try {
    await takeScreenshot(session, await readCheckpointLabel());
    await hydrateResponseBodies();
    await writeArtifacts(false);
  } finally {
    checkpointRunning = false;
  }
}

async function finish() {
  if (shutdownRunning) return;
  shutdownRunning = true;
  try {
    await takeScreenshot(session, 'stop');
    await hydrateResponseBodies();
    await writeArtifacts(true);
  } finally {
    try { ws.close(); } catch {}
  }
}

process.on('SIGUSR2', () => {
  checkpoint().catch((error) => console.error(error));
});
process.on('SIGTERM', () => {
  finish().then(() => process.exit(0)).catch((error) => { console.error(error); process.exit(1); });
});
process.on('SIGINT', () => {
  finish().then(() => process.exit(0)).catch((error) => { console.error(error); process.exit(1); });
});

setInterval(() => writeArtifacts(false).catch((error) => console.error(error.message)), 5000).unref();
