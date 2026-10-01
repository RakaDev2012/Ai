extends CharacterBody3D

var world: VoxelWorld
var hud: CanvasLayer
const SPEED := 5.2
const JUMP := 6.2
const GRAVITY := 17.0
const LOOK_SENS := 0.0025
var pitch := -0.08
var selected := 0
var health := 20
var hunger := 20
var inventory := ["moss", "slate", "emberwood", "glowstone", "glowstone"]
var left_item: MeshInstance3D
var right_item: MeshInstance3D
var left_light: OmniLight3D
var action_label: Label
var previous_y := 0.0

func _ready() -> void:
    var capsule := CapsuleShape3D.new()
    capsule.height = 1.8
    capsule.radius = 0.34
    $Collision.shape = capsule
    position = Vector3(0, 5, 5)
    previous_y = position.y
    _ensure_actions()
    _make_hands()
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    for i in range(5):
        if not InputMap.has_action("slot_%d" % i): InputMap.add_action("slot_%d" % i)
        var ev := InputEventKey.new()
        ev.keycode = KEY_1 + i
        InputMap.action_add_event("slot_%d" % i, ev)
    _sync_status()

func _ensure_actions() -> void:
    var bindings := {"move_forward": KEY_W, "move_back": KEY_S, "move_left": KEY_A, "move_right": KEY_D, "jump": KEY_SPACE}
    for action in bindings:
        if not InputMap.has_action(action): InputMap.add_action(action)
        var ev := InputEventKey.new()
        ev.keycode = bindings[action]
        InputMap.action_add_event(action, ev)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * LOOK_SENS)
        pitch = clamp(pitch - event.relative.y * LOOK_SENS, -1.45, 1.45)
        $Head.rotation.x = pitch
    if event is InputEventKey and event.keycode == KEY_ESCAPE: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    if event is InputEventMouseButton and event.pressed:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        if event.button_index == MOUSE_BUTTON_LEFT: _use_left()
        elif event.button_index == MOUSE_BUTTON_RIGHT: _use_right()

func _physics_process(delta: float) -> void:
    var input_vec := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := (transform.basis * Vector3(input_vec.x, 0, input_vec.y)).normalized()
    velocity.x = move_toward(velocity.x, direction.x * SPEED, 18.0 * delta)
    velocity.z = move_toward(velocity.z, direction.z * SPEED, 18.0 * delta)
    if not is_on_floor(): velocity.y -= GRAVITY * delta
    if Input.is_action_just_pressed("jump") and is_on_floor(): velocity.y = JUMP
    var before_y := position.y
    move_and_slide()
    if is_on_floor() and before_y - position.y > 4.0:
        health = max(0, health - int((before_y - position.y) - 3.0))
        _show_action("Benturan! health %d/20" % health)
    _update_hands(delta)
    for i in range(5):
        if Input.is_action_just_pressed("slot_%d" % i):
            selected = i
            _refresh_item_colors()
            _sync_status()
    hunger = max(0, hunger - (1 if Engine.get_physics_frames() % 240 == 0 else 0))
    if hunger == 0 and Engine.get_physics_frames() % 60 == 0: health = max(0, health - 1)
    _sync_status()

func _make_hands() -> void:
    left_item = _make_item(Color("#70d6ff"), Vector3(-0.46, -0.38, -0.75))
    right_item = _make_item(Color("#ffb45c"), Vector3(0.46, -0.38, -0.75))
    $Head/Camera.add_child(left_item)
    $Head/Camera.add_child(right_item)
    left_light = OmniLight3D.new()
    left_light.light_color = Color("#8fd8ff")
    left_light.light_energy = 1.8
    left_light.omni_range = 7.0
    left_light.shadow_enabled = false
    left_item.add_child(left_light)
    _refresh_item_colors()

func _make_item(color: Color, offset: Vector3) -> MeshInstance3D:
    var item := MeshInstance3D.new()
    item.position = offset
    var mesh := BoxMesh.new()
    mesh.size = Vector3(0.16, 0.16, 0.52)
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.metallic = 0.18
    mat.roughness = 0.42
    mesh.material = mat
    item.mesh = mesh
    return item

func _refresh_item_colors() -> void:
    var palette := {"moss": Color("#75b95f"), "slate": Color("#8e9bab"), "emberwood": Color("#b47a4e"), "glowstone": Color("#e7c45c")}
    var left_id: String = inventory[selected]
    var right_id: String = inventory[(selected + 1) % inventory.size()]
    (left_item.mesh as BoxMesh).material.albedo_color = palette[left_id]
    (right_item.mesh as BoxMesh).material.albedo_color = palette[right_id]
    left_light.light_energy = 3.0 if left_id == "glowstone" else 1.2

func _update_hands(delta: float) -> void:
    var bob := sin(Time.get_ticks_msec() * 0.008) * 0.018
    left_item.position.y = -0.38 + bob
    right_item.position.y = -0.38 - bob
    if action_label and is_instance_valid(action_label): action_label.modulate.a = max(0.0, action_label.modulate.a - delta * 1.8)

func _raycast_block() -> Dictionary:
    var camera := $Head/Camera
    var from: Vector3 = camera.global_position
    var to: Vector3 = from + -camera.global_transform.basis.z * 6.0
    var query := PhysicsRayQueryParameters3D.create(from, to, 1)
    return get_world_3d().direct_space_state.intersect_ray(query)

func _use_left() -> void:
    var hit := _raycast_block()
    if not hit.is_empty():
        var cell := Vector3i(floor(hit.position - hit.normal * 0.01))
        var mined := world.remove_block(cell)
        if not mined.is_empty():
            inventory[selected] = mined
            _show_action("Ditambang: %s (tangan kiri)" % mined)
        else: _show_action("Tidak ada block di sini")
    else: _show_action("Tangan kiri siap digunakan")
    _swing(left_item)
    _refresh_item_colors()

func _use_right() -> void:
    var hit := _raycast_block()
    if not hit.is_empty():
        var cell := Vector3i(floor(hit.position + hit.normal * 0.01))
        if world.set_block(cell, inventory[selected]): _show_action("Ditempatkan: %s (tangan kanan)" % inventory[selected])
    else: _show_action("Tangan kanan siap digunakan")
    _swing(right_item)

func _swing(item: Node3D) -> void:
    var tween := create_tween()
    tween.tween_property(item, "rotation:x", -0.8, 0.08)
    tween.tween_property(item, "rotation:x", 0.0, 0.15)

func _show_action(text: String) -> void:
    if not hud: return
    if not action_label:
        action_label = Label.new()
        action_label.position = Vector2(500, 525)
        action_label.add_theme_font_size_override("font_size", 18)
        action_label.add_theme_color_override("font_color", Color("#d5f4ff"))
        hud.add_child(action_label)
    action_label.text = text
    action_label.modulate.a = 1.0

func _sync_status() -> void:
    var root := get_parent()
    if root.has_method("update_player_status"): root.update_player_status(health, hunger, inventory[selected], selected)
