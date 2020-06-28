module agj.tilemap.operations;
import agj.tilemap.tilemap;


void fillRect (T)(ref TileMap!T tilemap, TileIndex start, TileIndex end, T value) {
    import std.algorithm: swap;
    if (start.x > end.x) { swap(start.x, end.x); }
    if (start.y > end.y) { swap(start.y, end.y); }
    ++end.x;
    ++end.y;
    for (int i = start.x; i < end.x; ++i) {
        for (int j = start.y; j < end.y; ++j) {
            tilemap.get(i, j) = value;
        }
    }
}
void fillRect (T)(ref TileMap!T tilemap, TileIndex start, TileIndex end, T value, bool delegate(T) predicate) {
    import std.algorithm: swap;
    if (start.x > end.x) { swap(start.x, end.x); }
    if (start.y > end.y) { swap(start.y, end.y); }
    ++end.x;
    ++end.y;
    for (int i = start.x; i < end.x; ++i) {
        for (int j = start.y; j < end.y; ++j) {
            if (predicate(tilemap.get(i, j))) {
                tilemap.get(i, j) = value;
            }
        }
    }
}
