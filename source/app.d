import raylib;
version = BindBC_Static;
//import bindbc.nuklear;
import std.exception: enforce;
import std.format: format;
import std.c.stdlib: malloc, free, realloc;
import sprites;
import std.stdio;
import std.functional: toDelegate;
import std.string: toStringz;


class Sprite {
	private Texture* 		 activeSprite = null;
	private SpriteAnimation* activeAnimation = null;
	private double 		     animationStartTime = 0;
	private double 			 animationPlaybackSpeed = 10;
	private uint 			 animationCurrentFrame = 0;
	public Vector2 		 	 position = Vector2(0, 0);
	private bool  		     loopAnimation = false;
	private bool 		     destroyed = false;
	private bool 		     flipX = false;
	private Vector2 	     centerOffset = Vector2(0, 0);
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
			DrawTexturePro(*activeSprite, srcRect, dstRect, pos, 0, WHITE);
			//DrawRectangleLines(-cast(int)position.x, -cast(int)position.y, cast(int)w, cast(int)h, WHITE);
		}
	}
	void destroy () { destroyed = true; writefln("destroying sprite!!"); }
}


struct SpriteRenderer {
	Sprite[] sprites;

	void render (ref Camera2D camera) {
		BeginMode2D(camera);		
		for (int i = cast(int)sprites.length; i --> 0; ) {
			if (sprites[i].destroyed) {
				sprites[i] = sprites[sprites.length - 1];
				--sprites.length;
			} else {
				sprites[i].draw();
			}
		}
		EndMode2D();
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

struct CameraControllerState {
	bool followPlayer;
	bool isDraggingCamera;
	Vector2 dragStartPos;
}



// update camera controls
void update (ref Camera2D camera, ref Player player, ref CameraControllerState state) {
	double dt = GetFrameTime();

	// camera controls
	auto prevZoom = camera.zoom;
	if (IsGamepadAvailable(0)) {
		camera.zoom += GetFrameTime() * 5.0 * (
			GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_TRIGGER) -
			GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_LEFT_TRIGGER)
		);

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
			camera.target = player.sprite.position;
		}
		if (IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_THUMB)) {
			state.followPlayer = !state.followPlayer;
		}
	}

	camera.zoom += GetFrameTime() * GetMouseWheelMove() * 3;

	if (camera.zoom > 10) camera.zoom = 10;
	if (camera.zoom < 0.5) camera.zoom = 0.5;
	if (camera.zoom != prevZoom) writefln("set zoom %s", camera.zoom);		


	if (MouseUI.beginDrag(
		MouseButton.MOUSE_MIDDLE_BUTTON, 
		delegate () {
			writefln("drag movement: %s %s", GetMouseX() - state.dragStartPos.x, GetMouseY() - state.dragStartPos.y);
			camera.target.x += (state.dragStartPos.x - GetMouseX()) / camera.zoom;
			camera.target.y += (state.dragStartPos.y - GetMouseY()) / camera.zoom;
			state.dragStartPos = Vector2(GetMouseX(), GetMouseY());
		},
		delegate () {
			writefln("stop drag");
			state.isDraggingCamera = false;
		}
	)) {
		writefln("start drag");
		state.isDraggingCamera = true;
		state.dragStartPos = Vector2(GetMouseX(), GetMouseY());
	}

	//writefln("camera target: %s", camera.target);
	if (state.followPlayer) {
		camera.target.lerpTo(Vector2(
			-player.sprite.position.x,
			-player.sprite.position.y), dt * 4);
	}
}

