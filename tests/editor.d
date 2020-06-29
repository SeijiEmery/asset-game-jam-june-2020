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

enum LayerType {
	None 					= 0x0,
	Air 					= 0x10,
	Vegetation 				= 0x11,
	InteriorWallDeco 		= 0x12,
	InteriorWallObject 		= 0x13,
	InteriorTorch 			= 0x14,
	InteriorLadder 			= 0x15,
	InteriorPlatform 		= 0x16,
	InteriorPlatformPillar  = 0x17,

	InteriorFluidBody 			= 0x50,
	InteriorFluidCascaseSmall 	= 0x51,
	InteriorFluidCascaseLarge 	= 0x52,

	Ground 					= 0x20,

	Fluid 					= 0x40,
	Water 					= 0x44,
	Lava 					= 0x48,

	WaterBody 				= 0x54,
	WaterCascadeSmall 		= 0x55,
	WaterCascadeLarge 		= 0x56,

	LavaBody		 		= 0x58,
	LavaCascadeSmall 		= 0x59,
	LavaCascadeLarge 		= 0x5A,
}
enum TileType {
	Air 					= 0x0,
	WallGroundTop 			= 0x10,
	WallGroundBtm 			= 0x11,
	WallGroundSide			= 0x12,
	WallGroundTopCorner 	= 0x13,
	WallGroundBtmCorner 	= 0x14,
	WallGroundInterior		= 0x15,
	WallGroundSingleVertical = 0x16,
	WallGroundSingleVerticalTop = 0x17,
	WallGroundSingleVerticalBtm = 0x18,

	WallOutsideSideAdj 		= 0x37,
	WallOutsideTopAdj 		= 0x38,
	WallOutsideBtmAdj 		= 0x39,

	LadderTop 				= 0x20,
	Ladder 					= 0x21,

	TorchTop 				= 0x22,
	TorchBtm 				= 0x23,

	Platform 					= 0x24,
	PlatformPillar 				= 0x25,
	PlatformWithSupportPillar 	= 0x26,

	CascadeOrigin 			= 0x01,
	CascadeSmall 			= 0x02,
	CascadeLarge 			= 0x03,

	CascadeImpactTop 		= 0x04,
	CascadeImpactTopCorner  = 0x05,
	CascadeImpactBtm		= 0x06,
	CascadeImpactBtmCorner 	= 0x07,

	FlipX 					= 0x40,
	VegetationFlag 			= 0x80,
}
enum BiomeType {
	Any 					= 0x1F,
	Grass 					= 0x1,
	Dirt 					= 0x2,
	Stone 					= 0x4,
	Lab						= 0x8,
	Snow					= 0x10,
	Water 					= 0x40,
	Lava 					= 0x80,
}

bool isGround (LayerType layer) {
	return (layer & LayerType.Ground) != 0;
}
bool isAir (LayerType layer) {
	return (layer & LayerType.Air) != 0;
}
bool isFluid (LayerType layer) {
	return (layer & LayerType.Fluid) != 0;
}

