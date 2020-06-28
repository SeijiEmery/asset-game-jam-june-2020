module agj.ui.mouse;
import raylib;


struct MouseUI {
    enum Result { None, Mouseover, Pressed, BeginDrag }
    private static bool            handled = false;
    private static bool            dragActive = false;
    private static MouseButton     activeDragButton;
    private static void delegate() onDragUpdate;
    private static void delegate() onDragEnd;

    public static void beginFrame() {
        handled = false;
        if (dragActive && IsMouseButtonUp(activeDragButton)) {
            if (onDragEnd) onDragEnd();
            dragActive = false;
        } else if (dragActive) {
            if (onDragUpdate) onDragUpdate();
            handled = true;
        }
    }
    public static Result pressed (MouseButton button) {
        if (handled) return Result.None;
        if (IsMouseButtonPressed(button)) {
            handled = true;
            return Result.Pressed;
        }
        return Result.None;
    }
    public static Result buttonDown (MouseButton button) {
        return !handled && IsMouseButtonDown(button) ? Result.Pressed : Result.None;
    }
    public static Result pressedOver (MouseButton button, Rectangle screenRect) {
        if (handled) return Result.None;
        if (!CheckCollisionPointRec(Vector2(GetMouseX(), GetMouseY()), screenRect)) return Result.None;
        auto result = pressed(button);
        if (result == Result.None) { handled = true; return Result.Mouseover; }
        return result;
    }
    public static Result beginDrag (MouseButton button, void delegate() onUpdate, void delegate() onEnd) {
        if (handled) return Result.None;
        if (IsMouseButtonPressed(button)) {
            handled = dragActive = true;
            activeDragButton = button;
            onDragUpdate = onUpdate;
            onDragEnd = onEnd;
            return Result.BeginDrag;
        }
        return Result.None;
    }
    public static Result beginDragOver (MouseButton button, Rectangle screenRect, void delegate() onUpdate, void delegate() onEnd) {
        if (handled) return Result.None;
        if (!CheckCollisionPointRec(Vector2(GetMouseX(), GetMouseY()), screenRect)) return Result.None;
        auto result = beginDrag(button, onUpdate, onEnd);
        if (result == Result.None) { handled = true; return Result.Mouseover; }
        return result;
    }
}