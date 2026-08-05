# Human-Agent Development Workflow

Riftwire treats coding agents as scoped contributors, not autonomous product owners. Humans set direction and accept material risk; agents execute bounded tasks and produce verifiable evidence. The repository owner may grant task-specific or standing authorization for agents to merge ordinary scoped changes after required checks pass.

## Roles

### Human product owner

- defines player experience and priorities;
- approves scope and acceptance criteria;
- resolves material product tradeoffs;
- approves licenses, major dependencies, external services, asset provenance, destructive operations, and other high-risk changes;
- defines whether merge authority is human-only, task-specific, or granted as standing authorization for ordinary changes.

### Orchestrator agent

- decomposes an approved goal into Issue-sized tasks;
- identifies dependencies and conflicting file ownership;
- assigns work to isolated branches/worktrees;
- tracks evidence and handoffs;
- merges ordinary scoped PRs only when applicable owner authorization exists and required checks pass;
- does not silently change product scope or treat merge authorization as approval for material architecture/product decisions.

### Implementation agent

- owns one bounded task;
- inspects relevant code and documentation;
- implements the smallest coherent change;
- adds tests and PR evidence;
- hands off limitations and follow-ups;
- may perform an authorized merge only after re-checking the current PR head and required checks.

### QA/review agent

- validates acceptance criteria independently;
- runs deterministic tests, replays, and stress fixtures;
- checks scope, architecture, and asset provenance;
- reports findings and does not fabricate independent approval.

Persistent agents may combine roles on small tasks, but implementation and final validation should be logically separated and documented.

## Task contract

Every agent task should specify:

```text
Goal:
Context:
In scope:
Out of scope:
Acceptance criteria:
Owned files/subsystems:
Required validation:
Dependencies:
Human decisions required:
Merge authorization:
```

An Issue can serve as this contract. Vague instructions such as "improve combat" should be decomposed before code changes begin.

## Branch and worktree isolation

One task, one branch, one worktree:

```bash
git worktree add ../riftwire-42 -b agent/42-buffered-jump origin/main
```

Rules:

- never run multiple write-capable agents in the same worktree;
- assign one active owner per scene/resource;
- rebase or update from `main` before final validation when needed;
- do not carry unrelated local changes into an agent branch;
- delete stale worktrees only after confirming their branches and uncommitted state.

## Recommended workflow

1. Human approves a goal or standing development direction.
2. Orchestrator drafts Issues with acceptance criteria and file ownership.
3. Human approves material architecture/product decisions.
4. Implementation agent works in an isolated branch/worktree.
5. Implementation agent runs relevant tests and opens a draft PR.
6. QA/review agent or a logically separate validation pass checks acceptance criteria and evidence.
7. When evidence is complete, the PR is marked ready.
8. If applicable owner merge authorization exists, the agent verifies required checks against the current head SHA and merges with an expected-head safeguard. Otherwise the human owner merges, requests changes, or closes the PR.
9. Orchestrator updates dependent tasks and records newly discovered work.

## Parallelization policy

Good parallel boundaries:

- player controller vs. weapon resource definitions;
- pure damage model vs. UI presentation;
- room metadata validator vs. authored room art;
- documentation vs. isolated runtime component;
- test harness vs. content using an already accepted contract.

Poor parallel boundaries:

- two agents editing the same `.tscn`;
- one agent changing an interface while another implements against the old version;
- simultaneous refactors of shared autoloads;
- broad architecture and content work in the same unreviewed branch.

The orchestrator should serialize contract changes before parallel implementations begin.

## Pull request contract

Agent PRs remain drafts until their acceptance criteria and evidence are complete. The PR must include:

- linked Issue;
- what changed and why;
- player/developer impact;
- exact tests and results;
- seed/replay and visual evidence when relevant;
- changed contracts or ADRs;
- known limitations;
- rollback or disable path for risky systems;
- follow-up Issues rather than hidden TODOs;
- the merge authorization basis when the agent will merge the PR.

## Agent permission boundary

Agents may prepare code, Issues, branches, commits, PRs, review comments, local artifacts, and—when explicitly authorized—merge ordinary scoped PRs after required checks pass.

Standing merge authorization does not permit agents to modify secrets, repository access, branch protection, visibility, or billing; publish releases; purchase or accept license terms for assets; select or change the project license; add major dependencies or external services; enable network data collection; make material architecture/product decisions; or perform destructive/irreversible operations. Those actions require explicit human approval even when ordinary self-merge is authorized.

Agents must never bypass required checks, merge a different head than the one validated, or push directly to `main` as a substitute for the PR workflow.

## Failure and uncertainty

Agents must be explicit when:

- a command was not available;
- a test was skipped;
- editor behavior was inferred rather than observed;
- an asset license could not be confirmed;
- requirements conflict;
- a change exceeds the assigned scope;
- standing merge authorization does not clearly cover the risk or decision involved.

The correct response to uncertainty is a reversible implementation, a documented assumption, or escalation to the human owner—not fabricated confidence.

## Handoff record

Use the handoff format in `AGENTS.md`. The next contributor should be able to continue from the Issue, PR, tests, and documentation without private chat context.
