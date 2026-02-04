---
date: 2025-11-07
type: chore
related_research: thoughts/shared/research/2025-11-06_api-signature-audit.md
---

Fixed test cleanup bug where `archiveMultiplePages()` was called with incorrect 4-parameter signature instead of 3 parameters. Removed unnecessary `connectionId` parameter from all test cleanup calls.
