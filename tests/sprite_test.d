import raylib;
import std.stdio;
import agj.sprite: Sprite, SpriteRenderer;
import agj.game.camera;
import agj.game.player;
import agj.game.utils;
import sprites;


void main() {
    int screenWidth = 1920, screenHeight = 1080;
    InitWindow(screenWidth, screenHeight, "asset game jam");
    SetTargetFPS(60);

    // preload all assets
    //Sprites.load();

    SpriteRenderer sprites;
    auto player = Player(sprites);
    auto cam = CameraController(player, screenWidth, screenHeight);

    Texture2D tiles = LoadTexture("assets/tiles/cavesofgallet.png");
    //Texture2D tiles = LoadTexture("assets/tiles/tiles.png");

    auto tree = sprites.create
        .fromAsset(Sprites.Tree01)
        .setPosition(Vector2(400, 200));

    while (!WindowShouldClose()) {
        player.update();
        cam.update();

        // sprite destruction test
        if (IsGamepadAvailable(0) && IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_UP)) {
            tree.destroy();
        }
        
        BeginDrawing();
        ClearBackground(BLACK);

        // draw test background
        auto camera = cam.camera;
        Camera2D backgroundCam = camera;
        const int FOREGROUND_BACKGROUND_SCALE = 2;
        backgroundCam.zoom *= FOREGROUND_BACKGROUND_SCALE;
        backgroundCam.target.x /= FOREGROUND_BACKGROUND_SCALE;
        backgroundCam.target.y /= FOREGROUND_BACKGROUND_SCALE;
        BeginMode2D(backgroundCam);
        DrawTexture(tiles, 0, 0, WHITE);
        EndMode2D();

        // draw all sprites
        sprites.render(camera);

        EndDrawing();
    }
    CloseWindow();
}
