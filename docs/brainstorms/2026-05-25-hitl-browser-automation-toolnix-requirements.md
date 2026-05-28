---
date: 2026-05-25
topic: hitl-browser-automation-toolnix
---

# HITL Browser Automation Skill and Toolnix Runtime

## Summary

Add human-in-the-loop browser automation as a two-layer capability: a portable `hitl-browser-automation` skill in `agent-skills`, plus a Toolnix opt-in that installs the skill and runtime dependencies needed to run it on a test VM.

---

## Problem Frame

The existing HITL browser automation prototype proves a useful workflow: a human can interact with a browser over VNC while an agent captures browser evidence through CDP and continues with `agent-browser`. That workflow is valuable when the agent needs a human checkpoint for demonstration, verification, or credential-sensitive work.

Today, the reusable shape is split. The skill package can carry workflow guidance and bundled helper scripts, but a fresh environment still needs the right browser, VNC/display stack, and CLI dependencies before the workflow is actually usable. Conversely, Toolnix can provision those dependencies, but the product behavior and safety rules belong in the skill so agents can use the workflow outside Toolnix too.

---

## Actors

- A1. Human operator: Connects to the VNC browser, demonstrates behavior, verifies state, or handles sensitive steps.
- A2. Agent using the skill: Starts the HITL workflow, captures evidence, and continues with `agent-browser` according to the user's stated objective.
- A3. Toolnix user or project consumer: Enables the opt-in runtime support on a host or project environment.
- A4. Toolnix maintainer: Keeps the dependency/runtime layer declarative, testable, and separate from default lightweight environments.
- A5. Target environment: A manually provisioned VM or project shell where the smoke proof and real workflows run.

---

## Key Flows

- F1. Portable skill use outside Toolnix
  - **Trigger:** A user asks for browser automation that needs human demonstration, human verification, credential handoff, or VNC-observed browser state in an environment that may not use Toolnix.
  - **Actors:** A1, A2, A5
  - **Steps:** The agent invokes the skill, checks prerequisites, reports missing dependencies clearly if they are absent, starts the bundled hub when possible, coordinates the human checkpoint, captures evidence, and stops the hub when complete.
  - **Outcome:** The workflow remains understandable and operable without Toolnix, assuming system dependencies are already present.
  - **Covered by:** R1, R2, R3, R4, R8, R9

- F2. Toolnix-enabled runtime use
  - **Trigger:** A Toolnix user enables the HITL browser automation option for a host or project environment.
  - **Actors:** A2, A3, A4, A5
  - **Steps:** Toolnix installs the skill-backed command path and runtime dependencies, configures browser environment variables consistently with existing browser tooling, and leaves the workflow available from the target project context.
  - **Outcome:** A user can enter the enabled environment and run the HITL browser workflow without manually assembling browser/VNC dependencies.
  - **Covered by:** R5, R6, R7, R8, R10, R11

- F3. Smoke VM proof
  - **Trigger:** A user wants to validate the feature on a fresh or test VM.
  - **Actors:** A1, A2, A3, A5
  - **Steps:** The VM is provisioned manually, Toolnix runtime support is enabled, the smoke app is started, the human connects through VNC and clicks buttons, and the agent verifies that VNC/CDP/recorder plumbing produced usable artifacts.
  - **Outcome:** The system proves the end-to-end HITL browser topology before use against a real application.
  - **Covered by:** R6, R7, R12, R13, R14, R15

- F4. Objective-specific manual demo
  - **Trigger:** The user asks the agent to use the HITL skill with an objective such as reporting the click sequence, achieving the same final state, generating a replay script, or continuing automation.
  - **Actors:** A1, A2
  - **Steps:** The user states the objective in the prompt, performs the browser actions over VNC, and the agent inspects captured evidence to satisfy that objective where possible.
  - **Outcome:** v0 demonstrates that the captured evidence can support useful agent reasoning without turning every objective into a hard automated test gate.
  - **Covered by:** R12, R15, R16, R17

---

## Requirements

**Portable skill package**
- R1. The `hitl-browser-automation` skill must live in `agent-skills` as the primary source of workflow instructions and bundled Browser Debug Hub scripts.
- R2. The skill must remain portable outside Toolnix by bundling instructions and helper scripts rather than depending on Toolnix-specific paths or commands.
- R3. The skill must check and report missing system prerequisites clearly before attempting partial startup.
- R4. The skill must preserve the existing HITL safety model: loopback-only VNC/CDP by default, explicit forwarding for remote access, and no secrets requested in chat.
- R5. The skill must document that normal operation should run from the target project context so runtime state and artifacts are scoped to the work being automated, not to the skill package itself.

**Toolnix runtime support**
- R6. Toolnix must expose a new explicit opt-in for HITL browser automation runtime support.
- R7. Enabling the Toolnix option must install the skill and the runtime dependencies needed for the bundled workflow, including browser automation, Chromium, Node, Python, `jq`, and a VNC/display stack.
- R8. Toolnix must treat the skill package as the source of truth for Browser Debug Hub scripts, wrapping or exposing those scripts rather than owning a divergent runtime copy.
- R9. Toolnix must keep the capability opt-in and must not add the heavy browser/VNC dependency set to default environments.
- R10. Toolnix-enabled environments must align browser executable configuration with existing Toolnix browser tooling so `agent-browser` and the HITL workflow use the intended Chromium runtime.
- R11. Toolnix docs must explain the relationship between the portable skill and the Toolnix option: the skill defines the workflow; Toolnix makes it easy to satisfy the runtime dependencies.

