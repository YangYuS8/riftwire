# Development Guide

## Baseline

Riftwire pins the following implementation baseline:

- Godot 4.7.1 Standard;
- GDScript;
- Mobile renderer;
- GUT 9.7.1 at the exact submodule commit recorded in ADR-0002;
- Linux-first development, while keeping Windows compatibility in scope.

See [`docs/adr/0002-engine-and-test-baseline.md`](adr/0002-engine-and-test-baseline.md) for the decision and upgrade policy.

## Recommended local tools

- Git;
- Godot 4.7.1 Standard editor/headless executable;
- an editor with EditorConfig support;
- optional `gh` CLI for Issue and PR workflows;
- Git LFS only if large binary assets later justify it.

Do not add a project-wide addon, formatter, linter, or native toolchain without documenting its purpose and maintenance cost.

## Clone and bootstrap

Clone submodules with the repository:

```bash
git clone --recurse-submodules https://github.com/YangYuS8/riftwire.git
cd riftwire
./tools/bootstrap.sh
```

For an existing clone:

```bash
git submodule update --init --recursive
./tools/bootstrap.sh
```

When the executable is not named `godot`:

```bash
GODOT_BIN=/path/to/Godot ./tools/bootstrap.sh
```

The bootstrap command fails rather than silently accepting a different engine version. It also copies the pinned plugin from `.vendor/gut/addons/gut` into the ignored `addons/gut` runtime path. Never edit the materialized copy; update the pinned dependency deliberately instead.

## Open the project

```bash
godot --editor --path .
```

## Run checks

```bash
./tools/test.sh
```

This performs:

1. exact engine-version verification;
2. GUT submodule initialization and plugin materialization;
3. headless Godot import;
4. GUT unit and integration tests;
5. JUnit output under `test-results/`.

## Repository hygiene

- Keep `.godot/` and exported builds out of Git.
- Commit source assets, not editor caches.
- Keep text scenes and resources readable; investigate unexplained mass diffs.
- Do not edit the same scene/resource concurrently across worktrees.
- Move or rename Godot resources through the editor when dependency rewrites are needed.
- Avoid committing local replay captures, profiling dumps, and screenshots unless they are intentional test fixtures or PR evidence.
- After switching branches, rerun bootstrap before opening the project.

## Directory responsibilities

- `game/`: shippable runtime content only.
- `assets/`: source art/audio and attribution records; runtime imports may live near their owning game content when that improves locality.
- `tests/`: automated tests and deterministic fixtures.
- `tools/`: non-shipping editor tools, replay runners, validation scripts, and bots.
- `docs/`: product and engineering contracts.
- `.vendor/`: exact upstream dependency repositories; not scanned as project content.
- `addons/`: materialized reviewed Godot addons; generated dependency copies are ignored.

## GDScript style

- Use typed parameters, return types, and important state.
- Prefer descriptive domain names over abbreviations.
- Keep methods small enough to test and reason about.
- Use leading underscore for private implementation details.
- Avoid `get_node("../../...")` reach-through; inject references or use owned child nodes.
- Avoid autoloads for ordinary domain state.
- Put balance values in Resources or configuration objects.
- Document non-obvious invariants and performance limits, not obvious syntax.

## Scene design

A scene should have one primary responsibility. Reusable actors should expose clear configuration and signals. Presentation children may reference their owner, but unrelated systems should communicate through explicit contracts.

Recommended pattern:

```text
player/
  player.tscn
  player.gd
  movement_controller.gd
  movement_config.gd
  weapon_controller.gd
  tests/
```

Co-locate small subsystem tests and fixtures when it improves discoverability; keep cross-system suites under top-level `tests/`.

## Adding content

A basic weapon/module/enemy should usually be addable through a new Resource plus existing reusable behavior. If every content addition requires editing a central conditional statement, stop and review the architecture.

Each content definition should have:

- stable identifier;
- display metadata separated from behavior where practical;
- tunable values;
- validation rules;
- test or debug-spawn path;
- attribution for non-original assets.

## Debugging contract

When reporting a gameplay defect, capture:

- commit/build identifier;
- Godot version and OS;
- root run seed;
- room/template identifier;
- player weapon and ordered module chain;
- exact reproduction steps or input replay;
- relevant logs and screenshots;
- observed and expected behavior.

Do not leave verbose per-frame logging enabled in normal builds.

## Dependency policy

Before adding an addon or library, document:

- problem it solves;
- why internal implementation is insufficient;
- license;
- maintenance/activity level;
- update and removal strategy;
- runtime/editor-only status;
- deterministic and headless-test impact.

Dependencies must be pinned. Never execute unreviewed installation scripts from third-party asset packs.
