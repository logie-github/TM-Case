# Adding or updating a mod

## Layout

Every mod is a self-contained folder under `mods/`:

```
mods/<mod_name>/
  manifest.json   # Gen1Recomp mod manifest (id must equal <mod_name>)
  README.md       # what it does, controls/options, how to enable it
  main.lua        # entry point, plus any other source files it needs
```

`<mod_name>` is the folder name and the manifest `id` — keep them
identical, and **don't put `-v` in it** (see Tagging, below, for why).

## Tagging and releases

Pushing a tag shaped `<mod_name>-v<version>` (e.g. `tm35_metronome-v1.0.0`)
runs `.github/workflows/release.yml`, which:

1. Splits the tag into mod name and version.
2. Zips `mods/<mod_name>/` (the zip's top-level entry is the mod folder
   itself, so extracting it into a `mods/` directory drops the mod in
   correctly).
3. Publishes a GitHub Release for that tag with the zip attached, using
   the mod's own `README.md` as the release notes.

The split is `TAG % "-v*"` / `TAG ## "*-v"` — the *last* `-v` in the tag
divides name from version. A mod folder containing `-v` anywhere in its
name breaks that split, which is why folder names avoid it.

Only the tag matters for triggering a release; you don't need to bump
anything else in-repo first, though keeping `manifest.json`'s `version`
field in sync with the tag is good practice.

To cut a release:

```sh
git tag tm35_metronome-v1.0.0
git push origin tm35_metronome-v1.0.0
```

## What not to commit

Packaged zips, built binaries, and anything large/regeneratable belong on
the Release, not in git history — `.gitignore` already excludes common
archive extensions and `dist/`. Small static assets a mod actually ships
(sprites, tiny audio clips) are fine to commit alongside its source.

## Multiple versions of the same mod

Old releases stay published under their own tags
(`<mod_name>-v1.0.0`, `<mod_name>-v1.1.0`, ...) — nothing needs deleting
when you cut a new one. The mod's folder in `main` always reflects the
latest source; past zips remain retrievable from their release pages.
