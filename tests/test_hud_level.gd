extends SceneTree

var frames = 0
var lvl

func _init():
    root.size = Vector2i(1280, 720)
    lvl = load("res://levels/level_01_breach/Level01.tscn").instantiate()
    root.add_child(lvl)

func _process(_delta):
    frames += 1
    if frames == 2:
        var hud = lvl.get_node_or_null("HUD")
        print("\n--- Level01 HUD Inspection in Frame 2 ---")
        if hud:
            var hp_num = hud.get_node_or_null("UIRoot/BottomLeftPanel/VBoxContainer/HealthHeader/HealthNumLabel")
            var hp_bar = hud.get_node_or_null("UIRoot/BottomLeftPanel/VBoxContainer/HealthBar")
            var shield_num = hud.get_node_or_null("UIRoot/BottomLeftPanel/VBoxContainer/ShieldHeader/ShieldNumLabel")
            var shield_bar = hud.get_node_or_null("UIRoot/BottomLeftPanel/VBoxContainer/ShieldBar")
            var w_name = hud.get_node_or_null("UIRoot/BottomRightPanel/VBoxContainer/WeaponHeader/WeaponNameLabel")
            var ammo_main = hud.get_node_or_null("UIRoot/BottomRightPanel/VBoxContainer/AmmoRow/AmmoMainLabel")
            var ammo_res = hud.get_node_or_null("UIRoot/BottomRightPanel/VBoxContainer/AmmoRow/AmmoReserveLabel")
            var bl = hud.get_node_or_null("UIRoot/BottomLeftPanel")
            var br = hud.get_node_or_null("UIRoot/BottomRightPanel")
            
            print("[HUD CHECK] BottomLeftPanel pos: ", bl.position, " global_pos: ", bl.global_position, " size: ", bl.size)
            print("[HUD CHECK] BottomRightPanel pos: ", br.position, " global_pos: ", br.global_position, " size: ", br.size)
            if hp_num: print("[HUD CHECK] Health Num: '", hp_num.text, "' (val=", hp_bar.value, "/", hp_bar.max_value, ")")
            if shield_num: print("[HUD CHECK] Shield Num: '", shield_num.text, "' (val=", shield_bar.value, "/", shield_bar.max_value, ")")
            if w_name: print("[HUD CHECK] Weapon: '", w_name.text, "' Ammo: '", ammo_main.text, ammo_res.text, "'")
        quit()
