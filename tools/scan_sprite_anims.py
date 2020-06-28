import os
import re

animated_sprites = {}
static_sprites = {}

def emit_static_sprite(sprite, path):
    static_sprites[sprite] = os.path.relpath(path, '..')

def emit_sprite_anim_frame(sprite, path, anim, frame):
    if sprite not in animated_sprites:
        animated_sprites[sprite] = {}
    if anim not in animated_sprites[sprite]:
        animated_sprites[sprite][anim] = set()
    animated_sprites[sprite][anim].add((frame, os.path.relpath(path, '..')))

SPRITE_DIR = os.path.join('..', 'assets', 'sprites')
for entity in os.listdir(SPRITE_DIR):
    entity_path = os.path.join(SPRITE_DIR, entity)
    if os.path.isdir(entity_path):
        for path, dirs, files in os.walk(entity_path):
            for file in files:
                if file.endswith('.png'):
                    parts = file[:-4].split('_')
                    if len(parts) == 0:
                        continue

                    if parts[-1].isdigit():
                        sprite_number = int(parts[-1])
                        parts = parts[:-1]
                        sprite_name = parts[0]
                        anim = '_'.join(parts[1:] if len(parts) > 1 else parts)
                        emit_sprite_anim_frame(sprite_name, os.path.join(path, file), anim, sprite_number)
                    else:
                        sprite_number = None
                        emit_static_sprite('_'.join(parts), os.path.join(path, file))

animated_sprites = {
    sprite: {
        anim: [ frame for (frame_num, frame) in sorted(frames) ]
        for anim, frames in sprites.items()
    }
    for sprite, sprites in animated_sprites.items()
}


print("{} static sprite(s):".format(len(static_sprites)))
for sprite, path in static_sprites.items():
    print("    {}: {}".format(sprite, path))
print()
print("{} animated sprite(s):".format(len(animated_sprites)))
for sprite, anims in animated_sprites.items():
    print("    {}:".format(sprite))
    for anim, frames in anims.items():
        print("        {} ({} frame(s))".format(anim, len(frames)))

def gen_asset_handling_code():
    return """
import std.algorithm: map;
import std.array: array;
import std.string: toStringz;
import raylib;
import agj.sprite.sprite_assets;


struct Sprites {{
    {static_sprite_decls}

    private static bool isLoaded = false;
    @property static bool loaded () {{ return isLoaded; }}
    @property static size_t resourceCount () {{ return {all_sprite_count}; }}

    static void load () {{
        isLoaded = true;
        {static_sprite_init}
        {animated_sprite_init}
    }}

    {animated_sprite_struct_decls}
}}
"""[1:].format(
    all_sprite_count = len(static_sprites) + sum([
        sum([ len(sprite_frames) for sprite_frames in anim ])
        for anim in animated_sprites.values()
    ]),
    static_sprite_decls='\n    '.join([
        "static StaticSpriteAsset {name} = StaticSpriteAsset(\"{path}\");".format(name=name, path=path)
        for name, path in static_sprites.items()
    ]),
    static_sprite_init='\n        '.join([
        "{name}.load();".format(name=name)
        for name, path in static_sprites.items()
    ]),
    animated_sprite_init='\n        '.join([
        '\n        '.join([
            "{name}.{anim}.load();".format(name=name, anim=anim)
            for anim in sprite.keys()
        ])
        for name, sprite in animated_sprites.items()
    ]),
    animated_sprite_struct_decls='\n\n'.join(['''
    struct {name} {{
        {sprite_decls}
    }}'''.format(
    name=name,
    sprite_decls='\n        '.join([
        "static SpriteAnimation {name} = SpriteAnimation(10f, [\n{frames}\n        ]);".format(
            name=anim, frames=',\n'.join([
                "            \"{path}\"".format(path=path)
                for path in frames
            ]))
            for anim, frames in sprite_anim.items()
    ]))
    for name, sprite_anim in animated_sprites.items()
])
)
# print(gen_asset_handling_code())


with open('../source/sprites.d', 'w') as f:
    f.write(gen_asset_handling_code())




