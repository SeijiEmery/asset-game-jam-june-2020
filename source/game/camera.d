module agj.game.camera;
public import agj.game.utils;
import agj.game.player;
import agj.ui: MouseUI;
import std.stdio: writefln;


struct CameraControllerState {
    bool followPlayer;
    bool isDraggingCamera;
    Vector2 dragStartPos;
}

// update camera controls
void update (ref Camera2D camera, ref Player player, ref CameraControllerState state) {
    double dt = GetFrameTime();

    // camera controls
    auto prevZoom = camera.zoom;
    if (IsGamepadAvailable(0)) {
        camera.zoom += GetFrameTime() * 5.0 * (
            GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_TRIGGER) -
            GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_LEFT_TRIGGER)
        );

        camera.target.x += dt * 1000 / camera.zoom * GetStickInput(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_X);
        camera.target.y += dt * 1000 / camera.zoom * GetStickInput(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_Y);

        //writefln("LS.X %s => %s LS.Y %s => %s RS.X %s => %s RS.Y %s => %s",
        //  GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_LEFT_X),
        //  GetStickInput(0, GamepadAxis.GAMEPAD_AXIS_LEFT_X),
        //  GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_LEFT_Y),
        //  GetStickInput(0, GamepadAxis.GAMEPAD_AXIS_LEFT_Y),
        //  GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_X),
        //  GetStickInput(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_X),
        //  GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_Y),
        //  GetStickInput(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_Y),
        //);

        //writefln("LS.X %s LS.Y %s RS.X %s RS.Y %s",
        //  GetStickInput(0, GamepadAxis.GAMEPAD_AXIS_LEFT_X),
        //  GetStickInput(0, GamepadAxis.GAMEPAD_AXIS_LEFT_Y),
        //  GetStickInput(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_X),
        //  GetStickInput(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_Y),
        //);

        if (IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_THUMB)) {
            camera.target = player.sprite.position;
        }
        if (IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_LEFT_THUMB)) {
            state.followPlayer = !state.followPlayer;
        }
    }

    camera.zoom += GetFrameTime() * GetMouseWheelMove() * 3;

    if (camera.zoom > 10) camera.zoom = 10;
    if (camera.zoom < 0.5) camera.zoom = 0.5;
    if (camera.zoom != prevZoom) writefln("set zoom %s", camera.zoom);      


    if (MouseUI.beginDrag(
        MouseButton.MOUSE_MIDDLE_BUTTON, 
        delegate () {
            //writefln("drag movement: %s %s", GetMouseX() - state.dragStartPos.x, GetMouseY() - state.dragStartPos.y);
            camera.target.x += (state.dragStartPos.x - GetMouseX()) / camera.zoom;
            camera.target.y += (state.dragStartPos.y - GetMouseY()) / camera.zoom;
            state.dragStartPos = Vector2(GetMouseX(), GetMouseY());
        },
        delegate () {
            //writefln("stop drag");
            state.isDraggingCamera = false;
        }
    )) {
        //writefln("start drag");
        state.isDraggingCamera = true;
        state.dragStartPos = Vector2(GetMouseX(), GetMouseY());
    }

    //writefln("camera target: %s", camera.target);
    if (state.followPlayer) {
        camera.target.lerpTo(Vector2(
            -player.sprite.position.x,
            -player.sprite.position.y), dt * 4);
    }
}