// update player controls
void update (ref Player player) {
	import std.math;
	double moveInput = 0;
	double dt = GetFrameTime();
	bool dodgeRollPressed = false;
	bool jumpPressed = false;
	bool attackPressed = false;

	if (IsGamepadAvailable(0)) {
		moveInput -= GetStickInput(0, GamepadAxis.GAMEPAD_AXIS_LEFT_X);
		if (IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_RIGHT)) {
			dodgeRollPressed = true;
		}
		if (IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN)) {
			jumpPressed = true;
		}
		if (IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_LEFT)) {
			attackPressed = true;
		}
	}

	bool moving = moveInput.abs > 0;
	
	if (moving && !player.inAttackAnim) {
		player.lastMoveDir = moveInput >= 0 ? 1 : -1;
	}

	if (dodgeRollPressed && !player.inAttackAnim) {
		player.inDodgeRollAnim = true;
		player.sprite.playAnimation(Sprites.Player.Roll);
		player.dodgeRollDirection = player.lastMoveDir;
		player.sprite.setXFlipped(player.dodgeRollDirection < 0);
		writefln("starting dodge roll");
	}

	if (attackPressed && !player.inDodgeRollAnim && !player.inAttackAnim) {
		player.inAttackAnim = true;
		import std.random;
		final switch (std.random.dice(20, 30, 30, 20)) {
			case 0: player.sprite.playAnimation(Sprites.Player.Attack01); break;
			case 1: player.sprite.playAnimation(Sprites.Player.Attack02); break;
			case 2: player.sprite.playAnimation(Sprites.Player.Attack03); break;
			case 3: player.sprite.playAnimation(Sprites.Player.AttackHard); break;
		}
	}

	if (player.inDodgeRollAnim) {
		player.sprite.position.x += player.dodgeRollDirection * dt * 300;
	} else {
		if (moving != player.wasMoving) {
			player.wasMoving = moving;

			if (!player.inAttackAnim) {
				if (moving) player.sprite.playAnimation(Sprites.Player.Run, true);
				else player.sprite.playAnimation(Sprites.Player.Idle, true);
			}
		}
		player.sprite.setXFlipped(player.lastMoveDir < 0);
		if (moving) {
			player.sprite.position.x += moveInput * dt * 150;
		}
		player.sprite.position.y -= GetStickInput(0, GamepadAxis.GAMEPAD_AXIS_LEFT_Y) * dt * 150;
	}
	player.sprite.setCenterOffset(Vector2(5, 0));
}

struct Player {
	Sprite sprite;
	int nextAnimation = 0;
	bool wasMoving = false;
	double lastMoveDir = 1;
	bool inDodgeRollAnim = false;
	bool inAttackAnim = false;
	double dodgeRollDirection = 1;

	this (ref SpriteRenderer renderer) {
		sprite = renderer.create
			.fromAsset(Sprites.Player.Idle, false)
			.setPosition(Vector2(0, 0))
			.onAnimationEnded(&this.onAnimationEnded)
			.setCenterOffset(Vector2(10, 0))
		;
	}
	void onAnimationEnded (Sprite sprite) {
		if (inDodgeRollAnim) {
			writefln("ending dodge roll");
			inDodgeRollAnim = false;
		}
		if (inAttackAnim) {
			inAttackAnim = false;
			sprite.playAnimation(Sprites.Player.StopAttack, false);
		}
		if (!sprite.playing) {
			sprite.playAnimation(Sprites.Player.Idle, true);
		}
			//final switch (animation % 17) {
			//	case 0: return Sprites.Player.Idle;
			//	case 1: return Sprites.Player.HitwSword;
			//	case 2: return Sprites.Player.Attack03;
			//	case 3: return Sprites.Player.TakeSword;
			//	case 4: return Sprites.Player.Roll;
			//	case 5: return Sprites.Player.Hit;
			//	case 6: return Sprites.Player.Attack02;
			//	case 7: return Sprites.Player.Death;
			//	case 8: return Sprites.Player.PutAwaySword;
			//	case 9: return Sprites.Player.RollSword;
			//	case 10: return Sprites.Player.RunwSword;
			//	case 11: return Sprites.Player.StopAttack;
			//	case 12: return Sprites.Player.Parry;
			//	case 13: return Sprites.Player.AttackHard;
			//	case 14: return Sprites.Player.Attack01;
			//	case 15: return Sprites.Player.Run;
			//	case 16: return Sprites.Player.ParryWithoutHit;
			//	case 17: return Sprites.Player.IdlewSword;
			//}
	}	
}

