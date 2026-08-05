# Human-Agent Development Workflow

Riftwire treats coding agents as scoped contributors, not autonomous product owners. Humans set direction and accept risk; agents execute bounded tasks and produce verifiable evidence.

## Roles

### Human product owner

- defines player experience and priorities;
- approves scope and acceptance criteria;
- resolves product tradeoffs;
- approves licenses, dependencies, external services, and asset provenance;
- reviews and merges PRs.

### Orchestrator agent

- decomposes an approved goal into Issue-sized tasks;
- identifies dependencies and conflicting file ownership;
- assigns work to isolated branches/worktrees;
- tracks evidence and handoffs;
- does not merge or silently change product scope.

### Implementation agent

- owns one bounded task;
- inspects relevant code and documentation;
- implements the smallest coherent change;
- adds tests and PR evidence;
- hands off limitations and follow-ups.

### QA/review agent

- validates acceptance criteria independently;
- runs deterministic tests, replays, and stress fixtures;
- checks scope, architecture, and asset provenance;
- reports findings but does not self-approve the implementation.

Persistent agents may combine roles on small tasks, but implementation and final validation should be logically separated.

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

1. Human approves a goal.
2. Orchestrator drafts Issues with acceptance criteria and file ownership.
3. Human approves material architecture/product decisions.
4. Implementation agent works in an isolated branch/worktree.
5. Implementation agent runs relevant tests and opens a draft PR.
6. QA/review agent validates independently and comments with evidence.
7. Human reviews product impact and unresolved risk.
8. Human merges, requests changes, or closes the PR.
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
- follow-up Issues rather than hidden TODOs.

## Agent permission boundary

Agents may prepare code, Issues, branches, commits, PRs, review comments, and local artifacts. They may not merge, modify secrets, change repository access, publish releases, purchase assets, accept license terms, or enable network data collection without explicit human authorization.

## Failure and uncertainty

Agents must be explicit when:

- a command was not available;
- a test was skipped;
- editor behavior was inferred rather than observed;
- an asset license could not be confirmed;
- requirements conflict;
- a change exceeds the assigned scope.

The correct response to uncertainty is a reversible implementation, a documented assumption, or escalation to the human owner—not fabricated confidence.

## Handoff record

Use the handoff format in `AGENTS.md`. The next contributor should be able to continue from the Issue, PR, tests, and documentation without private chat context.
