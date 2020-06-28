import raylib;
import std.exception: enforce;
import std.format: format;
import sprites;
import std.stdio;
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
	auto player = Player(sprites);
	auto cam = CameraController(player, screenWidth, screenHeight);
	auto tileEditor = new TileEditor();

	if (!IsGamepadAvailable(0)) {
		writefln("no gamepad present!!");
	}

	while (!WindowShouldClose()) {
		MouseUI.beginFrame();
		tileEditor.renderUI();

		player.update();
		cam.update();

		BeginDrawing();
		ClearBackground(BLACK);
		auto camera = cam.camera;

		// draw sprites
		sprites.render(camera);

		// draw UI
		tileEditor.render(camera);

		EndDrawing();
	}
	CloseWindow();
}
