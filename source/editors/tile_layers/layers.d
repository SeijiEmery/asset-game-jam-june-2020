module agj.editors.tile_layers.layers;

enum TileLayerFlag : ubyte {
    Write       = 1 << 0,
    Wall        = 1 << 1,
    Ladder      = 1 << 2,
    Water       = 1 << 3,
    Platform    = 1 << 4,
    Support     = 1 << 5,
}

enum TileLayer {
    None, Air, Wall, Water, Lava, Ladder, Platform, Support, WaterPipe, WaterFall, LavaPipe, LavaFall, 
}
Color toColor (TileLayer layer) {
    final switch (layer) {
        case TileLayer.None: return Color(0,0,0,0); 
        case TileLayer.Air:  return GRAY; 
        case TileLayer.Wall: return BROWN; 
        case TileLayer.Water: return DARKBLUE; 
        case TileLayer.WaterPipe: return BLUE; 
        case TileLayer.WaterFall: return SKYBLUE; 
        case TileLayer.Lava:  return RED; 
        case TileLayer.LavaPipe:  return MAROON; 
        case TileLayer.LavaFall:  return ORANGE; 
        case TileLayer.Ladder: return LIME; 
        case TileLayer.Platform: return GREEN; 
        case TileLayer.Support: return DARKGREEN; 
    }
}
