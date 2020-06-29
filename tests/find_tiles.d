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
import agj.image_processing.palettize;

alias uint64_t = ulong;


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

void forEachTwoFirst8x8TileSlicesMatchingPredicate(alias pred, alias cb)(
	void* data, 
	size_t width, 
	size_t height,
) {
	uint64_t* ptr = cast(uint64_t*)data;
	uint64_t* end = &ptr[width * height * 8];
	size_t i = 0;
	int ic = cast(int)width;
	while (ptr < end) {
		if (pred(ptr, i)) {
			uint64_t* p2 = ptr + 1;
			size_t j = i + 1;
			int jc = ic;
			//writefln("predicate begun at i = %s, j = %s", i, j);
			while (p2 < end) {
				if (--jc <= 0) {
					//writefln("advancing j at %s", j);
					p2 += width * 7;
					jc += width;
					if (p2 >= end) break;
				}
				cb(ptr, i, p2, j);
				++p2;
				++j;
			}
		}
		if (--ic <= 0) {
			//writefln("advancing i at %s", i);
			ptr += width * 7;
			ic += width;
		}
		++ptr;
		++i;
	}
}

alias TileIndex = uint; 		// index of a tile in a tile sheet

struct TileScanResult {
	TileIndex[] tiles;
	//TileIndex[] textureDataAsFirstUniqueTileIndex;
	size_t width = 0;
	size_t height = 0;
	TileIndex[] uniqueTileList;

	ref TileIndex get (size_t i, size_t j) {
		assert(i < width && j < height);
		return tiles[i + j * width];
	}

}
TileScanResult getFirstUnique8x8TileIndices(ref PalettizedTexture!ubyte texture) {
	size_t width = texture.width / 8, height = texture.height / 8;
	TileIndex[] tileIndices = new TileIndex[width * height];

	TileScanResult result;

	// find identical tiles using a sieve algorithm
	uint64_t  thisSlice;
	TileIndex thisTileIndex;
	forEachTwoFirst8x8TileSlicesMatchingPredicate!(
		(uint64_t* slice, size_t i) {
			if (tileIndices[i] == 0) {
				thisSlice = *slice;

				// tile indices are +1 so we can use 0 as a null / unassigned value
				thisTileIndex = tileIndices[i] = cast(TileIndex)(i + 1);
				result.uniqueTileList ~= thisTileIndex;
				result.tiles ~= tileIndices[i];
				return true;
			}
			result.tiles ~= tileIndices[i];
			return false;
		},
		(uint64_t* slice1, size_t i, uint64_t* slice2, size_t j) {
			if (tileIndices[j] == 0 && thisSlice == *slice2) {

				// 1st tile slice is the same - check remaining tile data
				for (int count = 7; count --> 0; ) {
					if (*(slice1 += width) != *(slice2 += width)) {

						// non-identical - skip
						return;
					}
				}

				// found a matching tile - assign index to the first found instance of this tile
				tileIndices[j] = thisTileIndex;
			}
		}
	)(&texture.data[0], width, height);

	//result.textureDataAsFirstUniqueTileIndex = tileIndices;
	result.width = width;
	result.height = height;
	return result;
}
void drawTile8x8 (Texture2D texture, TileIndex index, Vector2 pos, Color tint = WHITE) {
	if (index > 0) {
		int i = (index - 1) % (texture.width / 8);
		int j = (index - 1) / (texture.width / 8);
		DrawTextureRec(texture, Rectangle(i * 8, j * 8, 8, 8), pos, tint);
	}
}
void drawUniqueTiles (ref const(TileScanResult) tiles, Texture2D texture, Vector2 pos, Vector2 tilingOffset = Vector2(10, 0)) {
	foreach (index; tiles.uniqueTileList) {
		drawTile8x8(texture, index, pos);
		pos.x += tilingOffset.x;
		pos.y += tilingOffset.y;
	}
}
void drawAllTiles (ref const(TileScanResult) tiles, Texture2D texture, Vector2 pos) {
	size_t i = 0;
	auto x0 = pos.x;
	foreach (tile; tiles.tiles) {
		drawTile8x8(texture, tile, pos);
		if (++i >= tiles.width) {
			pos.x = x0;
			pos.y += 8;
			i = 0;
		} else {
			pos.x += 8;
		}
	}
}

void runTest() {
	size_t width = 4, height = 3;
	auto data = new uint64_t[width * height * 8];
	foreach (i; 0 .. width) {
		foreach (j; 0.. height) {
			data[i + j * width * 8] = (i << 32) | j;
		}
	}
	uint64_t* p0 = &data[0];
	forEachTwoFirst8x8TileSlicesMatchingPredicate!(
		(uint64_t* p, size_t i) {
			writefln("p %X %s (%s %s)", p - p0, i, (*p >> 32), *p & ((1L << 32) - 1));
			return i % 3 == 0;
		},
		(uint64_t* p1, size_t i, uint64_t* p2, size_t j) {
			writefln("  %X %s (%s %s) %X %s (%s %s)",
				p1 - p0, i, (*p1 >> 32), *p1 & ((1L << 32) - 1),
				p2 - p0, j, (*p2 >> 32), *p2 & ((1L << 32) - 1),
			);
		},
	)(&data[0], width, height);
}


void main() {

	runTest();

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
	auto p = featureTexture.palletize;
	auto result = p.getFirstUnique8x8TileIndices();

	auto p2 = targetTexture.palletize;
	auto result2 = p2.getFirstUnique8x8TileIndices();

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

		//result.drawUniqueTiles(featureTexture, exampleImageRect.bottomLeft);
		//result.drawAllTiles(featureTexture, exampleImageRect.topRight);

		//exampleImageRect.x += exampleImageRect.width * 2;
		result2.drawUniqueTiles(targetTexture, exampleImageRect.bottomLeft);
		result2.drawAllTiles   (targetTexture, exampleImageRect.topRight);

		EndMode2D();

		EndDrawing();
	}
	CloseWindow();
}