enum TileLayerFlag : ubyte {
	Write 		= 1 << 0,
	Wall 		= 1 << 1,
	Ladder 		= 1 << 2,
	Water 		= 1 << 3,
	Platform 	= 1 << 4,
	Support 	= 1 << 5,
}

enum TileLayer {
	None, Air, Wall, Ladder, Fluid, FluidStream, Platform, PlatformSupport, Vegetation,
}

struct AABB(T) {
	T minBoundX, maxBoundX;
	T minBoundY, maxBoundY;
	bool initialized = false;

	void grow (T x, T y) {
		if (!initialized) {
			initialized = true;
			minBoundX = maxBoundX = x;
			minBoundY = maxBoundY = y;
		} else {
			if (x < minBoundX) minBoundX = x;
			if (x > maxBoundX) maxBoundX = x;
			if (y < minBoundY) minBoundY = y;
			if (y > maxBoundY) maxBoundY = y;
		}
	}
}



// 64 x 64 chunks
struct TileChunk(T = ubyte) {
	T[4096] data;
	AABB!uint bounds;

	ref T get (uint i, uint j) {
		enforce(i < 64 && j < 64, format("indices out of range: %s, %s", i, j));
		bounds.grow(i, j);
		return data[i + j * 64];
	}
}

struct TileIndex { int x; int y; }

class TileMap(T = ubyte) {
	private TileChunk!T[TileIndex] chunks;
	public AABB!int bounds;
	public AABB!int chunkBounds;

	private ref TileChunk!T getChunk (TileIndex index) {
		//writefln("getting chunk %s", index);
		if (index !in chunks) {
			chunkBounds.grow(index.x, index.y);
			chunks[index] = TileChunk!T();
		}
		return chunks[index];
	}
	ref T get (int i, int j) {
		bounds.grow(i, j);

		auto chunkIndex = TileIndex(i >> 6, j >> 6);
		auto tileIndex  = TileIndex(i & 63, j & 63);

		//writefln("tile access: %s %s => %s %s", i, j, chunkIndex, tileIndex);
		
		return getChunk(chunkIndex).get(cast(uint)tileIndex.x, cast(uint)tileIndex.y);
	}
	void getTileBoundsFromScreenCoords(Rectangle screen, ref const(Camera2D) camera, out TileIndex minima, out TileIndex maxima) {
		if (!bounds.initialized) {
			minima = maxima = TileIndex(0, 0);
		}

		minima = screenToTileCoords(Vector2(screen.x, screen.y), camera);
		if (minima.x > bounds.minBoundX) minima.x = bounds.minBoundX;
		if (maxima.x < bounds.maxBoundX) maxima.x = bounds.maxBoundX;
		if (minima.y > bounds.minBoundY) minima.y = bounds.minBoundY;
		if (maxima.y < bounds.maxBoundY) maxima.y = bounds.maxBoundY;
		maxima = screenToTileCoords(Vector2(screen.x + screen.width, screen.y + screen.y), camera);
	}
}

Vector2 tileToWorldCoords (TileIndex index) {
	return Vector2(index.x * 8.0, index.y * 8.0);
}
Vector2 tileToScreenCoords (TileIndex index, ref const(Camera2D) camera) {
	return GetWorldToScreen2D(tileToWorldCoords(index), camera);
}
TileIndex worldToTileCoords (Vector2 worldPos) {
	return TileIndex(cast(int)(worldPos.x / 8), cast(int)(worldPos.y / 8));
}
TileIndex screenToTileCoords (Vector2 screenPos, ref const(Camera2D) camera) {
	return worldToTileCoords(GetScreenToWorld2D(screenPos, camera));
}

class TileRenderer {
	private Texture2D 		texture;
	private size_t 	  		tileCount;
	private auto   			roomLayerMap  = new TileMap!TileLayer();
	private auto 			drawnTileMap  = new TileMap!ubyte();

