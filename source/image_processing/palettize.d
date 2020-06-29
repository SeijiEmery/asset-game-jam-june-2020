module agj.image_processing.palettize;
import raylib;
import std.algorithm: map;
import std.array: array;


struct Palette(T = ubyte) {
    Color[] colors;

    T encode (Color color) {
        foreach (i, c; colors) {
            if (c == color) {
                return cast(T)i;
            }
        }
        colors ~= color;
        return cast(T)(colors.length - 1);
    }
    Color decode (T value) const {
        size_t index = value;
        return index < colors.length ? 
            colors[index] : MAGENTA;
    }
}
struct PalettizedTexture(T = ubyte) {
    Palette!T palette;
    T[]     data;
    size_t  width;
    size_t  height;

    ref T get (size_t i, size_t j) {
        return data[i + j * width];
    }
}

PalettizedTexture!ubyte palletize (ref const(Texture2D) texture) {
    return texture.GetTextureData.palletize;
}
PalettizedTexture!ubyte palletize (Image image) {
    size_t w = image.width, h = image.height;
    Palette!ubyte palette;
    ubyte[] data = image.GetImageData[0..w*h]
        .map!((color) => palette.encode(color))
        .array;
    return PalettizedTexture!ubyte(palette, data, w, h);
}
void drawPalletteHorizontal (ref const(Palette!ubyte) palette, Vector2 pos, Vector2 size = Vector2(10,10), int spacing = 1) {
    foreach (color; palette.colors) {
        DrawRectangleV(pos, size, color);
        pos.x += size.x + spacing;
    }
}

Color[] decode (T)(ref const(PalettizedTexture!T) texture) {
    return texture.data.map!((value) => texture.palette.decode(value)).array;
}
Image toImage (T)(ref const(PalettizedTexture!T) texture) {
    auto colors = texture.decode;
    return LoadImageEx(&colors[0], cast(int)texture.width, cast(int)texture.height);
}
Texture2D toTexture (T)(ref const(PalettizedTexture!T) texture) {
    return texture.toImage.LoadTextureFromImage;
}
