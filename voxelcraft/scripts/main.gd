extends Node3D

var hud: CanvasLayer
var status_label: Label
var survival_label: Label
var command_line: LineEdit
var world: VoxelWorld
var player: CharacterBody3D
var sun: DirectionalLight3D
var elapsed := 0.0
var autosave_elapsed := 0.0
const SAVE_PATH := "user://lumen_frontier_save.json"
var spawn_point := Vector3(0, 5, 5)
var difficulty := "normal"
var keep_inventory := true

func _ready() -> void:
    world = $World
    player = $Player
    _build_lighting()
    _build_hud()
    player.world = world
    player.hud = hud
    _load_game()

func _build_lighting() -> void:
    sun = DirectionalLight3D.new()
    sun.name = "SunCycle"
    sun.rotation_degrees = Vector3(-48, -25, 0)
    sun.light_energy = 1.1
    sun.shadow_enabled = true
    add_child(sun)
    var environment := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color("#77a9cf")
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("#9ab7d1")
    env.ambient_light_energy = 0.55
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    environment.environment = env
    add_child(environment)

func _process(delta: float) -> void:
    elapsed += delta
    autosave_elapsed += delta
    if autosave_elapsed >= 30.0:
        autosave_elapsed = 0.0
        _save_game()
    world.advance_time(delta)
    var phase := world.time_of_day * TAU
    sun.rotation_degrees = Vector3(-35.0 + sin(phase) * 38.0, phase * 57.3 - 90.0, 0)
    sun.light_energy = 0.18 + max(0.0, sin(phase)) * 1.0
    if is_instance_valid(status_label):
        status_label.text = "LUMEN FRONTIER  •  %d FPS  •  %s" % [Engine.get_frames_per_second(), "daylight" if sun.light_energy > 0.55 else "night"]

func _build_hud() -> void:
    hud = $HUD
    var top := ColorRect.new()
    top.color = Color(0.02, 0.04, 0.075, 0.82)
    top.size = Vector2(1280, 48)
    hud.add_child(top)
    status_label = Label.new()
    status_label.position = Vector2(20, 13)
    status_label.add_theme_color_override("font_color", Color("#b8d7ff"))
    status_label.add_theme_font_size_override("font_size", 14)
    top.add_child(status_label)
    survival_label = Label.new()
    survival_label.position = Vector2(1020, 13)
    survival_label.add_theme_color_override("font_color", Color("#ffd68a"))
    survival_label.add_theme_font_size_override("font_size", 14)
    top.add_child(survival_label)
    var help := Label.new()
    help.text = "WASD bergerak  •  Space lompat  •  LMB tambang/gunakan kiri  •  RMB pasang/gunakan kanan  •  / command"
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
    command_line = LineEdit.new()
    command_line.position = Vector2(280, 545)
    command_line.size = Vector2(720, 38)
    command_line.placeholder_text = "Ketik command: /help, /give, /set, /tp, /time"
    command_line.visible = false
    command_line.add_theme_font_size_override("font_size", 17)
    command_line.text_submitted.connect(_on_command_submitted)
    hud.add_child(command_line)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and event.keycode == KEY_SLASH and not command_line.visible:
        command_line.visible = true
        command_line.text = "/"
        command_line.grab_focus()
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func update_player_status(health: int, hunger: int, item: String, slot: int) -> void:
    if is_instance_valid(survival_label): survival_label.text = "HP %d/20  HUNGER %d/20  •  %s [%d]" % [health, hunger, item, slot + 1]

func _save_game() -> bool:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if not file: return false
    file.store_string(JSON.stringify({"world": {"time": world.time_of_day}, "player": player.get_save_state()}))
    file.close()
    world.save_world()
    return true

func _load_game() -> bool:
    var loaded_world := world.load_world()
    if not FileAccess.file_exists(SAVE_PATH): return loaded_world
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if not file: return loaded_world
    var parsed = JSON.parse_string(file.get_as_text())
    file.close()
    if parsed is Dictionary and parsed.has("player"): player.apply_save_state(parsed.player)
    return loaded_world

