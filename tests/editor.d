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
	WallDeco 				= 0x12,
	WallVegeation 			= 0x13,
	Torch 					= 0x14,
	Ladder 					= 0x15,
	Platform 				= 0x16,
	Support  	    		= 0x17,

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
Color toColor (LayerType layer) {
	switch (layer) {
		case LayerType.None: return Color(0,0,0,0); 
        case LayerType.Air:  return GRAY; 
        case LayerType.Ground: return BROWN; 
        case LayerType.WaterBody: return DARKBLUE; 
        case LayerType.WaterCascadeSmall: return BLUE; 
        case LayerType.WaterCascadeLarge: return SKYBLUE; 
        case LayerType.LavaBody:  			return RED; 
        case LayerType.LavaCascadeSmall:  	return MAROON; 
        case LayerType.LavaCascadeLarge:  	return ORANGE; 
        case LayerType.Ladder: 				return LIME; 
        case LayerType.Platform: 			return GREEN; 
        case LayerType.Support: 			return DARKGREEN; 
		default: return PINK;

	}
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
	TileMap!uint tiles
) {

}


enum FillMode { Default, FillEmpty }

void forEachRect(alias cb)(int x, int y, uint w, uint h) {
	for (; h > 0; ++y, --h) {
		for (; w > 0; ++x, --w) {
			cb(x, y);
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

	bool drawPt (FillMode drawMode = FillMode.Default)(int x, int y, LayerType value) {
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
	private void drawRect(FillMode mode, T)(int x, int y, uint w, uint h, T value) {
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
	void drawRect (T)(int x, int y, uint w, uint h, T value, FillMode drawMode) {
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

	this (int x, int y, T value) {
		this.value = value;
		this.x = x;
		this.y = y;
	}
	void execute(RenderedTileMap tilemap) {
		tilemap.get(x, y, prevValue);
		tilemap.drawPt(x, y, value);
	}
	void unexecute(RenderedTileMap tilemap) {
		tilemap.drawPt(x, y, prevValue);
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

	void drawPoint(T)(TileIndex pos, T value, FillMode drawMode = FillMode.Default) {
		T tile;
		tilemap.get(pos.x, pos.y, tile);
		if (tile != value && (drawMode != FillMode.FillEmpty || !tile)) {
			executeOp(new DrawTilePointOperation!T(pos.x, pos.y, value));
		}
	}
	void drawRect(T)(TileIndex a, TileIndex b, T value, FillMode drawMode = FillMode.Default) {
		import std.algorithm: swap;
		if (a.x > b.x) swap(a.x, b.x);
		if (a.y > b.y) swap(a.y, b.y);

		auto x = a.x, y = a.y;
		auto w = b.x - a.x, h = b.y - a.y;
		assert(w >= 0 && h >= 0);

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
        if (IsKeyPressed(KeyboardKey.KEY_R)) { drawMode = DrawMode.Rect; }
        if (IsKeyPressed(KeyboardKey.KEY_E)) { drawMode = DrawMode.Point; }
        if (IsKeyPressed(KeyboardKey.KEY_F)) { fillMode = fillMode == FillMode.Default ? FillMode.FillEmpty : FillMode.Default; }
        if (IsKeyPressed(KeyboardKey.KEY_D)) { activeLayer = LayerType.Ground; }
        if (IsKeyPressed(KeyboardKey.KEY_A)) { activeLayer = LayerType.Air; }
        if (IsKeyPressed(KeyboardKey.KEY_W)) {
            switch (activeLayer) {
                case LayerType.WaterBody: activeLayer = LayerType.WaterCascadeSmall; break;
                case LayerType.WaterCascadeSmall: activeLayer = LayerType.WaterCascadeLarge; break;
                default: activeLayer = LayerType.WaterBody;
            }
        }
        if (IsKeyPressed(KeyboardKey.KEY_L)) {
            switch (activeLayer) {
                case LayerType.LavaBody: activeLayer = LayerType.LavaCascadeSmall; break;
                case LayerType.LavaCascadeSmall: activeLayer = LayerType.LavaCascadeLarge; break;
                default: activeLayer = LayerType.LavaBody;
            }
        }
        if (IsKeyPressed(KeyboardKey.KEY_S)) {
            switch (activeLayer) {
                case LayerType.Platform: activeLayer = LayerType.Support; break;
                default: activeLayer = LayerType.Platform;
            }
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
    size_t opCountAtStart;

    private void beginDrawingRect(TileIndex start, LayerType layer) {
        drawingRectFillShape = true;
        fillShapeBeginPos = fillShapeEndPos = start;
        fillLayer = layer;
        opCountAtStart = operationIndex;
    }
    private void endDrag() {
        drawingRectFillShape = false;
        operationIndex = opCountAtStart;
        drawRect(fillShapeBeginPos, fillShapeEndPos, fillLayer);
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

        //msg ~= format("\ngot bounds: %s %s", i0, i1);
        //msg ~= format("\nbounds: %s", roomLayerMap.bounds);
        //msg ~= format("\nchunk bounds: %s", roomLayerMap.chunkBounds);

        for (int i = i0.x; i < i1.x; ++i) {
            for (int j = i0.y; j < i1.y; ++j) {
            	LayerType tile;
            	tilemap.get(i, j, tile);
                if (tile != LayerType.None) {
                    DrawRectangleV(tileToWorldCoords(TileIndex(i, j)), Vector2(8, 8), tile.toColor);
                }
            }
        }
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
                    beginDrawingRect(selectedTile, activeLayer);
                }
                else if (MouseUI.beginDrag(MouseButton.MOUSE_RIGHT_BUTTON, null, &endDrag)) {
                    beginDrawingRect(selectedTile, LayerType.None);
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
                    DrawRectangleV(start.tileToWorldCoords, Vector2(8 * (end.x - start.x), 8 * (end.y - start.y)),
                        fillLayer == LayerType.None ? BLACK : fillLayer.toColor);
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

	while (!WindowShouldClose()) {
		MouseUI.beginFrame();
		editor.renderUI();

		//tileEditor.renderUI();

		player.update();
		cam.update();
		editor.update();

		BeginDrawing();
		ClearBackground(BLACK);
		auto camera = cam.camera;

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
