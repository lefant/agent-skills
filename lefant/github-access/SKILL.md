---
name: github-access
description: "Access GitHub repositories programmatically using the exe.dev GitHub integration, gh CLI, or REST API. Use when interacting with GitHub repositories, issues, pull requests, workflows, discussions, or actions. On exe.dev VMs, prefer the tokenless GitHub integration before falling back to local gh authentication or GH_TOKEN."
---

# GitHub Access

## Overview

This skill enables programmatic GitHub access through the exe.dev GitHub integration, the `gh` CLI, or the REST API with `curl`. Prefer credentials held outside the VM when exe.dev provides them.

## Prerequisites and Tool Selection

Before performing GitHub operations, follow this workflow:

### 1. Prefer the exe.dev GitHub integration

On an exe.dev VM with `gh` installed, test the aggregate integration hostname:

```bash
GH_HOST=github.int.exe.xyz gh auth status --hostname github.int.exe.xyz
```

If this succeeds, use the integration for the rest of the task:

```bash
export GH_HOST=github.int.exe.xyz
gh repo view OWNER/REPO
gh issue list --repo OWNER/REPO
```

No `GH_TOKEN` is needed. The credential stays outside the VM and is injected at the network edge. Read `references/exe-dev-integration.md` for setup, repository scope, read-only mode, attribution, cloning, and pushing.

For Git operations, use the integration hostname rather than `github.com`:

```bash
git clone https://github.int.exe.xyz/OWNER/REPO.git
git push https://github.int.exe.xyz/OWNER/REPO.git HEAD
```

### 2. Fall back to ordinary GitHub authentication

Only when the exe.dev integration is unavailable:

1. If `gh` is installed and `gh auth status --hostname github.com` succeeds, use `gh` with its existing authentication.
2. Otherwise, check whether `GH_TOKEN` is non-empty without printing it:

   ```bash
   test -n "${GH_TOKEN:-}"
   ```

3. If no authentication is available, stop and ask the user to configure the exe.dev GitHub integration, run `gh auth login`, or provide `GH_TOKEN`. Never print or log token values.

### 3. Load the appropriate reference

- **exe.dev integration available**: Read `references/exe-dev-integration.md`, then use `references/gh-commands.md`.
- **Ordinary `gh` authentication available**: Read `references/gh-commands.md`.
- **Only `curl` and `GH_TOKEN` available**: Read `references/curl-api.md`.
- `references/mcp-tools.md` lists GitHub MCP tools and parameters.

## Key Operations

These are the most commonly used GitHub operations. Detailed commands for both `gh` and `curl` are provided in the reference documents.

### 1. Read Issue Content

**Use case**: Get the full details of a GitHub issue including title, body, state, labels, and metadata.

**When to use**: When the user provides an issue number or URL, or when following up on search results.

**With gh:**
```bash
gh issue view ISSUE_NUMBER --repo OWNER/REPO
gh issue view ISSUE_NUMBER --json title,body,state,labels --repo OWNER/REPO
```

**With curl:**
```bash
curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: token $GH_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/OWNER/REPO/issues/ISSUE_NUMBER
```

### 2. Read Pull Request Comments

**Use case**: Retrieve comments and reviews on a pull request. GitHub has several types of PR comments:
- **Regular comments**: General discussion comments on the PR (use `/issues/` endpoint)
- **Review summaries**: Top-level review with overall feedback (use `/reviews` endpoint)
- **Inline review comments**: Code-specific comments on file changes (use `/pulls/.../comments` endpoint)

**When to use**: When reviewing feedback on a PR, understanding discussion context, or analyzing review comments.

**With gh:**
```bash
# Get all comments and reviews
gh pr view PR_NUMBER --comments --repo OWNER/REPO

# Get as structured JSON
gh pr view PR_NUMBER --json comments,reviews --repo OWNER/REPO
```

**With curl:**
```bash
# Get all PR reviews (summary level with overall feedback)
curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: token $GH_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/OWNER/REPO/pulls/PR_NUMBER/reviews

# Get all inline review comments (code-specific comments on file changes)
curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: token $GH_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/OWNER/REPO/pulls/PR_NUMBER/comments

# Get regular PR comments (general discussion, not inline code comments)
curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: token $GH_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/OWNER/REPO/issues/PR_NUMBER/comments

# Get comments from a specific review (rarely needed - usually use /pulls/.../comments instead)
curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: token $GH_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/OWNER/REPO/pulls/PR_NUMBER/reviews/REVIEW_ID/comments
```

### 3. Check Workflow Status and Fetch Failure Logs

**Use case**: Diagnose CI/CD failures by checking workflow run status and retrieving logs from failed jobs.

**When to use**: When a PR has failing checks, when investigating build failures, or when debugging CI/CD issues.

**With gh:**
```bash
# 1. Check PR status
gh pr checks PR_NUMBER --repo OWNER/REPO

# 2. Get the most recent workflow run for the PR
RUN_ID=$(gh pr view PR_NUMBER --json headRefName --jq -r '.headRefName' | \
  xargs -I {} gh run list --branch {} --limit 1 --json databaseId --jq '.[0].databaseId' --repo OWNER/REPO)

# 3. View failed job logs
gh run view $RUN_ID --log-failed --repo OWNER/REPO
```

