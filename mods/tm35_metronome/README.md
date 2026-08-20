# TM35 Metronome

Add gesture controls to overwrite the main touch controls.

## Controls

- Tap = A
- Swipe from the right edge = B
- Swipe up from the bottom edge = Start
- Two-finger tap = Select
- Swipe and hold a direction = D-pad, held

## Setup

Turn off the touch overlay in OPTIONS → CONTROLS first, its buttons eat
any touch that starts on them before this mod sees it. Then enable
`tm35_metronome` under `mods` in `options.lua`, or through the F10 mod
manager.

## Notes

- A touch starting in the bottom-right corner reads as Start, not B.
  Bottom edge wins ties.
