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
import agj.editors.tile_layers;

enum LayerType {
	None 					= 0x0,
	Air 					= 0x10,
	WallTiles 				= 0x12,
	Vegetation 				= 0x13,
	Torch 					= 0x14,
	Ladder 					= 0x15,
	Platform 				= 0x16,

	Ground 					= 0x20,

	Fluid 					= 0x40,

	Water 			   		= 0x54,
	Waterfall 				= 0x55,
	Waterspout				= 0x56,

	Lava	 		 		= 0x58,
	LavaFall 				= 0x59,
}
enum TileType {
	None 					= 0x0,
	Air 					= 0x1,
	WallGroundTop 			= 0x10,
	WallGroundBtm 			= 0x11,
	WallGroundSideL			= 0x12,
	WallGroundSideR			= 0x112,

	WallGroundTopCornerL 	= 0x13,
	WallGroundTopCornerR 	= 0x113,

	WallGroundBtmCornerL 	= 0x14,
	WallGroundBtmCornerR 	= 0x114,

	WallGroundInterior		= 0x15,

	WallGroundSingleVertical 	= 0x16,
	WallGroundSingleVerticalTop = 0x17,
	WallGroundSingleVerticalBtm = 0x18,

	LadderTop 				= 0x20,
	Ladder 					= 0x21,

	TorchTop 				= 0x22,
	TorchBtm 				= 0x23,

	Platform 					= 0x24,
	PlatformEdgeL 				= 0x26,
	PlatformEdgeR 				= 0x126,
	PlatformPillar 				= 0x27,
	PlatformWithSupportPillar 	= 0x29,

	Water,
	WaterTop,
	WaterBtm,
	WaterBtmImpact,
	WaterBtmImpactL,
	WaterBtmImpactR,
	WaterSideL,
	WaterSideR,

	WaterFall,
	WaterFallImpact,
	WaterFallImpactL,
	WaterFallImpactR,

	WaterSpout,
	WaterSpoutImpact,
	WaterSource,

	Lava,
	LavaTop,
	LavaBtm,
	LavaSideL,
	LavaSideR,

