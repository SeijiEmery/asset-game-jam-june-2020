import raylib;

void main()
{
	InitWindow(800, 600, "Hello, Raylib-D!");
	while (!WindowShouldClose())
	{
		BeginDrawing();
		ClearBackground(RAYWHITE);
		DrawText("Hello, World!", 400, 300, 28, BLACK);
		EndDrawing();
	}
	CloseWindow();
}