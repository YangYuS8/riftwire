# Tests

Riftwire uses GUT 9.7.1 for GDScript unit and scene-integration tests. The full upstream repository is pinned under `.vendor/gut`; `tools/bootstrap.sh` materializes only its plugin directory into the ignored `addons/gut` path expected by Godot.

```text
tests/
├── unit/          Fast deterministic rules and resource tests
├── integration/   Minimal scene and component interaction tests
├── replay/        Fixed-seed scripted-input fixtures
└── performance/   Repeatable stress and budget fixtures
```

Run the current automated suite from the repository root:

```bash
./tools/test.sh
```

Test design and evidence requirements are defined in [`docs/TESTING.md`](../docs/TESTING.md).
