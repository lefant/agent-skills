#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import { createRequire } from "node:module";
import { fileURLToPath, pathToFileURL } from "node:url";

const cwd = process.cwd();
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

function loadDotEnv(filePath) {
  if (!fs.existsSync(filePath)) {
    return;
  }

  const content = fs.readFileSync(filePath, "utf8");

  for (const line of content.split(/\r?\n/)) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) {
      continue;
    }

    const match = trimmed.match(/^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$/);
    if (!match) {
      continue;
    }

    const [, key, rawValue] = match;
    let value = rawValue.trim();

    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }

    value = value.replace(/\\n/g, "\n");

    if (!process.env[key]) {
      process.env[key] = value;
    }
  }
}

async function loadExaConstructor() {
  const resolverBases = [cwd, path.join(cwd, ".tools"), __dirname];

  for (const base of resolverBases) {
    try {
      const requireFromBase = createRequire(path.join(base, "__exa_resolver__.cjs"));
      const resolved = requireFromBase.resolve("exa-js");
      const module = await import(pathToFileURL(resolved).href);
      return module.Exa ?? module.default?.Exa ?? module.default ?? module;
    } catch {
      // Fall back to direct HTTP below.
    }
  }

  return null;
}

function normalizeHighlights(highlights) {
  if (Array.isArray(highlights)) {
    return highlights;
  }

  if (typeof highlights === "string" && highlights.length > 0) {
    return [highlights];
  }

  return [];
}

function usage() {
  console.error("Usage: node scripts/exa-search.mjs <query> [numResults]");
  process.exit(1);
}

async function searchWithHttp(query, numResults) {
  const response = await fetch("https://api.exa.ai/search", {
    method: "POST",
    headers: {
      "x-api-key": process.env.EXA_API_KEY,
      "content-type": "application/json",
    },
    body: JSON.stringify({
      query,
      type: "auto",
      numResults,
      contents: {
        highlights: {
          maxCharacters: 1200,
        },
      },
    }),
  });

  const text = await response.text();
  if (!response.ok) {
    throw new Error(`Exa search failed (${response.status}): ${text}`);
  }
  return JSON.parse(text);
}

async function main() {
  loadDotEnv(path.join(cwd, ".env"));

  const [queryArg, numResultsArg = "5"] = process.argv.slice(2);
  const query = queryArg?.trim();

  if (!query) {
    usage();
  }

  const numResults = Number.parseInt(numResultsArg, 10);
  if (!Number.isFinite(numResults) || numResults < 1) {
    throw new Error(`Invalid numResults: ${numResultsArg}`);
  }

  if (!process.env.EXA_API_KEY) {
    throw new Error("EXA_API_KEY is not set. Export it or rely on OpenClaw skill apiKey injection.");
  }

  const Exa = await loadExaConstructor();
  const response = Exa
    ? await new Exa().search(query, {
        type: "auto",
        numResults,
        contents: {
          highlights: {
            maxCharacters: 1200,
          },
        },
      })
    : await searchWithHttp(query, numResults);

  const results = (response.results ?? []).map((result) => ({
    title: result.title ?? null,
    url: result.url ?? null,
    publishedDate: result.publishedDate ?? null,
    highlights: normalizeHighlights(result.highlights),
  }));

  console.log(
    JSON.stringify(
      {
        query,
        count: results.length,
        results,
      },
      null,
      2,
    ),
  );
}

main().catch((error) => {
  console.error(error.message || error);
  process.exit(1);
});
