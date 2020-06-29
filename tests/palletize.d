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
import std.algorithm: map;
import std.array: array;


struct Palette(T = ubyte) {
	Color[] colors;

	T encode (Color color) {
		foreach (i, c; colors) {
			if (c == color) {
				return cast(T)i;
			}
		}
		colors ~= color;
		return cast(T)(colors.length - 1);
	}
	Color decode (T value) const {
		size_t index = value;
		return index < colors.length ? 
			colors[index] : MAGENTA;
	}
}
struct PalettizedTexture(T = ubyte) {
	Palette!T palette;
	T[] 	data;
	size_t 	width;
	size_t  height;

	ref T get (size_t i, size_t j) {
		return data[i + j * width];
	}
}

PalettizedTexture!ubyte palletize (ref const(Texture2D) texture) {
	return texture.GetTextureData.palletize;
}
PalettizedTexture!ubyte palletize (Image image) {
	size_t w = image.width, h = image.height;
	Palette!ubyte palette;
	ubyte[] data = image.GetImageData[0..w*h]
		.map!((color) => palette.encode(color))
		.array;
	return PalettizedTexture!ubyte(palette, data, w, h);
}
void drawPalletteHorizontal (ref const(Palette!ubyte) palette, Vector2 pos, Vector2 size = Vector2(10,10), int spacing = 1) {
	foreach (color; palette.colors) {
		DrawRectangleV(pos, size, color);
		pos.x += size.x + spacing;
	}
}

Vector2 toVector2 (Rectangle rectangle) {
	return Vector2(rectangle.x, rectangle.y);
}
Vector2 bottomLeft (Rectangle rectangle) {
	return Vector2(rectangle.x, rectangle.x + rectangle.height);
}
Vector2 topRight (Rectangle rectangle) {
	return Vector2(rectangle.x + rectangle.width, rectangle.x);
}

Color[] decode (T)(ref const(PalettizedTexture!T) texture) {
	return texture.data.map!((value) => texture.palette.decode(value)).array;
}
Image toImage (T)(ref const(PalettizedTexture!T) texture) {
	auto colors = texture.decode;
	return LoadImageEx(&colors[0], cast(int)texture.width, cast(int)texture.height);
}
Texture2D toTexture (T)(ref const(PalettizedTexture!T) texture) {
	return texture.toImage.LoadTextureFromImage;
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
