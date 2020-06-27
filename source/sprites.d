import std.algorithm: map;
import std.array: array;
import std.string: toStringz;
import raylib;

struct AnimatedSpriteAsset {
    string[]    paths;
    Texture[]   frames = null;
    float       animationSpeed = 1f;

    this (float animationSpeed, string[] paths) { 
        this.animationSpeed = animationSpeed; 
        this.paths = paths;
    }

    @property bool loaded () { return frames != null; }
    @property size_t resourceCount () { return paths.length; }

    void load () {
        frames = paths.map!((path) => LoadTexture(path.toStringz)).array;
    }
}

struct StaticSpriteAsset {
    string          path;
    Texture         sprite;
    private bool    isLoaded = false;

    this (string path) { this.path = path; }

    @property bool loaded () { return isLoaded; }
    @property size_t resourceCount () { return 1; }    

    void load() {
        sprite = LoadTexture(path.toStringz);
        isLoaded = true;
    }
}


struct Sprites {
    StaticSpriteAsset TreeBack02 = StaticSpriteAsset("assets/sprites/Environments/Trees/TreeBack02.png");
    StaticSpriteAsset TreeBack03 = StaticSpriteAsset("assets/sprites/Environments/Trees/TreeBack03.png");
    StaticSpriteAsset TreeBack01 = StaticSpriteAsset("assets/sprites/Environments/Trees/TreeBack01.png");
    StaticSpriteAsset Tree01 = StaticSpriteAsset("assets/sprites/Environments/Trees/Tree01.png");
    StaticSpriteAsset Tree02 = StaticSpriteAsset("assets/sprites/Environments/Trees/Tree02.png");
    StaticSpriteAsset Tree03 = StaticSpriteAsset("assets/sprites/Environments/Trees/Tree03.png");
    StaticSpriteAsset Blood01 = StaticSpriteAsset("assets/sprites/Environments/Blood/Blood01.png");
    StaticSpriteAsset Blood02 = StaticSpriteAsset("assets/sprites/Environments/Blood/Blood02.png");
    StaticSpriteAsset Blood03 = StaticSpriteAsset("assets/sprites/Environments/Blood/Blood03.png");
    StaticSpriteAsset Cloud01 = StaticSpriteAsset("assets/sprites/Environments/Clouds/Cloud01.png");
    StaticSpriteAsset Rock02 = StaticSpriteAsset("assets/sprites/Environments/Rocks/Rock02.png");
    StaticSpriteAsset Rock01 = StaticSpriteAsset("assets/sprites/Environments/Rocks/Rock01.png");
    ShieldSprites Shield;
    GiantSwordSprites GiantSword;
    FireSprites Fire;
    ChestSprites Chest;
    NPC01Sprites NPC01;
    HitSprites Hit;
    Enemy01Sprites Enemy01;
    Enemy02Sprites Enemy02;
    PlayerSprites Player;
    StunAfterParrySprites StunAfterParry;

    private bool isLoaded = false;
    @property bool loaded () { return isLoaded; }
    @property size_t resourceCount () { return 322; }

    void load () {
        isLoaded = true;
        TreeBack02.load();
        TreeBack03.load();
        TreeBack01.load();
        Tree01.load();
        Tree02.load();
        Tree03.load();
        Blood01.load();
        Blood02.load();
        Blood03.load();
        Cloud01.load();
        Rock02.load();
        Rock01.load();
        Shield.Idle.load();
        Shield.Break.load();
        Shield.Create.load();
        GiantSword.GiantSword.load();
        Fire.Fire.load();
        Chest.Idle.load();
        Chest.Open.load();
        NPC01.Idle.load();
        Hit.Fx.load();
        Enemy01.Idle.load();
        Enemy01.Attack.load();
        Enemy01.Stun.load();
        Enemy01.Hit.load();
        Enemy01.Turn.load();
        Enemy01.Parry.load();
        Enemy01.Run.load();
        Enemy02.Idle.load();
        Enemy02.Hit.load();
        Enemy02.Reload.load();
        Enemy02.PrepareShoot.load();
        Enemy02.Run.load();
        Enemy02.PutGunAway.load();
        Enemy02.Shoot.load();
        Player.HitwSword.load();
        Player.Idle.load();
        Player.Attack03.load();
        Player.TakeSword.load();
        Player.Roll.load();
        Player.Hit.load();
        Player.Attack02.load();
        Player.Death.load();
        Player.PutAwaySword.load();
        Player.RollSword.load();
        Player.OpenChest.load();
        Player.RunwSword.load();
        Player.StopAttack.load();
        Player.Parry.load();
        Player.AttackHard.load();
        Player.Attack01.load();
        Player.Run.load();
        Player.ParryWithoutHit.load();
        Player.IdlewSword.load();
        StunAfterParry.Attack03_Player.load();
        StunAfterParry.Attack02_Player.load();
        StunAfterParry.Attack01_Player.load();
    }

    
    struct ShieldSprites {
        AnimatedSpriteAsset Idle = AnimatedSpriteAsset(1f, [
            "assets/sprites/ShieldsUI/Idle/Shield_Idle_01.png",
            "assets/sprites/ShieldsUI/Idle/Shield_Idle_02.png",
            "assets/sprites/ShieldsUI/Idle/Shield_Idle_03.png",
            "assets/sprites/ShieldsUI/Idle/Shield_Idle_04.png",
            "assets/sprites/ShieldsUI/Idle/Shield_Idle_05.png",
            "assets/sprites/ShieldsUI/Idle/Shield_Idle_06.png",
            "assets/sprites/ShieldsUI/Idle/Shield_Idle_07.png",
            "assets/sprites/ShieldsUI/Idle/Shield_Idle_08.png"
        ]);
        AnimatedSpriteAsset Break = AnimatedSpriteAsset(1f, [
            "assets/sprites/ShieldsUI/Break/Shield_Break_01.png",
            "assets/sprites/ShieldsUI/Break/Shield_Break_02.png",
            "assets/sprites/ShieldsUI/Break/Shield_Break_03.png",
            "assets/sprites/ShieldsUI/Break/Shield_Break_04.png",
            "assets/sprites/ShieldsUI/Break/Shield_Break_05.png",
            "assets/sprites/ShieldsUI/Break/Shield_Break_06.png",
            "assets/sprites/ShieldsUI/Break/Shield_Break_07.png",
            "assets/sprites/ShieldsUI/Break/Shield_Break_08.png",
            "assets/sprites/ShieldsUI/Break/Shield_Break_09.png",
            "assets/sprites/ShieldsUI/Break/Shield_Break_10.png"
        ]);
        AnimatedSpriteAsset Create = AnimatedSpriteAsset(1f, [
            "assets/sprites/ShieldsUI/Create/Shield_Create_01.png",
            "assets/sprites/ShieldsUI/Create/Shield_Create_02.png",
            "assets/sprites/ShieldsUI/Create/Shield_Create_03.png",
            "assets/sprites/ShieldsUI/Create/Shield_Create_04.png",
            "assets/sprites/ShieldsUI/Create/Shield_Create_05.png",
            "assets/sprites/ShieldsUI/Create/Shield_Create_06.png",
            "assets/sprites/ShieldsUI/Create/Shield_Create_07.png"
        ]);
    }


