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

	Texture2D tiles = LoadTexture("assets/tiles/cavesofgallet.png");
	//Texture2D tiles = LoadTexture("assets/tiles/tiles.png");

	GUIPanel panelTest;
	panelTest.position = Vector2(0, 0);
	panelTest.width = 200;

	auto tileEditor = new TileEditor();

	enum Test { Foo, Bar, Baz };
	Test testEnumValue;

	// test
	auto tree = sprites.create
		.fromAsset(Sprites.Tree01)
		.setPosition(Vector2(400, 200));

	if (!IsGamepadAvailable(0)) {
		writefln("no gamepad present!!");
	}

	while (!WindowShouldClose()) {
		MouseUI.beginFrame();

		//panelTest.beginUI();
		//panelTest.textRect("hello world!");
		//if (panelTest.button("click me!")) {

		//}
		//if (panelTest.horizontalSelectionToggle(testEnumValue)) {}
		//panelTest.endUI();

		tileEditor.renderUI();

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

		// draw sprites
		sprites.render(camera);

		// draw UI on top of everything else
		//panelTest.draw();
		tileEditor.render(camera);

		EndDrawing();
	}
	CloseWindow();
}