**With curl:**
```bash
# 1. Get PR details to find HEAD SHA
PR_DATA=$(curl -s -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: token $GH_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/OWNER/REPO/pulls/PR_NUMBER)

HEAD_SHA=$(echo "$PR_DATA" | jq -r '.head.sha')

# 2. Get check runs for that SHA
curl -s -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: token $GH_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/OWNER/REPO/commits/$HEAD_SHA/check-runs

# 3. Get failed workflow runs
RUNS=$(curl -s -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: token $GH_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/OWNER/REPO/actions/runs?head_sha=$HEAD_SHA")

FAILED_RUN_ID=$(echo "$RUNS" | jq -r '.workflow_runs[] | select(.conclusion == "failure") | .id' | head -1)

# 4. Get failed jobs
curl -s -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: token $GH_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/OWNER/REPO/actions/runs/$FAILED_RUN_ID/jobs?filter=failed"

# 5. Get logs for specific job
JOB_ID=$(curl -s -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: token $GH_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/OWNER/REPO/actions/runs/$FAILED_RUN_ID/jobs?filter=failed" | jq -r '.jobs[0].id')

curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: token $GH_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/OWNER/REPO/actions/jobs/$JOB_ID/logs
```

### 4. Search Issues

**Use case**: Find issues when the user doesn't provide a specific issue number or URL.

**When to use**: When the user mentions an issue by description, keyword, or topic rather than by number.

**With gh:**
```bash
# Search in specific repository
gh issue list --search "QUERY" --repo OWNER/REPO

# Search with filters
gh issue list --state open --label bug --repo OWNER/REPO

# Search across organization
gh search issues "QUERY" --owner OWNER
```

**With curl:**
```bash
# Search issues in repository
curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: token $GH_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/search/issues?q=QUERY+repo:OWNER/REPO+type:issue"

# Search with filters (e.g., open bugs)
curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: token $GH_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/search/issues?q=is:open+label:bug+repo:OWNER/REPO+type:issue"
```

### 5. Search Pull Requests

**Use case**: Find pull requests when the user doesn't provide a specific PR number or URL.

**When to use**: When the user references a PR by description, author, branch name, or topic rather than by number.

**With gh:**
```bash
# Search in specific repository
gh pr list --search "QUERY" --repo OWNER/REPO

# Search with filters
gh pr list --state open --author USERNAME --repo OWNER/REPO

# Search across organization
gh search prs "QUERY" --owner OWNER
```

**With curl:**
```bash
# Search PRs in repository
curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: token $GH_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/search/issues?q=QUERY+repo:OWNER/REPO+type:pr"

# Search with filters (e.g., open PRs by author)
curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: token $GH_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/search/issues?q=is:open+author:USERNAME+repo:OWNER/REPO+type:pr"
```

## Extracting Repository Information

When the user provides a GitHub URL, extract the owner and repository name:

**Example URL formats:**
- `https://github.com/owner/repo/issues/123`
- `https://github.com/owner/repo/pull/456`
- `https://github.com/owner/repo`

**Extraction with sed:**
```bash
URL="https://github.com/owner/repo/issues/123"
OWNER_REPO=$(echo "$URL" | sed -E 's|https://github.com/([^/]+/[^/]+)/.*|\1|')
OWNER=$(echo "$OWNER_REPO" | cut -d'/' -f1)
REPO=$(echo "$OWNER_REPO" | cut -d'/' -f2)
```

## Resources

This skill includes these reference documents:

### references/mcp-tools.md
Complete list of all available GitHub MCP tools and their parameters. Use this as a reference for understanding available functionality and parameter requirements.

### references/exe-dev-integration.md
Use exe.dev's GitHub integration without storing a GitHub token on the VM. Load this first on exe.dev VMs.

### references/gh-commands.md
Comprehensive `gh` CLI commands for all GitHub operations. Load this document when `gh` is available. Includes:
- Actions and workflow operations
- Issue management
- Pull request operations
- Discussions (via GraphQL)
- Common patterns and tips

**Official documentation**: https://docs.github.com/en/rest/using-the-rest-api/getting-started-with-the-rest-api?apiVersion=2022-11-28&tool=cli

### references/curl-api.md
Token-authenticated REST API calls using `curl` when neither the exe.dev integration nor authenticated `gh` is available. Includes:
- Complete REST API endpoints
- Request headers and authentication
- Response parsing with `jq`
- GraphQL queries for discussions
- Pagination and rate limiting

**Official documentation**: https://docs.github.com/en/rest/using-the-rest-api/getting-started-with-the-rest-api?apiVersion=2022-11-28&tool=curl

## Additional Operations

Beyond the key operations listed above, the reference documents provide detailed commands for:

- **Workflows**: Trigger, list, rerun, cancel, download artifacts
- **Issues**: Create, update, comment, label, assign, close
- **Pull Requests**: Create, update, merge, review, request reviewers, get diff
- **Discussions**: List, view, comment (via GraphQL)
- **Labels**: Get, create, update, delete
- **Repository operations**: Various repository-level operations

Consult the appropriate reference document (`gh-commands.md` or `curl-api.md`) for complete examples.
