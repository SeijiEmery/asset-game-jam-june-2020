# Asset Game Jam 2020

Small platformer / roguelike built from scratch (hopefully) over a weekend using raylib + nuklear + D standard libs.

## Assets:

- [https://hugues-laborde.itch.io/pixelartpacksidescroller](https://hugues-laborde.itch.io/pixelartpacksidescroller)
- [https://adamatomic.itch.io/cavernas](https://adamatomic.itch.io/cavernas)

## Dependencies:

- https://dlang.org/download.html
- https://github.com/raysan5/raylib/releases/tag/3.0.0

### build instructions (mac os, linux should be similar but with apt-get / etc):

```bash
brew install dub dmd raylib
git clone https://github.com/SeijiEmery/asset-game-jam-june-2020.git agj && cd agj
./setup.sh
dub run --config=editor
```
(this uses brew, a mac os package manager: https://brew.sh)

## Additional notes:

This was built from scratch over a 2-3 day game jam around an asset pack, inspired by https://www.youtube.com/watch?v=5CYdUXN8QOg. 

I went sligthly overboard and thought this would be a cool opportunity to try building a small scoped 2d platformer from scratch(ish). Ended up using raylib to keep the project in scope, and D b/c it's one of my favorite langages :) Ran into a few complications due to the combination of raylib + D making it difficult to add other packages (eg. imgui), so ended up rolling a very, very basic editor ui / button tray (from D enums! :) ) in an hour or two. 

Due to project scope + time limits this ended up getting scaled back a bit, and this basically turned into a small-ish level editor that could be built out / expanded into a full 2d engine in the future.

Features that I was able to implement:
- user friendly level editing w/ automatic tile generation from a set of rules (which sadly ended up having to just be hardcoded - I was initially hoping to use an image-based learning approach from sample images (which is why there's a labeled version of the sample tileset image, and a bunch of half finished code to load + process sample images like that), but this was obviously way too much work to do in 2 days (and on top of everything else). lol).
- simple retained-mode sprite renderer with depth sorting, culling, and transparency (mostly just calls a bunch of raylib functions)
- performant chunked tile renderer (no limit on map size, map expands as you edit it, up to 2^31 x 2^31 tiles or whatever; 4kb chunks)
- file saving / loading (technically, saves map data to one pair of binary that can be moved / copied to produce backups or reset)
- nice mouse / keyboard editing UI w/ hotkeys (see below)
- undo / redo
- animation playback on the player w/ a small FSM and gamepad controls (see below)
- automatic sprite animation loading from the structure + file names of sprites in the sprite folder; python script scans these and generates a D script (sprites.d) that has hardcoded paths to load everything. Usage is as follows:
   
```dlang
auto sprite = <sprite renderer>.create
    .fromAsset(Sprites.Player.<AnimationName>, <loop animation>)
    .SetPosition(<position>)
;
<sprite renderer>.render(<camera>);     // to draw all sprites each frame
...
sprite.destroy();                       // to delete this object
```

Missing features:
- physics, AI, pathding, enemies, pickups, any real game mechanics, etc
- only some player animations are implemented
- only a few tile types are currently implemented (grass, water, platforms); the rest could be implemented easily but are TBD
- non-gamepad player controls
- animation speeds are semi-hardcoded into sprites.d, and should be pulled from eg. a separate config file but aren't


### Gamepad controls:

```
Left Stick - player movement
Right Stick - camera movement (can also pan w/ the mouse, see below)
Left Stick (pressed) - toggle follow player or free look mode (the latter is the default)
Right Stick (pressed) - reset camera / jump to player

X / square - attack (plays random weighted attack animations)
B / circle - roll (this animation is jank and would need hand tuning)
```

### Editor controls:

```
Left click - draw currently selected tile type at the cursor
Right click - erase / clear a tile
Scroll wheel - zoom in / out
Middle mouse click + drag - pan the camera

R key (Point, Rect) - toggle between draw point + draw rect drawing modes
F key (Default, FillEmpty) - toggles fill mode (FillEmpty is a filter that makes all drawing actions only draw in cleared / erased tiles; good for filling areas while preserving details)
Q key - eyedropper: select the currently moused over tile type

Cmd/Ctrl + S - save map
Cmd/Ctrl + O - open / reload saved map (if present)
Cmd/Ctrl + Z - undo drawing action
Cmd/Ctrl + Shift + Z - redo drawing action
```

#### tile selection:

```
A key (Air)    - "indoors" tiles
G key (Ground) - grassy "wall" tiles
T key (Torch)  - torches
D key (Ladder) - ladders
S key (Platform) - platforms / support / pillar tiles
W key (Water / Waterfall / Waterspout) - toggles water tile types
(waterspout is a special smaller single-tile waterfall and has a poured water source assoc w/ it)
L key (Lava / Lavafall) - ditto w/ lava, but only two types
```

## Additional tests + examples

Shared source code is in `source` (and comprises the `agj` module), tests (main entrypoints) are in `tests` (including `editor.d`, atm)

Code was reasonably structured / cleaned up but then everything ended up back in editor.d lol. Cleanup TBD.

You can run other programs + tests with `dub run --config=<test-name>` (where `test-name` corresponds to `tests/test_name.d`); for a detailed list see `dub.json` and the `configurations` list.