    struct GiantSwordSprites {
        AnimatedSpriteAsset GiantSword = AnimatedSpriteAsset(1f, [
            "assets/sprites/Environments/GiantSword/GiantSword_01.png",
            "assets/sprites/Environments/GiantSword/GiantSword_02.png",
            "assets/sprites/Environments/GiantSword/GiantSword_03.png",
            "assets/sprites/Environments/GiantSword/GiantSword_04.png",
            "assets/sprites/Environments/GiantSword/GiantSword_05.png",
            "assets/sprites/Environments/GiantSword/GiantSword_06.png",
            "assets/sprites/Environments/GiantSword/GiantSword_07.png",
            "assets/sprites/Environments/GiantSword/GiantSword_08.png",
            "assets/sprites/Environments/GiantSword/GiantSword_09.png",
            "assets/sprites/Environments/GiantSword/GiantSword_10.png",
            "assets/sprites/Environments/GiantSword/GiantSword_11.png",
            "assets/sprites/Environments/GiantSword/GiantSword_12.png",
            "assets/sprites/Environments/GiantSword/GiantSword_13.png",
            "assets/sprites/Environments/GiantSword/GiantSword_14.png",
            "assets/sprites/Environments/GiantSword/GiantSword_15.png",
            "assets/sprites/Environments/GiantSword/GiantSword_16.png",
            "assets/sprites/Environments/GiantSword/GiantSword_17.png",
            "assets/sprites/Environments/GiantSword/GiantSword_18.png",
            "assets/sprites/Environments/GiantSword/GiantSword_19.png",
            "assets/sprites/Environments/GiantSword/GiantSword_20.png",
            "assets/sprites/Environments/GiantSword/GiantSword_21.png",
            "assets/sprites/Environments/GiantSword/GiantSword_22.png",
            "assets/sprites/Environments/GiantSword/GiantSword_23.png",
            "assets/sprites/Environments/GiantSword/GiantSword_24.png",
            "assets/sprites/Environments/GiantSword/GiantSword_25.png",
            "assets/sprites/Environments/GiantSword/GiantSword_26.png",
            "assets/sprites/Environments/GiantSword/GiantSword_27.png",
            "assets/sprites/Environments/GiantSword/GiantSword_28.png",
            "assets/sprites/Environments/GiantSword/GiantSword_29.png",
            "assets/sprites/Environments/GiantSword/GiantSword_30.png",
            "assets/sprites/Environments/GiantSword/GiantSword_31.png",
            "assets/sprites/Environments/GiantSword/GiantSword_32.png",
            "assets/sprites/Environments/GiantSword/GiantSword_33.png",
            "assets/sprites/Environments/GiantSword/GiantSword_34.png",
            "assets/sprites/Environments/GiantSword/GiantSword_35.png",
            "assets/sprites/Environments/GiantSword/GiantSword_36.png",
            "assets/sprites/Environments/GiantSword/GiantSword_37.png",
            "assets/sprites/Environments/GiantSword/GiantSword_38.png",
            "assets/sprites/Environments/GiantSword/GiantSword_39.png",
            "assets/sprites/Environments/GiantSword/GiantSword_40.png"
        ]);
    }


    struct FireSprites {
        AnimatedSpriteAsset Fire = AnimatedSpriteAsset(1f, [
            "assets/sprites/Environments/Fire/Fire_01.png",
            "assets/sprites/Environments/Fire/Fire_02.png",
            "assets/sprites/Environments/Fire/Fire_03.png",
            "assets/sprites/Environments/Fire/Fire_04.png",
            "assets/sprites/Environments/Fire/Fire_05.png",
            "assets/sprites/Environments/Fire/Fire_06.png",
            "assets/sprites/Environments/Fire/Fire_07.png",
            "assets/sprites/Environments/Fire/Fire_08.png",
            "assets/sprites/Environments/Fire/Fire_09.png",
            "assets/sprites/Environments/Fire/Fire_10.png",
            "assets/sprites/Environments/Fire/Fire_11.png",
            "assets/sprites/Environments/Fire/Fire_12.png",
            "assets/sprites/Environments/Fire/Fire_13.png",
            "assets/sprites/Environments/Fire/Fire_14.png",
            "assets/sprites/Environments/Fire/Fire_15.png",
            "assets/sprites/Environments/Fire/Fire_16.png"
        ]);
    }


    struct ChestSprites {
        AnimatedSpriteAsset Idle = AnimatedSpriteAsset(1f, [
            "assets/sprites/Environments/Chest/Idle/Chest_Idle_01.png",
            "assets/sprites/Environments/Chest/Idle/Chest_Idle_02.png",
            "assets/sprites/Environments/Chest/Idle/Chest_Idle_03.png",
            "assets/sprites/Environments/Chest/Idle/Chest_Idle_04.png",
            "assets/sprites/Environments/Chest/Idle/Chest_Idle_05.png",
            "assets/sprites/Environments/Chest/Idle/Chest_Idle_06.png",
            "assets/sprites/Environments/Chest/Idle/Chest_Idle_07.png",
            "assets/sprites/Environments/Chest/Idle/Chest_Idle_08.png"
        ]);
        AnimatedSpriteAsset Open = AnimatedSpriteAsset(1f, [
            "assets/sprites/Environments/Chest/Open/Chest_Open_01.png",
            "assets/sprites/Environments/Chest/Open/Chest_Open_02.png",
            "assets/sprites/Environments/Chest/Open/Chest_Open_03.png",
            "assets/sprites/Environments/Chest/Open/Chest_Open_04.png",
            "assets/sprites/Environments/Chest/Open/Chest_Open_05.png",
            "assets/sprites/Environments/Chest/Open/Chest_Open_06.png",
            "assets/sprites/Environments/Chest/Open/Chest_Open_07.png",
            "assets/sprites/Environments/Chest/Open/Chest_Open_08.png",
            "assets/sprites/Environments/Chest/Open/Chest_Open_09.png",
            "assets/sprites/Environments/Chest/Open/Chest_Open_10.png",
            "assets/sprites/Environments/Chest/Open/Chest_Open_11.png"
        ]);
    }


