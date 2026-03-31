---
date: 2026-03-31
status: ✅ COMPLETED
related_issues: []
---

# Implementation Log - 2026-03-31

**Implementation**: Refreshed vendored skills and hardened vendor update automation

## Summary

Updated the vendored skill set with the latest upstream content, fixed broken upstream source paths in `scripts/update-vendor.sh`, made vendor refreshes resilient to per-source failures, and switched fetches to sparse shallow clones to reduce disk pressure during updates. After the refresh, applied and automated a small set of compatibility and link-fix patches needed to keep local skill naming stable for Pi and to preserve valid cross-references in vendored docs. Verified the resulting `vendor/` tree for broken relative Markdown links and confirmed the check passed with zero remaining broken links.

## Plan vs Reality

**What was planned:**
- [ ] Check the repo guidance in `README.md`
- [ ] Run the vendor upgrade script
- [ ] Review the resulting vendor changes
- [ ] Fix update issues uncovered during the refresh

**What was actually implemented:**
- [x] Read `README.md` before making changes
- [x] Ran `./scripts/update-vendor.sh` and reviewed the partial failure
- [x] Fixed the `shadcn-ui` upstream path in `scripts/update-vendor.sh`
- [x] Made the update script continue past individual vendor failures instead of aborting the full refresh
- [x] Switched vendor fetches to sparse shallow clones to reduce local disk usage during updates
- [x] Identified that the old OpenClaw Tavily source path no longer existed and updated it to a current upstream skill path
- [x] Refreshed vendored skills across the configured upstream sources
- [x] Preserved local compatibility for `vendor/dz0ny/devenv` by keeping `name: devenv`
- [x] Fixed broken vendored links in Remotion and Vercel React best practices docs
- [x] Added post-fetch fixups to the update script so those compatibility/link fixes are re-applied automatically on future refreshes
- [x] Validated relative Markdown links under `vendor/` and confirmed zero broken links remain
- [x] Wrote this devlog entry

## Challenges & Solutions

**Challenges encountered:**
- The vendor refresh initially failed because the upstream `giuseppe-trisciuoglio/developer-kit` repository had moved `shadcn-ui` from `skills/shadcn-ui` to `plugins/developer-kit-typescript/skills/shadcn-ui`.
- The update script cloned full upstream repositories, which is costly on a host with very limited free disk space.
- The previously configured OpenClaw Tavily skill path no longer existed upstream.
- Several refreshed upstream docs introduced broken relative links or upstream naming that conflicted with local Pi compatibility expectations.

**Solutions found:**
- Updated the `shadcn-ui` source path and made each fetch best-effort so one bad upstream path does not block the whole refresh.
- Reworked the script to use sparse shallow clones with blob filtering to lower temporary checkout size.
- Selected a current OpenClaw Tavily skill path that matches the local `tavily-search` skill shape and refreshed from that source instead.
- Added automated post-fetch patching for known local compatibility and documentation fixes, then verified the vendored tree with a link check.

## Learnings

- Vendored skill refreshes benefit from best-effort behavior; a single moved path should not cancel the rest of the update.
- Sparse clone plus sparse checkout is a practical improvement for vendor mirroring on small disks.
- Some upstream skills need stable local patches after refreshes, especially when the local ecosystem depends on exact skill names or stricter link validity than upstream currently guarantees.
- A lightweight relative-link audit is useful immediately after large vendor updates because it catches regressions that are easy to miss in manual review.

## Next Steps

- [ ] Consider documenting the rationale for the OpenClaw Tavily source selection in `vendor/README.md` or script comments if that upstream repo continues to churn
- [ ] Consider filtering out pure file-mode-only vendor changes if they create review noise
- [ ] Commit the vendor refresh with the script hardening and devlog entry together