void generateTilesFirstPass (
	TileMap!LayerType layer, TileMap!BiomeType biome, 
	int x, int y,
	TileMap!TileType outputTile, TileMap!BiomeType outputBiome
) {
	auto center = layer.get(x, y);
	auto top 	= layer.get(x, y+1);
	auto btm 	= layer.get(x, y-1);
	auto left   = layer.get(x-1, y);
	auto right  = layer.get(x+1, y);

	outputBiome.get(x, y) = biome.get(x, y);

	if (center.isGround) {		
		auto lg = left.isGround, rg = right.isGround;
		if (!top.isGround) {
			//if (top.isFluid) {
			//	if (left.isFluid == right.isFluid) {
			//	} else if (!left.isFluid) {

			//	} else if (!right.isFluid) {

			//	}
			//} else 
			if (lg == rg) {
				outputTile.get(x, y) = TileType.WallGroundTop;
			} else if (lg) {
				outputTile.get(x, y) = TileType.WallGroundTopCorner;
			} else if (right.isGround) {
				outputTile.get(x, y) = TileType.WallGroundTopCorner | TileType.FlipX;
			}
		} else if (!btm.isGround) {
			if (lg == rg) {
				outputTile.get(x, y) = TileType.WallGroundBtm;
			} else if (lg) {
				outputTile.get(x, y) = TileType.WallGroundTopCorner;
			} else if (right.isGround) {
				outputTile.get(x, y) = TileType.WallGroundTopCorner | TileType.FlipX;
			}
		} else if (lg == rg) {
			outputTile.get(x, y) = !lg ? TileType.WallGroundSingleVertical : TileType.WallGroundInterior;
		} else {
			outputTile.get(x, y) = !lg ? TileType.WallGroundSide :
				TileType.WallGroundSide | TileType.FlipX;
		}
	} 
	else if (center.isFluid) {
		outputTile.get(x, y) = TileType.WallGroundInterior;
		outputBiome.get(x, y) = (center & LayerType.Lava) ? BiomeType.Lava : BiomeType.Water;
	}
	else {
		outputTile.get(x, y) = TileType.Air;
	}
}
void renderTile (
	TileMap!TileType tileTypes, TileMap!BiomeType biome,
	int x, int y,
	TileMap!TileIndex tiles
) {

}


enum DrawMode { Default, FillEmpty }

void forEachRect(alias cb)(int x, int y, uint w, uint h) {
	for (; h > 0; ++y, --h) {
		for (; w > 0; ++x, --w) {
			cb(x, y);
		}
	}
}
class RenderedTileMap {
	TileMap!LayerType editableLayers;
	TileMap!BiomeType editableBiomes;
	TileMap!TileType  firstPassTiles;
	TileMap!BiomeType drawnBiome;
	TileMap!TileIndex tilemap;
	TileIndex[]	dirtyDrawList; 
	TileIndex[] firstPassDirtyList;