    struct NPC01Sprites {
        AnimatedSpriteAsset Idle = AnimatedSpriteAsset(1f, [
            "assets/sprites/NPC01/Idle/NPC01_Idle_01.png",
            "assets/sprites/NPC01/Idle/NPC01_Idle_02.png",
            "assets/sprites/NPC01/Idle/NPC01_Idle_03.png",
            "assets/sprites/NPC01/Idle/NPC01_Idle_04.png",
            "assets/sprites/NPC01/Idle/NPC01_Idle_05.png",
            "assets/sprites/NPC01/Idle/NPC01_Idle_06.png",
            "assets/sprites/NPC01/Idle/NPC01_Idle_07.png",
            "assets/sprites/NPC01/Idle/NPC01_Idle_08.png",
            "assets/sprites/NPC01/Idle/NPC01_Idle_09.png",
            "assets/sprites/NPC01/Idle/NPC01_Idle_10.png",
            "assets/sprites/NPC01/Idle/NPC01_Idle_11.png",
            "assets/sprites/NPC01/Idle/NPC01_Idle_12.png",
            "assets/sprites/NPC01/Idle/NPC01_Idle_13.png",
            "assets/sprites/NPC01/Idle/NPC01_Idle_14.png",
            "assets/sprites/NPC01/Idle/NPC01_Idle_15.png",
            "assets/sprites/NPC01/Idle/NPC01_Idle_16.png"
        ]);
    }


    struct HitSprites {
        AnimatedSpriteAsset Fx = AnimatedSpriteAsset(1f, [
            "assets/sprites/HitFx/Hit_Fx_01.png",
            "assets/sprites/HitFx/Hit_Fx_02.png",
            "assets/sprites/HitFx/Hit_Fx_03.png",
            "assets/sprites/HitFx/Hit_Fx_04.png"
        ]);
    }


