# Asset Game Jam 2020

Small platformer / roguelike built from scratch (hopefully) over a weekend using raylib + nuklear + D standard libs.

## Assets:

- [https://hugues-laborde.itch.io/pixelartpacksidescroller](https://hugues-laborde.itch.io/pixelartpacksidescroller)
- [https://adamatomic.itch.io/cavernas](https://adamatomic.itch.io/cavernas)

## Build instructions:

- install the D compiler + build tool (dub): https://dlang.org/download.html
- extract the art assets: `cd assets && ./extract.sh && cd ..`
- make sure you have raylib 3.0.0 installed somewhere (shared / static library) 
    - see install notes at https://code.dlang.org/packages/raylib-d
    - on mac os you can just run `brew install raylib` (and `brew upgrade raylib` if your raylib install is out of date / not `v3.0.0`)
    - linux should be similar (`sudo apt-get install raylib`?)
- extract assets and build / install other dependencies (necessary to build + install nuklear libs *unless* you're on windows): run `./install.sh`
- run `dub run` to fetch all remaining dependencies + build and run the game! :)

### simplified build instructions (mac os, linux should be similar but with apt-get / yum / whatever package manager you're using - or choco (well, maybe) on windows):

```bash
brew install dub dmd raylib
./setup.sh
dub run --config=editor
```
if you don't have brew, install it at https://brew.sh

## Additional notes:

This is currently a work in progress, so check back later!
