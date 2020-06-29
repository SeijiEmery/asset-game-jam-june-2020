import raylib;
import std.exception: enforce;
import std.format: format;
import sprites;
import agj.ui;
import agj.sprite: Sprite, SpriteRenderer;
import agj.game.camera;
import agj.game.player;
import agj.game.utils;
import std.stdio;
import std.format: format;
import std.string: toStringz;
import agj.image_processing.palettize;


Vector2 toVector2 (Rectangle rectangle) {
	return Vector2(rectangle.x, rectangle.y);
}
Vector2 bottomLeft (Rectangle rectangle) {
	return Vector2(rectangle.x, rectangle.x + rectangle.height);
}
Vector2 topRight (Rectangle rectangle) {
	return Vector2(rectangle.x + rectangle.width, rectangle.x);
}



void main() {
	int screenWidth = 1920, screenHeight = 1080;
	InitWindow(screenWidth, screenHeight, "asset game jam");
	SetTargetFPS(60);

	Sprites.load(); // preload all sprites
 
	SpriteRenderer sprites;
	auto player = Player(sprites);
	auto cam = CameraController(player, screenWidth, screenHeight);

	// load visual target + feature map
	auto targetTexture = LoadTexture("assets/tiles/cavesofgallet.png");
	auto featureTexture = LoadTexture("assets/tiles/feature_map.png");
	auto exampleImageRect = Rectangle(
		0, 0, 
		featureTexture.width, featureTexture.height);

	// draw visual target w/ semi-transparent feature map overlaid on top
	sprites.create()
		.fromTexture(&targetTexture)
		.setPosition(exampleImageRect.toVector2)
	;
	sprites.create()
		.fromTexture(&featureTexture)
		.setDepth(10)
		.setAlpha(0.2)
		.setPosition(exampleImageRect.toVector2)
	;

	// convert into a palettized format for future processing
	auto palettizedTarget = targetTexture.palletize;
	auto palettizedFeatures = featureTexture.palletize;

	// draw reconstructed visual target + feature map from palettized versions
	auto reconstructedTargetTexture = palettizedTarget.toTexture;
	auto reconstructedFeatureTexture = palettizedFeatures.toTexture;

	auto reconstructedTextureDrawPos = exampleImageRect.topRight;
	reconstructedTextureDrawPos.x += 10;
	reconstructedTextureDrawPos.x *= -1;	// fix a weird bug causing this to be drawn in the wrong location...?
	sprites.create()
		.fromTexture(&reconstructedTargetTexture)
		.setPosition(reconstructedTextureDrawPos);
	sprites.create()
		.fromTexture(&reconstructedFeatureTexture)
		.setDepth(10)
		.setAlpha(0.2)
		.setPosition(reconstructedTextureDrawPos);
	reconstructedTextureDrawPos.x *= -1; 	// restore so we have correct coordinates after

	while (!WindowShouldClose()) {
		MouseUI.beginFrame();

		player.update();
		cam.update();

		BeginDrawing();
		ClearBackground(BLACK);
		auto camera = cam.camera;

		// draw sprites
		sprites.render(camera);

		// draw texture palettes
		Vector2 drawPalettes(Vector2 pos, int size) {
			pos.y += 1;
			palettizedTarget.palette.drawPalletteHorizontal(pos, Vector2(size, size));
			pos.y += size + 1;
			palettizedFeatures.palette.drawPalletteHorizontal(pos, Vector2(size, size));
			pos.y += size + 1;
			return pos;
		}

		BeginMode2D(camera);
		auto pos = drawPalettes(exampleImageRect.bottomLeft, 10);
		DrawText(format("palette size: %s, %s", 
			palettizedTarget.palette.colors.length,
			palettizedFeatures.palette.colors.length,
		).toStringz, cast(int)pos.x, cast(int)pos.y, 10, WHITE);
		
		DrawText("reconstructed texture".toStringz, cast(int)reconstructedTextureDrawPos.x, cast(int)reconstructedTextureDrawPos.y - 12, 10, WHITE);
		EndMode2D();

		EndDrawing();
	}
	CloseWindow();
}
