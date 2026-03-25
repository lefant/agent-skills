# implement_plan

Preserve this workflow name when using this reference.

Original command source: `sources/claude-code-plugins/rpi/commands/implement_plan.md`

Environment adaptation note:
- When the text says `Read files fully`, do that with local shell tools
- When the text says `TodoWrite`, use the current environment's task tracking
- When the text says `Edit`, update the plan file directly in the current environment

---

Implement technical plans from `thoughts/shared/plans/` with verification.

You are tasked with implementing an approved technical plan from `thoughts/shared/plans/`. These plans contain phases with specific changes and success criteria.

## Getting Started

When given a plan path:
- Read the plan completely and check for any existing checkmarks (- [x])
- Read the original ticket and all files mentioned in the plan
- **Read files fully** - never use partial reads, you need complete context
- Think deeply about how the pieces fit together
- Create a todo list to track your progress
- Start implementing if you understand what needs to be done

If no plan path provided, ask for one.

## Implementation Philosophy

Plans are carefully designed, but reality can be messy. Your job is to:
- Follow the plan's intent while adapting to what you find
- Implement each phase fully before moving to the next
- Verify your work makes sense in the broader codebase context
- Update checkboxes in the plan as you complete sections

When things don't match the plan exactly, think about why and communicate clearly. The plan is your guide, but your judgment matters too.

If you encounter a mismatch:
- STOP and think deeply about why the plan can't be followed
- Present the issue clearly:
  ```
  Issue in Phase [N]:
  Expected: [what the plan says]
  Found: [actual situation]
  Why this matters: [explanation]

  How should I proceed?
  ```

## Verification Approach

After implementing a phase:
- Run the success criteria checks (usually `make check test` covers everything)
- Fix any issues before proceeding
- Update your progress in both the plan and your todos
- Check off completed items in the plan file itself
- **If the plan has manual verification items for this phase**, pause and inform the human:
  ```
  Phase [N] Complete - Ready for Manual Verification

  Automated verification passed:
  - [List automated checks that passed]

  Manual verification items from the plan:
  - [List manual verification items]

  Let me know when manual testing is complete so I can proceed to Phase [N+1].
  ```
  Do not check off manual verification items until confirmed by the user.
- **If the phase has no manual verification items**, proceed directly to the next phase after automated checks pass.

## After Each Phase

After a phase passes verification (and manual confirmation if applicable):

1. **Commit the changes**: Create a git commit with a clear message referencing the plan and phase, e.g. `"plan: <plan-name> - phase N: <brief description>"`. Commit all files changed in the phase.

2. **Update plan status**: Check off all completed automated verification items in the plan file itself. Update any status metadata in the plan frontmatter if present.

3. **Write a devlog entry** (if a devlog skill or workflow is available): After the final phase (or when pausing for manual verification on a significant milestone), write a devlog entry summarizing what was implemented, any deviations from plan, and learnings. Use `--wip` semantics if the plan is not fully complete yet.

## If You Get Stuck

When something isn't working as expected:
- First, make sure you've read and understood all the relevant code
- Consider if the codebase has evolved since the plan was written
- Present the mismatch clearly and ask for guidance

Use sub-tasks sparingly - mainly for targeted debugging or exploring unfamiliar territory.

## Resuming Work

If the plan has existing checkmarks:
- Trust that completed work is done
- Pick up from the first unchecked item
- Verify previous work only if something seems off

Remember: You're implementing a solution, not just checking boxes. Keep the end goal in mind and maintain forward momentum.
