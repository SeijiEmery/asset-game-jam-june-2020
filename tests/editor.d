import raylib;
import std.exception: enforce;
import std.format: format;
import std.c.stdlib: malloc, free, realloc;
import sprites;
import std.stdio;
import std.functional: toDelegate;
import std.string: toStringz;
import agj.ui;
import agj.sprite: Sprite, SpriteRenderer;
import agj.game.camera;
import agj.game.player;
import agj.game.utils;
import agj.tilemap;
import agj.editors.tile_layers: TileEditor;


void main() {
	int screenWidth = 1920, screenHeight = 1080;
	InitWindow(screenWidth, screenHeight, "asset game jam");
	SetTargetFPS(60);

	Sprites.load(); // preload all sprites
 
	SpriteRenderer sprites;
	int currentAnimation = 0;

	Sprites.Player.Roll.animationSpeed = 25;

	auto player = Player(sprites);

	Camera2D camera;
	camera.target = Vector2(0, 0);
	camera.zoom = 4;
	camera.rotation = 0;
	camera.offset = Vector2(screenWidth / 2, screenHeight / 2);
	CameraControllerState cameraControlState;

	auto tileEditor = new TileEditor();

	if (!IsGamepadAvailable(0)) {
		writefln("no gamepad present!!");
	}

	while (!WindowShouldClose()) {
		MouseUI.beginFrame();
		tileEditor.renderUI();

		player.update();
		camera.update(player, cameraControlState);

		BeginDrawing();
		
		ClearBackground(BLACK);

		// draw sprites
		sprites.render(camera);

		// draw UI
		tileEditor.render(camera);

		EndDrawing();
	}
	CloseWindow();
}
