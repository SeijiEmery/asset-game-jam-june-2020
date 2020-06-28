module agj.ui.utils;
import raylib;

void lighten (ref Color color, ubyte amount = 10, ubyte max = 255) {
    if (cast(uint)color.r + amount < ubyte.max) color.r += amount; else color.r = ubyte.max;
    if (cast(uint)color.g + amount < ubyte.max) color.g += amount; else color.g = ubyte.max;
    if (cast(uint)color.b + amount < ubyte.max) color.b += amount; else color.b = ubyte.max;
}
