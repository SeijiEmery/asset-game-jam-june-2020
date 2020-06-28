import raylib;
import sprites;
import std.stdio;
import agj.sprite: Sprite, SpriteRenderer;
import agj.game.camera;
import agj.game.player;
import agj.game.utils;


void main() {
    int screenWidth = 1920, screenHeight = 1080;
    InitWindow(screenWidth, screenHeight, "asset game jam");
    SetTargetFPS(60);

    Sprites.load(); // preload all sprites
 
    SpriteRenderer sprites;
    Sprites.Player.Roll.animationSpeed = 25;
    auto player = Player(sprites);

    Camera2D camera;
    camera.target = Vector2(0, 0);
    camera.zoom = 4;
    camera.rotation = 0;
    camera.offset = Vector2(screenWidth / 2, screenHeight / 2);
    CameraControllerState cameraControlState;

    Texture2D tiles = LoadTexture("assets/tiles/cavesofgallet.png");
    //Texture2D tiles = LoadTexture("assets/tiles/tiles.png");

    auto tree = sprites.create
        .fromAsset(Sprites.Tree01)
        .setPosition(Vector2(400, 200));

    while (!WindowShouldClose()) {
        player.update();
        camera.update(player, cameraControlState);

        // sprite destruction test
        if (IsGamepadAvailable(0) && IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_UP)) {
            tree.destroy();
        }
        
        BeginDrawing();
        ClearBackground(BLACK);

        // draw test background
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
