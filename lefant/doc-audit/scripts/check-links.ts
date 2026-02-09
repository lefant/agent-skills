#!/usr/bin/env npx ts-node
/**
 * Check markdown files for broken internal links and references.
 *
 * Usage:
 *   npx ts-node check-links.ts [PATH]      # Check path (default: current dir)
 *   npx ts-node check-links.ts --json      # Output as JSON
 *   npx ts-node check-links.ts --fix       # Suggest fixes for broken links
 *
 * Or compile and run:
 *   tsc check-links.ts && node check-links.js [PATH]
 */

import * as fs from "fs";
import * as path from "path";

interface Issue {
  file: string;
  line: number;
  severity: "critical" | "warning" | "info";
  category: string;
  message: string;
  suggestion?: string;
}

function slugify(text: string): string {
  return text
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, "")
    .replace(/[-\s]+/g, "-");
}

function extractHeadings(content: string): Set<string> {
  const headings = new Set<string>();
  const regex = /^#{1,6}\s+(.+?)(?:\s*\{#([^}]+)\})?$/gm;
  let match;

  while ((match = regex.exec(content)) !== null) {
    const [, text, explicitId] = match;
    if (explicitId) {
      headings.add(explicitId);
    } else {
      headings.add(slugify(text));
    }
  }

  return headings;
}

function extractLinks(
  content: string
): Array<{ line: number; text: string; target: string }> {
  const links: Array<{ line: number; text: string; target: string }> = [];
  const lines = content.split("\n");
  let inCodeBlock = false;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    // Track code blocks
    if (line.trim().startsWith("```")) {
      inCodeBlock = !inCodeBlock;
      continue;
    }
    if (inCodeBlock) continue;

    // Remove inline code
    const lineNoCode = line.replace(/`[^`]+`/g, "");

    // Markdown links: [text](url)
    const linkRegex = /\[([^\]]*)\]\(([^)]+)\)/g;
    let match;
    while ((match = linkRegex.exec(lineNoCode)) !== null) {
      links.push({ line: i + 1, text: match[1], target: match[2] });
    }

    // Reference-style links: [text][ref]
    const refRegex = /\[([^\]]+)\]\[([^\]]*)\]/g;
    while ((match = refRegex.exec(lineNoCode)) !== null) {
      links.push({
        line: i + 1,
        text: match[1],
        target: `ref:${match[2] || match[1]}`,
      });
    }
  }

  return links;
}

function extractImages(
  content: string
): Array<{ line: number; path: string }> {
  const images: Array<{ line: number; path: string }> = [];
  const lines = content.split("\n");
  let inCodeBlock = false;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    if (line.trim().startsWith("```")) {
      inCodeBlock = !inCodeBlock;
      continue;
    }
    if (inCodeBlock) continue;

    const lineNoCode = line.replace(/`[^`]+`/g, "");
    const imgRegex = /!\[[^\]]*\]\(([^)]+)\)/g;
    let match;

    while ((match = imgRegex.exec(lineNoCode)) !== null) {
      images.push({ line: i + 1, path: match[1] });
    }
  }

  return images;
}

function findMarkdownFiles(dir: string): string[] {
  const files: string[] = [];

  function walk(currentDir: string) {
    const entries = fs.readdirSync(currentDir, { withFileTypes: true });

    for (const entry of entries) {
      const fullPath = path.join(currentDir, entry.name);

      // Skip common non-doc directories
      if (entry.isDirectory()) {
        if (
          ["node_modules", ".git", "dist", "build", ".next", "coverage"].includes(
            entry.name
          )
        ) {
          continue;
        }
        walk(fullPath);
      } else if (entry.isFile() && /\.(md|mdx)$/i.test(entry.name)) {
        files.push(fullPath);
      }
    }
  }

  walk(dir);
  return files;
}

function findSimilarFiles(
  target: string,
  searchDir: string,
  maxResults = 3
): string[] {
  const targetName = path.basename(target).toLowerCase();
  const candidates: Array<{ score: number; path: string }> = [];

  try {
    const allFiles = findMarkdownFiles(searchDir);

    for (const f of allFiles) {
      const name = path.basename(f).toLowerCase();
      let score = 0;

      if (targetName.includes(name) || name.includes(targetName)) {
        score += 2;
      }
      if (path.extname(f) === path.extname(target)) {
        score += 1;
      }

      if (score > 0) {
        candidates.push({ score, path: path.relative(searchDir, f) });
      }
    }
  } catch {
    // Ignore errors during suggestion search
  }

  candidates.sort((a, b) => b.score - a.score);
  return candidates.slice(0, maxResults).map((c) => c.path);
}

function checkFile(filePath: string, root: string): Issue[] {
  const issues: Issue[] = [];
  let content: string;

  try {
    content = fs.readFileSync(filePath, "utf-8");
  } catch (e) {
    return [
      {
        file: path.relative(root, filePath),
        line: 0,
        severity: "critical",
        category: "read-error",
        message: `Cannot read file: ${e}`,
      },
    ];
  }

  const fileDir = path.dirname(filePath);
  const headings = extractHeadings(content);

  // Check links
  for (const { line, text, target } of extractLinks(content)) {
    // Skip reference-style links
    if (target.startsWith("ref:")) continue;

    // Skip external links
    if (/^(https?|mailto|ftp):\/\//i.test(target)) continue;

    // Split path and anchor
    const hashIndex = target.indexOf("#");
    const pathPart =
      hashIndex >= 0 ? decodeURIComponent(target.slice(0, hashIndex)) : decodeURIComponent(target);
    const anchor = hashIndex >= 0 ? target.slice(hashIndex + 1) : "";

    if (pathPart) {
      const targetPath = path.resolve(fileDir, pathPart);
      const relTarget = path.relative(root, targetPath);

      if (!fs.existsSync(targetPath)) {
        const similar = findSimilarFiles(pathPart, root);
        issues.push({
          file: path.relative(root, filePath),
          line,
          severity: "critical",
          category: "broken-link",
          message: `Link target not found: ${pathPart}`,
          suggestion: similar.length
            ? `Did you mean: ${similar.join(", ")}`
            : undefined,
        });
      } else if (anchor) {
        // Check anchor in target file
        try {
          const targetContent = fs.readFileSync(targetPath, "utf-8");
          const targetHeadings = extractHeadings(targetContent);

          if (!targetHeadings.has(anchor)) {
            const available = Array.from(targetHeadings).slice(0, 5).join(", ");
            issues.push({
              file: path.relative(root, filePath),
              line,
              severity: "warning",
              category: "missing-anchor",
              message: `Anchor #${anchor} not found in ${pathPart}`,
              suggestion: targetHeadings.size
                ? `Available anchors: ${available}`
                : undefined,
            });
          }
        } catch {
          // Ignore read errors for anchor check
        }
      }
    } else if (anchor) {
      // Same-file anchor
      if (!headings.has(anchor)) {
        const available = Array.from(headings).slice(0, 5).join(", ");
        issues.push({
          file: path.relative(root, filePath),
          line,
          severity: "warning",
          category: "missing-anchor",
          message: `Anchor #${anchor} not found in this file`,
          suggestion: headings.size ? `Available anchors: ${available}` : undefined,
        });
      }
    }
  }

  // Check images
  for (const { line, path: imgPath } of extractImages(content)) {
    if (/^(https?|data):/i.test(imgPath)) continue;

    const targetPath = path.resolve(fileDir, decodeURIComponent(imgPath));

    if (!fs.existsSync(targetPath)) {
      issues.push({
        file: path.relative(root, filePath),
        line,
        severity: "critical",
        category: "missing-image",
        message: `Image not found: ${imgPath}`,
      });
    }
  }

  return issues;
}

