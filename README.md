# Riftwire

**Riftwire** is the development codename for a Godot 4 side-scrolling action roguelite built around modular weapon circuits, room-based combat, and reproducible runs.

> Status: pre-production / repository foundation

## Project direction

The project aims to combine responsive platform shooting with a build system in which weapon modules are connected in order and transform projectile behavior.

Example:

```text
Emitter -> Splitter -> Homing -> Detonator
```

Changing the order changes the result. The goal is not to reproduce *Neon Abyss*, but to explore the same broad genre with a distinct, system-driven identity.

### Design pillars

1. **Movement first** — running, jumping, aiming, firing, hit reactions, and recovery must feel reliable before content scales.
2. **Readable chaos** — strong projectile combinations without losing combat readability.
3. **Composable content** — weapons, modules, enemies, and encounters are data-driven and use shared behaviors.
4. **Reproducible runs** — seeded generation, input recording, and structured telemetry make defects repeatable.
5. **Human-directed agents** — humans retain product, architecture, licensing, and risk authority; agents may implement, verify, and merge ordinary scoped changes when explicitly authorized and required checks pass.

## First playable target

The initial vertical slice is deliberately small:

- one playable character;
- one polished movement controller;
- one base weapon;
- five stackable weapon modules;
- two normal enemies;
- three authored combat rooms;
- one small boss encounter;
- deterministic run seeds and a basic replay trace.

Randomized room graphs, shops, meta progression, pets, multiple characters, and large content pools come later.

## Technology baseline

- Godot 4.7.1 Standard;
- GDScript-first;
- Mobile renderer;
- GUT 9.7.1, pinned as a Git submodule;
- Linux-first development, with Windows compatibility kept in scope;
- GitHub Issues, isolated branches/worktrees, and draft pull requests for collaboration.

See [`ADR-0002`](docs/adr/0002-engine-and-test-baseline.md) for the version and upgrade policy.

## Getting started

```bash
git clone --recurse-submodules https://github.com/YangYuS8/riftwire.git
cd riftwire
./tools/bootstrap.sh
godot --editor --path .
```

Run the current checks:

```bash
./tools/test.sh
```

Before contributing, read:

1. [`CONTRIBUTING.md`](CONTRIBUTING.md)
2. [`AGENTS.md`](AGENTS.md) — required for both autonomous agents and humans delegating work to agents
3. [`docs/VISION.md`](docs/VISION.md)
4. [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
5. [`docs/TESTING.md`](docs/TESTING.md)

## Repository map

```text
addons/     Reviewed and pinned Godot addons
assets/     Licensed source assets and attribution records
docs/       Product, architecture, workflow, and decision documents
game/       Runtime scenes, scripts, resources, and UI
tests/      Logic, integration, replay, and performance tests
tools/      Editor tools, validation scripts, bots, and developer utilities
```

## Collaboration model

Every non-trivial change should start from a clear Issue or task contract, use an isolated branch or worktree, and end in a draft PR containing validation evidence. Agents must not silently broaden scope. When the repository owner has granted applicable task-specific or standing merge authorization, agents may mark a completed PR ready and merge it after required checks pass against the current head SHA. Material product or architecture decisions and other high-risk actions still require explicit human approval.

See [`docs/AGENT_WORKFLOW.md`](docs/AGENT_WORKFLOW.md) for the full human-agent workflow.

## License

Riftwire is licensed under the [Mozilla Public License 2.0](LICENSE). Third-party assets retain their original licenses and must be recorded with their required attribution.