    struct Enemy01Sprites {
        AnimatedSpriteAsset Idle = AnimatedSpriteAsset(1f, [
            "assets/sprites/Enemies/Enemy01/Idle/Enemy01_Idle_01.png",
            "assets/sprites/Enemies/Enemy01/Idle/Enemy01_Idle_02.png",
            "assets/sprites/Enemies/Enemy01/Idle/Enemy01_Idle_03.png",
            "assets/sprites/Enemies/Enemy01/Idle/Enemy01_Idle_04.png",
            "assets/sprites/Enemies/Enemy01/Idle/Enemy01_Idle_05.png",
            "assets/sprites/Enemies/Enemy01/Idle/Enemy01_Idle_06.png",
            "assets/sprites/Enemies/Enemy01/Idle/Enemy01_Idle_07.png",
            "assets/sprites/Enemies/Enemy01/Idle/Enemy01_Idle_08.png"
        ]);
        AnimatedSpriteAsset Attack = AnimatedSpriteAsset(1f, [
            "assets/sprites/Enemies/Enemy01/Attack/Enemy01_Attack_01.png",
            "assets/sprites/Enemies/Enemy01/Attack/Enemy01_Attack_02.png",
            "assets/sprites/Enemies/Enemy01/Attack/Enemy01_Attack_03.png",
            "assets/sprites/Enemies/Enemy01/Attack/Enemy01_Attack_04.png",
            "assets/sprites/Enemies/Enemy01/Attack/Enemy01_Attack_05.png",
            "assets/sprites/Enemies/Enemy01/Attack/Enemy01_Attack_06.png",
            "assets/sprites/Enemies/Enemy01/Attack/Enemy01_Attack_07.png",
            "assets/sprites/Enemies/Enemy01/Attack/Enemy01_Attack_08.png",
            "assets/sprites/Enemies/Enemy01/Attack/Enemy01_Attack_09.png",
            "assets/sprites/Enemies/Enemy01/Attack/Enemy01_Attack_10.png",
            "assets/sprites/Enemies/Enemy01/Attack/Enemy01_Attack_11.png",
            "assets/sprites/Enemies/Enemy01/Attack/Enemy01_Attack_12.png",
            "assets/sprites/Enemies/Enemy01/Attack/Enemy01_Attack_13.png",
            "assets/sprites/Enemies/Enemy01/Attack/Enemy01_Attack_14.png",
            "assets/sprites/Enemies/Enemy01/Attack/Enemy01_Attack_15.png",
            "assets/sprites/Enemies/Enemy01/Attack/Enemy01_Attack_16.png",
            "assets/sprites/Enemies/Enemy01/Attack/Enemy01_Attack_17.png",
            "assets/sprites/Enemies/Enemy01/Attack/Enemy01_Attack_18.png",
            "assets/sprites/Enemies/Enemy01/Attack/Enemy01_Attack_19.png",
            "assets/sprites/Enemies/Enemy01/Attack/Enemy01_Attack_20.png",
            "assets/sprites/Enemies/Enemy01/Attack/Enemy01_Attack_21.png"
        ]);
        AnimatedSpriteAsset Stun = AnimatedSpriteAsset(1f, [
            "assets/sprites/Enemies/Enemy01/Stun/Enemy01_Stun_01.png",
            "assets/sprites/Enemies/Enemy01/Stun/Enemy01_Stun_02.png",
            "assets/sprites/Enemies/Enemy01/Stun/Enemy01_Stun_03.png",
            "assets/sprites/Enemies/Enemy01/Stun/Enemy01_Stun_04.png",
            "assets/sprites/Enemies/Enemy01/Stun/Enemy01_Stun_05.png",
            "assets/sprites/Enemies/Enemy01/Stun/Enemy01_Stun_06.png",
            "assets/sprites/Enemies/Enemy01/Stun/Enemy01_Stun_07.png"
        ]);
        AnimatedSpriteAsset Hit = AnimatedSpriteAsset(1f, [
            "assets/sprites/Enemies/Enemy01/Hit/Enemy01_Hit_01.png",
            "assets/sprites/Enemies/Enemy01/Hit/Enemy01_Hit_02.png",
            "assets/sprites/Enemies/Enemy01/Hit/Enemy01_Hit_03.png",
            "assets/sprites/Enemies/Enemy01/Hit/Enemy01_Hit_04.png",
            "assets/sprites/Enemies/Enemy01/Hit/Enemy01_Hit_05.png",
            "assets/sprites/Enemies/Enemy01/Hit/Enemy01_Hit_06.png",
            "assets/sprites/Enemies/Enemy01/Hit/Enemy01_Hit_07.png",
            "assets/sprites/Enemies/Enemy01/Hit/Enemy01_Hit_08.png",
            "assets/sprites/Enemies/Enemy01/Hit/Enemy01_Hit_09.png"
        ]);
        AnimatedSpriteAsset Turn = AnimatedSpriteAsset(1f, [
            "assets/sprites/Enemies/Enemy01/Turn/Enemy01_Turn_01.png",
            "assets/sprites/Enemies/Enemy01/Turn/Enemy01_Turn_02.png",
            "assets/sprites/Enemies/Enemy01/Turn/Enemy01_Turn_03.png",
            "assets/sprites/Enemies/Enemy01/Turn/Enemy01_Turn_04.png",
            "assets/sprites/Enemies/Enemy01/Turn/Enemy01_Turn_05.png",
            "assets/sprites/Enemies/Enemy01/Turn/Enemy01_Turn_06.png",
            "assets/sprites/Enemies/Enemy01/Turn/Enemy01_Turn_07.png",
            "assets/sprites/Enemies/Enemy01/Turn/Enemy01_Turn_08.png",
            "assets/sprites/Enemies/Enemy01/Turn/Enemy01_Turn_09.png",
            "assets/sprites/Enemies/Enemy01/Turn/Enemy01_Turn_10.png",
            "assets/sprites/Enemies/Enemy01/Turn/Enemy01_Turn_11.png",
            "assets/sprites/Enemies/Enemy01/Turn/Enemy01_Turn_12.png",
            "assets/sprites/Enemies/Enemy01/Turn/Enemy01_Turn_13.png",
            "assets/sprites/Enemies/Enemy01/Turn/Enemy01_Turn_14.png",
            "assets/sprites/Enemies/Enemy01/Turn/Enemy01_Turn_15.png",
            "assets/sprites/Enemies/Enemy01/Turn/Enemy01_Turn_16.png",
            "assets/sprites/Enemies/Enemy01/Turn/Enemy01_Turn_17.png",
            "assets/sprites/Enemies/Enemy01/Turn/Enemy01_Turn_18.png"
        ]);
        AnimatedSpriteAsset Parry = AnimatedSpriteAsset(1f, [
            "assets/sprites/Enemies/Enemy01/Parry/Enemy01_Parry_01.png",
            "assets/sprites/Enemies/Enemy01/Parry/Enemy01_Parry_02.png",
            "assets/sprites/Enemies/Enemy01/Parry/Enemy01_Parry_03.png",
            "assets/sprites/Enemies/Enemy01/Parry/Enemy01_Parry_04.png",
            "assets/sprites/Enemies/Enemy01/Parry/Enemy01_Parry_05.png",
            "assets/sprites/Enemies/Enemy01/Parry/Enemy01_Parry_06.png",
            "assets/sprites/Enemies/Enemy01/Parry/Enemy01_Parry_07.png",
            "assets/sprites/Enemies/Enemy01/Parry/Enemy01_Parry_08.png",
            "assets/sprites/Enemies/Enemy01/Parry/Enemy01_Parry_09.png",
            "assets/sprites/Enemies/Enemy01/Parry/Enemy01_Parry_10.png"
        ]);
        AnimatedSpriteAsset Run = AnimatedSpriteAsset(1f, [
            "assets/sprites/Enemies/Enemy01/Run/Enemy01_Run_01.png",
            "assets/sprites/Enemies/Enemy01/Run/Enemy01_Run_02.png",
            "assets/sprites/Enemies/Enemy01/Run/Enemy01_Run_03.png",
            "assets/sprites/Enemies/Enemy01/Run/Enemy01_Run_04.png",
            "assets/sprites/Enemies/Enemy01/Run/Enemy01_Run_05.png",
            "assets/sprites/Enemies/Enemy01/Run/Enemy01_Run_06.png",
            "assets/sprites/Enemies/Enemy01/Run/Enemy01_Run_07.png",
            "assets/sprites/Enemies/Enemy01/Run/Enemy01_Run_08.png"
        ]);
    }


