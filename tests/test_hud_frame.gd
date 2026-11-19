extends SceneTree

var frames = 0
var canvas: CanvasLayer
var ui_root: Control
var bl: PanelContainer

func _init():
    root.size = Vector2i(1280, 720)
    canvas = CanvasLayer.new()
    root.add_child(canvas)
    
    ui_root = Control.new()
    ui_root.name = "UIRoot"
    ui_root.set_anchors_preset(Control.PRESET_FULL_RECT)
    canvas.add_child(ui_root)
    
    bl = PanelContainer.new()
    bl.name = "BottomLeft"
    bl.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    bl.offset_left = 32
    bl.offset_top = -140
    bl.offset_right = 360
    bl.offset_bottom = -32
    ui_root.add_child(bl)

func _process(_delta):
    frames += 1
    if frames == 2:
        print("Frame 2 - Viewport visible rect: ", root.get_visible_rect())
        print("Frame 2 - UIRoot size: ", ui_root.size)
        print("Frame 2 - BottomLeft pos: ", bl.position, " global_pos: ", bl.global_position)
        quit()
