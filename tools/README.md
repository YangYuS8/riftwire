# Tools

Repository-owned developer utilities live here.

- `bootstrap.sh` verifies Godot 4.7.1, initializes pinned submodules, and materializes GUT into `addons/gut`.
- `test.sh` performs a headless import and runs GUT 9.7.1.

The source dependency remains pinned under `.vendor/gut`; the generated `addons/gut` directory is ignored and must not be edited.

Both scripts accept `GODOT_BIN` when the executable is not named `godot`:

```bash
GODOT_BIN=/path/to/Godot ./tools/test.sh
```
