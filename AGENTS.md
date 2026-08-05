# AGENTS.md

This file defines the operating contract for every coding agent, subagent, automation, and human delegating work to an agent in Riftwire.

## 1. Authority order

When instructions conflict, follow this order:

1. explicit instructions from the repository owner in the current task;
2. accepted ADRs in `docs/adr/`;
3. this file;
4. `CONTRIBUTING.md` and other repository documentation;
5. local conventions in the files being changed.

Do not invent product decisions to resolve a material ambiguity. Record the uncertainty in the PR and choose the smallest reversible implementation.

## 2. Read before changing code

At minimum, read:

- `README.md`;
- `docs/VISION.md`;
- `docs/ARCHITECTURE.md`;
- `docs/TESTING.md`;
- the relevant Issue or task contract;
- nearby code and tests.

For architecture, workflow, or product changes, also read relevant ADRs.

## 3. Project invariants

These constraints require explicit human approval to change:

- Godot 4.x and GDScript-first implementation;
- side-scrolling real-time platform shooting;
- modular, ordered weapon-effect pipeline;
- authored room templates assembled through seeded run generation;
- deterministic random-number ownership;
- gameplay rules must not depend on animation completion;
- no network service or multiplayer in the first playable;
- no unlicensed or provenance-unknown assets;
- human review before merge.

## 4. Work protocol

1. Translate the task into explicit acceptance criteria.
2. Inspect the current repository state; do not assume files or APIs exist.
3. Work on one Issue-sized scope in an isolated branch/worktree.
4. Prefer additive, reversible changes over broad rewrites.
5. Add or update tests with the implementation.
6. Run the smallest relevant checks, then the broader available checks.
7. Open a draft PR and report evidence, limitations, and follow-up work.
8. Stop when the acceptance criteria are met. Do not opportunistically redesign unrelated systems.

Recommended agent branch format:

```text
agent/<issue-number>-<short-description>
```

Only one active owner should modify a scene or resource file at a time. Coordinate ownership before parallel work.

## 5. Change boundaries

Agents may, when in scope:

- create implementation branches and draft PRs;
- add scripts, scenes, resources, tests, and documentation;
- refactor code covered by relevant tests;
- create small temporary debug tools that are removed or documented before merge.

Agents must not without explicit human approval:

- merge or approve their own PR;
- push directly to `main`;
- alter repository visibility, branch protection, secrets, billing, or access;
- select or change the project license;
- add telemetry that sends data off-device;
- add paid, proprietary, generated, or third-party assets without documented provenance and license;
- add a new engine, language, native extension, or major dependency;
- perform destructive history rewrites;
- delete user-authored content merely because it appears unused.

## 6. Implementation rules

### GDScript

- Prefer typed GDScript for public APIs, state, and return values.
- Use composition and focused components instead of deep inheritance trees.
- Keep input gathering, simulation, and presentation separate.
- Do not use global singletons as a shortcut for ordinary dependencies.
- Emit domain events or call explicit interfaces; avoid fragile node-path reach-through.
- Keep tunable values in Resources or dedicated configuration objects.

### Scenes and resources

- Keep scenes focused and reusable.
- Avoid unrelated formatting churn in `.tscn` and `.tres` files.
- Never hand-edit imported/generated data inside `.godot/`.
- Do not rename or move assets casually; Godot resource paths are part of the dependency graph.
- One PR should not combine mass asset moves with gameplay changes.

### Randomness

- Never instantiate hidden ad-hoc RNGs in gameplay code.
- Obtain RNG streams from the run/session context.
- Include the seed in failure reports and replay evidence.
- A fixed seed and fixed input sequence must produce equivalent gameplay decisions.

### Real-time behavior

- Gameplay state transitions must not wait on visual animation completion.
- Use physics ticks for movement and collision-sensitive logic.
- Bound projectile counts, repeated triggers, and recursive modifier chains.
- Every repeating timer, signal subscription, and spawned object needs a defined cleanup path.

## 7. Required validation

Choose evidence appropriate to the change:

- pure logic tests for damage, modifiers, drops, and graph generation;
- integration tests for components and scene interactions;
- scripted input/replay tests for movement and combat;
- screenshots or short recordings for visible behavior;
- performance counters for projectile-heavy changes;
- fixed seeds for generation and encounter defects.

Never claim a test passed if it was not run. State exactly what was run and why anything was skipped.

## 8. Definition of done

A change is complete when:

- acceptance criteria are met;
- no unrelated files changed;
- relevant tests pass or documented blockers exist;
- debug output and temporary assets are removed;
- documentation and ADRs are updated when contracts changed;
- the PR explains player impact, implementation, evidence, risks, and follow-ups;
- another developer or agent can continue without hidden context.

## 9. Handoff format

End every agent task with:

```text
Summary:
- ...

Changed:
- path: reason

Validated:
- command/check: result

Known limitations:
- ...

Next recommended task:
- ...
```

Concise, factual handoffs are preferred over narrative logs.
