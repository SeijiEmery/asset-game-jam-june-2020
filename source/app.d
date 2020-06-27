import raylib;
version = BindBC_Static;
//import bindbc.nuklear;
import std.exception: enforce;
import std.format: format;
import std.c.stdlib: malloc, free, realloc;
import sprites;
import std.stdio;
import std.functional: toDelegate;

//extern(C) void* nkAlloc (nk_handle handle, void* ptr, size_t size) nothrow @nogc {
//	return ptr ? malloc(size) : realloc(ptr, size);
//}
//extern(C) void nkFree (nk_handle, void* ptr) nothrow @nogc {
//	free(ptr);
//}

//struct NkInit {
//	nk_context context;
//	nk_allocator allocator;
//	nk_font_atlas atlas;
//	void[] memory;
//	this(this) {
//		version(BindNuklear_Static){}
//		else {
//			NuklearSupport support = loadNuklear();
//			enforce(support == NuklearSupport.Nuklear4,
//				format("expected %s, got %s",
//					NuklearSupport.Nuklear4,
//					support));
//		}
//		allocator.alloc = &nkAlloc;
//		allocator.free = &nkFree;
//		nk_font_atlas_init_default(&atlas);		
//		nk_font_atlas_begin(&atlas);
//		nk_font_atlas_add_from_file(&atlas, "assets/fonts/Calibri.ttf", 13, 0);
//		const void* img = nk_font_atlas_bake(&atlas, &img_width, &img_height, NK_FONT_ATLAS_RGBA32);
//		nk_font_atlas_end(&atlas);	
//		nk_init(&context, &allocator, atlas);
//	}
//	~this() {

//	}
//}

class Sprite {
	private Texture* 		 activeSprite = null;
	private SpriteAnimation* activeAnimation = null;
	private double 		     animationStartTime = 0;
	private double 			 animationPlaybackSpeed = 10;
	private uint 			 animationCurrentFrame = 0;
	public Vector2 		 	 position = Vector2(0, 0);
	private bool  		     loopAnimation = false;
	private bool 		     destroyed = false;
	private void delegate(Sprite) onSpriteAnimationEnded;

	public @property bool 	 playing () { return activeAnimation != null; }

	this () {}
	this (ref StaticSpriteAsset sprite) {
		writefln("Set sprite");
		setSprite(sprite);
	}
	this (ref SpriteAnimation animation, bool loopAnimation = false) {
		playAnimation(animation, loopAnimation);
	}
	Sprite fromAsset (ref StaticSpriteAsset spriteAsset) { return this.setSprite(spriteAsset); }
	Sprite fromAsset (ref SpriteAnimation animation, bool loopAnimation = false) { return this.playAnimation(animation, loopAnimation); }

	Sprite setPosition (Vector2 position) {
		this.position = position;
		return this;
	}
	Sprite setSprite(ref StaticSpriteAsset spriteAsset) {
		if (!spriteAsset.loaded) spriteAsset.load();
		activeSprite = &spriteAsset.sprite;
		activeAnimation = null;
		return this;
	}
	Sprite playAnimation(ref SpriteAnimation animation, bool loopAnimation = false) {
		if (!animation.loaded) animation.load();
		animationStartTime = GetTime();
		activeSprite = &animation.frames[0];
		activeAnimation = &animation;
		animationCurrentFrame = 0;
		this.loopAnimation = loopAnimation;
		return this;
	}
	Sprite onAnimationEnded(void function(Sprite) onSpriteAnimationEnded) {
		return onAnimationEnded(toDelegate(onSpriteAnimationEnded));
	}
	Sprite onAnimationEnded (void delegate(Sprite) onSpriteAnimationEnded) {
		this.onSpriteAnimationEnded = onSpriteAnimationEnded;
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
					activeAnimation = null;
				}
				if (onSpriteAnimationEnded) {
					onSpriteAnimationEnded(this);
				}
			}
			activeSprite = &activeAnimation.frames[animationCurrentFrame];
		}
		if (activeSprite) {
			DrawTexture(*activeSprite, cast(int)position.x, cast(int)position.y, WHITE);
		}
	}
	void destroy () { destroyed = true; writefln("destroying sprite!!"); }
}


struct SpriteRenderer {
	Sprite[] sprites;

	void render () {
		for (int i = cast(int)sprites.length; i --> 0; ) {
			if (sprites[i].destroyed) {
				sprites[i] = sprites[sprites.length - 1];
				--sprites.length;
			} else {
				sprites[i].draw();
			}
		}
	}
	Sprite create (Args...)(Args args) {
		Sprite sprite = new Sprite(args);
		sprites ~= sprite;
		return sprite;
	}
}


void main() {
	InitWindow(1920, 1080, "Hello, Raylib-D!");
	Sprites.load();

	SpriteRenderer sprites;
	int currentAnimation = 0;

	ref SpriteAnimation getPlayerAnimation (int animation) {
		final switch (animation % 17) {
			case 0: return Sprites.Player.Idle;
			case 1: return Sprites.Player.HitwSword;
			case 2: return Sprites.Player.Attack03;
			case 3: return Sprites.Player.TakeSword;
			case 4: return Sprites.Player.Roll;
			case 5: return Sprites.Player.Hit;
			case 6: return Sprites.Player.Attack02;
			case 7: return Sprites.Player.Death;
			case 8: return Sprites.Player.PutAwaySword;
			case 9: return Sprites.Player.RollSword;
			case 10: return Sprites.Player.RunwSword;
			case 11: return Sprites.Player.StopAttack;
			case 12: return Sprites.Player.Parry;
			case 13: return Sprites.Player.AttackHard;
			case 14: return Sprites.Player.Attack01;
			case 15: return Sprites.Player.Run;
			case 16: return Sprites.Player.ParryWithoutHit;
			case 17: return Sprites.Player.IdlewSword;
		}
	}

	auto playerSprite = sprites.create
		.fromAsset(Sprites.Player.Idle)
		.setPosition(Vector2(500, 400))
		.onAnimationEnded(delegate (sprite) { 
			sprite.playAnimation(getPlayerAnimation(++currentAnimation));
		});

	auto tree = sprites.create
		.fromAsset(Sprites.Tree01)
		.setPosition(Vector2(400, 200));

	while (!WindowShouldClose()) {
		BeginDrawing();
		ClearBackground(RAYWHITE);
		DrawText("Hello, World!", 400, 300, 28, BLACK);
		sprites.render();
		EndDrawing();
		if (!IsGamepadAvailable(0)) {
			writefln("no gamepad present!!");
		}

		if (IsGamepadAvailable(0) && IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_UP)) {
			tree.destroy();
		}
	}
	CloseWindow();
}