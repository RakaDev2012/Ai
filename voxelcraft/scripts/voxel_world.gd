extends Node3D
class_name VoxelWorld

const SIZE := 20
const BLOCKS := {
    "moss": {"type": 0, "color": Color("#75b95f"), "collides": true},
    "slate": {"type": 1, "color": Color("#8e9bab"), "collides": true},
    "emberwood": {"type": 2, "color": Color("#b47a4e"), "collides": true},
    "glowstone": {"type": 3, "color": Color("#e7c45c"), "collides": true},
    "sand": {"type": 4, "color": Color("#d9bd76"), "collides": true},
    "snow": {"type": 5, "color": Color("#eaf4ff"), "collides": true},
    "obsidian": {"type": 6, "color": Color("#30284b"), "collides": true},
    "brick": {"type": 7, "color": Color("#b55245"), "collides": true},
    "glass": {"type": 8, "color": Color(0.45, 0.78, 0.92, 0.42), "collides": true},
    "water": {"type": 9, "color": Color(0.18, 0.42, 0.82, 0.72), "collides": false},
    "leaves": {"type": 10, "color": Color("#3e8b59"), "collides": true},
    "copper": {"type": 11, "color": Color("#c47d54"), "collides": true},
    "gold": {"type": 12, "color": Color("#f0c84e"), "collides": true},
    "clay": {"type": 13, "color": Color("#a88c85"), "collides": true},
    "bedrock": {"type": 14, "color": Color("#25262d"), "collides": true}
}
const SAVE_PATH := "user://lumen_frontier_world.json"
var atlas: Texture2D
var block_materials: Array[StandardMaterial3D] = []
var grid: Dictionary = {}
var visual_root: Node3D
var collision_root: Node3D
var time_of_day := 0.35

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
    block_materials.resize(BLOCKS.size())
    for id in BLOCKS:
        var type: int = int(BLOCKS[id].type)
        var mat := StandardMaterial3D.new()
        mat.albedo_color = BLOCKS[id].color
        mat.albedo_texture = atlas
        mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
        mat.roughness = 0.92
        if id == "glowstone" or id == "gold":
            mat.emission_enabled = true
            mat.emission = BLOCKS[id].color
            mat.emission_energy_multiplier = 1.25
        if id == "glass" or id == "water":
            mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
            mat.cull_mode = BaseMaterial3D.CULL_DISABLED
        block_materials[type] = mat

func _generate_world() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 20261001
    for x in range(-SIZE / 2, SIZE / 2):
        for z in range(-SIZE / 2, SIZE / 2):
            var wave := sin(float(x) * 0.55) * 0.7 + cos(float(z) * 0.42) * 0.55
            var top := 2 + int(round(wave + rng.randf_range(-0.25, 0.25)))
            for y in range(-1, top + 1):
                var id := "moss" if y == top else ("slate" if y >= top - 2 else "clay")
                grid[Vector3i(x, y, z)] = id
    for x in range(-3, 4):
        grid[Vector3i(x, 3, -2)] = "water"
    grid[Vector3i(0, 4, 0)] = "glowstone"
    grid[Vector3i(0, 5, 0)] = "glowstone"
    grid[Vector3i(3, 3, 3)] = "gold"
    grid[Vector3i(-3, 3, -3)] = "obsidian"

func get_block(cell: Vector3i) -> String:
    return str(grid.get(cell, ""))

func set_block(cell: Vector3i, id: String) -> bool:
    if not BLOCKS.has(id): return false
    grid[cell] = id
    rebuild()
    return true

func remove_block(cell: Vector3i) -> String:
    var id := get_block(cell)
    if id.is_empty() or id == "bedrock": return ""
    grid.erase(cell)
    rebuild()
    return id

func fill_region(a: Vector3i, b: Vector3i, id: String) -> int:
    if not BLOCKS.has(id): return 0
    var min_v := Vector3i(min(a.x, b.x), min(a.y, b.y), min(a.z, b.z))
    var max_v := Vector3i(max(a.x, b.x), max(a.y, b.y), max(a.z, b.z))
    var count := 0
    for x in range(min_v.x, max_v.x + 1):
        for y in range(min_v.y, max_v.y + 1):
            for z in range(min_v.z, max_v.z + 1):
                grid[Vector3i(x, y, z)] = id
                count += 1
    rebuild()
    return count

func rebuild() -> void:
    for child in visual_root.get_children(): child.queue_free()
    for child in collision_root.get_children(): child.queue_free()
    var grouped: Array[Array] = []
    grouped.resize(BLOCKS.size())
    for i in range(BLOCKS.size()): grouped[i] = []
    for cell in grid:
        var id := str(grid[cell])
        grouped[int(BLOCKS[id].type)].append(Vector3(cell))
    for type in range(grouped.size()): _build_multimesh(grouped[type], type)
    _build_collisions()

func _build_multimesh(positions: Array, type: int) -> void:
    if positions.is_empty(): return
    var mm := MultiMesh.new()
    mm.transform_format = MultiMesh.TRANSFORM_3D
    mm.mesh = _make_box(block_materials[type])
    mm.instance_count = positions.size()
    for i in range(positions.size()): mm.set_instance_transform(i, Transform3D(Basis.IDENTITY, positions[i]))
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
        var id := str(grid[cell])
        if not BLOCKS[id].collides: continue
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
    for cell in grid: blocks.append({"x": cell.x, "y": cell.y, "z": cell.z, "id": grid[cell]})
    var file := FileAccess.open(path, FileAccess.WRITE)
    if not file: return false
    file.store_string(JSON.stringify({"version": 2, "time": time_of_day, "blocks": blocks}))
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
