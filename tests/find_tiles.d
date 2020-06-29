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
import std.exception: enforce;

struct Tile(T = Color, size_t X = 8, size_t Y = 8) {
	T[] data;
	@property size_t hash () { return data.hashOf; }

	Image toImage () {
		return (&data[0]).LoadImageEx(cast(int)X, cast(int)Y);
	}
	Texture2D toTexture () {
		auto image = toImage();
		auto texture = image.LoadTextureFromImage();
		//image.UnloadImage();
		return texture;
	}
}

class TileSet(ValueT = Color, TileIndexT = size_t, size_t X = 8, size_t Y = 8) {
	alias TileType = Tile!(ValueT, X, Y);
	alias This = TileSet!(ValueT, TileIndexT, X, Y);

	private TileType[] tiles;

	TileIndexT encode (ValueT[] tileData) {
		enforce(tileData.length == X * Y, format("invalid tile length: %s, expected %s x %s", tileData.length, X, Y));
		auto hash = tileData.hashOf;
		foreach (i, tile; tiles) {
			if (tile.data.hashOf == hash && tile.data == tileData) {
				return cast(TileIndexT)i;
			}
		}
		tiles ~= TileType(tileData);
		return cast(TileIndexT)(tiles.length - 1);
	}
	TileIndexT encode (ValueT* tileData) {
		return encode(tileData[0..X*Y]);
	}
	ref TileType get (TileIndexT index) {
		enforce(index < tiles.length, format("tile index out of range: %s > %s", index, tiles.length));
		return tiles[index];
	}

	TileMap!(ValueT, TileIndexT, X, Y) encode (Image image) {
		enforce(image.width % X == 0 && image.height % Y == 0,
			format("image has an irregular size %s x %s and is not tileable at %s x %s",
				image.width, image.height, X, Y));

		TileMap!(ValueT,TileIndexT,X,Y) tilemap;
		tilemap.width = image.width / X;
		tilemap.height = image.height / Y;
		tilemap.mapData = new TileIndexT[tilemap.width * tilemap.height];
		for (size_t i = 0; i < tilemap.width; ++i) {
			for (size_t j = 0; j < tilemap.height; ++j) {
				Image tileImage = image.ImageFromImage(Rectangle(cast(int)(i * X), cast(int)(j * Y), cast(int)X, cast(int)Y));
				tilemap.getTileIndex(i, j) = encode(tileImage.GetImageData());
				tileImage.UnloadImage();
			}
		}
		return tilemap;
	}

	Texture2D[] getTileTextures () {
		return tiles.map!((tile) => tile.toTexture).array;
	}
}

struct TileMap(ValueT = Color, TileIndexT = size_t, size_t X = 8, size_t Y = 8) {
	TileSet!(ValueT, TileIndexT, 8, 8) tileset;
	TileIndexT[] mapData;
	size_t width;
	size_t height;

	ref TileIndexT getTileIndex (size_t i, size_t j) {
		enforce(i < width && j < height, format("out of range: %s, %s (width = %s, height = %s)", width, height));
		return mapData[i + j * width];
	}
	ref Tile!(ValueT, 8, 8) getTile(size_t i, size_t j) {
		return tileset.get(getTileIndex(i, j));
	}
}

TileMap!(Color, size_t, 8, 8) buildTileMap (Image image, TileSet!(Color, size_t, 8, 8) tileset = null) {
	if (tileset is null) tileset = new TileSet!(Color, size_t, 8, 8)();
	return tileset.encode(image);
}
TileMap!(Color, size_t, 8, 8) buildTileMap (Texture2D texture, TileSet!(Color, size_t, 8, 8) tileset = null) {
	auto image = texture.GetTextureData;
	auto result = buildTileMap(image, tileset);
	image.UnloadImage;
	return result;
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

	auto targetImageTiles = targetTexture.buildTileMap;
	auto tileTextures     = targetImageTiles.tileset.getTileTextures;
	auto pos = exampleImageRect.bottomLeft;
	//pos.y += 5;
	//foreach (i, tile; tileTextures) {
	//	sprites.create()
	//		.fromTexture(&tileTextures[i])
	//		.setPosition(pos);
	//	pos.x += 12;
	//	if ((i + 1) % 10 == 0) {
	//		pos.x = exampleImageRect.bottomLeft.x;
	//		pos.y += 12;
	//	}
	//}

	while (!WindowShouldClose()) {
		MouseUI.beginFrame();

		player.update();
		cam.update();

		BeginDrawing();
		ClearBackground(BLACK);
		auto camera = cam.camera;

		// draw sprites
		sprites.render(camera);

		BeginMode2D(camera);

		EndMode2D();

		EndDrawing();
	}
	CloseWindow();
}
