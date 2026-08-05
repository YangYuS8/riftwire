# ADR-0002: Engine and Test Baseline

- Status: Accepted
- Date: 2026-08-05
- Decision owners: repository owner

## Context

Riftwire needs a single reproducible implementation baseline before gameplay scenes, physics behavior, resources, and automated tests begin to accumulate. The project prioritizes the latest stable tooling, low setup overhead, fast feedback, and predictable agent/CI behavior.

## Decision

Riftwire will use:

1. **Godot 4.7.1 Standard** as the pinned engine version;
2. **GDScript** as the default implementation language;
3. the **Mobile renderer** as the primary renderer;
4. **GUT 9.7.1** for GDScript unit and scene-integration tests;
5. GUT pinned as the `addons/gut` Git submodule at commit `aeb5d4f3f7f0a6c9b5e178876d6c99b791fda605`;
6. headless import and GUT execution in GitHub Actions;
7. JUnit XML output retained as a CI artifact.

The engine version is recorded in `.godot-version`, documentation, project features, scripts, and CI. CI uses `chickensoft-games/setup-godot@v2.4.1` with the non-.NET editor.

## Rationale

- Godot 4.7.1 is the latest stable maintenance release at the time of the decision.
- A new project has no compatibility reason to begin on an older minor release.
- Standard Godot avoids the .NET SDK and Mono dependency chain while the project is GDScript-first.
- GUT 9.7.1 explicitly targets Godot 4.7.x and provides CLI execution, doubles, parameterized tests, and JUnit export.
- Mobile offers a better balance for modern 2D effects and projectile-heavy scenes than Compatibility, with less baseline cost than Forward+.
- Exact dependency commits make local, CI, human, and agent environments converge on the same behavior.

## Upgrade policy

### Patch releases

A Godot 4.7.x patch upgrade may be proposed in a dedicated PR. It must update every version pin and pass import, unit, integration, replay, and applicable performance checks.

### Minor releases

A Godot 4.8+ upgrade requires a dedicated ADR or ADR amendment after:

- the release is stable, not beta/RC/dev;
- GUT has a stable compatible release;
- addon compatibility is verified;
- deterministic replay fixtures and representative scenes pass;
- migration notes and rollback steps are documented.

### Test framework

GUT remains pinned until a deliberate dependency-update PR is reviewed. Replacing it requires evidence that the alternative improves the project rather than only offering more features.

## Consequences

### Positive

- contributors receive one command for environment verification and testing;
- CI and local development use identical engine and framework versions;
- agents can produce tests against a stable API;
- modern 2D rendering features remain available without choosing Forward+ by default.

### Negative

- clones must initialize the GUT submodule;
- Mobile renderer requires hardware/platform support consistent with its Vulkan baseline;
- Web and very old GPU support are not guaranteed by the primary renderer;
- version upgrades require coordinated pin changes rather than silently following latest releases.

## Alternatives considered

- **Godot 4.6.x:** mature, but immediately starts a new project on an older minor line.
- **Godot development/beta/RC builds:** newer, but inappropriate for a stable production baseline.
- **Godot .NET:** unnecessary dependency and build complexity while no C# requirement exists.
- **Compatibility renderer:** simpler and broader, but unnecessarily limits the intended effects pipeline.
- **Forward+:** capable, but has higher baseline cost than this 2D project currently needs.
- **GdUnit4:** strong scene-testing capabilities, but GUT provides the smaller and currently explicit Godot 4.7.x baseline chosen for the first playable.
