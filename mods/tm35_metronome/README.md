# TM35 Metronome

Add gesture controls to overwrite the main touch controls.

No on-screen D-pad or buttons — the whole screen reads gestures instead.

## Controls

| Gesture | Button |
|---|---|
| Tap | A |
| Swipe from the right edge | B |
| Swipe and hold a direction | D-pad (held) |
| Swipe up from the bottom edge | Start |
| Two-finger tap | Select |

## Enable it

Turn off the on-screen touch overlay first, in **OPTIONS → CONTROLS** —
its virtual buttons claim any touch that starts on them before this mod
ever sees it, so gestures only work once it's off. Then enable
`tm35_metronome` under `mods` in `options.lua`, or through the in-game mod
manager (F10).

## How it works

Built on the `input.pointer` hook (raw touch/mouse events) and `mod.input`
(source-safe GB button injection), both part of the mod API — nothing here
reaches into engine internals. Each finger is tracked independently:

- A tap (little movement, quick release) fires A.
- Movement past a small threshold locks in a D-pad direction and holds it
  until that finger lifts.
- A touch starting in the bottom or right edge strip is held back until it
  swipes inward far enough, then fires Start or B respectively — a light
  touch near an edge still falls through to a normal tap/swipe.
- A second finger touching down while the first is still an undecided tap
  fires Select and consumes both.

## Known limitations

- Not yet tested on-device — this was built directly against the engine
  source and `docs/modding.md`, but hasn't been run in LÖVE2D or on
  Android.
- A touch starting in the bottom-right corner is treated as the start of a
  Start gesture, not a B gesture (bottom edge is checked first).
