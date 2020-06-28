import raylib;
import std.stdio;
import agj.ui;


void main() {
	int screenWidth = 1920, screenHeight = 1080;
	InitWindow(screenWidth, screenHeight, "asset game jam");
	SetTargetFPS(60);

	GUIPanel panelTest;
	panelTest.position = Vector2(0, 0);
	panelTest.width = 200;

	enum Test { Foo, Bar, Baz };
	Test testEnumValue;

	while (!WindowShouldClose()) {
		MouseUI.beginFrame();

		panelTest.beginUI();
		panelTest.textRect("hello world!");
		if (panelTest.button("click me!")) {
			writefln("button clicked!");
		}
		if (panelTest.horizontalSelectionToggle(testEnumValue)) {
			writefln("enum set to %s", testEnumValue);
		}
		panelTest.endUI();
		
		BeginDrawing();
		ClearBackground(BLACK);
		panelTest.draw();

		EndDrawing();
	}
	CloseWindow();
}