	LavaFall,
	LavaFallImpact,
	LavaSource,
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

TileType generateTilesFirstPass (
	TileMap!LayerType layer, TileMap!BiomeType biome, 
	int x, int y,
	TileMap!BiomeType outputBiome
) {
	//writefln("generating (pass 1) for %s %s", x, y);
	auto center = layer.get(x, y);
	auto top 	= layer.get(x, y-1);
	auto btm 	= layer.get(x, y+1);
	auto left   = layer.get(x-1, y);
	auto right  = layer.get(x+1, y);

	outputBiome.get(x, y) = biome.get(x, y);

	if (center.isGround) {		
		auto lg = left.isGround, rg = right.isGround;
		if (!top.isGround) {
			if (lg == rg) {
				return TileType.WallGroundTop;
			} else if (!lg) {
				return TileType.WallGroundTopCornerL;
			} else {
				return TileType.WallGroundTopCornerR;
			}
		} else if (!btm.isGround) {
			if (lg == rg) {
				return TileType.WallGroundBtm;
			} else if (lg) {
				return TileType.WallGroundBtmCornerR;
			} else if (right.isGround) {
				return TileType.WallGroundBtmCornerL;
			}
		} else if (lg == rg) {
			return !lg ? TileType.WallGroundSingleVertical : TileType.WallGroundInterior;
		} else {
			return !lg ? TileType.WallGroundSideL :
				TileType.WallGroundSideR;
		}
	} 
	else if (center.isFluid) {
		switch (center) {
			case LayerType.Water:
				if (btm != LayerType.Water) return TileType.WaterBtm;
				if (top == LayerType.Water) return TileType.Water;
				if (top == LayerType.Waterfall) return TileType.WaterBtmImpact;
				if (layer.get(x-1,y-1) == LayerType.Waterfall) return TileType.WaterBtmImpactL;
				if (layer.get(x+1,y-1) == LayerType.Waterfall) return TileType.WaterBtmImpactR;
				return TileType.WaterTop;

			case LayerType.Lava:
				if (btm != LayerType.Lava) return TileType.LavaBtm;
				if (top == LayerType.Lava) return TileType.Lava;
				return TileType.LavaTop;

			case LayerType.Waterfall:
				if (btm != LayerType.Waterfall) return TileType.WaterFallImpact;
				return TileType.WaterFall;

			case LayerType.Waterspout:
				if (btm != LayerType.Waterspout) return TileType.WaterSpoutImpact;
				if (top != LayerType.Waterspout) return TileType.WaterSource;
				return TileType.WaterSpout;


			//case LayerType.LavaCascadeSmall:
			//	if (btm.isFluid && (btm != LayerType.WaterCascadeSmall && btm != LayerType.LavaCascadeSmall)) {
			//		return TileType.CascadeImpactSmall;
			//	} else if (top == LayerType.WaterCascadeSmall || top == LayerType.LavaCascadeSmall) {
			//		return TileType.CascadeSmall;
			//	} else {
			//		return TileType.CascadeOrigin;
			//	}
			//case LayerType.LavaCascadeLarge: case LayerType.WaterCascadeLarge:
			//	return TileType.CascadeLarge;
			default:
				//if (!btm.isFluid) return TileType.WallGroundBtm;
				//if (!top.isFluid) return TileType.WallGroundTop;
				//return TileType.WallGroundInterior;
		}
	}
	else {
		switch (center) {
			case LayerType.None: 
				if (top == LayerType.Torch)
					return TileType.TorchBtm;
			return TileType.None;
			
			// air + torches
			case LayerType.Air:   	
				if (top == LayerType.Torch)
					return TileType.TorchBtm;
				return TileType.Air;
			
			case LayerType.Torch:  	
				return TileType.TorchTop;
			
			// ladders
			case LayerType.Ladder: 
				return top == LayerType.Ladder 
					? TileType.Ladder 
					: TileType.LadderTop;
			
			// platforms + supports
			case LayerType.Platform:
				if (btm == LayerType.Platform || top == LayerType.Platform)
					return left == LayerType.Platform || right == LayerType.Platform || (top != LayerType.Platform && !top.isGround) ?
						TileType.PlatformWithSupportPillar : TileType.PlatformPillar;
				return left.isGround ? TileType.PlatformEdgeL 
					: right.isGround ? TileType.PlatformEdgeR
					: TileType.Platform;

			default: return TileType.Air;
		}		
	}
	return TileType.None;
}
uint renderTile (
	TileMap!TileType tileTypes, TileMap!BiomeType biomes,
	int x, int y
) {
	import std.random;

	auto tile = tileTypes.get(x, y);
	auto biome = biomes.get(x, y);

	switch (tile) {
		case TileType.None: 						return 0;
		case TileType.Air: 							return 1;
		case TileType.TorchTop: 					return 46;
		case TileType.TorchBtm: 					return 54;
		case TileType.LadderTop: 					return 47;
		case TileType.Ladder: 	 					return 55;
		case TileType.Platform: 	 				return 15;
		case TileType.PlatformEdgeL: 	 			return 0x110;
		case TileType.PlatformEdgeR: 	 			return 0x10;
		case TileType.PlatformPillar: 	 			return 31;
		case TileType.PlatformWithSupportPillar: 	return 23;
		//case TileType.CascadeOrigin: 				
		//	return biome == BiomeType.Lava ? 73 : 69;
		//case TileType.CascadeSmall:
		//	return biome == BiomeType.Lava ? 77 : 75;
		//case TileType.CascadeImpactSmall:
		//	return biome == BiomeType.Lava ? 85 : 84;
		//case TileType.CascadeLarge:
		//	return biome == BiomeType.Lava ? 77 : 74;
		//case TileType.CascadeImpactTop:
		//	return biome == BiomeType.Lava ? 85 : 82;
		//case TileType.CascadeImpactTopCornerL: return 81;
		//case TileType.CascadeImpactTopCornerR: return 83;

		case TileType.Water: 	return 0x5B;
		case TileType.WaterTop: return 0x54;
		case TileType.WaterBtm: return 0x59;
		case TileType.WaterBtmImpact:  return 0x52;
		case TileType.WaterBtmImpactL: return 0x51;
		case TileType.WaterBtmImpactR: return 0x53;
		case TileType.WaterSideL: return 0x15C;
		case TileType.WaterSideR: return 0x5C;
 
		case TileType.WaterFall: return uniform01() < 0.3 ? 0x42 : 0x5B;
		case TileType.WaterFallImpact:  return 0x4A;
		case TileType.WaterFallImpactL: return 0x49;
		case TileType.WaterFallImpactR: return 0x4B;
 
		case TileType.WaterSpout: return 0x43;
		case TileType.WaterSpoutImpact: return 0x4C;
		case TileType.WaterSource: return 0x41;
 
		case TileType.Lava: return 1;
		case TileType.LavaTop: return 1;
		case TileType.LavaBtm: return 1;
		case TileType.LavaSideL: return 1;
		case TileType.LavaSideR: return 1;
 
		case TileType.LavaFall: return 1;
		case TileType.LavaFallImpact: return 1;
		case TileType.LavaSource: return 1;

		default:
			switch (biome) {
				case BiomeType.Any: case BiomeType.Grass:
					switch (tile) {
						case TileType.WallGroundTop:	    return 0x0A;
						case TileType.WallGroundBtm: 	    return 0x1A;
						case TileType.WallGroundSideL: 	    return 0x11;
						case TileType.WallGroundSideR: 	    return 0x111;
						case TileType.WallGroundTopCornerL: return 0x09;
						case TileType.WallGroundTopCornerR: return 0x109;
						case TileType.WallGroundBtmCornerL: return 0x19;
						case TileType.WallGroundBtmCornerR: return 0x119;
						//case WallGroundSingleVertical: 
						//case WallGroundSingleVerticalTop:
						//case WallGroundSingleVerticalBtm:
						case TileType.WallGroundInterior:  
						default:				
							return uniform01() < 0.2 ? 0x12 : 0x1;
					}
				default:
			}
			return 1;

	}
}


enum FillMode { Default, FillEmpty }

void forEachRect(alias cb)(int x, int y, uint w, uint h) {
	for (int i = 0; i < w; ++i) {
		for (int j = 0; j < h; ++j) {
			cb(x + i, y + j);
		}
	}
}
class RenderedTileMap {
	auto editableLayers = new TileMap!LayerType();
	auto editableBiomes = new TileMap!BiomeType();
	auto firstPassTiles = new TileMap!TileType();
	auto drawnBiome = new TileMap!BiomeType();
	auto tilemap = new TileMap!uint();
	TileIndex[]	dirtyDrawList; 
	TileIndex[] firstPassDirtyList;

