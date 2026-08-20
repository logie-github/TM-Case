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

| Mod | Description | Latest release |
|---|---|---|
| [tm35_metronome](mods/tm35_metronome) | Add gesture controls to overwrite the main touch controls. | [Releases](https://github.com/logie-github/TM-Case/releases?q=tm35_metronome) |

## Installation

Download the mod you want from its [release](https://github.com/logie-github/TM-Case/releases)
and install it using the normal Gen1Recomp mod installation process:
extract the zip so the mod's folder lands under your game's `mods/`
directory, then enable it in `options.lua` or the in-game mod manager.

Individual mods may have additional configuration options or
requirements — see the documentation included with each mod package.

## Repository structure

```
mods/<mod_name>/     one folder per mod: manifest.json, README.md, source
.github/workflows/   release automation (zip + publish on tagged pushes)
```

Each mod is distributed separately with its own documentation, version
information, requirements, and installation package. Source lives in this
repo; packaged zips are published as [GitHub Release](https://github.com/logie-github/TM-Case/releases)
assets under tags namespaced `<mod_name>-v<version>` (e.g.
`tm35_metronome-v1.0.0`), so history stays text-only and every version of
every mod stays independently downloadable.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the folder layout and how the
release automation works.
