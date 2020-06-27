import raylib;
version = BindBC_Static;
//import bindbc.nuklear;
import std.exception: enforce;
import std.format: format;
import std.c.stdlib: malloc, free, realloc;
import sprites;
import std.stdio;

//extern(C) void* nkAlloc (nk_handle handle, void* ptr, size_t size) nothrow @nogc {
//	return ptr ? malloc(size) : realloc(ptr, size);
//}
//extern(C) void nkFree (nk_handle, void* ptr) nothrow @nogc {
//	free(ptr);
//}

//struct NkInit {
//	nk_context context;
//	nk_allocator allocator;
//	nk_font_atlas atlas;
//	void[] memory;
//	this(this) {
//		version(BindNuklear_Static){}
//		else {
//			NuklearSupport support = loadNuklear();
//			enforce(support == NuklearSupport.Nuklear4,
//				format("expected %s, got %s",
//					NuklearSupport.Nuklear4,
//					support));
//		}
//		allocator.alloc = &nkAlloc;
//		allocator.free = &nkFree;
//		nk_font_atlas_init_default(&atlas);		
//		nk_font_atlas_begin(&atlas);
//		nk_font_atlas_add_from_file(&atlas, "assets/fonts/Calibri.ttf", 13, 0);
//		const void* img = nk_font_atlas_bake(&atlas, &img_width, &img_height, NK_FONT_ATLAS_RGBA32);
//		nk_font_atlas_end(&atlas);	
//		nk_init(&context, &allocator, atlas);
//	}
//	~this() {

//	}
//}
void main() {
	InitWindow(800, 600, "Hello, Raylib-D!");
	Sprites Sprites;
	Sprites.load();

	auto sprite = Sprites.Player.Roll;
	double SPEED = 10;
	//size_t i = 0;

	while (!WindowShouldClose()) {
		 BeginDrawing();
		 ClearBackground(RAYWHITE);
		 DrawText("Hello, World!", 400, 300, 28, BLACK);

		 //DrawTextureQuad(sprite.frames[0], Vector2(0, 0), Vector2(400, 300), Rectangle(32,32), WHITE);
		 size_t i = cast(size_t)(GetTime() * sprite.animationSpeed * SPEED) % sprite.frames.length;
		 //writefln("%s %s", GetTime(), cast(size_t)GetTime());
		 DrawTexture(sprite.frames[i], 400, 300, WHITE);
		 //i = (i + 1) % sprite.frames.length;

		 EndDrawing();
	}
	CloseWindow();
}