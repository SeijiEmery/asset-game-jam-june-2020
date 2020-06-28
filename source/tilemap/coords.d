module agj.tilemap.coords;
import agj.tilemap.tilemap: TileIndex;
import raylib: Vector2, Camera2D, GetWorldToScreen2D, GetScreenToWorld2D;


Vector2 tileToWorldCoords (TileIndex index) {
    return Vector2(index.x * 8.0, index.y * 8.0);
}
Vector2 tileToScreenCoords (TileIndex index, ref const(Camera2D) camera) {
    return GetWorldToScreen2D(tileToWorldCoords(index), camera);
}
TileIndex worldToTileCoords (Vector2 worldPos) {
    auto index = TileIndex(cast(int)(worldPos.x / 8), cast(int)(worldPos.y / 8));
    return index;
}
TileIndex screenToTileCoords (Vector2 screenPos, ref const(Camera2D) camera) {
    return worldToTileCoords(GetScreenToWorld2D(screenPos, camera));
}
