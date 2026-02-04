#!/usr/bin/env node
/**
 * List Sentry releases for an organization
 * Usage: list-releases.js --org <org> [--project <project>] [--limit <n>] [--env <environment>] [--commit <sha>]
 */

import { getAuthToken, getSentryApiBase, fetchJson, formatTimestamp } from "../lib/auth.js";
import { parseArgs } from "util";

const { values: args } = parseArgs({
  options: {
    org: { type: "string", short: "o" },
    project: { type: "string", short: "p" },
    limit: { type: "string", short: "l", default: "10" },
    env: { type: "string", short: "e" },
    commit: { type: "string", short: "c" },
    help: { type: "boolean", short: "h" },
  },
  allowPositionals: true,
});

if (args.help) {
  console.log(`Usage: list-releases.js --org <org> [options]

Options:
  --org, -o       Organization slug (required)
  --project, -p   Filter by project slug
  --limit, -l     Number of releases to fetch (default: 10)
  --env, -e       Filter by deploy environment (e.g., vercel-production)
  --commit, -c    Find release by commit SHA (partial match supported)
  --help, -h      Show this help

Examples:
  list-releases.js --org myorg
  list-releases.js --org myorg --project backend --limit 5
  list-releases.js --org myorg --env vercel-production
  list-releases.js --org myorg --commit 1cd97989
`);
  process.exit(0);
}

if (!args.org) {
  console.error("Error: --org is required");
  process.exit(1);
}

async function main() {
  const token = getAuthToken();
  const apiBase = getSentryApiBase();

  // Build URL with query params
  const params = new URLSearchParams();
  params.set("per_page", args.limit);
  if (args.project) {
    params.set("project", args.project);
  }

  const url = `${apiBase}/organizations/${encodeURIComponent(args.org)}/releases/?${params}`;

  let releases;
  try {
    releases = await fetchJson(url, token);
  } catch (err) {
    console.error(`Error fetching releases: ${err.message}`);
    process.exit(1);
  }

  if (!Array.isArray(releases) || releases.length === 0) {
    console.log("No releases found");
    return;
  }

  // Filter by commit if specified
  if (args.commit) {
    const commitFilter = args.commit.toLowerCase();
    releases = releases.filter(r =>
      r.version?.toLowerCase().startsWith(commitFilter) ||
      r.version?.toLowerCase().includes(commitFilter)
    );
  }

  // Filter by environment if specified
  if (args.env) {
    const envFilter = args.env.toLowerCase();
    releases = releases.filter(r =>
      r.lastDeploy?.environment?.toLowerCase() === envFilter ||
      r.lastDeploy?.environment?.toLowerCase().includes(envFilter)
    );
  }

  if (releases.length === 0) {
    console.log("No releases match the filters");
    return;
  }

  console.log(`Found ${releases.length} release(s):\n`);

  for (const release of releases) {
    const version = release.shortVersion || release.version;
    const created = formatTimestamp(release.dateCreated);
    const projects = release.projects?.map(p => p.slug).join(", ") || "N/A";
    const newGroups = release.newGroups || 0;

    console.log(`[${version}]`);
    console.log(`  created: ${created} | projects: ${projects} | new issues: ${newGroups}`);

    if (release.lastDeploy) {
      const deploy = release.lastDeploy;
      console.log(`  deploy: ${deploy.environment} @ ${formatTimestamp(deploy.dateFinished)}`);
      if (deploy.url) {
        console.log(`  url: ${deploy.url}`);
      }
    }

    if (release.firstEvent || release.lastEvent) {
      console.log(`  events: first ${formatTimestamp(release.firstEvent)} | last ${formatTimestamp(release.lastEvent)}`);
    }

    if (release.authors?.length > 0) {
      const authors = release.authors.map(a => a.name || a.email).join(", ");
      console.log(`  authors: ${authors}`);
    }

    console.log();
  }
}

main();
