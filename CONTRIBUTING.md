# Contributing to Riftwire

Riftwire is designed for collaboration between human developers and coding agents. The same engineering standards apply to both.

## Before starting

1. Read `README.md`, `AGENTS.md`, and the relevant documents in `docs/`.
2. Search existing Issues and PRs to avoid duplicate work.
3. Create or claim an Issue for any non-trivial change.
4. Write acceptance criteria before implementation.

Small typo and documentation fixes may skip the Issue when their scope is obvious.

## Development setup

The exact Godot 4 minor version will be pinned before gameplay implementation. Once pinned, use that version for imports and scene edits to reduce serialization churn.

```bash
git clone https://github.com/YangYuS8/riftwire.git
cd riftwire
godot --editor --path .
```

See `docs/DEVELOPMENT.md` for environment and repository conventions.

## Branches and worktrees

Use short-lived branches:

```text
feat/<issue>-<description>
fix/<issue>-<description>
docs/<issue>-<description>
chore/<issue>-<description>
agent/<issue>-<description>
```

For parallel work, prefer Git worktrees:

```bash
git fetch origin
git worktree add ../riftwire-123 -b feat/123-player-jump origin/main
```

Do not run multiple agents against the same working tree. Avoid assigning the same `.tscn`, `.tres`, or binary asset to multiple concurrent tasks.

## Commits

Use focused commits with imperative Conventional Commit-style messages:

```text
feat(player): add buffered jump input
fix(projectile): cap recursive split depth
docs(agent): define replay evidence contract
```

Do not mix mechanical renames, formatting, asset moves, and behavior changes in one commit.

## Pull requests

Open a draft PR early for meaningful work. A PR should contain:

- the problem and intended player/developer impact;
- linked Issue and acceptance criteria;
- a concise implementation summary;
- tests and exact commands run;
- fixed seed, replay, screenshots, or recording when relevant;
- performance impact for projectile-heavy or generation changes;
- risks, limitations, and follow-up tasks.

Keep PRs reviewable. As a guideline, split work when it changes several independent subsystems or requires unrelated review expertise.

## Code and content conventions

- Prefer typed GDScript and explicit dependencies.
- Use composition over deep inheritance.
- Separate input, simulation, and presentation.
- Put tunable gameplay data in Resources rather than scattered literals.
- Use seeded RNG from the run/session context.
- Keep authored rooms valid without relying on a particular random sequence.
- Never make gameplay correctness depend on animation callbacks.
- Avoid broad scene/resource rewrites caused only by a different editor version.

## Assets and licensing

Every non-original asset must have:

- source URL or vendor reference;
- author/creator;
- license and version;
- proof that the intended use is permitted;
- required attribution;
- record in `assets/ATTRIBUTION.md` before merge.

Generated assets must document the generator/tool, model or service when known, prompt/source inputs where practical, and applicable usage rights. Do not add assets with uncertain provenance.

## Reviews

Reviewers should prioritize:

1. player-facing correctness and regressions;
2. architecture boundaries and determinism;
3. test quality and reproducibility;
4. performance and cleanup behavior;
5. readability and documentation.

Agents may prepare reviews, but a human retains merge authority during the foundation phase.

## Reporting bugs

Use the Bug Report Issue form. Include the Godot version, OS, build/commit, seed, room, equipped modules, reproduction steps, logs, and replay evidence when available.
