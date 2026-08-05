# Player movement

Open `movement_lab.tscn` to manually evaluate the first-pass controller.

Controls:

- move: `A` / `D` or left / right arrows;
- jump: Space;
- release Space early for a shorter jump.

The current values are engineering defaults, not final game-feel decisions. Adjust `default_player_movement_config.tres` only with before/after measurements and human playtest notes.

Input is gathered through `PlayerInputSource`. Runtime keyboard input uses `ActionPlayerInputSource`; deterministic tests and future replays can inject `ScriptedPlayerInputSource` without changing movement simulation.