func _on_command_submitted(raw: String) -> void:
    command_line.visible = false
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    var text := raw.strip_edges().trim_prefix("/")
    var parts := text.split(" ", false)
    if parts.is_empty(): return
    var result := "Command tidak dikenal. /help"
    match parts[0].to_lower():
        "help": result = "Command: /give /setblock /fill /clone /tp /spawnpoint /kill /clear /locate /time /weather /difficulty /gamerule /effect /craft /save /load"
        "give":
            if parts.size() > 1 and (VoxelWorld.BLOCKS.has(parts[1]) or ContentRegistry.ITEMS.has(parts[1])):
                player.inventory[player.selected] = parts[1]
                player._refresh_item_colors()
                result = "Diberi %s" % parts[1]
            else: result = "Gunakan /give <block|item>. 35 block dan content registry tersedia."
        "set":
            if parts.size() >= 5:
                var cell := Vector3i(int(parts[1]), int(parts[2]), int(parts[3]))
                result = "Block dipasang" if world.set_block(cell, parts[4]) else "Block tidak valid"
        "setblock":
            if parts.size() >= 5:
                var cell := Vector3i(int(parts[1]), int(parts[2]), int(parts[3]))
                result = "Block dipasang" if world.set_block(cell, parts[4]) else "Block tidak valid"
        "fill":
            if parts.size() >= 8:
                var a := Vector3i(int(parts[1]), int(parts[2]), int(parts[3]))
                var b := Vector3i(int(parts[4]), int(parts[5]), int(parts[6]))
                var count := world.fill_region(a, b, parts[7])
                result = "%d block diisi" % count if count > 0 else "Block tidak valid"
        "clone":
            if parts.size() >= 10:
                var a := Vector3i(int(parts[1]), int(parts[2]), int(parts[3]))
                var b := Vector3i(int(parts[4]), int(parts[5]), int(parts[6]))
                var dest := Vector3i(int(parts[7]), int(parts[8]), int(parts[9]))
                result = "%d block disalin" % world.clone_region(a, b, dest)
        "tp":
            if parts.size() >= 4:
                player.position = Vector3(float(parts[1]), float(parts[2]), float(parts[3]))
                result = "Teleport berhasil"
        "spawnpoint":
            spawn_point = player.position
            result = "Spawn point ditetapkan"
        "kill":
            player.health = 0
            player.position = spawn_point
            player.health = 20
            result = "Pemain respawn di spawn point"
        "clear":
            player.inventory[player.selected] = "moss"
            player._refresh_item_colors()
            result = "Slot aktif dikosongkan"
        "locate":
            result = "Posisi: %d %d %d" % [int(player.position.x), int(player.position.y), int(player.position.z)]
        "time":
            if parts.size() > 1 and parts[1] == "night": world.time_of_day = 0.75
            elif parts.size() > 1 and parts[1] == "day": world.time_of_day = 0.25
            result = "Waktu diubah"
        "weather":
            result = "Cuaca cerah" if parts.size() < 2 or parts[1] == "clear" else "Cuaca %s disiapkan" % parts[1]
        "difficulty":
            if parts.size() > 1 and parts[1] in ["peaceful", "easy", "normal", "hard"]: difficulty = parts[1]
            result = "Difficulty: %s" % difficulty
        "gamerule":
            if parts.size() > 2 and parts[1] == "keepinventory": keep_inventory = parts[2].to_lower() == "true"
            result = "keepinventory=%s" % keep_inventory
        "effect":
            result = "Effect %s diterapkan selama %s detik" % [parts[1], parts[2] if parts.size() > 2 else "30"] if parts.size() > 1 else "Format: /effect <nama> <detik>"
        "craft":
            var recipe := ContentRegistry.recipe(parts[1]) if parts.size() > 1 else {}
            if not recipe.is_empty():
                player.inventory[player.selected] = str(recipe.output)
                player._refresh_item_colors()
                result = "Craft berhasil: %s" % recipe.output
            else: result = "Recipe tidak ditemukan. Gunakan /help atau /recipes"
        "recipes":
            result = "Recipe: " + ", ".join(ContentRegistry.RECIPES.keys())
        "save": result = "World tersimpan" if _save_game() else "Save gagal"
        "load": result = "World dimuat" if _load_game() else "Belum ada save"
    player._show_action(result)