	private bool drawPt (FillMode drawMode = FillMode.Default)(int x, int y, LayerType value) {
		writefln("drawing %s at %s, %s", value, x, y);
		static if (drawMode == FillMode.FillEmpty) {
			if (editableLayers.get(x, y) != LayerType.None) {
				writefln("skipping due to fill mode");
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
	void drawPoint (int x, int y, LayerType value, FillMode drawMode = FillMode.Default) {
		drawRect(x, y, 1, 1, value, drawMode);
	}
	private void markDirty (int x, int y) {
		if (editableLayers.get(x, y)) {
			dirtyDrawList ~= TileIndex(x, y);
		}
	}

	private bool isDirty = false;

	private void lazyRebuildAllTilesOnScreen(Camera2D camera) {
		if (isDirty) {
			isDirty = false;
			rebuildAllTilesOnScreen(camera);
		}
	}
	public void rebuildAllTilesOnScreen (Camera2D camera) {
		isDirty = false;

		TileIndex i0, i1;
		editableLayers.getTileBoundsFromScreenCoords(Rectangle(500, 1500, 3000, 1500), camera, i0, i1);
        for (int i = i0.x; i < i1.x; ++i) {
            for (int j = i0.y; j < i1.y; ++j) {
            	updateTileFirstPass(i, j, firstPassDirtyList);
            }
        }

        foreach (tile; firstPassDirtyList) {
			//writefln("processing dirty 2 %s %s", tile.x, tile.y);
			updateTileSecondPass(tile.x, tile.y);
		}
		firstPassDirtyList.length = 0;
	}

	private void rebuildDirtyTiles () {
		isDirty = true;
		foreach (tile; dirtyDrawList) {
			//writefln("processing dirty %s %s", tile.x, tile.y);
			updateTileFirstPass(tile.x, tile.y, firstPassDirtyList);
		}
		dirtyDrawList.length = 0;
		foreach (tile; firstPassDirtyList) {
			//writefln("processing dirty 2 %s %s", tile.x, tile.y);
			updateTileSecondPass(tile.x, tile.y);
		}
		firstPassDirtyList.length = 0;
	}
	private void drawRect(FillMode mode, T)(int x, int y, uint w, uint h, T value) {
		forEachRect!((i, j) {
			if (drawPt!mode(i, j, value)) {
				//markDirty(i-1, j);
				//markDirty(i+1, j);
			} 
			//else {
			//	markDirty(i, j);
			//}
		})(x, y, w, h);

		forEachRect!((i, j) { markDirty(i, j); })(x - 10, y - 10, w + 20, h + 20);
		//foreach (k; x - 1 .. x + w + 1) {
		//	markDirty(k, y - 1);
		//	markDirty(k, y + h + 1);
		//}
		rebuildDirtyTiles();
	}
	void drawRect (T)(int x, int y, uint w, uint h, T value, FillMode drawMode) {
		writefln("drawing rect at %s, %s: %s x %s with mode %s", x, y, w, h, drawMode);
		final switch (drawMode) {
			case FillMode.Default:
				drawRect!(FillMode.Default)(x, y, w, h, value);
				break;
			case FillMode.FillEmpty:
				drawRect!(FillMode.FillEmpty)(x, y, w, h, value);
				break;
		}
	}
	void drawRect (T)(int x, int y, int w, int h, T[] values) {
		writefln("drawing rect at %s, %s: %s x %s", x, y, w, h);

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
	void drawCascade(int x, int y, LayerType value, FillMode drawMode, ref LayerType[] prevValues) {
		int end = y + 1;
		while (editableLayers.get(x, end) && !editableLayers.get(x, end).isGround && !editableLayers.get(x, end).isFluid) {
			++end;
		}
		writefln("drawing cascade at %s %s -> cascaded to %s (length %s)", x, y, end, end - y);
		getRect(x, y, 1, end - y, prevValues);
		drawRect(x, y, 1, end - y, value, drawMode);
	}
	void undrawCascade(int x, int y, LayerType[] prevValues) {
		drawRect(x, y, 1, cast(int)prevValues.length, prevValues);
	}
	private void updateTileFirstPass(int x, int y, ref TileIndex[] dirtyTiles) {
		auto prevTile = firstPassTiles.get(x, y);
		auto prevBiome = drawnBiome.get(x, y);
		firstPassTiles.get(x, y) = generateTilesFirstPass(editableLayers, editableBiomes, x, y, drawnBiome);
		if (prevTile != firstPassTiles.get(x, y) || prevBiome != drawnBiome.get(x, y)) {
			dirtyTiles ~= TileIndex(x, y);
		}
	}
	private void updateTileSecondPass(int x, int y) {
		tilemap.get(x, y) = renderTile(firstPassTiles, drawnBiome, x, y);
	}

	auto getTileBoundsFromScreenCoords (Args...)(Args args) {
		return editableLayers.getTileBoundsFromScreenCoords(args);
	}
}
interface TileOperation {
	void execute	(RenderedTileMap tilemap);
	void unexecute	(RenderedTileMap tilemap);
}
class DrawTilePointOperation(T : LayerType) : TileOperation {
	int x, y;
	T value, prevValue = LayerType.None;
	FillMode drawMode;

	this (int x, int y, T value, FillMode drawMode) {
		this.value = value;
		this.x = x;
		this.y = y;
		this.drawMode = drawMode;
	}
	void execute(RenderedTileMap tilemap) {
		tilemap.get(x, y, prevValue);
		tilemap.drawPoint(x, y, value, drawMode);
	}
	void unexecute(RenderedTileMap tilemap) {
		tilemap.drawPoint(x, y, prevValue, drawMode);
	}
}
class DrawTileRectOperation(T : LayerType) : TileOperation {
	int  x, y;
	uint w, h;
	T value;
	FillMode drawMode;
	T[] prevValues;

	this (int x, int y, uint w, uint h, T value, FillMode drawMode) {
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
	FillMode drawMode;
	T[] prevValues;

	this (int x, int y, T value, FillMode drawMode) {
		this.x = x; this.y = y;
		this.value = value; this.drawMode = drawMode;
	}
	void execute(RenderedTileMap tilemap) {
		tilemap.drawCascade(x, y, value, drawMode, prevValues);
	}
	void unexecute(RenderedTileMap tilemap) {
		tilemap.undrawCascade(x, y, prevValues);
	}
}
void erase(TileMap!LayerType tilemap, int i, int j) {
	tilemap.get(i, j) = LayerType.None;
}
bool drawWithCascade (LayerType layerType) {
	switch (layerType) {
		case LayerType.Waterfall:
		case LayerType.LavaFall:
		case LayerType.Waterspout:
		case LayerType.Ladder: return true;
		default: return false;
	}
}

class TileMapEditor {
	public RenderedTileMap tilemap = new RenderedTileMap();
	TileOperation[] operations;
	size_t operationIndex;

	this () { load(); }

	void drawPoint(T)(TileIndex pos, T value, FillMode drawMode = FillMode.Default) {
		writefln("draw point, mode %s", drawMode);
		T tile;
		tilemap.get(pos.x, pos.y, tile);
		if (tile != value && (drawMode != FillMode.FillEmpty || !tile)) {
			if (value.drawWithCascade) {
				executeOp(new DrawTileCascade!T(pos.x, pos.y, value, drawMode));
			} else {
				executeOp(new DrawTilePointOperation!T(pos.x, pos.y, value, drawMode));
			}
		}
	}
	void drawRect(T)(TileIndex a, TileIndex b, T value, FillMode drawMode = FillMode.Default) {
		writefln("draw rect, mode %s", drawMode);
		import std.algorithm: swap;
		if (a.x > b.x) swap(a.x, b.x);
		if (a.y > b.y) swap(a.y, b.y);

		auto x = a.x, y = a.y;
		auto w = b.x - a.x, h = b.y - a.y;
		assert(w >= 0 && h >= 0);
		++w;
		++h;

		executeOp(new DrawTileRectOperation!T(x, y, cast(uint)w, cast(uint)h, value, drawMode));
	}
	void drawCascade(Args...)(Args args) {
		//executeOp(new DrawTileRectOperation!T(args));
	}
	private void executeOp (TileOperation operation) {
		operation.execute(tilemap);
		if (operationIndex < operations.length) {
			operations.length = operationIndex;
		}
		writefln("executing operation %s: %s", operations.length, operation);
		operations ~= operation;
		operationIndex = operations.length;
	}
	public void undo () {
		if (operationIndex > 0) {
			writefln("undoing operation %s: %s", operationIndex - 1, operations[operationIndex-1]);
			operations[--operationIndex].unexecute(tilemap);
		}
	}
	public void redo () {
		if (operationIndex >= 0 && operationIndex < operations.length) {
			writefln("redoing operation %s: %s", operationIndex, operations[operationIndex]);
			operations[operationIndex++].execute(tilemap);
		}
	}
	public void save () {
		import std.file;
		writefln("saving...");
		write("mapdata.layers", cast(void[])tilemap.editableLayers.save);
		write("mapdata.biomes", cast(void[])tilemap.editableBiomes.save);
		writefln("finished writing save file");
	}
	bool needsRebuild = false;
	public void load () {
		import std.file;
		writefln("loading...");
		if (exists("mapdata.layers") && exists("mapdata.biomes")) {
			tilemap.editableLayers.load(cast(ubyte[])read("mapdata.layers"));
			tilemap.editableBiomes.load(cast(ubyte[])read("mapdata.biomes"));
			needsRebuild = true;
			writefln("finished loading save file");
		} else {
			writefln("no save file(s)");
		}
	}
	public void update(Camera2D camera) {
		// implement undo / redo hotkeys
		version(OSX) {
			auto cmdDown = IsKeyDown(KeyboardKey.KEY_LEFT_SUPER) || IsKeyDown(KeyboardKey.KEY_RIGHT_SUPER);
		} else {
			auto cmdDown = IsKeyDown(KeyboardKey.KEY_LEFT_CTRL) || IsKeyDown(KeyboardKey.KEY_RIGHT_CTRL);
		}
		if (cmdDown) { 
			if (IsKeyDown(KeyboardKey.KEY_Z)) {
				if (IsKeyDown(KeyboardKey.KEY_LEFT_SHIFT) || IsKeyDown(KeyboardKey.KEY_RIGHT_SHIFT)) {
					redo();
				} else {
					undo();
				}
			}
			if (IsKeyPressed(KeyboardKey.KEY_S)) {
				save();
			}
			if (IsKeyPressed(KeyboardKey.KEY_O)) {
				load();
			}
		}
		if (needsRebuild) {
			needsRebuild = false;
			tilemap.rebuildAllTilesOnScreen(camera);
		}
	}

	private GUIPanel toolsPanel;
    private GUIPanel editorPanel;
    enum EditMode { TileEditor, Play }
    enum DrawMode { None, Point, Rect }
    EditMode editMode;
    DrawMode drawMode = DrawMode.Point;
    LayerType activeLayer = LayerType.Air;
    FillMode fillMode;
    private bool drawEditorPanel;

	private void drawTileEditorToolsWindow () {
        editorPanel.beginUI();
        editorPanel.horizontalSelectionToggle(drawMode);
        editorPanel.horizontalSelectionToggle(activeLayer);
        editorPanel.horizontalSelectionToggle(fillMode);
        editorPanel.endUI();

        // tile editor hotkeys
        if (IsKeyPressed(KeyboardKey.KEY_R)) { drawMode = drawMode == DrawMode.Point ? DrawMode.Rect : DrawMode.Point; }
        if (IsKeyPressed(KeyboardKey.KEY_F)) { fillMode = fillMode == FillMode.Default ? FillMode.FillEmpty : FillMode.Default; }
        if (IsKeyPressed(KeyboardKey.KEY_G)) { activeLayer = LayerType.Ground; }
        if (IsKeyPressed(KeyboardKey.KEY_A)) { activeLayer = LayerType.Air; }
        if (IsKeyPressed(KeyboardKey.KEY_W)) {
            switch (activeLayer) {
                case LayerType.Water: activeLayer = LayerType.Waterfall; break;
                case LayerType.Waterfall: activeLayer = LayerType.Waterspout; break;
                default: activeLayer = LayerType.Water;
            }
        }
        if (IsKeyPressed(KeyboardKey.KEY_L)) {
            switch (activeLayer) {
                case LayerType.Lava: activeLayer = LayerType.LavaFall; break;
                default: activeLayer = LayerType.Lava;
            }
        }
        if (IsKeyPressed(KeyboardKey.KEY_S)) {
        	activeLayer = LayerType.Platform;
        }
        if (IsKeyPressed(KeyboardKey.KEY_D)) { activeLayer = LayerType.Ladder; }
        //if (IsKeyPressed(KeyboardKey.KEY_T)) { activeLayer = LayerType.Torch; }
    }
    void renderUI () {
        toolsPanel.width = editMode == EditMode.Play ? 200 : 800;
        toolsPanel.beginUI();
        toolsPanel.layout.y = toolsPanel.position.y + 3;
        toolsPanel.layout.height = 6;
            if (toolsPanel.horizontalSelectionToggle(editMode)) {
                writefln("changed edit mode: %s", editMode);
            }
        toolsPanel.endUI();
        editorPanel.width = toolsPanel.width;
        editorPanel.moveable = false;
        editorPanel.position = toolsPanel.position;
        editorPanel.position.y += toolsPanel.height;
        editorPanel.layout.y = editorPanel.position.y + 3;
        editorPanel.layout.height = 6;
        final switch (editMode) {
            case EditMode.TileEditor:
                drawEditorPanel = true;
                drawTileEditorToolsWindow();
                break;
            case EditMode.Play:
                drawEditorPanel = false;
                break;
        }
    }

    bool drawingRectFillShape = false;
    TileIndex fillShapeBeginPos;
    TileIndex fillShapeEndPos;
    LayerType fillLayer;
    FillMode drawingFillMode;
    size_t opCountAtStart;

    private void beginDrawingRect(TileIndex start, LayerType layer, FillMode mode) {
        drawingRectFillShape = true;
        fillShapeBeginPos = fillShapeEndPos = start;
        fillLayer = layer;
        opCountAtStart = operationIndex;
        drawingFillMode = mode;
    }
    private void endDrag() {
        drawingRectFillShape = false;
        operationIndex = opCountAtStart;
        drawRect(fillShapeBeginPos, fillShapeEndPos, fillLayer, drawingFillMode);
    }
    private void drawTileEditor(Camera2D camera) {
        const int FOREGROUND_BACKGROUND_SCALE = 2;
        camera.zoom *= FOREGROUND_BACKGROUND_SCALE;
        camera.target.x /= FOREGROUND_BACKGROUND_SCALE;
        camera.target.y /= FOREGROUND_BACKGROUND_SCALE;
        BeginMode2D(camera);

        auto mousePos = Vector2(GetMouseX(), GetMouseY());
        auto selectedTile = mousePos.screenToTileCoords(camera);
        auto worldPos = GetScreenToWorld2D(mousePos, camera);

        // add 'Q' as an eyedropper hotkey
        if (IsKeyPressed(KeyboardKey.KEY_Q)) {
        	LayerType selection;
        	tilemap.get(selectedTile.x, selectedTile.y, selection);
        	if (selection) activeLayer = selection;
        }

        // draw tile layers
        TileIndex i0, i1;
        tilemap.editableLayers.getTileBoundsFromScreenCoords(Rectangle(0, 1080, 1920, 1080), camera, i0, i1);

        ////msg ~= format("\ngot bounds: %s %s", i0, i1);
        ////msg ~= format("\nbounds: %s", roomLayerMap.bounds);
        ////msg ~= format("\nchunk bounds: %s", roomLayerMap.chunkBounds);

        //for (int i = i0.x; i < i1.x; ++i) {
        //    for (int j = i0.y; j < i1.y; ++j) {
        //    	LayerType tile;
        //    	tilemap.get(i, j, tile);
        //        if (tile != LayerType.None) {
        //        	auto color = tile.toColor;
        //        	color.a = 50;
        //            DrawRectangleV(tileToWorldCoords(TileIndex(i, j)), Vector2(8, 8), color);
        //        }
        //    }
        //}
        auto w0 = i0.tileToWorldCoords;
        auto w1 = i1.tileToWorldCoords;
        DrawRectangleLinesEx(Rectangle(w0.x, w0.y, w1.x - w0.x, w1.y - w0.y), 1, WHITE);

        final switch (drawMode) {
            case DrawMode.None: break;
            case DrawMode.Point:
                if (MouseUI.buttonDown(MouseButton.MOUSE_LEFT_BUTTON)) {
                	drawPoint(selectedTile, activeLayer, fillMode);
                	//tilemap.drawPt(selectedTile.x, selectedTile.y, activeLayer);
                } else if (MouseUI.buttonDown(MouseButton.MOUSE_RIGHT_BUTTON)) {
                	drawPoint(selectedTile, LayerType.None);
                }
                // draw tile debug
                auto tilePos = selectedTile.tileToWorldCoords();
                DrawRectangleV(tilePos, Vector2(8, 8), ORANGE);
                break;
            case DrawMode.Rect:
                if (MouseUI.beginDrag(MouseButton.MOUSE_LEFT_BUTTON, null, &endDrag)) {
                    beginDrawingRect(selectedTile, activeLayer, fillMode);
                }
                else if (MouseUI.beginDrag(MouseButton.MOUSE_RIGHT_BUTTON, null, &endDrag)) {
                    beginDrawingRect(selectedTile, LayerType.None, FillMode.Default);
                }
                if (drawingRectFillShape) {
                    import std.algorithm: swap;
                    fillShapeEndPos = selectedTile;
                    TileIndex start = fillShapeBeginPos;
                    TileIndex end   = fillShapeEndPos;
                    if (start.x > end.x) { swap(start.x, end.x); }
                    if (start.y > end.y) { swap(start.y, end.y); }
                    ++end.x;
                    ++end.y;
                    //DrawRectangleV(start.tileToWorldCoords, Vector2(8 * (end.x - start.x), 8 * (end.y - start.y)),
                    //    fillLayer == LayerType.None ? BLACK : fillLayer.toColor);
                }
                // draw tile debug
                auto tilePos = selectedTile.tileToWorldCoords();
                DrawRectangleV(tilePos, Vector2(8, 8), ORANGE);

                break;
        }

        // draw pixel debug
        DrawRectangleV(Vector2(cast(double)cast(int)worldPos.x, cast(double)cast(int)worldPos.y), Vector2(1, 1), RED);
        EndMode2D();
    }

    void render (ref Camera2D camera) {
        final switch (editMode) {
            case EditMode.TileEditor:
                drawTileEditor(camera);
                break;
            case EditMode.Play: 
            break;
        }
        toolsPanel.draw();
        if (drawEditorPanel) {
            editorPanel.draw(); 
        }
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
		// correct for smaller tileset
		camera.zoom *= 2;
		camera.target.x /= 2;
		camera.target.y /= 2;

		BeginMode2D(camera);
		TileIndex i0, i1;
		auto tilemapWidth  = tilemapTexture.width / 8;
		auto tilemapHeight = tilemapTexture.height / 8;
        tilemap.tilemap.getTileBoundsFromScreenCoords(Rectangle(0, 1080, 1920, 1080), camera, i0, i1);
        for (int i = i0.x; i < i1.x; ++i) {
            for (int j = i0.y; j < i1.y; ++j) {
            	auto tileIndex = tilemap.tilemap.get(i, j);
                if (tileIndex > 0) {
                	int flipXW = 8;
                	if ((tileIndex & 0x100) != 0) {
                		tileIndex &= ~0x100;
                		flipXW = -flipXW;
                	}
                	--tileIndex;
                	auto tx = tileIndex % tilemapWidth, ty = tileIndex / tilemapWidth;
                	if (ty >= tilemapHeight) {
                		DrawRectangleV(tileToWorldCoords(TileIndex(i, j)), Vector2(8, 8), PINK);
                	} else {
                		//writefln("rendering %s => %s %s", tileIndex, tx, ty);
                		DrawTextureRec(tilemapTexture, Rectangle(tx * 8, ty * 8, flipXW, 8), tileToWorldCoords(TileIndex(i, j)), WHITE);
                	}
                }
            }
        }
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

	size_t counter = 0;

	while (!WindowShouldClose()) {
		MouseUI.beginFrame();
		editor.renderUI();

		auto camera = cam.camera;
		//if (++counter % 15 == 0) {
		//	editor.tilemap.lazyRebuildAllTilesOnScreen(camera);
		//}
		//tileEditor.renderUI();

		player.update();
		cam.update();
		editor.update(cam.camera);

		BeginDrawing();
		ClearBackground(BLACK);

		// draw tiles
		tileRenderer.render(camera);
		editor.render(camera);

		// draw sprites
		sprites.render(camera);

		// draw UI
		EndDrawing();
	}
	CloseWindow();
}
