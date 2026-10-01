extends Node3D
class_name VoxelWorld

const SIZE := 20
var atlas: Texture2D
var block_materials: Array[StandardMaterial3D] = []
var block_positions: Array[Array] = [[], [], []]

func _ready() -> void:
    atlas = load("res://assets/terrain.svg")
    _make_materials()
    _generate_world()
    _build_multimeshes()
    _build_collisions()

func _make_materials() -> void:
    var colors := [Color("#75b95f"), Color("#8e9bab"), Color("#b47a4e")]
    for color in colors:
        var mat := StandardMaterial3D.new()
        mat.albedo_color = color
        mat.albedo_texture = atlas
        mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
        mat.roughness = 0.92
        block_materials.append(mat)

func _generate_world() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 20261001
    for x in range(-SIZE / 2, SIZE / 2):
        for z in range(-SIZE / 2, SIZE / 2):
            var wave := sin(float(x) * 0.55) * 0.7 + cos(float(z) * 0.42) * 0.55
            var top := 2 + int(round(wave + rng.randf_range(-0.25, 0.25)))
            for y in range(-1, top + 1):
                var type := 0 if y == top else (1 if y >= top - 2 else 2)
                block_positions[type].append(Vector3(x, y, z))
    block_positions[2].append(Vector3(0, 4, 0))
    block_positions[2].append(Vector3(0, 5, 0))

func _build_multimeshes() -> void:
    for type in range(block_positions.size()):
        var positions: Array = block_positions[type]
        var mm := MultiMesh.new()
        mm.transform_format = MultiMesh.TRANSFORM_3D
        mm.mesh = _make_box(block_materials[type])
        mm.instance_count = positions.size()
        for i in range(positions.size()):
            mm.set_instance_transform(i, Transform3D(Basis.IDENTITY, positions[i]))
        var instance := MultiMeshInstance3D.new()
        instance.multimesh = mm
        instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
        add_child(instance)

func _make_box(material: Material) -> BoxMesh:
    var box := BoxMesh.new()
    box.size = Vector3.ONE
    box.material = material
    return box

func _build_collisions() -> void:
    var collider := BoxShape3D.new()
    collider.size = Vector3.ONE
    for positions in block_positions:
        for pos in positions:
            var body := StaticBody3D.new()
            body.position = pos
            body.collision_layer = 1
            body.collision_mask = 1
            var shape := CollisionShape3D.new()
            shape.shape = collider
            body.add_child(shape)
            add_child(body)