	this () { 
		texture = LoadTexture("assets/tiles/tiles.png");
		tileCount = (texture.width / 8) * (texture.height / 8);
		writefln("loaded tileset: %s x %s (%s tiles x %s tiles = %s tiles)", 
			texture.width, texture.height,
			texture.width / 8, texture.height / 8,
			texture.width * texture.height / 64);
	}

	void render (Camera2D camera) {
		const int FOREGROUND_BACKGROUND_SCALE = 2;
		camera.zoom *= FOREGROUND_BACKGROUND_SCALE;
		camera.target.x /= FOREGROUND_BACKGROUND_SCALE;
		camera.target.y /= FOREGROUND_BACKGROUND_SCALE;

		auto mousePos = Vector2(GetMouseX(), GetMouseY());
		auto selectedTile = mousePos.screenToTileCoords(camera);

		string msg = format("mouse pos: %s %s", mousePos.x, mousePos.y);
		auto worldPos = GetScreenToWorld2D(mousePos, camera);
		msg ~= format("\nworld pos: %s %s", worldPos.x, worldPos.y);
		msg ~= format("\ntile pos: %s %s", selectedTile.x, selectedTile.y);

		auto tileWorldPos = selectedTile.tileToWorldCoords();
		msg ~= format("\nworld pos: %s %s", tileWorldPos.x, tileWorldPos.y);

		auto tileScreenPos = selectedTile.tileToScreenCoords(camera);
		msg ~= format("\nscreen pos: %s %s", tileScreenPos.x, tileScreenPos.y);

		auto fixedTilePos = TileIndex(1, 1).tileToWorldCoords();
		msg ~= format("\nworld coords of tile (1,1): %s %s", fixedTilePos.x, fixedTilePos.y);


		// do tile edits (okay, shouldn't really be in a render function, but whatever...)
		if (MouseUI.buttonDown(MouseButton.MOUSE_LEFT_BUTTON)) {
			roomLayerMap.get(selectedTile.x, selectedTile.y) = TileLayer.Wall;
		} else if (MouseUI.buttonDown(MouseButton.MOUSE_RIGHT_BUTTON)) {
			roomLayerMap.get(selectedTile.x, selectedTile.y) = TileLayer.None;
		}

		BeginMode2D(camera);

		// draw tile layers
		TileIndex i0, i1;
		roomLayerMap.getTileBoundsFromScreenCoords(Rectangle(0, 1080, 1920, 1080), camera, i0, i1);

		msg ~= format("\ngot bounds: %s %s", i0, i1);
		msg ~= format("\nbounds: %s", roomLayerMap.bounds);
		msg ~= format("\nchunk bounds: %s", roomLayerMap.chunkBounds);

		for (int i = i0.x; i < i1.x; ++i) {
			for (int j = i0.y; j < i1.y; ++j) {
				auto tile = roomLayerMap.get(i, j);
				switch (tile) {
					case TileLayer.Wall: DrawRectangleV(tileToWorldCoords(TileIndex(i, j)), Vector2(8, 8), PURPLE); break;
					case TileLayer.Air: DrawRectangleV(tileToWorldCoords(TileIndex(i, j)), Vector2(8, 8), LIME); break;
					default:
				}
			}
		}
		auto w0 = i0.tileToWorldCoords;
		auto w1 = i1.tileToWorldCoords;
		DrawRectangleLinesEx(Rectangle(w0.x, w0.y, w1.x - w0.x, w1.y - w0.y), 1, WHITE);

		// draw tile debug
		auto tilePos = selectedTile.tileToWorldCoords();
		DrawRectangleV(tilePos, Vector2(8, 8), ORANGE);
		DrawRectangleV(fixedTilePos, Vector2(8, 8), GREEN);

		// draw pixel debug
		DrawRectangleV(Vector2(cast(double)cast(int)worldPos.x, cast(double)cast(int)worldPos.y), Vector2(1, 1), RED);

		EndMode2D();

		DrawText(msg.toStringz, 0, 0, 16, GOLD);

	}

}

