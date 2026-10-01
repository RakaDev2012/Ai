extends CharacterBody3D

var world: Node
var hud: CanvasLayer
const SPEED := 5.2
const JUMP := 6.2
const GRAVITY := 17.0
const LOOK_SENS := 0.0025
var pitch := -0.08
var selected := 0
var left_item: MeshInstance3D
var right_item: MeshInstance3D
var left_light: OmniLight3D
var action_label: Label

func _ready() -> void:
    var capsule := CapsuleShape3D.new()
    capsule.height = 1.8
    capsule.radius = 0.34
    $Collision.shape = capsule
    position = Vector3(0, 5, 5)
    _ensure_actions()
    _make_hands()
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    for i in range(5):
        if not InputMap.has_action("slot_%d" % i):
            InputMap.add_action("slot_%d" % i)
        var ev := InputEventKey.new()
        ev.keycode = KEY_1 + i
        InputMap.action_add_event("slot_%d" % i, ev)

func _ensure_actions() -> void:
    var bindings := {"move_forward": KEY_W, "move_back": KEY_S, "move_left": KEY_A, "move_right": KEY_D, "jump": KEY_SPACE}
    for action in bindings:
        if not InputMap.has_action(action):
            InputMap.add_action(action)
        var ev := InputEventKey.new()
        ev.keycode = bindings[action]
        InputMap.action_add_event(action, ev)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * LOOK_SENS)
        pitch = clamp(pitch - event.relative.y * LOOK_SENS, -1.45, 1.45)
        $Head.rotation.x = pitch
    if event is InputEventKey and event.keycode == KEY_ESCAPE:
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    if event is InputEventMouseButton and event.pressed:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        if event.button_index == MOUSE_BUTTON_LEFT:
            _use_left()
        elif event.button_index == MOUSE_BUTTON_RIGHT:
            _use_right()

func _physics_process(delta: float) -> void:
    var input_vec := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := (transform.basis * Vector3(input_vec.x, 0, input_vec.y)).normalized()
    velocity.x = move_toward(velocity.x, direction.x * SPEED, 18.0 * delta)
    velocity.z = move_toward(velocity.z, direction.z * SPEED, 18.0 * delta)
    if not is_on_floor(): velocity.y -= GRAVITY * delta
    if Input.is_action_just_pressed("jump") and is_on_floor(): velocity.y = JUMP
    move_and_slide()
    _update_hands(delta)
    for i in range(5):
        if Input.is_action_just_pressed("slot_%d" % i):
            selected = i
            _refresh_item_colors()

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
    var palette := [Color("#70d6ff"), Color("#ffb45c"), Color("#b6f36b"), Color("#f58aff"), Color("#e9efff")]
    (left_item.mesh as BoxMesh).material.albedo_color = palette[selected]
    (right_item.mesh as BoxMesh).material.albedo_color = palette[(selected + 1) % palette.size()]

func _update_hands(delta: float) -> void:
    var bob := sin(Time.get_ticks_msec() * 0.008) * 0.018
    left_item.position.y = -0.38 + bob
    right_item.position.y = -0.38 - bob
    if action_label and is_instance_valid(action_label):
        action_label.modulate.a = max(0.0, action_label.modulate.a - delta * 1.8)

func _use_left() -> void:
    _show_action("Tangan kiri: item digunakan")
    var tween := create_tween()
    tween.tween_property(left_item, "rotation:x", -0.8, 0.08)
    tween.tween_property(left_item, "rotation:x", 0.0, 0.15)

func _use_right() -> void:
    _show_action("Tangan kanan: item digunakan")
    var tween := create_tween()
    tween.tween_property(right_item, "rotation:x", -0.8, 0.08)
    tween.tween_property(right_item, "rotation:x", 0.0, 0.15)

func _show_action(text: String) -> void:
    if not hud: return
    if not action_label:
        action_label = Label.new()
        action_label.position = Vector2(520, 525)
        action_label.add_theme_font_size_override("font_size", 18)
        action_label.add_theme_color_override("font_color", Color("#d5f4ff"))
        hud.add_child(action_label)
    action_label.text = text
    action_label.modulate.a = 1.0
