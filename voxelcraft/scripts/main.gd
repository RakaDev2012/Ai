extends Node3D

var hud: CanvasLayer
var status_label: Label

func _ready() -> void:
    _build_hud()
    var player := $Player
    player.world = $World
    player.hud = hud

func _process(_delta: float) -> void:
    if is_instance_valid(status_label):
        var fps := Engine.get_frames_per_second()
        status_label.text = "LUMEN FRONTIER  •  %d FPS  •  dynamic light ON" % fps

func _build_hud() -> void:
    var top := ColorRect.new()
    top.color = Color(0.02, 0.04, 0.075, 0.78)
    top.position = Vector2(0, 0)
    top.size = Vector2(1280, 42)
    hud = $HUD
    hud.add_child(top)
    status_label = Label.new()
    status_label.position = Vector2(20, 11)
    status_label.add_theme_color_override("font_color", Color("#b8d7ff"))
    status_label.add_theme_font_size_override("font_size", 14)
    top.add_child(status_label)
    var help := Label.new()
    help.text = "WASD bergerak  •  Space lompat  •  LMB tangan kiri  •  RMB tangan kanan  •  E inventory"
    help.position = Vector2(20, 650)
    help.add_theme_color_override("font_color", Color(0.78, 0.84, 0.93, 0.9))
    help.add_theme_font_size_override("font_size", 15)
    hud.add_child(help)
    var cross := Label.new()
    cross.text = "+"
    cross.position = Vector2(635, 340)
    cross.add_theme_color_override("font_color", Color.WHITE)
    cross.add_theme_font_size_override("font_size", 22)
    hud.add_child(cross)
    for i in range(5):
        var slot := ColorRect.new()
        slot.position = Vector2(540 + i * 44, 585)
        slot.size = Vector2(38, 38)
        slot.color = Color(0.08, 0.11, 0.17, 0.92) if i != 0 else Color(0.22, 0.42, 0.56, 0.95)
        hud.add_child(slot)
        var n := Label.new()
        n.text = str(i + 1)
        n.position = Vector2(12, 8)
        n.add_theme_color_override("font_color", Color("#eaf4ff"))
        slot.add_child(n)
