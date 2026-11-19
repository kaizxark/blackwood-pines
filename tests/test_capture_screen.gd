extends SceneTree

var frames = 0
var lvl

func _init():
    root.size = Vector2i(1280, 720)
    lvl = load("res://levels/level_01_breach/Level01.tscn").instantiate()
    root.add_child(lvl)

func _process(_delta):
    frames += 1
    if frames == 15:
        var img = root.get_texture().get_image()
        if img:
            img.save_png("screenshot_frame15.png")
            print("Screenshot saved to screenshot_frame15.png (size: ", img.get_size(), ")")
        quit()
