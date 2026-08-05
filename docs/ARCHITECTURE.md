# Architecture

This document defines the intended boundaries for the first playable. It is a contract, not a claim that every subsystem already exists.

## Architectural goals

- keep real-time input and presentation responsive;
- make weapons, modules, enemies, and encounters independently extensible;
- reproduce runs and defects with seeds and recorded inputs;
- allow multiple developers or agents to work without frequently editing the same files;
- keep content iteration possible through Godot Resources and small authored scenes;
- fail safely when modifier chains become recursive or too expensive.

## Planned repository layout

```text
game/
  actors/
    player/
    enemies/
  combat/
    damage/
    health/
    weapons/
    projectiles/
    modifiers/
    status_effects/
  dungeon/
    run_graph/
    rooms/
    encounters/
  content/
    weapons/
    modules/
    enemies/
    encounters/
  autoload/
  presentation/
  ui/

tests/
  unit/
  integration/
  replay/
  performance/

tools/
  validation/
  replay/
  bots/
  editor/
```

Folders should be introduced as working code requires them; do not create large empty hierarchies merely to match this diagram.

## Runtime layers

### Input

Collects human, scripted, or replay input and converts it into a stable `PlayerCommand`-like representation. Gameplay code should not read arbitrary device input throughout the scene tree.

### Simulation

Owns movement decisions, damage, health, weapon state, projectile state, modifiers, encounters, room completion, rewards, and seeded generation. Simulation rules must not depend on visual animation completion.

### Presentation

Consumes state and events to drive animation, sound, camera effects, particles, UI, and accessibility feedback. Presentation may lag, skip, or reduce effects without changing authoritative outcomes.

### Tooling and telemetry

Records seeds, room identifiers, equipped modules, important events, performance counters, and test artifacts. Foundation telemetry remains local and must not transmit data off-device.

## Composition model

Prefer small components with explicit interfaces:

```text
Player
  InputAdapter
  MovementController
  WeaponController
  HealthComponent
  Hurtbox
  AnimationPresenter
```

Avoid a single player script that owns input, movement, shooting, health, UI, and animation. Avoid inheritance chains such as `Actor -> Shooter -> PlayerShooter -> SpecialPlayer` when components or resources can express the variation.

## Weapon pipeline

A weapon produces an immutable or copy-on-write `ShotSpec` describing an intended shot. Ordered modules transform that specification or subscribe to bounded lifecycle events.

```text
WeaponDefinition
  -> base ShotSpec
  -> ordered module transforms
  -> ProjectileSpawner
  -> projectile movement
  -> hit events
  -> death/expiry events
```

The design must distinguish:

- **spec transforms**: change damage, count, spread, speed, lifetime, visuals;
- **spawn transforms**: create multiple or delayed projectiles;
- **movement behaviors**: straight, arc, wave, homing;
- **hit behaviors**: pierce, chain, status, knockback;
- **termination behaviors**: split, explode, return, drop effect.

Recursive triggers require a depth or generation budget. Every spawned projectile should carry provenance such as source weapon, module chain, generation depth, and run seed context.

## Randomness

A run/session context owns the root seed and derives named streams for independent domains, for example:

```text
run_graph
drops
encounters
enemy_variation
weapon_rolls
```

Gameplay systems must not create hidden random generators or use time-based seeds. Named streams prevent an unrelated visual or drop roll from silently changing room generation.

## Rooms and run generation

Run generation creates a graph from room categories and constraints. It then selects authored room templates that declare metadata such as:

- allowed entrances and exits;
- dimensions and camera bounds;
- difficulty and biome tags;
- enemy spawn markers;
- reward/shop/boss category;
- navigation validation points;
- supported movement abilities.

A room must be manually completable with the baseline movement kit before it enters the selectable pool.

## Events

Use signals or explicit event objects for domain boundaries, but avoid an untyped global event bus. Events should have a clear owner, payload contract, and lifetime.

Examples:

- `damage_applied`;
- `projectile_spawned`;
- `encounter_completed`;
- `room_entered`;
- `module_chain_changed`.

Connections must be cleaned up when objects leave the tree or are returned to pools.

## Performance boundaries

Projectile-heavy systems need explicit budgets:

- maximum active player projectiles;
- maximum descendants per originating shot;
- maximum recursive event depth;
- maximum expensive target searches per physics tick;
- object-pool capacity and fallback behavior;
- effect quality levels for low-end hardware.

Optimization should follow measurement, but unbounded behavior is an architectural defect even before profiling.

## Persistence

The first playable only needs settings, debug unlocks, and optional run/replay artifacts. Save formats should be versioned and treated as untrusted input. Do not serialize live scene nodes directly as the long-term save contract.

## Decisions requiring an ADR

Create an ADR before changing:

- engine minor-version baseline after it is pinned;
- primary scripting language or native extensions;
- weapon modifier contract;
- save/replay format;
- third-party addons with architectural impact;
- networking or online telemetry;
- procedural geometry strategy;
- public modding API;
- project license.
