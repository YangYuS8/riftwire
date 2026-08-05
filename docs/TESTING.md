# Testing Strategy

Real-time action games cannot be validated through unit tests alone. Riftwire uses layered evidence so deterministic rules, scene integration, player movement, visuals, and performance can be checked independently.

## Test layers

### 1. Pure logic tests

Use for code that can run without a rendered scene:

- damage and mitigation;
- health and invulnerability windows;
- weapon statistics;
- ordered module transforms;
- trigger budgets and recursion limits;
- drop tables;
- run graph generation;
- room selection constraints;
- save/replay parsing.

Pure logic tests should be fast and deterministic.

### 2. Scene integration tests

Use minimal scenes to validate:

- signal connections and cleanup;
- hitbox/hurtbox interaction;
- projectile spawn, collision, expiry, and pooling;
- encounter completion;
- room doors and transitions;
- UI updates from gameplay state.

Integration fixtures should avoid decorative content unrelated to the behavior under test.

### 3. Scripted input and replay tests

Represent player input as a sequence independent of physical devices. Example:

```text
0-59: move_right
10: jump_pressed
11-24: jump_held
25: jump_released
40-120: fire_toward(1, 0)
```

Assertions may include:

- player reaches an expected region;
- jump height and duration remain within tolerance;
- no wall penetration or permanent stuck state occurs;
- expected enemies are defeated;
- encounter completes;
- projectile counts remain bounded;
- final state hash or key event sequence matches the fixture.

Physics-sensitive assertions should use tolerances and stable physics-tick counts, not wall-clock timing.

### 4. Visual evidence

Screenshots and short recordings are required when behavior is primarily visible:

- animation state;
- hit feedback;
- projectile readability;
- camera shake;
- room composition;
- UI layout;
- module-chain presentation.

Visual evidence supplements tests; it does not replace correctness checks.

### 5. Performance tests

Track at least:

- active and peak projectile counts;
- spawned projectiles per second;
- physics frame time under stress;
- object-pool misses/expansions;
- target-search operations;
- recursive trigger depth;
- leaked nodes or signal connections after room exit.

Performance fixtures should define hardware/context and use repeatable seeds.

## Determinism contract

A reproducible test artifact should contain:

```text
commit
godot_version
platform
root_seed
room_id
input_sequence
weapon_id
ordered_modules
expected_key_events
```

Random domains derive named streams from the run context. Visual randomness must not consume gameplay RNG streams.

## Room validation

Before a room enters the generation pool, validate:

- entrances/exits align with declared metadata;
- baseline player can reach required platforms;
- spawn points do not overlap solid geometry;
- enemies have valid navigation/behavior space;
- encounter completion can unlock exits;
- no required reward is unreachable;
- camera bounds cover playable space;
- the room can complete under a fixed test seed.

## Pull request evidence matrix

| Change | Minimum evidence |
|---|---|
| Pure calculation/resource validation | Unit test |
| New component or actor behavior | Unit or integration test |
| Movement/physics change | Scripted input test + recording |
| Weapon/module behavior | Logic test + combat fixture + recording |
| Room/encounter | Room validation + fixed seed + screenshot/recording |
| Generator | Property/invariant tests across many seeds |
| Projectile optimization | Stress fixture + before/after metrics |
| UI/presentation | Screenshot/recording + relevant integration check |

## Failure reporting

A failing test or QA report must state what was actually executed. Never replace missing evidence with an assertion that behavior is "obviously correct." If an automated check cannot run because tooling is not yet installed, record the blocker and provide manual evidence without calling it an automated pass.
