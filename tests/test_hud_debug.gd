extends SceneTree

func _init():
    var lvl = load("res://levels/level_01_breach/Level01.tscn").instantiate()
    root.add_child(lvl)
    var hud = lvl.get_node_or_null("HUD")
    print("HUD node: ", hud)
    if hud:
        print("HUD children count: ", hud.get_child_count())
        for c in hud.get_children():
            print("  - ", c.name, " (", c.get_class(), ") visible=", c.visible)
            if c is Control:
                print("    pos=", c.position, " size=", c.size, " global_pos=", c.global_position)
        var bl = hud.get_node_or_null("BottomLeftPanel")
        if bl:
            print("BottomLeftPanel pos=", bl.position, " size=", bl.size, " anchors: left=", bl.anchor_left, " top=", bl.anchor_top, " right=", bl.anchor_right, " bottom=", bl.anchor_bottom)
            print("BottomLeftPanel offsets: left=", bl.offset_left, " top=", bl.offset_top, " right=", bl.offset_right, " bottom=", bl.offset_bottom)
        var br = hud.get_node_or_null("BottomRightPanel")
        if br:
            print("BottomRightPanel pos=", br.position, " size=", br.size, " anchors: left=", br.anchor_left, " top=", br.anchor_top, " right=", br.anchor_right, " bottom=", br.anchor_bottom)
            print("BottomRightPanel offsets: left=", br.offset_left, " top=", br.offset_top, " right=", br.offset_right, " bottom=", br.offset_bottom)
    quit()
