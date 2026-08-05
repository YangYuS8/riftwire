# Tools

Repository-owned developer utilities live here.

- `bootstrap.sh` verifies Godot 4.7.1 and initializes pinned submodules.
- `test.sh` performs a headless import and runs GUT 9.7.1.

Both scripts accept `GODOT_BIN` when the executable is not named `godot`:

```bash
GODOT_BIN=/path/to/Godot ./tools/test.sh
```
