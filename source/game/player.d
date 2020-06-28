module agj.game.player;
public import agj.game.utils;
import agj.sprite: Sprite, SpriteRenderer;
import std.stdio: writefln;
import sprites: Sprites;


// update player controls
void update (ref Player player) {
    import std.math;
    double moveInput = 0;
    double dt = GetFrameTime();
    bool dodgeRollPressed = false;
    bool jumpPressed = false;
    bool attackPressed = false;

    if (IsGamepadAvailable(0)) {
        moveInput -= GetStickInput(0, GamepadAxis.GAMEPAD_AXIS_LEFT_X);
        if (IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_RIGHT)) {
            dodgeRollPressed = true;
        }
        if (IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN)) {
            jumpPressed = true;
        }
        if (IsGamepadButtonPressed(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_LEFT)) {
            attackPressed = true;
        }
    }

    bool moving = moveInput.abs > 0;
    
    if (moving && !player.inAttackAnim) {
        player.lastMoveDir = moveInput >= 0 ? 1 : -1;
    }

    if (dodgeRollPressed && !player.inAttackAnim) {
        player.inDodgeRollAnim = true;
        player.sprite.playAnimation(Sprites.Player.Roll);
        player.dodgeRollDirection = player.lastMoveDir;
        player.sprite.setXFlipped(player.dodgeRollDirection < 0);
        writefln("starting dodge roll");
    }

    if (attackPressed && !player.inDodgeRollAnim && !player.inAttackAnim) {
        player.inAttackAnim = true;
        import std.random;
        final switch (std.random.dice(20, 30, 30, 20)) {
            case 0: player.sprite.playAnimation(Sprites.Player.Attack01); break;
            case 1: player.sprite.playAnimation(Sprites.Player.Attack02); break;
            case 2: player.sprite.playAnimation(Sprites.Player.Attack03); break;
            case 3: player.sprite.playAnimation(Sprites.Player.AttackHard); break;
        }
    }

    if (player.inDodgeRollAnim) {
        player.sprite.position.x += player.dodgeRollDirection * dt * 300;
    } else {
        if (moving != player.wasMoving) {
            player.wasMoving = moving;

            if (!player.inAttackAnim) {
                if (moving) player.sprite.playAnimation(Sprites.Player.Run, true);
                else player.sprite.playAnimation(Sprites.Player.Idle, true);
            }
        }
        player.sprite.setXFlipped(player.lastMoveDir < 0);
        if (moving) {
            player.sprite.position.x += moveInput * dt * 150;
        }
        player.sprite.position.y -= GetStickInput(0, GamepadAxis.GAMEPAD_AXIS_LEFT_Y) * dt * 150;
    }
    player.sprite.setCenterOffset(Vector2(5, 0));
}

struct Player {
    Sprite sprite;
    int nextAnimation = 0;
    bool wasMoving = false;
    double lastMoveDir = 1;
    bool inDodgeRollAnim = false;
    bool inAttackAnim = false;
    double dodgeRollDirection = 1;

    this (ref SpriteRenderer renderer) {
        Sprites.Player.Roll.animationSpeed = 25;
        sprite = renderer.create
            .fromAsset(Sprites.Player.Idle, false)
            .setPosition(Vector2(0, 0))
            .onAnimationEnded(&this.onAnimationEnded)
            .setCenterOffset(Vector2(10, 0))
        ;
    }
    void onAnimationEnded (Sprite sprite) {
        if (inDodgeRollAnim) {
            writefln("ending dodge roll");
            inDodgeRollAnim = false;
        }
        if (inAttackAnim) {
            inAttackAnim = false;
            sprite.playAnimation(Sprites.Player.StopAttack, false);
        }
        if (!sprite.playing) {
            sprite.playAnimation(Sprites.Player.Idle, true);
        }
            //final switch (animation % 17) {
            //  case 0: return Sprites.Player.Idle;
            //  case 1: return Sprites.Player.HitwSword;
            //  case 2: return Sprites.Player.Attack03;
            //  case 3: return Sprites.Player.TakeSword;
            //  case 4: return Sprites.Player.Roll;
            //  case 5: return Sprites.Player.Hit;
            //  case 6: return Sprites.Player.Attack02;
            //  case 7: return Sprites.Player.Death;
            //  case 8: return Sprites.Player.PutAwaySword;
            //  case 9: return Sprites.Player.RollSword;
            //  case 10: return Sprites.Player.RunwSword;
            //  case 11: return Sprites.Player.StopAttack;
            //  case 12: return Sprites.Player.Parry;
            //  case 13: return Sprites.Player.AttackHard;
            //  case 14: return Sprites.Player.Attack01;
            //  case 15: return Sprites.Player.Run;
            //  case 16: return Sprites.Player.ParryWithoutHit;
            //  case 17: return Sprites.Player.IdlewSword;
            //}
    }   
}
