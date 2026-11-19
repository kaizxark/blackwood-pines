extends SceneTree

func _init():
    var viewport = root
    viewport.size = Vector2i(1280, 720)
    
    var canvas = CanvasLayer.new()
    viewport.add_child(canvas)
    
    var ui_root = Control.new()
    ui_root.name = "UIRoot"
    ui_root.set_anchors_preset(Control.PRESET_FULL_RECT)
    ui_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    canvas.add_child(ui_root)
    
    var bl = PanelContainer.new()
    bl.name = "BottomLeft"
    ui_root.add_child(bl)
    bl.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    bl.offset_left = 32
    bl.offset_top = -140
    bl.offset_right = 360
    bl.offset_bottom = -32
    
    var br = PanelContainer.new()
    br.name = "BottomRight"
    ui_root.add_child(br)
    br.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
    br.offset_left = -320
    br.offset_top = -140
    br.offset_right = -32
    br.offset_bottom = -32

    # Force a frame update
    print("Testing UIRoot structure:")
    print("UIRoot size: ", ui_root.size)
    print("BottomLeft pos: ", bl.position, " global_pos: ", bl.global_position, " size: ", bl.size)
    print("BottomRight pos: ", br.position, " global_pos: ", br.global_position, " size: ", br.size)
    quit()
