# ADR-0003: Ordered Weapon Module Contract

- Status: Accepted
- Date: 2026-08-05
- Decision owners: repository owner

## Context

Riftwire's primary product differentiator is a weapon circuit whose module order changes the resulting shot. The existing `PlayerWeapon` directly instantiates one projectile from scalar weapon configuration, which is sufficient for the baseline shooter but cannot express one-to-many transforms, provenance, or bounded ordered composition.

The first playable needs a small contract that supports visible module behavior now without prematurely committing to homing, hit effects, delayed spawning, pooling, rewards, or a public modding API.

## Decision

### Shot specification

A weapon first creates a `ShotSpec`, a copy-on-write value object containing:

- normalized direction;
- speed;
- lifetime;
- damage;
- generation depth;
- ordered module provenance.

Consumers receive values or copies rather than a mutable scene node. A module must return new shot specifications and must not mutate the input specification in place.

### Module contract

A `WeaponModule` is a Godot `Resource` with a stable `module_id` and one transformation entrypoint:

```text
Array[ShotSpec] -> Array[ShotSpec]
```

Modules execute strictly in the order declared by the weapon. The complete output of one module becomes the input of the next. This permits one-to-one transforms and one-to-many transforms while keeping scene creation outside modules.

Modules must not:

- instantiate or add scene nodes;
- read device input;
- seed hidden random generators;
- reach into the player controller;
- bypass pipeline budgets.

### Spawning authority

`PlayerWeapon` owns the configured ordered module list, creates the base specification, runs the pipeline, and instantiates one projectile for each final specification. Projectile scenes remain unaware of the player controller and module Resources.

### Budgets

The foundation pipeline processes at most 16 modules and returns at most 32 final shot specifications per fire event. Null outputs are discarded. These are safety ceilings, not balance targets.

The generation depth and provenance fields are carried now so later termination or recursive behaviors can enforce descendant budgets without changing the base specification contract.

### First module

`SplitShotModule` is the first implementation. It transforms each input specification into an evenly spaced fan, increments descendant generation depth, and records its module ID. The playtest weapon equips a three-projectile split so the architecture produces an immediately visible result.

## Rationale

- Ordered array transformation directly models the product promise.
- Copy-on-write values make unit tests deterministic and prevent one module from silently altering another module's input.
- Resource-backed modules are editable and reusable without coupling content to the player scene.
- Keeping node spawning in `PlayerWeapon` separates simulation data from scene-tree ownership.
- Explicit ceilings turn runaway composition into a bounded result before recursive behavior exists.
- Provenance makes debugging, replay records, and later descendant rules possible.

## Consequences

### Positive

- simple modules can be added without editing the player controller or base projectile;
- module order is testable without running a scene;
- one-to-many transforms are visible in the current playtest;
- scene-tree ownership remains centralized;
- future replay and telemetry work can identify the module chain that produced a projectile.

### Negative

- every transform allocates new lightweight specification objects;
- the initial contract only covers pre-spawn specification transforms;
- a hard output cap may truncate extreme chains;
- module validation and authoring UI remain minimal.

## Deferred decisions

The following require later scoped work and may require an ADR amendment when their contracts become concrete:

- movement behaviors such as homing or wave motion;
- hit and termination behaviors such as pierce, chain, split-on-death, or explosion;
- delayed and scheduled spawning;
- seeded random module behavior;
- projectile pooling;
- module inventory, rewards, rewiring UI, and persistence;
- public modding interfaces.

## Alternatives considered

- **Modules directly spawn projectiles:** rejected because it distributes scene ownership and makes budgets harder to enforce.
- **Mutating one shared dictionary:** rejected because order bugs and accidental aliasing become difficult to diagnose.
- **Inheritance per weapon combination:** rejected because combinations grow exponentially and violate composability.
- **A global combat event bus:** rejected because the first contract only needs local ordered transformation and explicit ownership.
- **Implementing all lifecycle behaviors immediately:** rejected as premature architecture beyond the first visible module.
