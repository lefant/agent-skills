# Make development inspectable and delivery deliberate

Apply the service and release guidance only where the repository needs it.

## Support a working checkout, not just a build

Provide repeatable setup that installs pinned dependencies and validates
configuration without overwriting work or resetting shared data. Document required
external access separately. Repeated setup should be safe; a lightweight resume
step is useful only when the execution environment needs one.

For long-lived remote previews, use the environment's supported service supervisor
with status, logs, readiness, restart, and stop controls. Ordinary foreground local
development does not require a new supervisor. Give remote humans a protected,
reachable preview URL rather than a loopback address. Verify the access path and
representative application behavior, not merely that a process started.

Identify the backend and safe fixtures explicitly. A preview does not make its
mutations disposable. Never fall back silently to production or broader credentials.
Label mock/demo modes so they cannot be mistaken for integration evidence. Use
current platform documentation for service configuration instead of copied snippets.

## Enforce safety where effects happen

- Authorize at the API/action that performs the effect, not just in the UI.
- Use transactions, conditional writes, or appropriate locks for concurrency
  invariants; use idempotency when retries could duplicate effects.
- Distinguish backend failure from legitimate empty data. If fallback is intended,
  make it explicit and test it.
- Separate safe configuration from secrets. Prefer scoped, short-lived identities
  where supported and avoid broad credential fallback.
- Test revocation and recovery as well as initial access. Understand shared grant
  lifecycles before removing temporary credentials.
- Keep untrusted builds away from deployment authority. Build isolation does not
  make deployed code safe: it can still use its runtime permissions.
- Expose non-secret version, environment, and readiness information to authorized
  operators without exposing sensitive topology or credentials.

## Push coherent checkpoints continuously once authorized

Follow the destination's branch and attribution policy; do not impose a universal
feature-branch workflow. Preserve unrelated work. Make coherent, reviewable
checkpoints with relevant checks, and inspect the staged diff for unintended files
and sensitive material. Clearly label incomplete verification.

Default to pushing each coherent, checked checkpoint rather than waiting for the
end of the session. Establish authorization for continuous pushes to the agreed
remote and branch first; that authorization carries forward without asking again
for each ordinary push within scope. Push checkpoints, not every edit. If checks
fail, fix the failure or report the blocker rather than silently pushing it as
verified work.

Before an authorized push, inspect its automatic CI/deployment effects. Push only
to the agreed destination. Permission to push does not itself authorize a PR,
merge, release, manually triggered deployment, access change, shared-data reset,
or published-history rewrite. Integrate remote changes without discarding others'
work; do not treat force-push as routine error recovery.

## Keep CI evidence proportional to risk

Run cheap credential-free checks by default: locked installation, applicable
format/type/unit/build checks, and useful docs/secret checks. Avoid redundant runs
when they add no coverage. Separate credentialed or shared-state tests and restrict
their authority. Cancel obsolete read-only jobs when useful, but account for
cleanup and recovery before interrupting mutations.

For releases spanning services, verify compatible revisions together and document
schema/configuration changes, rollout order, rollback limits, and readiness checks.
Use the project's approved release path rather than assuming a particular branch
model. Treat deployment completion, process readiness, and user-visible correctness
as different checks. Verify the served revision and a representative authorized
journey. Changing stored configuration may require restarting or redeploying a
consumer; inspect the platform's behavior rather than assuming propagation.
