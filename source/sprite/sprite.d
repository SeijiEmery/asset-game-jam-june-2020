module agj.sprite.sprite;
public import agj.sprite.sprite_assets: SpriteAnimation, StaticSpriteAsset;
import raylib;
import std.stdio: writefln;
import std.functional: toDelegate;
import std.algorithm: sort;


struct SpriteRenderer {
    Sprite[] sprites;
    bool dirty = false;

    void render (ref Camera2D camera) {
        BeginMode2D(camera);

        if (dirty) {
            sprites.sort!((a,b) => a.depth > b.depth);
            dirty = false;
        }
        for (int i = cast(int)sprites.length; i --> 0; ) {
            if (sprites[i].destroyed) {
                sprites[i] = sprites[sprites.length - 1];
                --sprites.length;
                dirty = true;
            } else {
                sprites[i].draw();
            }
        }
        EndMode2D();
    }
    Sprite create (Args...)(Args args) {
        Sprite sprite = new Sprite(args);
        sprites ~= sprite;
        dirty = true;
        return sprite;
    }
}


class Sprite {
    private Texture*         activeSprite = null;
    private SpriteAnimation* activeAnimation = null;
    private Color            colorTint = WHITE;
    private double           animationStartTime = 0;
    private double           animationPlaybackSpeed = 10;
    private uint             animationCurrentFrame = 0;
    public Vector2           position = Vector2(0, 0);
    private bool             loopAnimation = false;
    public  bool             destroyed = false;
    private bool             flipX = false;
    private Vector2          centerOffset = Vector2(0, 0);
    public double            depth = 0;
    private void delegate(Sprite) onSpriteAnimationEnded;

    public @property bool    playing () { return activeAnimation != null; }

    this () {}
    this (ref StaticSpriteAsset sprite) {
        writefln("Set sprite");
        setSprite(sprite);
    }
    this (ref SpriteAnimation animation, bool loopAnimation = false) {
        playAnimation(animation, loopAnimation);
    }
    Sprite fromTexture(Texture* texture) {
        this.activeSprite = texture;
        this.activeAnimation = null;
        return this;
    }
    Sprite fromAsset (ref StaticSpriteAsset spriteAsset) { return this.setSprite(spriteAsset); }
    Sprite fromAsset (ref SpriteAnimation animation, bool loopAnimation = false) { return this.playAnimation(animation, loopAnimation); }

    Sprite setColorTint (Color color) {
        this.colorTint = color;
        return this;
    }
    Sprite setAlpha (double alpha) {
        import std.algorithm: clamp;
        this.colorTint.a = cast(ubyte)(255 * alpha.clamp(0, 1));
        return this;
    }
    Sprite setDepth (double depth) {
        this.depth = depth;
        return this;
    }
    Sprite setPosition (Vector2 position) {
        this.position = position;
        return this;
    }
    Sprite setPosition (int x, int y) {
        this.position = Vector2(x, y);
        return this;
    }
    Sprite setSprite(ref StaticSpriteAsset spriteAsset) {
        if (!spriteAsset.loaded) spriteAsset.load();
        activeSprite = &spriteAsset.sprite;
        activeAnimation = null;
        flipX = false;
        return this;
    }
    Sprite playAnimation(ref SpriteAnimation animation, bool loopAnimation = false) {
        if (!animation.loaded) animation.load();
        animationStartTime = GetTime();
        activeSprite = &animation.frames[0];
        activeAnimation = &animation;
        animationCurrentFrame = 0;
        flipX = false;
        this.loopAnimation = loopAnimation;
        return this;
    }
    Sprite setCenterOffset(Vector2 offset) {
        centerOffset = offset;
        return this;
    }
    Sprite onAnimationEnded(void function(Sprite) onSpriteAnimationEnded) {
        return onAnimationEnded(toDelegate(onSpriteAnimationEnded));
    }
    Sprite onAnimationEnded (void delegate(Sprite) onSpriteAnimationEnded) {
        this.onSpriteAnimationEnded = onSpriteAnimationEnded;
        return this;
    }
    Sprite setXFlipped (bool flipped) {
        flipX = !flipped;
        return this;
    }
    void draw() {
        if (activeAnimation) {
            auto elapsedTime = GetTime() - animationStartTime;
            auto currentFrame = elapsedTime * activeAnimation.animationSpeed;
            if (currentFrame < 0) currentFrame = 0;

            animationCurrentFrame = cast(uint)currentFrame;
            if (animationCurrentFrame >= activeAnimation.frames.length) {
                animationCurrentFrame = 0;
                if (loopAnimation) {
                    animationStartTime = GetTime();
                } else {
                    activeSprite = &activeAnimation.frames[animationCurrentFrame];
                    activeAnimation = null;
                }
                if (onSpriteAnimationEnded) {
                    onSpriteAnimationEnded(this);
                }
            }
            if (activeAnimation) {
                activeSprite = &activeAnimation.frames[animationCurrentFrame];
            }   
        }
        if (activeSprite) {
            auto w = activeSprite.width, h = activeSprite.height;
            auto srcRect = Rectangle(0, 0, w, h);
            auto dstRect = srcRect;

            Vector2 pos = position;
            if (flipX) {
                srcRect.w = -w;
                dstRect.x = -dstRect.x;
                pos.x += centerOffset.x;
            } else {
                pos.x -= centerOffset.x;
            }
            DrawTexturePro(*activeSprite, srcRect, dstRect, pos, 0, colorTint);
            //DrawRectangleLines(-cast(int)position.x, -cast(int)position.y, cast(int)w, cast(int)h, WHITE);
        }
    }
    void destroy () { destroyed = true; writefln("destroying sprite!!"); }
}
