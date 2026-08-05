# ADR-0001: Project Foundation

- Status: Accepted
- Date: 2026-08-05
- Decision owners: repository owner

## Context

Riftwire is starting as a side-scrolling action roguelite developed with substantial assistance from coding agents. Real-time platform combat creates risks that are less visible in ordinary application development: movement feel, physics timing, projectile growth, scene merge conflicts, visual readability, and non-deterministic defects.

A foundation is needed before gameplay implementation so human and agent contributors share the same product and engineering constraints.

## Decision

Riftwire will initially use:

1. Godot 4.x with a minor version pinned before meaningful scene production;
2. GDScript as the default language;
3. component-oriented scenes and Resources rather than deep inheritance;
4. a layered input, simulation, presentation, and tooling model;
5. an ordered modular weapon pipeline as the core product differentiator;
6. authored room templates assembled through seeded run graphs;
7. local deterministic replay and telemetry support;
8. isolated branches/worktrees and draft PRs for all non-trivial agent work;
9. human approval for merges, licensing, dependencies, releases, secrets, and product direction;
10. no online services, multiplayer, native extensions, or large meta-progression in the first playable.

## Consequences

### Positive

- defects can be reproduced with seeds and scripted input;
- content can grow without central conditional logic;
- agents can work in smaller, independently reviewable scopes;
- room quality remains authored while run order varies;
- gameplay remains testable independently of visual polish.

### Negative

- replay and validation infrastructure must be built early;
- strict scene/resource ownership may reduce apparent parallelism;
- the modifier contract needs careful design before many items are added;
- some rapid prototypes may feel slower because they must respect boundaries and evidence requirements.

## Deferred decisions

- exact Godot minor version;
- unit/integration test framework;
- project license;
- final save and replay formats;
- controller remapping and accessibility baseline;
- specific third-party addons;
- release platforms and distribution process.

Each deferred decision should receive its own ADR when it becomes implementation-blocking.