	private bool drawPt (DrawMode drawMode = DrawMode.Default)(int x, int y, LayerType value) {
		static if (drawMode == DrawMode.FillEmpty) {
			if (editableLayers.get(x, y) != LayerType.None) {
				return false;
			}
		}
		auto prevValue = editableLayers.get(x, y);
		if (prevValue != value) {
			editableLayers.get(x, y) = value;
			dirtyDrawList ~= TileIndex(x, y);
			return true;
		}
		return false;
	}
	private void markDirty (int x, int y) {
		if (editableLayers.get(x, y)) {
			dirtyDrawList ~= TileIndex(x, y);
		}
	}
	private void rebuildDirtyTiles () {
		foreach (tile; dirtyDrawList) {
			updateTileFirstPass(tile.x, tile.y, firstPassDirtyList);
		}
		dirtyDrawList.length = 0;
		foreach (tile; firstPassDirtyList) {
			updateTileSecondPass(tile.x, tile.y);
		}
		firstPassDirtyList.length = 0;
	}
	private void drawRect(DrawMode mode, T)(int x, int y, uint w, uint h, T value) {
		forEachRect!((i, j) {
			if (drawPt!mode(i, j, value)) {
				markDirty(i-1, j);
				markDirty(i+1, j);
			} else {
				markDirty(i, j);
			}
		})(x, y, w, h);
		foreach (k; x .. x + w) {
			markDirty(k, y - 1);
			markDirty(k, y + h + 1);
		}
		rebuildDirtyTiles();
	}
	void drawRect (T)(int x, int y, uint w, uint h, T value, DrawMode drawMode) {
		final switch (drawMode) {
			case DrawMode.Default:
				drawRect!(DrawMode.Default)(x, y, w, h, value);
				break;
			case DrawMode.FillEmpty:
				drawRect!(DrawMode.FillEmpty)(x, y, w, h, value);
				break;
		}
	}
	void drawRect (T)(int x, int y, int w, int h, T[] values) {
		assert(values.length == w * h, format("invalid length: %s != %s x %s", values.length, w, h));
		T* next = &values[0];
		forEachRect!((i, j) {
			if (drawPt(i, j, *(next++))) {
				markDirty(i-1, j);
				markDirty(i+1, j);
			} else {
				markDirty(i, j);
			}
		})(x, y, w, h);
		foreach (k; x .. x + w) {
			markDirty(k, y - 1);
			markDirty(k, y + h + 1);
		}
		rebuildDirtyTiles();
	}
	void getRect (T)(int x, int y, int w, int h, ref T[] values) {
		values.length = 0;
		forEachRect!((i, j) { 
			T value;
			get(i, j, value);
			values ~= value;
		})(x, y, w, h);
	}
	void get (int x, int y, out LayerType value) {
		value = editableLayers.get(x, y);
	}
	void drawCascade(int x, int y, LayerType value, DrawMode drawMode, ref LayerType[] prevValues) {
		int end = y + 1;
		while (editableLayers.get(x, end) && !editableLayers.get(x, end).isGround) {
			++end;
		}
		getRect(x, y, 1, end - y, prevValues);
		drawRect(x, y, 1, end - y, value, drawMode);
	}
	void undrawCascade(int x, int y, LayerType[] prevValues) {
		drawRect(x, y, 1, cast(int)prevValues.length, prevValues);
	}
	private void updateTileFirstPass(int x, int y, ref TileIndex[] dirtyTiles) {
		auto prevTile = firstPassTiles.get(x, y);
		auto prevBiome = drawnBiome.get(x, y);
		generateTilesFirstPass(editableLayers, editableBiomes, x, y, firstPassTiles, drawnBiome);
		if (prevTile != firstPassTiles.get(x, y) || prevBiome != drawnBiome.get(x, y)) {
			dirtyTiles ~= TileIndex(x, y);
		}
	}
	private void updateTileSecondPass(int x, int y) {
		renderTile(firstPassTiles, drawnBiome, x, y, tilemap);
	}	
}
interface TileOperation {
	void execute	(RenderedTileMap tilemap);
	void unexecute	(RenderedTileMap tilemap);
}
class DrawTilePointOperation(T : LayerType) : TileOperation {
	int x, y;
	T value, prevValue = LayerType.None;

	this (int x, int y, T value) {
		this.value = value;
		this.x = x;
		this.y = y;
	}
	void execute(RenderedTileMap tilemap) {
		tilemap.get(x, y, prevValue);
		tilemap.draw(x, y, value);
	}
	void unexecute(RenderedTileMap tilemap) {
		tilemap.draw(x, y, prevValue);
	}
}
class DrawTileRectOperation(T : LayerType) : TileOperation {
	int  x, y;
	uint w, h;
	T value;
	TileDrawMode drawMode;
	T[] prevValues;

	this (int x, int y, uint w, uint h, T value, TileDrawMode drawMode) {
		this.x = x; this.y = y; this.w = w; this.h = h;
		this.value = value; this.drawMode = drawMode;
	}
	void execute(RenderedTileMap tilemap) {
		tilemap.getRect(x, y, w, h, prevValues);
		tilemap.drawRect(x, y, w, h, value, drawMode);
	}
	void unexecute(RenderedTileMap tilemap) {
		tilemap.drawRect(x, y, w, h, prevValues);
	}
}
class DrawTileCascade(T : LayerType) : TileOperation {
	int  x, y;
	T value;
	TileDrawMode drawMode;
	T[] prevValues;

