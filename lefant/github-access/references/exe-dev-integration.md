# exe.dev GitHub Integration

Use this integration on exe.dev VMs before personal access tokens. It keeps GitHub credentials outside the VM and injects authorization at the network edge.

Official documentation: https://exe.dev/docs/integrations-github.md

## Verify access from a VM

The integration requires `gh` and uses exe.dev's aggregate GitHub hostname:

```bash
GH_HOST=github.int.exe.xyz gh auth status --hostname github.int.exe.xyz
```

If authentication succeeds, export the host for subsequent `gh` commands:

```bash
export GH_HOST=github.int.exe.xyz
gh repo view OWNER/REPO
gh issue list --repo OWNER/REPO
gh pr list --repo OWNER/REPO
```

Do not require, inspect, print, or replace `GH_TOKEN` when this works.

## Clone and push

Use the integration hostname for Git HTTPS operations:

```bash
git clone https://github.int.exe.xyz/OWNER/REPO.git
git push https://github.int.exe.xyz/OWNER/REPO.git HEAD
```

A remote that still points to `https://github.com/...` does not use the integration. Either pass the integration URL directly to the Git command or deliberately update the remote.

## Setup

The user must first link their GitHub account and install the exe.dev GitHub App from the exe.dev Integrations page. Then create a per-repository integration and attach it to the VM:

```bash
ssh exe.dev integrations add github \
  --name REPO_INTEGRATION \
  --repository OWNER/REPO \
  --attach vm:VM_NAME
```

An existing integration can be attached later:

```bash
ssh exe.dev integrations attach REPO_INTEGRATION vm:VM_NAME
```

If setup needs account authorization or GitHub App installation, ask the user to complete it rather than requesting credentials in chat.

## Access controls and attribution

- Integrations are repository-scoped.
- Add `--readonly` for read-only Git and API access.
- By default, writes are attributed to `exe-dev-github-integration[bot]`.
- Add `--act-as-user` to attribute writes to the linked GitHub user. This is unavailable for team integrations.
- Attach integrations to one VM, `auto:all`, or a tag. Prefer the narrowest scope needed.

Examples:

```bash
ssh exe.dev integrations add github \
  --name REPO_INTEGRATION \
  --repository OWNER/REPO \
  --readonly \
  --attach vm:VM_NAME

ssh exe.dev integrations add github \
  --name REPO_INTEGRATION \
  --repository OWNER/REPO \
  --act-as-user \
  --attach vm:VM_NAME
```

## Troubleshooting

- `gh auth status` fails for `github.int.exe.xyz`: verify the integration exists and is attached to this VM.
- Repository returns not found: verify the integration targets the requested `OWNER/REPO` and the GitHub App has repository access.
- Push is denied: verify the integration is not read-only and the GitHub App or linked user has write permission.
- `gh` unexpectedly targets `github.com`: set `GH_HOST=github.int.exe.xyz` for the command or shell.