**Smoke proof and validation**
- R12. v0 must include a smoke app with enough visible interaction to let a human click through a small flow over VNC and produce meaningful browser evidence.
- R13. Automated smoke validation must prove the core plumbing: launch, VNC/display availability, loopback CDP, recorder artifact creation, and clean teardown.
- R14. The smoke proof must support a manually provisioned test VM path; full VM provisioning automation is not required for v0.
- R15. The smoke proof must make captured artifacts available for agent inspection without requiring raw artifacts to be committed or pasted into chat.
- R16. v0 must include a documented manual demo showing how the agent can use captured evidence according to the user's objective.
- R17. Objective-specific inference must remain prompt-directed in v0: the user states whether the agent should infer sequence, reproduce the outcome, generate a script, continue automation, or do something else.

---

## Acceptance Examples

- AE1. **Covers R1, R2, R3.** Given a non-Toolnix environment with missing VNC dependencies, when an agent invokes the skill, then the skill reports the missing prerequisite clearly rather than assuming Toolnix is present.
- AE2. **Covers R4, R15.** Given a browser session captures screenshots, network evidence, profiles, or logs, when the agent summarizes or preserves evidence, then raw sensitive artifacts are treated as local/untracked and not pasted or committed by default.
- AE3. **Covers R6, R7, R9, R10.** Given a Toolnix host or project enables the HITL browser automation option, when the environment starts, then the workflow command and required browser/VNC dependencies are available without changing default Toolnix environments.
- AE4. **Covers R8, R11.** Given the Browser Debug Hub scripts evolve in the skill package, when Toolnix exposes HITL support, then Toolnix uses the skill-owned runtime rather than maintaining a separate copy with independent behavior.
- AE5. **Covers R12, R13, R14.** Given a manually provisioned test VM with the Toolnix option enabled, when the smoke proof runs, then the human can access the browser over VNC, the recorder can capture evidence through CDP, and the hub can stop cleanly.
- AE6. **Covers R16, R17.** Given the user prompts the agent to infer the clicked sequence from a smoke-app demonstration, when the human clicks buttons over VNC, then the documented manual demo shows the agent inspecting artifacts and answering that objective from evidence.
- AE7. **Covers R16, R17.** Given the user instead prompts the agent to generate a replay script or reproduce the final state, when the same HITL workflow is used, then the agent follows that stated objective rather than assuming sequence inference is always the goal.

---

## Success Criteria

- The skill is installed from `agent-skills` and can be used as a portable HITL browser automation workflow in environments that satisfy its prerequisites.
- A Toolnix user can enable one explicit option and receive the skill plus the runtime dependencies needed to run the workflow on a test VM or project shell.
- The smoke proof validates the browser/VNC/CDP/recorder lifecycle without requiring real credentials or a production application.
- The manual demo shows that captured evidence can support different prompt-directed objectives, not just one hardcoded replay shape.
- Downstream planning does not need to invent the ownership boundary between the skill and Toolnix, the safety model, or the v0 validation bar.

---

## Scope Boundaries

- Full VM provisioning automation is out of scope for v0; a documented manually provisioned test VM path is enough.
- Browser-based VNC/noVNC is out of scope for v0.
- Vendoring binary system dependencies inside the skill package is out of scope.
- Automatic objective inference is out of scope as a hard runtime test gate; objective-specific behavior remains prompt-directed and manually demonstrated.
- Moving Browser Debug Hub ownership into Toolnix is out of scope; Toolnix should expose the skill-owned runtime.
- Replacing `agent-browser` or building a broader browser automation platform is out of scope.
- Real-application validation with production credentials is out of scope for the initial smoke proof.

---

## Key Decisions

- Two-layer ownership: The skill owns workflow and bundled scripts, while Toolnix owns declarative dependency provisioning. This preserves portability while making the common Nix path easy.
- Explicit Toolnix option: HITL browser automation gets its own opt-in because the browser/VNC dependency set is heavier and more specialized than ordinary browser automation.
- Plumbing-first smoke gate: Automated tests should prove the topology is safe and functional; higher-level agent inference stays documented/manual because user objectives vary.
- Prompt-directed objectives: The user's prompt determines whether the agent reports a sequence, reproduces an outcome, generates a script, or continues automation.
- Manual VM provisioning for v0: The feature should be testable on a VM, but VM creation itself is not part of the first implementation.

---

## Dependencies / Assumptions

- Toolnix can consume the updated `agent-skills` input and expose the new skill to supported agents.
- Toolnix can package or install the required browser/VNC/display dependencies in supported Linux environments.
- The existing Browser Debug Hub scripts are suitable as the initial skill-owned runtime after minor portability and documentation adjustments.
- The smoke app does not need to model real application authentication or production workflows.
- Some runtime tests may be skipped or reported as unavailable when the host lacks browser/VNC capabilities; that is acceptable outside the Toolnix-enabled proof path.

---

## Outstanding Questions

### Deferred to Planning

- [Affects R6, R7][Technical] What exact Toolnix option name and module shape should be used for the HITL runtime support?
- [Affects R7][Technical] Which VNC/display stack should Toolnix install by default for the supported VM environments?
- [Affects R8][Technical] What is the cleanest way for Toolnix to expose the skill-owned `hitl-browser-hub` command without duplicating runtime scripts?
- [Affects R12, R16][Technical] How should the smoke app be shaped so button interactions produce evidence that is useful for multiple prompt-directed objectives?
- [Affects R13][Technical] Which smoke checks should run as automated tests versus documented manual validation on a VM?
