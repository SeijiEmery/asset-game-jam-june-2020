module agj.sprite.sprite_assets;
import raylib;
import std.string: toStringz;
import std.algorithm: map;
import std.array: array;


struct SpriteAnimation {
    string[]    paths;
    Texture[]   frames = null;
    float       animationSpeed = 1f;

    this (float animationSpeed, string[] paths) { 
        this.animationSpeed = animationSpeed; 
        this.paths = paths;
    }

    @property bool loaded () { return frames != null; }
    @property size_t resourceCount () { return paths.length; }

    void load () {
        frames = paths.map!((path) => LoadTexture(path.toStringz)).array;
    }
}

struct StaticSpriteAsset {
    string          path;
    Texture         sprite;
    private bool    isLoaded = false;

    this (string path) { this.path = path; }

    @property bool loaded () { return isLoaded; }
    @property size_t resourceCount () { return 1; }    

    void load() {
        sprite = LoadTexture(path.toStringz);
        isLoaded = true;
    }
}