struct MouseUI {
	enum Result { None, Mouseover, Pressed, BeginDrag }
	private static bool 		   handled = false;
	private static bool 		   dragActive = false;
	private static MouseButton 	   activeDragButton;
	private static void delegate() onDragUpdate;
	private static void delegate() onDragEnd;

	public static void beginFrame() {
		handled = false;
		if (dragActive && IsMouseButtonUp(activeDragButton)) {
			if (onDragEnd) onDragEnd();
			dragActive = false;
		} else if (dragActive) {
			if (onDragUpdate) onDragUpdate();
			handled = true;
		}
	}
	public static Result pressed (MouseButton button) {
		if (handled) return Result.None;
		if (IsMouseButtonPressed(button)) {
			handled = true;
			return Result.Pressed;
		}
		return Result.None;
	}
	public static Result buttonDown (MouseButton button) {
		return !handled && IsMouseButtonDown(button) ? Result.Pressed : Result.None;
	}
	public static Result pressedOver (MouseButton button, Rectangle screenRect) {
		if (handled) return Result.None;
		if (!CheckCollisionPointRec(Vector2(GetMouseX(), GetMouseY()), screenRect)) return Result.None;
		auto result = pressed(button);
		if (result == Result.None) { handled = true; return Result.Mouseover; }
		return result;
	}
	public static Result beginDrag (MouseButton button, void delegate() onUpdate, void delegate() onEnd) {
		if (handled) return Result.None;
		if (IsMouseButtonPressed(button)) {
			handled = dragActive = true;
			activeDragButton = button;
			onDragUpdate = onUpdate;
			onDragEnd = onEnd;
			return Result.BeginDrag;
		}
		return Result.None;
	}
	public static Result beginDragOver (MouseButton button, Rectangle screenRect, void delegate() onUpdate, void delegate() onEnd) {
		if (handled) return Result.None;
		if (!CheckCollisionPointRec(Vector2(GetMouseX(), GetMouseY()), screenRect)) return Result.None;
		auto result = beginDrag(button, onUpdate, onEnd);
		if (result == Result.None) { handled = true; return Result.Mouseover; }
		return result;
	}
}

void lighten (ref Color color, ubyte amount = 10, ubyte max = 255) {
	if (cast(uint)color.r + amount < ubyte.max) color.r += amount; else color.r = ubyte.max;
	if (cast(uint)color.g + amount < ubyte.max) color.g += amount; else color.g = ubyte.max;
	if (cast(uint)color.b + amount < ubyte.max) color.b += amount; else color.b = ubyte.max;
}

struct GUIPanel {
	public Vector2 	position = Vector2(0, 0);
	public int 		width = 0;
	private Rectangle layout;
	private GUIRect[] elements;
	private Vector2   dragStartPos = Vector2(0, 0);
	public bool moveable = true;
	private bool hasMouseover = false;
	public Color color = GRAY;

