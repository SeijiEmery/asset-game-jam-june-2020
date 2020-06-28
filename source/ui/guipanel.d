module agj.ui.guipanel;
import agj.ui.mouse;
import agj.ui.utils: lighten;
import std.string: toStringz;
import raylib;


struct GUIPanel {
    public Vector2  position = Vector2(0, 0);
    public int      width = 0;
    public Rectangle layout;
    private GUIRect[] elements;
    private Vector2   dragStartPos = Vector2(0, 0);
    public bool moveable = true;
    private bool hasMouseover = false;
    public Color color = GRAY;
    @property int height () { return cast(int)layout.height; }

    public void beginUI () {
        layout.x = position.x + 6;
        layout.y = position.y + 24;
        layout.width = width - 12;
        layout.height = 30;
        elements.length = 0;
        hasMouseover = false;
    }
    public void endUI () {
        layout.x = position.x;
        layout.y = position.y;
        layout.width = width;
        if (moveable) {
            switch (MouseUI.beginDragOver(MouseButton.MOUSE_LEFT_BUTTON, layout, &updateDrag, null)) {
                case MouseUI.Result.BeginDrag: dragStartPos = Vector2(GetMouseX(), GetMouseY()); break;
                case MouseUI.Result.Mouseover: hasMouseover = true; break;
                default:
            }
        }
    }
    private void updateDrag() {
        position.x += GetMouseX() - dragStartPos.x;
        position.y += GetMouseY() - dragStartPos.y;
        dragStartPos = Vector2(GetMouseX(), GetMouseY());
    }
    public Rectangle textRect (string text, Color textColor = WHITE, Color backgroundColor = BLACK) {
        Rectangle rect = layout;
        rect.height = 25;
        layout.y += 32;
        layout.height += 28;
        elements ~= GUIRect(text, rect, textColor, backgroundColor);
        return rect;
    }
    public bool button (string text, Color textColor = WHITE, Color backgroundColor = BLACK) {
        auto rect = textRect(text, textColor, backgroundColor);
        switch (MouseUI.pressedOver(MouseButton.MOUSE_LEFT_BUTTON, rect)) {
            case MouseUI.Result.Pressed:
                lighten(elements[$-1].backgroundColor, 10);
                return true;
            case MouseUI.Result.Mouseover:
                lighten(elements[$-1].backgroundColor, 30);
                return false;
            default:
                return false;
        }
    }
    public bool verticalSelectionToggle(T)(ref T value, Color textColor = WHITE, Color backgroundColor = BLACK) {
        import std.traits;
        import std.conv: to;
        bool changed = false;
        bool first = true;
        foreach (val; [EnumMembers!T]) {
            if (button(val.to!string, textColor, backgroundColor)) {
                value = val;
                changed = true;
                lighten(elements[$-1].backgroundColor, 20);
            } else if (val == value) {
                lighten(elements[$-1].backgroundColor, 30);
            }
            if (first) { 
                first = false;
            } else {
                elements[$-1].rect.y -= 5;
                //layout.height -= 5;
                layout.y -= 5;
            }
        }
        return changed;
    }
    public bool horizontalSelectionToggle(T)(ref T value, Color textColor = WHITE, Color backgroundColor = BLACK) {
        import std.traits;
        import std.conv: to;
        bool changed = false;
        bool first = true;

        Rectangle rect = layout;
        rect.height = 25;
        layout.y += 32;
        layout.height += 28;

        foreach (val; [EnumMembers!T]) {
            string name = val.to!string;
            if (first) { first = false; }
            else { rect.x += rect.width + 2; }
            rect.width = MeasureText(name.toStringz, 16) + 18;
            Color color = backgroundColor;

            switch (MouseUI.pressedOver(MouseButton.MOUSE_LEFT_BUTTON, rect)) {
                case MouseUI.Result.Pressed:
                    lighten(color, 10);
                    value = val;
                    changed = true;
                    break;
                case MouseUI.Result.Mouseover:
                    lighten(color, 30);
                    break;
                default:
            }
            if (value == val) {
                lighten(color, 50);
            }
            elements ~= GUIRect(name, rect, textColor, color);
        }
        return changed;
    }
    public void draw() {
        Color tempColor = color;
        if (hasMouseover) lighten(tempColor, 30);
        DrawRectangleRec(layout, tempColor);
        foreach (element; elements) {
            DrawRectangleRec(element.rect, element.backgroundColor);

            int textWidth = MeasureText(element.text.toStringz, 16);
            int width = cast(int)element.rect.width - 8;
            int excessHalfWidth = width > textWidth ? (width - textWidth) / 2 : 0;
            DrawText(element.text.toStringz, cast(int)element.rect.x + 4 + excessHalfWidth, cast(int)element.rect.y + 4, 16, element.textColor);
        }
    }
}

struct GUIRect {
    string          text;
    Rectangle       rect;
    Color           textColor;
    Color           backgroundColor;
}
