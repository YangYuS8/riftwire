# Development Guide

## Baseline

Riftwire targets Godot 4.x with GDScript as the default implementation language. The exact minor version is intentionally not pinned during repository foundation; pin it before meaningful scene and resource work begins.

## Recommended local tools

- Git;
- Git LFS only if large binary assets later justify it;
- Godot 4 editor and headless executable;
- an editor with EditorConfig support;
- optional `gh` CLI for Issue and PR workflows.

Do not add a project-wide addon, formatter, linter, or native toolchain without documenting its purpose and maintenance cost.

## Open the project

```bash
godot --editor --path .
```

Basic headless import check once a pinned Godot version exists:

```bash
godot --headless --editor --quit --path .
```

## Repository hygiene

- Keep `.godot/` and exported builds out of Git.
- Commit source assets, not editor caches.
- Keep text scenes and resources readable; investigate unexplained mass diffs.
- Do not edit the same scene/resource concurrently across worktrees.
- Move or rename Godot resources through the editor when dependency rewrites are needed.
- Avoid committing local replay captures, profiling dumps, and screenshots unless they are intentional test fixtures or PR evidence.

## Proposed directory responsibilities

- `game/`: shippable runtime content only.
- `assets/`: source art/audio and attribution records; runtime imports may live near their owning game content when that improves locality.
- `tests/`: automated tests and deterministic fixtures.
- `tools/`: non-shipping editor tools, replay runners, validation scripts, and bots.
- `docs/`: product and engineering contracts.

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

Vendor or pin dependencies where practical. Never execute unreviewed installation scripts from third-party asset packs.