	public void beginUI () {
		layout.x = position.x + 6;
		layout.y = position.y + 24;
		layout.width = width - 12;
		layout.height = 30;
		elements.length = 0;
		hasMouseover = false;
	}
	public void endUI () {
		layout.x = position.x;
		layout.y = position.y;
		layout.width = width;
		if (moveable) {
			switch (MouseUI.beginDragOver(MouseButton.MOUSE_LEFT_BUTTON, layout, &updateDrag, null)) {
				case MouseUI.Result.BeginDrag: dragStartPos = Vector2(GetMouseX(), GetMouseY()); break;
				case MouseUI.Result.Mouseover: hasMouseover = true; break;
				default:
			}
		}
	}
	private void updateDrag() {
		position.x += GetMouseX() - dragStartPos.x;
		position.y += GetMouseY() - dragStartPos.y;
		dragStartPos = Vector2(GetMouseX(), GetMouseY());
	}
	public Rectangle textRect (string text, Color textColor = WHITE, Color backgroundColor = BLACK) {
		Rectangle rect = layout;
		rect.height = 25;
		layout.y += 32;
		layout.height += 28;
		elements ~= GUIRect(text, rect, textColor, backgroundColor);
		return rect;
	}
	public bool button (string text, Color textColor = WHITE, Color backgroundColor = BLACK) {
		auto rect = textRect(text, textColor, backgroundColor);
		switch (MouseUI.pressedOver(MouseButton.MOUSE_LEFT_BUTTON, rect)) {
			case MouseUI.Result.Pressed:
				lighten(elements[$-1].backgroundColor, 10);
				return true;
			case MouseUI.Result.Mouseover:
				lighten(elements[$-1].backgroundColor, 30);
				return false;
			default:
				return false;
		}
	}
	public void draw() {
		Color tempColor = color;
		if (hasMouseover) lighten(tempColor, 30);
		DrawRectangleRec(layout, tempColor);
		foreach (element; elements) {
			DrawRectangleRec(element.rect, element.backgroundColor);

			int textWidth = MeasureText(element.text.toStringz, 16);
			int width = cast(int)element.rect.width - 8;
			int excessHalfWidth = width > textWidth ? (width - textWidth) / 2 : 0;
			DrawText(element.text.toStringz, cast(int)element.rect.x + 4 + excessHalfWidth, cast(int)element.rect.y + 4, 16, element.textColor);
		}
	}
}

struct GUIRect {
	string 			text;
	Rectangle 		rect;
	Color 			textColor;
	Color 			backgroundColor;
}


void main() {
	int screenWidth = 1920, screenHeight = 1080;
	InitWindow(screenWidth, screenHeight, "asset game jam");
	SetTargetFPS(60);

	Sprites.load(); // preload all sprites
 

	SpriteRenderer sprites;
	int currentAnimation = 0;

	auto tileRenderer = new TileRenderer();


	Sprites.Player.Roll.animationSpeed = 25;

	auto player = Player(sprites);

	Camera2D camera;
	camera.target = Vector2(0, 0);
	camera.zoom = 4;
	camera.rotation = 0;
	camera.offset = Vector2(screenWidth / 2, screenHeight / 2);
	CameraControllerState cameraControlState;

	Texture2D tiles = LoadTexture("assets/tiles/cavesofgallet.png");
	//Texture2D tiles = LoadTexture("assets/tiles/tiles.png");

	GUIPanel panelTest;
	panelTest.position = Vector2(0, 0);
	panelTest.width = 200;

	// test
	auto tree = sprites.create
		.fromAsset(Sprites.Tree01)
		.setPosition(Vector2(400, 200));

	if (!IsGamepadAvailable(0)) {
		writefln("no gamepad present!!");
	}

	while (!WindowShouldClose()) {
		MouseUI.beginFrame();

		panelTest.beginUI();
		panelTest.textRect("hello world!");
		if (panelTest.button("click me!")) {

		}
		panelTest.endUI();

		player.update();
		camera.update(player, cameraControlState);

		// sprite destruction test
		if (IsGamepadAvailable(0) && IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_UP)) {
			tree.destroy();
		}
		
		BeginDrawing();
		ClearBackground(BLACK);
		//ClearBackground(RAYWHITE);
		
		// draw non-scaled user interface elements
		DrawText("Hello, World!", 400, 300, 28, BLACK);
		
		// draw background...?
		Camera2D backgroundCam = camera;

		//const int FOREGROUND_BACKGROUND_SCALE = 2;
		//backgroundCam.zoom *= FOREGROUND_BACKGROUND_SCALE;
		//backgroundCam.target.x /= FOREGROUND_BACKGROUND_SCALE;
		//backgroundCam.target.y /= FOREGROUND_BACKGROUND_SCALE;
		//BeginMode2D(backgroundCam);
		//DrawTexture(tiles, 0, 0, WHITE);
		//EndMode2D();

		tileRenderer.render(camera);

		// draw sprites
		sprites.render(camera);

		// draw UI on top of everything else
		panelTest.draw();

		EndDrawing();
	}
	CloseWindow();
}