    struct Enemy02Sprites {
        AnimatedSpriteAsset Idle = AnimatedSpriteAsset(1f, [
            "assets/sprites/Enemies/Enemy02/Idle/Enemy02_Idle_01.png",
            "assets/sprites/Enemies/Enemy02/Idle/Enemy02_Idle_02.png",
            "assets/sprites/Enemies/Enemy02/Idle/Enemy02_Idle_03.png",
            "assets/sprites/Enemies/Enemy02/Idle/Enemy02_Idle_04.png",
            "assets/sprites/Enemies/Enemy02/Idle/Enemy02_Idle_05.png",
            "assets/sprites/Enemies/Enemy02/Idle/Enemy02_Idle_06.png",
            "assets/sprites/Enemies/Enemy02/Idle/Enemy02_Idle_07.png",
            "assets/sprites/Enemies/Enemy02/Idle/Enemy02_Idle_08.png"
        ]);
        AnimatedSpriteAsset Hit = AnimatedSpriteAsset(1f, [
            "assets/sprites/Enemies/Enemy02/Hit/Enemy02_Hit_01.png",
            "assets/sprites/Enemies/Enemy02/Hit/Enemy02_Hit_02.png",
            "assets/sprites/Enemies/Enemy02/Hit/Enemy02_Hit_03.png",
            "assets/sprites/Enemies/Enemy02/Hit/Enemy02_Hit_04.png",
            "assets/sprites/Enemies/Enemy02/Hit/Enemy02_Hit_05.png",
            "assets/sprites/Enemies/Enemy02/Hit/Enemy02_Hit_06.png",
            "assets/sprites/Enemies/Enemy02/Hit/Enemy02_Hit_07.png"
        ]);
        AnimatedSpriteAsset Reload = AnimatedSpriteAsset(1f, [
            "assets/sprites/Enemies/Enemy02/Reload/Enemy02_Reload_01.png",
            "assets/sprites/Enemies/Enemy02/Reload/Enemy02_Reload_02.png",
            "assets/sprites/Enemies/Enemy02/Reload/Enemy02_Reload_03.png",
            "assets/sprites/Enemies/Enemy02/Reload/Enemy02_Reload_04.png",
            "assets/sprites/Enemies/Enemy02/Reload/Enemy02_Reload_05.png",
            "assets/sprites/Enemies/Enemy02/Reload/Enemy02_Reload_06.png",
            "assets/sprites/Enemies/Enemy02/Reload/Enemy02_Reload_07.png",
            "assets/sprites/Enemies/Enemy02/Reload/Enemy02_Reload_08.png",
            "assets/sprites/Enemies/Enemy02/Reload/Enemy02_Reload_09.png",
            "assets/sprites/Enemies/Enemy02/Reload/Enemy02_Reload_10.png",
            "assets/sprites/Enemies/Enemy02/Reload/Enemy02_Reload_11.png",
            "assets/sprites/Enemies/Enemy02/Reload/Enemy02_Reload_12.png"
        ]);
        AnimatedSpriteAsset PrepareShoot = AnimatedSpriteAsset(1f, [
            "assets/sprites/Enemies/Enemy02/PrepareShoot/Enemy02_PrepareShoot_01.png",
            "assets/sprites/Enemies/Enemy02/PrepareShoot/Enemy02_PrepareShoot_02.png",
            "assets/sprites/Enemies/Enemy02/PrepareShoot/Enemy02_PrepareShoot_03.png",
            "assets/sprites/Enemies/Enemy02/PrepareShoot/Enemy02_PrepareShoot_04.png",
            "assets/sprites/Enemies/Enemy02/PrepareShoot/Enemy02_PrepareShoot_05.png",
            "assets/sprites/Enemies/Enemy02/PrepareShoot/Enemy02_PrepareShoot_06.png",
            "assets/sprites/Enemies/Enemy02/PrepareShoot/Enemy02_PrepareShoot_07.png"
        ]);
        AnimatedSpriteAsset Run = AnimatedSpriteAsset(1f, [
            "assets/sprites/Enemies/Enemy02/Run/Enemy02_Run_01.png",
            "assets/sprites/Enemies/Enemy02/Run/Enemy02_Run_02.png",
            "assets/sprites/Enemies/Enemy02/Run/Enemy02_Run_03.png",
            "assets/sprites/Enemies/Enemy02/Run/Enemy02_Run_04.png",
            "assets/sprites/Enemies/Enemy02/Run/Enemy02_Run_05.png",
            "assets/sprites/Enemies/Enemy02/Run/Enemy02_Run_06.png",
            "assets/sprites/Enemies/Enemy02/Run/Enemy02_Run_07.png",
            "assets/sprites/Enemies/Enemy02/Run/Enemy02_Run_08.png"
        ]);
        AnimatedSpriteAsset PutGunAway = AnimatedSpriteAsset(1f, [
            "assets/sprites/Enemies/Enemy02/PutGunAway/Enemy02_PutGunAway_01.png",
            "assets/sprites/Enemies/Enemy02/PutGunAway/Enemy02_PutGunAway_02.png",
            "assets/sprites/Enemies/Enemy02/PutGunAway/Enemy02_PutGunAway_03.png",
            "assets/sprites/Enemies/Enemy02/PutGunAway/Enemy02_PutGunAway_04.png",
            "assets/sprites/Enemies/Enemy02/PutGunAway/Enemy02_PutGunAway_05.png",
            "assets/sprites/Enemies/Enemy02/PutGunAway/Enemy02_PutGunAway_06.png",
            "assets/sprites/Enemies/Enemy02/PutGunAway/Enemy02_PutGunAway_07.png"
        ]);
        AnimatedSpriteAsset Shoot = AnimatedSpriteAsset(1f, [
            "assets/sprites/Enemies/Enemy02/Shoot/Enemy02_Shoot_01.png",
            "assets/sprites/Enemies/Enemy02/Shoot/Enemy02_Shoot_02.png",
            "assets/sprites/Enemies/Enemy02/Shoot/Enemy02_Shoot_03.png",
            "assets/sprites/Enemies/Enemy02/Shoot/Enemy02_Shoot_04.png",
            "assets/sprites/Enemies/Enemy02/Shoot/Enemy02_Shoot_05.png",
            "assets/sprites/Enemies/Enemy02/Shoot/Enemy02_Shoot_06.png",
            "assets/sprites/Enemies/Enemy02/Shoot/Enemy02_Shoot_07.png",
            "assets/sprites/Enemies/Enemy02/Shoot/Enemy02_Shoot_08.png",
            "assets/sprites/Enemies/Enemy02/Shoot/Enemy02_Shoot_09.png",
            "assets/sprites/Enemies/Enemy02/Shoot/Enemy02_Shoot_10.png",
            "assets/sprites/Enemies/Enemy02/Shoot/Enemy02_Shoot_11.png",
            "assets/sprites/Enemies/Enemy02/Shoot/Enemy02_Shoot_12.png",
            "assets/sprites/Enemies/Enemy02/Shoot/Enemy02_Shoot_13.png",
            "assets/sprites/Enemies/Enemy02/Shoot/Enemy02_Shoot_14.png",
            "assets/sprites/Enemies/Enemy02/Shoot/Enemy02_Shoot_15.png",
            "assets/sprites/Enemies/Enemy02/Shoot/Enemy02_Shoot_16.png"
        ]);
    }


