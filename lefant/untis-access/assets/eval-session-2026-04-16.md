# Sanitized eval notes

Date: 2026-04-16

This artifact records useful eval findings without storing real tenant data, account identifiers, message contents, student names, teacher names, or timetable details.

## Eval prompts used

1. Check a WebUntis tenant and show the latest inbox message.
2. Print the dependent student's timetable for a given week.
3. Compare local WebUntis repos and identify the best basis for inbox messages.
4. Describe the credential file format expected by the skill.

## Findings

- The skill produced usable answers for all four prompts in a fresh temporary workdir.
- The main friction point was incomplete local config: the scripts require `WEBUNTIS_HOST` and `WEBUNTIS_SCHOOL` in addition to username and password.
- After adding a config-completeness hint and ensuring those values exist locally, the message and timetable prompts should run more directly.
- Repo-comparison prompts depend on the referenced local repos actually existing at the expected paths.

## Non-sensitive conclusions worth preserving

- Direct HTTP proofs are the most reliable basis for this skill.
- Guardian timetable access should resolve dependents first, then query timetable entries for the selected student.
- Fresh login plus fresh JWT mint per run is the safe default.
- The skill should keep placeholders in repo-tracked docs and rely on local setup notes for tenant-specific values.
