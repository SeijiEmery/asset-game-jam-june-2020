module agj.game.utils;
public import raylib;

Vector2 lerp (Vector2 a, Vector2 b, double t) {
    if (t < 0) t = 0;
    if (t > 1) t = 1;
    return Vector2(
        a.x * (1 - t) + b.x * t,
        a.y * (1 - t) + b.y * t
    );
}
ref Vector2 lerpTo (ref Vector2 a, Vector2 b, double t) {
    return a = lerp(a, b, t);
}

double GetStickInput(int gamepad, GamepadAxis axis) {
    import std.math;
    double x = GetGamepadAxisMovement(0, axis);
    double sign = x >= 0 ? +1 : -1;
    //if (axis == GamepadAxis.GAMEPAD_AXIS_LEFT_Y || axis == GamepadAxis.GAMEPAD_AXIS_RIGHT_Y) {
    //  sign = -sign;
    //}
    x = pow(abs(x), 2.3);
    return x > 2.5e-2 ? x * sign : 0;
}