    struct PlayerSprites {
        AnimatedSpriteAsset HitwSword = AnimatedSpriteAsset(1f, [
            "assets/sprites/Player/HitwSword/Player_HitwSword_01.png",
            "assets/sprites/Player/HitwSword/Player_HitwSword_02.png",
            "assets/sprites/Player/HitwSword/Player_HitwSword_03.png",
            "assets/sprites/Player/HitwSword/Player_HitwSword_04.png",
            "assets/sprites/Player/HitwSword/Player_HitwSword_05.png",
            "assets/sprites/Player/HitwSword/Player_HitwSword_06.png",
            "assets/sprites/Player/HitwSword/Player_HitwSword_07.png",
            "assets/sprites/Player/HitwSword/Player_HitwSword_08.png",
            "assets/sprites/Player/HitwSword/Player_HitwSword_09.png"
        ]);
        AnimatedSpriteAsset Idle = AnimatedSpriteAsset(1f, [
            "assets/sprites/Player/Idle/Player_Idle_01.png",
            "assets/sprites/Player/Idle/Player_Idle_02.png",
            "assets/sprites/Player/Idle/Player_Idle_03.png",
            "assets/sprites/Player/Idle/Player_Idle_04.png",
            "assets/sprites/Player/Idle/Player_Idle_05.png",
            "assets/sprites/Player/Idle/Player_Idle_06.png",
            "assets/sprites/Player/Idle/Player_Idle_07.png",
            "assets/sprites/Player/Idle/Player_Idle_08.png"
        ]);
        AnimatedSpriteAsset Attack03 = AnimatedSpriteAsset(1f, [
            "assets/sprites/Player/Attack03/Player_Attack03_01.png",
            "assets/sprites/Player/Attack03/Player_Attack03_02.png",
            "assets/sprites/Player/Attack03/Player_Attack03_03.png",
            "assets/sprites/Player/Attack03/Player_Attack03_04.png",
            "assets/sprites/Player/Attack03/Player_Attack03_05.png",
            "assets/sprites/Player/Attack03/Player_Attack03_06.png",
            "assets/sprites/Player/Attack03/Player_Attack03_07.png",
            "assets/sprites/Player/Attack03/Player_Attack03_08.png",
            "assets/sprites/Player/Attack03/Player_Attack03_09.png",
            "assets/sprites/Player/Attack03/Player_Attack03_10.png",
            "assets/sprites/Player/Attack03/Player_Attack03_11.png",
            "assets/sprites/Player/Attack03/Player_Attack03_12.png",
            "assets/sprites/Player/Attack03/Player_Attack03_13.png"
        ]);
        AnimatedSpriteAsset TakeSword = AnimatedSpriteAsset(1f, [
            "assets/sprites/Player/TakeSword/Player_TakeSword_01.png",
            "assets/sprites/Player/TakeSword/Player_TakeSword_02.png",
            "assets/sprites/Player/TakeSword/Player_TakeSword_03.png",
            "assets/sprites/Player/TakeSword/Player_TakeSword_04.png",
            "assets/sprites/Player/TakeSword/Player_TakeSword_05.png",
            "assets/sprites/Player/TakeSword/Player_TakeSword_06.png",
            "assets/sprites/Player/TakeSword/Player_TakeSword_07.png",
            "assets/sprites/Player/TakeSword/Player_TakeSword_08.png",
            "assets/sprites/Player/TakeSword/Player_TakeSword_09.png",
            "assets/sprites/Player/TakeSword/Player_TakeSword_10.png",
            "assets/sprites/Player/TakeSword/Player_TakeSword_11.png",
            "assets/sprites/Player/TakeSword/Player_TakeSword_12.png",
            "assets/sprites/Player/TakeSword/Player_TakeSword_13.png",
            "assets/sprites/Player/TakeSword/Player_TakeSword_14.png",
            "assets/sprites/Player/TakeSword/Player_TakeSword_15.png",
            "assets/sprites/Player/TakeSword/Player_TakeSword_16.png"
        ]);
        AnimatedSpriteAsset Roll = AnimatedSpriteAsset(1f, [
            "assets/sprites/Player/Roll/Player_Roll_01.png",
            "assets/sprites/Player/Roll/Player_Roll_02.png",
            "assets/sprites/Player/Roll/Player_Roll_03.png",
            "assets/sprites/Player/Roll/Player_Roll_04.png",
            "assets/sprites/Player/Roll/Player_Roll_05.png",
            "assets/sprites/Player/Roll/Player_Roll_06.png",
            "assets/sprites/Player/Roll/Player_Roll_07.png",
            "assets/sprites/Player/Roll/Player_Roll_08.png",
            "assets/sprites/Player/Roll/Player_Roll_09.png",
            "assets/sprites/Player/Roll/Player_Roll_10.png",
            "assets/sprites/Player/Roll/Player_Roll_11.png"
        ]);
        AnimatedSpriteAsset Hit = AnimatedSpriteAsset(1f, [
            "assets/sprites/Player/Hit/Player_Hit_01.png",
            "assets/sprites/Player/Hit/Player_Hit_02.png",
            "assets/sprites/Player/Hit/Player_Hit_03.png",
            "assets/sprites/Player/Hit/Player_Hit_04.png",
            "assets/sprites/Player/Hit/Player_Hit_05.png",
            "assets/sprites/Player/Hit/Player_Hit_06.png",
            "assets/sprites/Player/Hit/Player_Hit_07.png",
            "assets/sprites/Player/Hit/Player_Hit_08.png",
            "assets/sprites/Player/Hit/Player_Hit_09.png"
        ]);
        AnimatedSpriteAsset Attack02 = AnimatedSpriteAsset(1f, [
            "assets/sprites/Player/Attack02/Player_Attack02_01.png",
            "assets/sprites/Player/Attack02/Player_Attack02_02.png",
            "assets/sprites/Player/Attack02/Player_Attack02_03.png",
            "assets/sprites/Player/Attack02/Player_Attack02_04.png",
            "assets/sprites/Player/Attack02/Player_Attack02_05.png",
            "assets/sprites/Player/Attack02/Player_Attack02_06.png",
            "assets/sprites/Player/Attack02/Player_Attack02_07.png",
            "assets/sprites/Player/Attack02/Player_Attack02_08.png",
            "assets/sprites/Player/Attack02/Player_Attack02_09.png",
            "assets/sprites/Player/Attack02/Player_Attack02_10.png",
            "assets/sprites/Player/Attack02/Player_Attack02_11.png",
            "assets/sprites/Player/Attack02/Player_Attack02_12.png",
            "assets/sprites/Player/Attack02/Player_Attack02_13.png",
            "assets/sprites/Player/Attack02/Player_Attack02_14.png"
        ]);
        AnimatedSpriteAsset Death = AnimatedSpriteAsset(1f, [
            "assets/sprites/Player/Death/Player_Death_01.png",
            "assets/sprites/Player/Death/Player_Death_02.png",
            "assets/sprites/Player/Death/Player_Death_03.png",
            "assets/sprites/Player/Death/Player_Death_04.png",
            "assets/sprites/Player/Death/Player_Death_05.png",
            "assets/sprites/Player/Death/Player_Death_06.png",
            "assets/sprites/Player/Death/Player_Death_07.png",
            "assets/sprites/Player/Death/Player_Death_08.png",
            "assets/sprites/Player/Death/Player_Death_09.png",
            "assets/sprites/Player/Death/Player_Death_10.png",
            "assets/sprites/Player/Death/Player_Death_11.png",
            "assets/sprites/Player/Death/Player_Death_12.png",
            "assets/sprites/Player/Death/Player_Death_13.png",
            "assets/sprites/Player/Death/Player_Death_14.png",
            "assets/sprites/Player/Death/Player_Death_15.png",
            "assets/sprites/Player/Death/Player_Death_16.png",
            "assets/sprites/Player/Death/Player_Death_17.png"
        ]);
        AnimatedSpriteAsset PutAwaySword = AnimatedSpriteAsset(1f, [
            "assets/sprites/Player/PutAwaySword/Player_PutAwaySword_01.png",
            "assets/sprites/Player/PutAwaySword/Player_PutAwaySword_02.png",
            "assets/sprites/Player/PutAwaySword/Player_PutAwaySword_03.png",
            "assets/sprites/Player/PutAwaySword/Player_PutAwaySword_04.png",
            "assets/sprites/Player/PutAwaySword/Player_PutAwaySword_05.png",
            "assets/sprites/Player/PutAwaySword/Player_PutAwaySword_06.png",
            "assets/sprites/Player/PutAwaySword/Player_PutAwaySword_07.png",
            "assets/sprites/Player/PutAwaySword/Player_PutAwaySword_08.png",
            "assets/sprites/Player/PutAwaySword/Player_PutAwaySword_09.png",
            "assets/sprites/Player/PutAwaySword/Player_PutAwaySword_10.png",
            "assets/sprites/Player/PutAwaySword/Player_PutAwaySword_11.png",
            "assets/sprites/Player/PutAwaySword/Player_PutAwaySword_12.png",
            "assets/sprites/Player/PutAwaySword/Player_PutAwaySword_13.png",
            "assets/sprites/Player/PutAwaySword/Player_PutAwaySword_14.png",
            "assets/sprites/Player/PutAwaySword/Player_PutAwaySword_15.png",
            "assets/sprites/Player/PutAwaySword/Player_PutAwaySword_16.png",
            "assets/sprites/Player/PutAwaySword/Player_PutAwaySword_17.png",
            "assets/sprites/Player/PutAwaySword/Player_PutAwaySword_18.png",
            "assets/sprites/Player/PutAwaySword/Player_PutAwaySword_19.png",
            "assets/sprites/Player/PutAwaySword/Player_PutAwaySword_20.png",
            "assets/sprites/Player/PutAwaySword/Player_PutAwaySword_21.png"
        ]);
        AnimatedSpriteAsset RollSword = AnimatedSpriteAsset(1f, [
            "assets/sprites/Player/RollSword/Player_RollSword_01.png",
            "assets/sprites/Player/RollSword/Player_RollSword_02.png",
            "assets/sprites/Player/RollSword/Player_RollSword_03.png",
            "assets/sprites/Player/RollSword/Player_RollSword_04.png",
            "assets/sprites/Player/RollSword/Player_RollSword_05.png",
            "assets/sprites/Player/RollSword/Player_RollSword_06.png",
            "assets/sprites/Player/RollSword/Player_RollSword_07.png",
            "assets/sprites/Player/RollSword/Player_RollSword_08.png",
            "assets/sprites/Player/RollSword/Player_RollSword_09.png",
            "assets/sprites/Player/RollSword/Player_RollSword_10.png",
            "assets/sprites/Player/RollSword/Player_RollSword_11.png"
        ]);
        AnimatedSpriteAsset OpenChest = AnimatedSpriteAsset(1f, [
            "assets/sprites/Player/OpenChest/Player_OpenChest_01.png",
            "assets/sprites/Player/OpenChest/Player_OpenChest_02.png",
            "assets/sprites/Player/OpenChest/Player_OpenChest_03.png",
            "assets/sprites/Player/OpenChest/Player_OpenChest_04.png",
            "assets/sprites/Player/OpenChest/Player_OpenChest_05.png",
            "assets/sprites/Player/OpenChest/Player_OpenChest_06.png",
            "assets/sprites/Player/OpenChest/Player_OpenChest_07.png",
            "assets/sprites/Player/OpenChest/Player_OpenChest_08.png",
            "assets/sprites/Player/OpenChest/Player_OpenChest_09.png",
            "assets/sprites/Player/OpenChest/Player_OpenChest_10.png",
            "assets/sprites/Player/OpenChest/Player_OpenChest_11.png",
            "assets/sprites/Player/OpenChest/Player_OpenChest_12.png",
            "assets/sprites/Player/OpenChest/Player_OpenChest_13.png",
            "assets/sprites/Player/OpenChest/Player_OpenChest_14.png",
            "assets/sprites/Player/OpenChest/Player_OpenChest_15.png",
            "assets/sprites/Player/OpenChest/Player_OpenChest_16.png",
            "assets/sprites/Player/OpenChest/Player_OpenChest_17.png",
            "assets/sprites/Player/OpenChest/Player_OpenChest_18.png",
            "assets/sprites/Player/OpenChest/Player_OpenChest_19.png"
        ]);
        AnimatedSpriteAsset RunwSword = AnimatedSpriteAsset(1f, [
            "assets/sprites/Player/RunwSword/Player_RunwSword_01.png",
            "assets/sprites/Player/RunwSword/Player_RunwSword_02.png",
            "assets/sprites/Player/RunwSword/Player_RunwSword_03.png",
            "assets/sprites/Player/RunwSword/Player_RunwSword_04.png",
            "assets/sprites/Player/RunwSword/Player_RunwSword_05.png",
            "assets/sprites/Player/RunwSword/Player_RunwSword_06.png",
            "assets/sprites/Player/RunwSword/Player_RunwSword_07.png",
            "assets/sprites/Player/RunwSword/Player_RunwSword_08.png"
        ]);
        AnimatedSpriteAsset StopAttack = AnimatedSpriteAsset(1f, [
            "assets/sprites/Player/StopAttack/Player_StopAttack_01.png",
            "assets/sprites/Player/StopAttack/Player_StopAttack_02.png",
            "assets/sprites/Player/StopAttack/Player_StopAttack_03.png",
            "assets/sprites/Player/StopAttack/Player_StopAttack_04.png",
            "assets/sprites/Player/StopAttack/Player_StopAttack_05.png",
            "assets/sprites/Player/StopAttack/Player_StopAttack_06.png",
            "assets/sprites/Player/StopAttack/Player_StopAttack_07.png",
            "assets/sprites/Player/StopAttack/Player_StopAttack_08.png",
            "assets/sprites/Player/StopAttack/Player_StopAttack_09.png",
            "assets/sprites/Player/StopAttack/Player_StopAttack_10.png",
            "assets/sprites/Player/StopAttack/Player_StopAttack_11.png",
            "assets/sprites/Player/StopAttack/Player_StopAttack_12.png",
            "assets/sprites/Player/StopAttack/Player_StopAttack_13.png",
            "assets/sprites/Player/StopAttack/Player_StopAttack_14.png"
        ]);
        AnimatedSpriteAsset Parry = AnimatedSpriteAsset(1f, [
            "assets/sprites/Player/Parry/Player_Parry_01.png",
            "assets/sprites/Player/Parry/Player_Parry_02.png",
            "assets/sprites/Player/Parry/Player_Parry_03.png",
            "assets/sprites/Player/Parry/Player_Parry_04.png",
            "assets/sprites/Player/Parry/Player_Parry_05.png",
            "assets/sprites/Player/Parry/Player_Parry_06.png",
            "assets/sprites/Player/Parry/Player_Parry_07.png",
            "assets/sprites/Player/Parry/Player_Parry_08.png",
            "assets/sprites/Player/Parry/Player_Parry_09.png",
            "assets/sprites/Player/Parry/Player_Parry_10.png"
        ]);
        AnimatedSpriteAsset AttackHard = AnimatedSpriteAsset(1f, [
            "assets/sprites/Player/AttackHard/Player_AttackHard_01.png",
            "assets/sprites/Player/AttackHard/Player_AttackHard_02.png",
            "assets/sprites/Player/AttackHard/Player_AttackHard_03.png",
            "assets/sprites/Player/AttackHard/Player_AttackHard_04.png",
            "assets/sprites/Player/AttackHard/Player_AttackHard_05.png",
            "assets/sprites/Player/AttackHard/Player_AttackHard_06.png",
            "assets/sprites/Player/AttackHard/Player_AttackHard_07.png",
            "assets/sprites/Player/AttackHard/Player_AttackHard_08.png",
            "assets/sprites/Player/AttackHard/Player_AttackHard_09.png",
            "assets/sprites/Player/AttackHard/Player_AttackHard_10.png"
        ]);
        AnimatedSpriteAsset Attack01 = AnimatedSpriteAsset(1f, [
            "assets/sprites/Player/Attack01/Player_Attack01_01.png",
            "assets/sprites/Player/Attack01/Player_Attack01_02.png",
            "assets/sprites/Player/Attack01/Player_Attack01_03.png",
            "assets/sprites/Player/Attack01/Player_Attack01_04.png",
            "assets/sprites/Player/Attack01/Player_Attack01_05.png",
            "assets/sprites/Player/Attack01/Player_Attack01_06.png",
            "assets/sprites/Player/Attack01/Player_Attack01_07.png",
            "assets/sprites/Player/Attack01/Player_Attack01_08.png",
            "assets/sprites/Player/Attack01/Player_Attack01_09.png",
            "assets/sprites/Player/Attack01/Player_Attack01_10.png",
            "assets/sprites/Player/Attack01/Player_Attack01_11.png",
            "assets/sprites/Player/Attack01/Player_Attack01_12.png"
        ]);
        AnimatedSpriteAsset Run = AnimatedSpriteAsset(1f, [
            "assets/sprites/Player/Run/Player_Run_01.png",
            "assets/sprites/Player/Run/Player_Run_02.png",
            "assets/sprites/Player/Run/Player_Run_03.png",
            "assets/sprites/Player/Run/Player_Run_04.png",
            "assets/sprites/Player/Run/Player_Run_05.png",
            "assets/sprites/Player/Run/Player_Run_06.png",
            "assets/sprites/Player/Run/Player_Run_07.png",
            "assets/sprites/Player/Run/Player_Run_08.png"
        ]);
        AnimatedSpriteAsset ParryWithoutHit = AnimatedSpriteAsset(1f, [
            "assets/sprites/Player/ParryWithoutHit/Player_ParryWithoutHit_01.png",
            "assets/sprites/Player/ParryWithoutHit/Player_ParryWithoutHit_02.png",
            "assets/sprites/Player/ParryWithoutHit/Player_ParryWithoutHit_03.png",
            "assets/sprites/Player/ParryWithoutHit/Player_ParryWithoutHit_04.png",
            "assets/sprites/Player/ParryWithoutHit/Player_ParryWithoutHit_05.png",
            "assets/sprites/Player/ParryWithoutHit/Player_ParryWithoutHit_06.png",
            "assets/sprites/Player/ParryWithoutHit/Player_ParryWithoutHit_07.png",
            "assets/sprites/Player/ParryWithoutHit/Player_ParryWithoutHit_08.png",
            "assets/sprites/Player/ParryWithoutHit/Player_ParryWithoutHit_09.png",
            "assets/sprites/Player/ParryWithoutHit/Player_ParryWithoutHit_10.png"
        ]);
        AnimatedSpriteAsset IdlewSword = AnimatedSpriteAsset(1f, [
            "assets/sprites/Player/IdlewSword/Player_IdlewSword_01.png",
            "assets/sprites/Player/IdlewSword/Player_IdlewSword_02.png",
            "assets/sprites/Player/IdlewSword/Player_IdlewSword_03.png",
            "assets/sprites/Player/IdlewSword/Player_IdlewSword_04.png",
            "assets/sprites/Player/IdlewSword/Player_IdlewSword_05.png",
            "assets/sprites/Player/IdlewSword/Player_IdlewSword_06.png",
            "assets/sprites/Player/IdlewSword/Player_IdlewSword_07.png",
            "assets/sprites/Player/IdlewSword/Player_IdlewSword_08.png"
        ]);
    }


    struct StunAfterParrySprites {
        AnimatedSpriteAsset Attack03_Player = AnimatedSpriteAsset(1f, [
            "assets/sprites/Player/StunAfterParry/StunAfterParry_Attack03_Player_01.png"
        ]);
        AnimatedSpriteAsset Attack02_Player = AnimatedSpriteAsset(1f, [
            "assets/sprites/Player/StunAfterParry/StunAfterParry_Attack02_Player_01.png"
        ]);
        AnimatedSpriteAsset Attack01_Player = AnimatedSpriteAsset(1f, [
            "assets/sprites/Player/StunAfterParry/StunAfterParry_Attack01_Player_01.png"
        ]);
    }
}
