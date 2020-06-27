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

Vector2 lerp (Vector2 a, Vector2 b, double t) {
	if (t < 0) t = 0;
	if (t > 1) t = 1;
	return Vector2(
		a.x * (1 - t) + b.x * t,
		a.y * (1 - t) + b.y * t
	);
}
ref Vector2 lerpTo (ref Vector2 a, Vector2 b, double t) {
	return a = lerp(a, b, t);
}


void main() {
	int screenWidth = 1920, screenHeight = 1080;

	InitWindow(screenWidth, screenHeight, "Hello, Raylib-D!");
	SetTargetFPS(60);

	Sprites.load(); // preload all sprites

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
		.setPosition(Vector2(0, 0))
		.onAnimationEnded(delegate (sprite) { 
			sprite.playAnimation(getPlayerAnimation(++currentAnimation));
		});

	auto tree = sprites.create
		.fromAsset(Sprites.Tree01)
		.setPosition(Vector2(400, 200));

	Camera2D camera;
	camera.target = Vector2(0, 0);
	camera.zoom = 4;
	camera.rotation = 0;
	camera.offset = Vector2(screenWidth / 2, screenHeight / 2);

	bool followPlayer = false;

	while (!WindowShouldClose()) {

		double dt = GetFrameTime();

		// camera controls
		if (IsGamepadAvailable(0)) {
			auto prevZoom = camera.zoom;
			camera.zoom += GetFrameTime() * 5.0 * (
				GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_TRIGGER) -
				GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_LEFT_TRIGGER)
			);
			if (camera.zoom > 10) camera.zoom = 10;
			if (camera.zoom < 0.5) camera.zoom = 0.5;
			if (camera.zoom != prevZoom) writefln("set zoom %s", camera.zoom);


			double GetStickInput(int gamepad, GamepadAxis axis) {
				import std.math;
				double x = GetGamepadAxisMovement(0, axis);
				double sign = x >= 0 ? +1 : -1;
				//if (axis == GamepadAxis.GAMEPAD_AXIS_LEFT_Y || axis == GamepadAxis.GAMEPAD_AXIS_RIGHT_Y) {
				//	sign = -sign;
				//}
				x = pow(abs(x), 2.3);
				return x > 2.5e-2 ? x * sign : 0;
			}

			camera.target.x += dt * 1000 / camera.zoom * GetStickInput(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_X);
			camera.target.y += dt * 1000 / camera.zoom * GetStickInput(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_Y);

			//writefln("LS.X %s => %s LS.Y %s => %s RS.X %s => %s RS.Y %s => %s",
			//	GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_LEFT_X),
			//	GetStickInput(0, GamepadAxis.GAMEPAD_AXIS_LEFT_X),
			//	GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_LEFT_Y),
			//	GetStickInput(0, GamepadAxis.GAMEPAD_AXIS_LEFT_Y),
			//	GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_X),
			//	GetStickInput(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_X),
			//	GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_Y),
			//	GetStickInput(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_Y),
			//);

			//writefln("LS.X %s LS.Y %s RS.X %s RS.Y %s",
			//	GetStickInput(0, GamepadAxis.GAMEPAD_AXIS_LEFT_X),
			//	GetStickInput(0, GamepadAxis.GAMEPAD_AXIS_LEFT_Y),
			//	GetStickInput(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_X),
			//	GetStickInput(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_Y),
			//);

			if (IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_THUMB)) {
				camera.target = playerSprite.position;
			}
			if (IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_THUMB)) {
				followPlayer = !followPlayer;
			}
		}
		//writefln("camera target: %s", camera.target);
		if (followPlayer) {
			camera.target.lerpTo(Vector2(
				playerSprite.position.x,
				playerSprite.position.y), dt * 4);
		}
		
		BeginDrawing();
		
		ClearBackground(RAYWHITE);
		DrawText("Hello, World!", 400, 300, 28, BLACK);
		
		BeginMode2D(camera);
		sprites.render();
		EndMode2D();
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