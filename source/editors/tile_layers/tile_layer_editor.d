module agj.editors.tile_layers.tile_layer_editor;

class TileEditor {
    private GUIPanel toolsPanel;
    private GUIPanel editorPanel;
    enum EditMode { TileEditor, Play }
    enum DrawMode { None, Point, Rect }
    enum FillMode { Default, ReplaceEmpty }
    EditMode editMode;
    DrawMode drawMode = DrawMode.Point;
    TileLayer activeLayer = TileLayer.Wall;
    FillMode fillMode;
    private bool drawEditorPanel;

    private Texture2D       texture;
    private size_t          tileCount;
    private auto            roomLayerMap  = new TileMap!TileLayer();
    private auto            drawnTileMap  = new TileMap!ubyte();

    this () { 
        texture = LoadTexture("assets/tiles/tiles.png");
        tileCount = (texture.width / 8) * (texture.height / 8);
        writefln("loaded tileset: %s x %s (%s tiles x %s tiles = %s tiles)", 
            texture.width, texture.height,
            texture.width / 8, texture.height / 8,
            texture.width * texture.height / 64);
        toolsPanel.position = Vector2(0, 0);
    }
    private void drawTileEditorToolsWindow () {
        editorPanel.beginUI();
        editorPanel.horizontalSelectionToggle(drawMode);
        editorPanel.horizontalSelectionToggle(activeLayer);
        editorPanel.horizontalSelectionToggle(fillMode);
        editorPanel.endUI();

        // tile editor hotkeys
        if (IsKeyPressed(KeyboardKey.KEY_R)) { drawMode = DrawMode.Rect; }
        if (IsKeyPressed(KeyboardKey.KEY_E)) { drawMode = DrawMode.Point; }
        if (IsKeyPressed(KeyboardKey.KEY_F)) { fillMode = fillMode == FillMode.Default ? FillMode.ReplaceEmpty : FillMode.Default; }
        if (IsKeyPressed(KeyboardKey.KEY_D)) { activeLayer = TileLayer.Wall; }
        if (IsKeyPressed(KeyboardKey.KEY_A)) { activeLayer = TileLayer.Air; }
        if (IsKeyPressed(KeyboardKey.KEY_W)) {
            switch (activeLayer) {
                case TileLayer.Water: activeLayer = TileLayer.WaterFall; break;
                case TileLayer.WaterFall: activeLayer = TileLayer.WaterPipe; break;
                default: activeLayer = TileLayer.Water;
            }
        }
        if (IsKeyPressed(KeyboardKey.KEY_L)) {
            switch (activeLayer) {
                case TileLayer.Lava: activeLayer = TileLayer.LavaFall; break;
                case TileLayer.LavaFall: activeLayer = TileLayer.LavaPipe; break;
                default: activeLayer = TileLayer.Lava;
            }
        }
        if (IsKeyPressed(KeyboardKey.KEY_L)) {
            switch (activeLayer) {
                case TileLayer.Lava: activeLayer = TileLayer.LavaFall; break;
                case TileLayer.LavaFall: activeLayer = TileLayer.LavaPipe; break;
                default: activeLayer = TileLayer.Lava;
            }
        }
        if (IsKeyPressed(KeyboardKey.KEY_S)) {
            switch (activeLayer) {
                case TileLayer.Platform: activeLayer = TileLayer.Support; break;
                default: activeLayer = TileLayer.Platform;
            }
        }
        if (IsKeyPressed(KeyboardKey.KEY_D)) { activeLayer = TileLayer.Ladder; }
        //if (IsKeyPressed(KeyboardKey.KEY_T)) { activeLayer = TileLayer.Torch; }
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
    TileLayer fillLayer;

    private void beginDrawingRect(TileIndex start, TileLayer layer) {
        drawingRectFillShape = true;
        fillShapeBeginPos = fillShapeEndPos = start;
        fillLayer = layer;
    }
    private void endDrag() {
        drawingRectFillShape = false;
        if (fillMode != FillMode.ReplaceEmpty || fillLayer == TileLayer.None) {
            roomLayerMap.fillRect(fillShapeBeginPos, fillShapeEndPos, fillLayer);
        } else { 
            roomLayerMap.fillRect(fillShapeBeginPos, fillShapeEndPos, fillLayer, 
                delegate(TileLayer layer){ return layer == TileLayer.None; });
        }
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
            auto selectedTileType = roomLayerMap.get(selectedTile.x, selectedTile.y);
            if (selectedTileType != TileLayer.None) {
                activeLayer = selectedTileType;
            }
        }

        // draw tile layers
        TileIndex i0, i1;
        roomLayerMap.getTileBoundsFromScreenCoords(Rectangle(0, 1080, 1920, 1080), camera, i0, i1);

        //msg ~= format("\ngot bounds: %s %s", i0, i1);
        //msg ~= format("\nbounds: %s", roomLayerMap.bounds);
        //msg ~= format("\nchunk bounds: %s", roomLayerMap.chunkBounds);

        for (int i = i0.x; i < i1.x; ++i) {
            for (int j = i0.y; j < i1.y; ++j) {
                auto tile = roomLayerMap.get(i, j);
                if (tile != TileLayer.None) {
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
                    if (fillMode != FillMode.ReplaceEmpty || roomLayerMap.get(selectedTile.x, selectedTile.y) == TileLayer.None) {
                        roomLayerMap.get(selectedTile.x, selectedTile.y) = activeLayer;
                    }
                } else if (MouseUI.buttonDown(MouseButton.MOUSE_RIGHT_BUTTON)) {
                    roomLayerMap.get(selectedTile.x, selectedTile.y) = TileLayer.None;
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
                    beginDrawingRect(selectedTile, TileLayer.None);
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
                        fillLayer == TileLayer.None ? BLACK : fillLayer.toColor);
                }
                // draw tile debug
                auto tilePos = selectedTile.tileToWorldCoords();
                DrawRectangleV(tilePos, Vector2(8, 8), ORANGE);

                break;
        }

        // draw pixel debug
        DrawRectangleV(Vector2(cast(double)cast(int)worldPos.x, cast(double)cast(int)worldPos.y), Vector2(1, 1), RED);






        //string msg = format("mouse pos: %s %s", mousePos.x, mousePos.y);
        //msg ~= format("\nworld pos: %s %s", worldPos.x, worldPos.y);
        //msg ~= format("\ntile pos: %s %s", selectedTile.x, selectedTile.y);

        //auto tileWorldPos = selectedTile.tileToWorldCoords();
        //msg ~= format("\nworld pos: %s %s", tileWorldPos.x, tileWorldPos.y);

        //auto tileScreenPos = selectedTile.tileToScreenCoords(camera);
        //msg ~= format("\nscreen pos: %s %s", tileScreenPos.x, tileScreenPos.y);

        // do tile edits (okay, shouldn't really be in a render function, but whatever...)
        


        

        EndMode2D();

        //DrawText(msg.toStringz, 0, 0, 16, GOLD);
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
