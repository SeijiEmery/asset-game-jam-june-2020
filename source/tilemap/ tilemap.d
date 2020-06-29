module agj.tilemap.tilemap;
import agj.utils.bounds: AABB;
import raylib;
import std.exception: enforce;
import std.format: format;
import agj.tilemap.coords;
import cerealed;

// 64 x 64 chunks
struct TileChunk(T = ubyte) {
    T[4096] data;
    AABB!uint bounds;

    ref T get (uint i, uint j) {
        enforce(i < 64 && j < 64, format("indices out of range: %s, %s", i, j));
        bounds.grow(i, j);
        return data[i + j * 64];
    }
}

struct TileIndex { int x; int y; }

class TileMap(T = ubyte) {
    private TileChunk!T[TileIndex] chunks;
    public AABB!int bounds;
    public AABB!int chunkBounds;

    private ref TileChunk!T getChunk (TileIndex index) {
        //writefln("getting chunk %s", index);
        if (index !in chunks) {
            chunkBounds.grow(index.x, index.y);
            chunks[index] = TileChunk!T();
        }
        return chunks[index];
    }
    ref T get (int i, int j) {
        bounds.grow(i, j);

        auto chunkIndex = TileIndex(i >> 6, j >> 6);
        auto tileIndex  = TileIndex(i & 63, j & 63);

        //writefln("tile access: %s %s => %s %s", i, j, chunkIndex, tileIndex);
        
        return getChunk(chunkIndex).get(cast(uint)tileIndex.x, cast(uint)tileIndex.y);
    }

    void getTileBoundsFromScreenCoords(Rectangle screen, ref const(Camera2D) camera, out TileIndex minima, out TileIndex maxima) {
        if (!bounds.initialized) {
            minima = maxima = TileIndex(0, 0);
        }

        minima = screenToTileCoords(Vector2(screen.x, screen.y), camera);
        if (minima.x > bounds.minBoundX) minima.x = bounds.minBoundX;
        if (maxima.x < bounds.maxBoundX) maxima.x = bounds.maxBoundX;
        if (minima.y > bounds.minBoundY) minima.y = bounds.minBoundY;
        if (maxima.y < bounds.maxBoundY) maxima.y = bounds.maxBoundY;
        maxima = screenToTileCoords(Vector2(screen.x + screen.width, screen.y + screen.y), camera);
    }
}

struct SavedMapData(T) {
    struct MapChunk {
        TileIndex   index;
        TileChunk!T chunkData;
    }
    AABB!int bounds;
    AABB!int chunkBounds;
    MapChunk[] chunks;
}

ubyte[] save (T)(TileMap!T tilemap) {
    import std.algorithm;
    import std.array;

    SavedMapData!T data;
    data.bounds = tilemap.bounds;
    data.chunkBounds = tilemap.chunkBounds;
    data.chunks = tilemap.chunks.byKeyValue
        .map!((kv) => SavedMapData!T.MapChunk(kv.key, kv.value))
        .array;
    return data.cerealise;
}

void load (T)(TileMap!T map, ubyte[] bytes) {
    auto data = decerealize!(SavedMapData!T)(bytes);
    map.bounds = data.bounds;
    map.chunkBounds = data.chunkBounds;
    map.chunks.clear();
    foreach (chunk; data.chunks) {
        map.chunks[chunk.index] = chunk.chunkData;
    }
}
