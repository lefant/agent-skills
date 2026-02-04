import { readFileSync, existsSync } from "fs";
import { homedir } from "os";
import { join } from "path";

// Cache for project slug -> ID resolution
const projectIdCache = new Map();

// Cached API base URL
let cachedApiBase = null;

/**
 * Parse the region URL from a Sentry token.
 * New-style tokens (sntrys_...) contain a base64-encoded JSON payload with region_url.
 * @param {string} token - The auth token
 * @returns {string|null} The API base URL or null if not found
 */
function getApiBaseFromToken(token) {
  // New-style Sentry tokens: sntrys_<base64-payload>_<signature>
  if (token.startsWith("sntrys_")) {
    try {
      const parts = token.split("_");
      if (parts.length >= 2) {
        const payload = Buffer.from(parts[1], "base64").toString("utf-8");
        const data = JSON.parse(payload);
        if (data.region_url) {
          return `${data.region_url}/api/0`;
        }
      }
    } catch {
      // Fall through
    }
  }
  return null;
}

/**
 * Get the Sentry URL from environment or config file.
 * Checks: SENTRY_URL env var, url= in ~/.sentryclirc
 * @returns {string|null} The Sentry URL or null if not found
 */
function getSentryUrlFromConfig() {
  // Check environment variable
  if (process.env.SENTRY_URL) {
    return process.env.SENTRY_URL;
  }

  // Check ~/.sentryclirc for url setting
  const rcPath = join(homedir(), ".sentryclirc");
  if (existsSync(rcPath)) {
    const content = readFileSync(rcPath, "utf-8");
    const match = content.match(/url\s*=\s*(.+)/);
    if (match) {
      return match[1].trim();
    }
  }

  return null;
}

/**
 * Get the Sentry API base URL.
 * Priority: SENTRY_URL env var > url in sentryclirc > token-embedded region > default
 * @returns {string} The API base URL
 */
export function getSentryApiBase() {
  if (cachedApiBase) return cachedApiBase;

  // 1. Check explicit URL config
  const configUrl = getSentryUrlFromConfig();
  if (configUrl) {
    // Ensure it ends with /api/0
    cachedApiBase = configUrl.replace(/\/$/, "") + "/api/0";
    return cachedApiBase;
  }

  // 2. Try to extract from token
  const token = getAuthToken();
  const tokenUrl = getApiBaseFromToken(token);
  if (tokenUrl) {
    cachedApiBase = tokenUrl;
    return cachedApiBase;
  }

  // 3. Default to US region
  cachedApiBase = "https://sentry.io/api/0";
  return cachedApiBase;
}

/**
 * Get auth token from SENTRY_AUTH_TOKEN env var or ~/.sentryclirc
 * @returns {string} The auth token
 */
export function getAuthToken() {
  // Check environment variable first
  if (process.env.SENTRY_AUTH_TOKEN) {
    return process.env.SENTRY_AUTH_TOKEN;
  }

  const rcPath = join(homedir(), ".sentryclirc");
  if (!existsSync(rcPath)) {
    console.error("Error: SENTRY_AUTH_TOKEN not set and ~/.sentryclirc not found");
    console.error("Either set SENTRY_AUTH_TOKEN or run 'sentry-cli login'");
    process.exit(1);
  }

  const content = readFileSync(rcPath, "utf-8");
  const match = content.match(/token\s*=\s*(.+)/);
  if (!match) {
    console.error("Error: No token found in ~/.sentryclirc");
    process.exit(1);
  }
  return match[1].trim();
}

/**
 * Fetch JSON from a Sentry API endpoint
 * @param {string} url - The full URL to fetch
 * @param {string} token - The auth token
 * @returns {Promise<any>} The parsed JSON response
 */
export async function fetchJson(url, token) {
  const res = await fetch(url, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`API error ${res.status}: ${text}`);
  }

  return res.json();
}

/**
 * Format a timestamp for display
 * @param {string|number} ts - Timestamp (ISO string or unix)
 * @returns {string} Formatted timestamp
 */
export function formatTimestamp(ts) {
  if (!ts) return "N/A";
  try {
    const date = new Date(ts);
    if (isNaN(date.getTime())) return ts;
    return date.toLocaleString();
  } catch {
    return ts;
  }
}

/**
 * Resolve a project slug to its numeric ID.
 * If the input is already a numeric ID, returns it as-is.
 * @param {string} org - Organization slug
 * @param {string} project - Project slug or numeric ID
 * @param {string} token - Auth token
 * @returns {Promise<string>} The numeric project ID
 */
export async function resolveProjectId(org, project, token) {
  // If already numeric, return as-is
  if (/^\d+$/.test(project)) {
    return project;
  }

  // Check cache
  const cacheKey = `${org}/${project}`;
  if (projectIdCache.has(cacheKey)) {
    return projectIdCache.get(cacheKey);
  }

  // Fetch project details to get the ID
  const url = `${getSentryApiBase()}/projects/${encodeURIComponent(org)}/${encodeURIComponent(project)}/`;
  const data = await fetchJson(url, token);

  if (!data || !data.id) {
    throw new Error(`Project '${project}' not found in organization '${org}'`);
  }

  const id = String(data.id);
  projectIdCache.set(cacheKey, id);
  return id;
}