function main() {
  const args = process.argv.slice(2);
  const jsonOutput = args.includes("--json");
  const showFix = args.includes("--fix");
  const targetPath = args.find((a) => !a.startsWith("--")) || ".";

  const root = path.resolve(targetPath);

  if (!fs.existsSync(root)) {
    console.error(`Error: Path not found: ${root}`);
    process.exit(1);
  }

  // Find markdown files
  let mdFiles: string[];
  if (fs.statSync(root).isFile()) {
    mdFiles = [root];
  } else {
    mdFiles = findMarkdownFiles(root);
  }

  // Check all files
  const allIssues: Issue[] = [];
  for (const f of mdFiles) {
    const issues = checkFile(f, fs.statSync(root).isFile() ? path.dirname(root) : root);
    allIssues.push(...issues);
  }

  // Output
  if (jsonOutput) {
    console.log(JSON.stringify(allIssues, null, 2));
  } else {
    if (allIssues.length === 0) {
      console.log(`No issues found in ${mdFiles.length} files.`);
      process.exit(0);
    }

    const critical = allIssues.filter((i) => i.severity === "critical");
    const warnings = allIssues.filter((i) => i.severity === "warning");
    const info = allIssues.filter((i) => i.severity === "info");

    console.log(`Found ${allIssues.length} issues in ${mdFiles.length} files\n`);

    const groups: Array<[string, Issue[]]> = [
      ["CRITICAL", critical],
      ["WARNING", warnings],
      ["INFO", info],
    ];

    for (const [label, issues] of groups) {
      if (issues.length === 0) continue;

      console.log(`## ${label} (${issues.length})\n`);

      for (const i of issues) {
        console.log(`  ${i.file}:${i.line} [${i.category}]`);
        console.log(`    ${i.message}`);
        if (showFix && i.suggestion) {
          console.log(`    -> ${i.suggestion}`);
        }
        console.log();
      }
    }
  }

  process.exit(allIssues.length > 0 ? 1 : 0);
}

main();
