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
  const errors = [];

  for (const base of resolverBases) {
    try {
      const requireFromBase = createRequire(path.join(base, "__exa_resolver__.cjs"));
      const resolved = requireFromBase.resolve("exa-js");
      const module = await import(pathToFileURL(resolved).href);
      return module.Exa ?? module.default?.Exa ?? module.default ?? module;
    } catch (error) {
      errors.push(`${base}: ${error.message}`);
    }
  }

  throw new Error(
    [
      "Could not resolve the exa-js package.",
      "Install it in the target workspace (for example: npm install exa-js),",
      "or make it available under .tools/node_modules.",
      "Resolution errors:",
      ...errors.map((error) => `- ${error}`),
    ].join("\n"),
  );
}

function usage() {
  console.error("Usage: node scripts/exa-contents.mjs <url> [highlights|text] [maxCharacters]");
  process.exit(1);
}

async function main() {
  loadDotEnv(path.join(cwd, ".env"));

  const [urlArg, modeArg = "highlights", maxCharactersArg = "2000"] = process.argv.slice(2);
  const url = urlArg?.trim();
  const mode = modeArg.trim().toLowerCase();
  const maxCharacters = Number.parseInt(maxCharactersArg, 10);

  if (!url) {
    usage();
  }

  if (!["highlights", "text"].includes(mode)) {
    throw new Error(`Invalid mode: ${modeArg}`);
  }

  if (!Number.isFinite(maxCharacters) || maxCharacters < 1) {
    throw new Error(`Invalid maxCharacters: ${maxCharactersArg}`);
  }

  if (!process.env.EXA_API_KEY) {
    throw new Error("EXA_API_KEY is not set. Export it or put it in the workspace .env file.");
  }

  const Exa = await loadExaConstructor();
  const exa = new Exa();

  const options =
    mode === "text"
      ? { text: { maxCharacters } }
      : { highlights: { maxCharacters } };

  const response = await exa.getContents([url], options);
  const result = response.results?.[0] ?? null;

  console.log(
    JSON.stringify(
      {
        url,
        mode,
        result: result
          ? {
              title: result.title ?? null,
              url: result.url ?? url,
              publishedDate: result.publishedDate ?? null,
              author: result.author ?? null,
              highlights: Array.isArray(result.highlights)
                ? result.highlights
                : result.highlights
                  ? [result.highlights]
                  : [],
              text: result.text ?? null,
            }
          : null,
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
