# Product Vision

## One-sentence pitch

Riftwire is a fast side-scrolling action roguelite where players assemble ordered weapon circuits that radically transform how every shot moves, multiplies, and reacts.

## Player fantasy

The player descends through unstable rifts as a mobile weapons operator who rewires experimental technology during each run. Success comes from movement skill, combat reading, and discovering interactions between imperfect modules.

## Core loop

```text
Enter room
  -> read terrain and threats
  -> move, jump, aim, and shoot
  -> clear encounter
  -> choose a weapon/module/reward
  -> rewire the build
  -> choose the next room
  -> defeat the boss or lose the run
```

A run should produce meaningful build evolution quickly. New modules must change decisions or projectile behavior, not merely add invisible percentage bonuses.

## Pillars

### 1. Responsive platform shooting

Movement and firing must remain understandable under pressure. The first milestone is a controller that feels intentional with keyboard/mouse and controller input.

### 2. Ordered modular weapons

A weapon circuit is a sequence of modules. Order is mechanically significant.

```text
Split -> Home
```

means every split projectile acquires targeting, while:

```text
Home -> Split
```

means the parent projectile homes before creating children. This ordering system is the project's primary product differentiator.

### 3. Authored rooms, procedural runs

Rooms are designed and validated by humans. Run generation assembles them through a seeded graph with tags, difficulty budgets, and connection constraints. Fully procedural platform geometry is out of scope for the foundation phase.

### 4. Readable escalation

Builds may become powerful and visually expressive, but enemy tells, harmful projectiles, player hit feedback, and safe navigation must remain readable.

### 5. Reproducibility

Every run has a seed. Important player inputs and game events can be recorded. A failure report should identify the build, room, seed, and event sequence needed to reproduce it.

## Initial audience

Players who enjoy action roguelites, platform shooters, expressive build crafting, and discovering system interactions. The project should support short focused runs rather than long campaigns in its early form.

## First playable success criteria

The vertical slice succeeds when:

- movement and aiming are pleasant enough to replay without progression rewards;
- five modules create at least three visibly different build patterns;
- every room and boss can be completed with the base weapon;
- a seed and scripted input can reproduce a test run;
- adding a new simple module does not require editing the player controller or base weapon;
- automated validation catches obvious room, projectile, and recursive-trigger failures.

## Explicit non-goals for the first playable

- online multiplayer or network services;
- multiple characters;
- pets, eggs, or companion ecosystems;
- large narrative systems;
- procedural platform geometry;
- user-generated mods;
- native C++ extensions;
- hundreds of items;
- mobile release support;
- permanent meta-progression beyond debug unlocks.

These may be reconsidered through ADRs after the core loop is proven.
