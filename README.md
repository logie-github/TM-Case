# TM Case

TM Case is a collection of mods for Gen1Recomp, ranging from small
quality-of-life improvements and optional cheats to more substantial
gameplay overhauls, letting you choose only what you want to change.

Each mod is designed for [Gen1Recomp](https://github.com/bryanthaboi/gen1recomp)
and can be used independently unless its documentation states otherwise.

## Supported games

- Pokémon Red
- Pokémon Blue
- Pokémon Yellow

Check the individual mod's README or manifest for exact compatibility.

## What's in the Case

| Mod | Description | Releases |
|---|---|---|
| [tm35_metronome](mods/tm35_metronome) | Gesture-only touch controls — no on-screen D-pad. | [link](https://github.com/logie-github/TM-Case/releases?q=tm35_metronome) |

## Installation

Grab the mod you want from [Releases](https://github.com/logie-github/TM-Case/releases),
extract it into your game's `mods/` folder, and enable it in
`options.lua` or the in-game mod manager.

Some mods have their own extra setup — check the mod's README.

## Layout

```
mods/<mod_name>/     one folder per mod: manifest.json, README.md, source
.github/workflows/   zips a mod and publishes it as a Release on tag push
```

Source lives here; packaged zips live on [Releases](https://github.com/logie-github/TM-Case/releases),
tagged `<mod_name>-v<version>` (e.g. `tm35_metronome-v1.0.0`).

See [CONTRIBUTING.md](CONTRIBUTING.md) for adding a new mod.
