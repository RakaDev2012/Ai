extends Node3D
class_name VoxelWorld

const SIZE := 20
const BLOCKS := {
    "moss": {"type": 0, "color": Color("#75b95f")},
    "slate": {"type": 1, "color": Color("#8e9bab")},
    "emberwood": {"type": 2, "color": Color("#b47a4e")},
    "glowstone": {"type": 3, "color": Color("#e7c45c")}
}
var atlas: Texture2D
var block_materials: Array[StandardMaterial3D] = []
var grid: Dictionary = {}
var visual_root: Node3D
var collision_root: Node3D
var time_of_day := 0.35
const SAVE_PATH := "user://lumen_frontier_world.json"

func _ready() -> void:
    atlas = load("res://assets/terrain.svg")
    _make_materials()
    visual_root = Node3D.new()
    visual_root.name = "OptimizedBlockMeshes"
    add_child(visual_root)
    collision_root = Node3D.new()
    collision_root.name = "BlockCollisions"
    add_child(collision_root)
    _generate_world()
    rebuild()

func _make_materials() -> void:
    var colors := [Color("#75b95f"), Color("#8e9bab"), Color("#b47a4e"), Color("#e7c45c")]
    for color in colors:
        var mat := StandardMaterial3D.new()
        mat.albedo_color = color
        mat.albedo_texture = atlas
        mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
        mat.roughness = 0.92
        if color == Color("#e7c45c"):
            mat.emission_enabled = true
            mat.emission = Color("#c98d24")
            mat.emission_energy_multiplier = 1.6
        block_materials.append(mat)

func _generate_world() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 20261001
    for x in range(-SIZE / 2, SIZE / 2):
        for z in range(-SIZE / 2, SIZE / 2):
            var wave := sin(float(x) * 0.55) * 0.7 + cos(float(z) * 0.42) * 0.55
            var top := 2 + int(round(wave + rng.randf_range(-0.25, 0.25)))
            for y in range(-1, top + 1):
                var id := "moss" if y == top else ("slate" if y >= top - 2 else "emberwood")
                grid[Vector3i(x, y, z)] = id
    grid[Vector3i(0, 4, 0)] = "glowstone"
    grid[Vector3i(0, 5, 0)] = "glowstone"

func get_block(cell: Vector3i) -> String:
    return str(grid.get(cell, ""))

func set_block(cell: Vector3i, id: String) -> bool:
    if not BLOCKS.has(id): return false
    grid[cell] = id
    rebuild()
    return true

func remove_block(cell: Vector3i) -> String:
    var id := get_block(cell)
    if id.is_empty(): return ""
    grid.erase(cell)
    rebuild()
    return id

func rebuild() -> void:
    for child in visual_root.get_children(): child.queue_free()
    for child in collision_root.get_children(): child.queue_free()
    var grouped: Array[Array] = [[], [], [], []]
    for cell in grid:
        var id := str(grid[cell])
        var type: int = int(BLOCKS[id].type)
        grouped[type].append(Vector3(cell))
    for type in range(grouped.size()):
        _build_multimesh(grouped[type], type)
    _build_collisions()

func _build_multimesh(positions: Array, type: int) -> void:
    if positions.is_empty(): return
    var mm := MultiMesh.new()
    mm.transform_format = MultiMesh.TRANSFORM_3D
    mm.mesh = _make_box(block_materials[type])
    mm.instance_count = positions.size()
    for i in range(positions.size()):
        mm.set_instance_transform(i, Transform3D(Basis.IDENTITY, positions[i]))
    var instance := MultiMeshInstance3D.new()
    instance.multimesh = mm
    instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
    visual_root.add_child(instance)

func _make_box(material: Material) -> BoxMesh:
    var box := BoxMesh.new()
    box.size = Vector3.ONE
    box.material = material
    return box

func _build_collisions() -> void:
    var collider := BoxShape3D.new()
    collider.size = Vector3.ONE
    for cell in grid:
        var body := StaticBody3D.new()
        body.position = Vector3(cell)
        body.collision_layer = 1
        body.collision_mask = 1
        var shape := CollisionShape3D.new()
        shape.shape = collider
        body.add_child(shape)
        collision_root.add_child(body)

func advance_time(delta: float) -> void:
    time_of_day = fmod(time_of_day + delta * 0.006, 1.0)

func save_world(path: String = SAVE_PATH) -> bool:
    var blocks: Array = []
    for cell in grid:
        blocks.append({"x": cell.x, "y": cell.y, "z": cell.z, "id": grid[cell]})
    var file := FileAccess.open(path, FileAccess.WRITE)
    if not file: return false
    file.store_string(JSON.stringify({"version": 1, "time": time_of_day, "blocks": blocks}))
    file.close()
    return true

func load_world(path: String = SAVE_PATH) -> bool:
    if not FileAccess.file_exists(path): return false
    var file := FileAccess.open(path, FileAccess.READ)
    if not file: return false
    var parsed = JSON.parse_string(file.get_as_text())
    file.close()
    if not parsed is Dictionary or not parsed.has("blocks"): return false
    grid.clear()
    for entry in parsed.blocks:
        if entry is Dictionary and BLOCKS.has(str(entry.id)):
            grid[Vector3i(int(entry.x), int(entry.y), int(entry.z))] = str(entry.id)
    time_of_day = float(parsed.get("time", 0.35))
    rebuild()
    return true