	this (int x, int y, T value, TileDrawMode drawMode) {
		this.x = x; this.y = y;
		this.value = value; this.drawMode = drawMode;
	}
	void execute(RenderedTileMap tilemap) {
		tilemap.drawCascade(x, y, value, prevValues);
	}
	void unexecute(RenderedTileMap tilemap) {
		tilemap.undrawCascade(prevValues);
	}
}
void erase(TileMap!LayerType tilemap, int i, int j) {
	tilemap.get(i, j) = LayerType.None;
}

class TileMapEditor {
	public RenderedTileMap tilemap = new RenderedTileMap();
	TileOperation[] operations;
	size_t operationIndex;

	this () { load(); }
	~this() { save(); }

	void drawPoint(Args...)(Args args) {
		executeOp(new DrawTilePointOperation(args));
	}
	void drawRect(Args...)(Args args) {
		executeOp(new DrawTileRectOperation(args));
	}
	void drawCascade(Args...)(Args args) {
		executeOp(new DrawTileRectOperation(args));
	}
	private void executeOp (TileOperation operation) {
		operation.execute(tilemap);
		if (operationIndex < operations.length) {
			operations.length = operationIndex;
		}
		operations ~= operation;
		operationIndex = operations.length;
	}
	public void undo () {
		if (operationIndex > 0) {
			operations[--operationIndex].unexecute(tilemap);
		}
	}
	public void redo () {
		if (operationIndex > 0) {
			operations[operationIndex++].execute(tilemap);
		}
	}
	public void save () {
		writefln("saving... (TBD)");
	}
	public void load () {
		writefln("loading... (TBD)");
	}
	public void update() {
		// implement undo / redo hotkeys
		version(OSX) {
			auto cmdDown = IsKeyDown(KeyboardKey.KEY_LEFT_SUPER) || IsKeyDown(KeyboardKey.KEY_RIGHT_SUPER);
		} else {
			auto cmdDown = IsKeyDown(KeyboardKey.KEY_LEFT_CTRL) || IsKeyDown(KeyboardKey.KEY_RIGHT_CTRL);
		}
		if (cmdDown) { 
			if (IsKeyPressed(KeyboardKey.KEY_Z)) {
				if (IsKeyDown(KeyboardKey.KEY_LEFT_SHIFT) || IsKeyDown(KeyboardKey.KEY_RIGHT_SHIFT)) {
					redo();
				} else {
					undo();
				}
			}
			if (IsKeyPressed(KeyboardKey.KEY_S)) {
				save();
			}
		}
	}
	public void setupUI() {

	}
	public void drawUI() {

	}
}

class TileMapRenderer {
	RenderedTileMap tilemap;
	Texture2D tilemapTexture;

	this (RenderedTileMap tilemap) { 
		this.tilemap = tilemap;
		this.tilemapTexture = LoadTexture("assets/tiles/tiles.png");
	}

	void render (Camera2D camera) {
		BeginMode2D(camera);

		EndMode2D();
	}
}



void main() {
	int screenWidth = 1920, screenHeight = 1080;
	InitWindow(screenWidth, screenHeight, "agj editor");
	SetTargetFPS(60);

	Sprites.load(); // preload all sprites

	auto editor = new TileMapEditor();
	auto tileRenderer = new TileMapRenderer(editor.tilemap);
 
	SpriteRenderer sprites;
	auto player = Player(sprites);
	auto cam = CameraController(player, screenWidth, screenHeight);
	auto tileEditor = new TileEditor();

	if (!IsGamepadAvailable(0)) {
		writefln("no gamepad present!!");
	}
	editor.setupUI();

	while (!WindowShouldClose()) {
		MouseUI.beginFrame();
		tileEditor.renderUI();

		player.update();
		cam.update();
		editor.update();

		BeginDrawing();
		ClearBackground(BLACK);
		auto camera = cam.camera;

		// draw tiles
		tileRenderer.render(camera);

		// draw sprites
		sprites.render(camera);

		// draw UI
		tileEditor.render(camera);
		editor.drawUI();
		EndDrawing();
	}
	CloseWindow();
}
