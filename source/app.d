import raylib;
version = BindBC_Static;
import bindbc.nuklear;
import std.exception: enforce;
import std.format: format;
import std.c.stdlib: malloc, free, realloc;

extern(C) void* nkAlloc (nk_handle handle, void* ptr, size_t size) nothrow @nogc {
	return ptr ? malloc(size) : realloc(ptr, size);
}
extern(C) void nkFree (nk_handle, void* ptr) nothrow @nogc {
	free(ptr);
}

struct NkInit {
	nk_context context;
	nk_allocator allocator;
	nk_font_atlas atlas;
	void[] memory;
	this(this) {
		version(BindNuklear_Static){}
		else {
			NuklearSupport support = loadNuklear();
			enforce(support == NuklearSupport.Nuklear4,
				format("expected %s, got %s",
					NuklearSupport.Nuklear4,
					support));
		}
		allocator.alloc = &nkAlloc;
		allocator.free = &nkFree;

		nk_font_atlas_init_default(&atlas);		
		nk_font_atlas_begin(&atlas);
		nk_font_atlas_add_from_file(&atlas, "assets/fonts/Calibri.ttf", 13, 0);
		const void* img = nk_font_atlas_bake(&atlas, &img_width, &img_height, NK_FONT_ATLAS_RGBA32);
		nk_font_atlas_end(&atlas);	
		nk_init(&context, &allocator, atlas);
	}
	~this() {

	}
}



enum {EASY, HARD};
static int op = EASY;
static float value = 0.6f;
static int i =  20;


void main() {
	NkInit nkInit;
	nk_context* nk = &nkInit.context;

	InitWindow(800, 600, "Hello, Raylib-D!");
	while (!WindowShouldClose())
	{
		// BeginDrawing();
		// ClearBackground(RAYWHITE);
		// DrawText("Hello, World!", 400, 300, 28, BLACK);
		// EndDrawing();

		if (nk_begin(nk, "Show", nk_rect(50, 50, 220, 220),
			NK_WINDOW_BORDER|NK_WINDOW_MOVABLE|NK_WINDOW_CLOSABLE)) {
			/* fixed widget pixel width */
			nk_layout_row_static(nk, 30, 80, 1);
			if (nk_button_label(nk, "button")) {
				/* event handling */
			}

			/* fixed widget window ratio width */
			nk_layout_row_dynamic(nk, 30, 2);
			if (nk_option_label(nk, "easy", op == EASY)) op = EASY;
			if (nk_option_label(nk, "hard", op == HARD)) op = HARD;

			/* custom widget pixel width */
			nk_layout_row_begin(nk, NK_STATIC, 30, 2);
			{
				nk_layout_row_push(nk, 50);
				nk_label(nk, "Volume:", NK_TEXT_LEFT);
				nk_layout_row_push(nk, 110);
				nk_slider_float(nk, 0, &value, 1.0f, 0.1f);
			}
			nk_layout_row_end(nk);
		}
		nk_end(nk);
	}
	CloseWindow();
}