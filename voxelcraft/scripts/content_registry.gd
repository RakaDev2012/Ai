extends RefCounted
class_name ContentRegistry

const ITEMS := {
    "wooden_pick": {"kind": "tool", "durability": 80, "speed": 2.0},
    "stone_pick": {"kind": "tool", "durability": 160, "speed": 3.5},
    "iron_pick": {"kind": "tool", "durability": 320, "speed": 5.0},
    "diamond_pick": {"kind": "tool", "durability": 900, "speed": 8.0},
    "wooden_axe": {"kind": "tool", "durability": 80, "speed": 2.0},
    "stone_axe": {"kind": "tool", "durability": 160, "speed": 3.5},
    "iron_axe": {"kind": "tool", "durability": 320, "speed": 5.0},
    "diamond_axe": {"kind": "tool", "durability": 900, "speed": 8.0},
    "wooden_sword": {"kind": "weapon", "durability": 80, "damage": 4},
    "stone_sword": {"kind": "weapon", "durability": 160, "damage": 5},
    "iron_sword": {"kind": "weapon", "durability": 320, "damage": 7},
    "diamond_sword": {"kind": "weapon", "durability": 900, "damage": 10},
    "apple": {"kind": "food", "hunger": 4},
    "bread": {"kind": "food", "hunger": 6},
    "cooked_meat": {"kind": "food", "hunger": 8},
    "leather_helmet": {"kind": "armor", "slot": "head", "armor": 1},
    "iron_helmet": {"kind": "armor", "slot": "head", "armor": 2},
    "diamond_helmet": {"kind": "armor", "slot": "head", "armor": 3},
    "leather_chestplate": {"kind": "armor", "slot": "chest", "armor": 3},
    "iron_chestplate": {"kind": "armor", "slot": "chest", "armor": 6},
    "diamond_chestplate": {"kind": "armor", "slot": "chest", "armor": 8},
    "arrow": {"kind": "ammo", "damage": 2},
    "bow": {"kind": "weapon", "durability": 384, "damage": 5}
}

const RECIPES := {
    "wooden_pick": {"output": "wooden_pick", "ingredients": {"planks": 3, "stick": 2}},
    "stone_pick": {"output": "stone_pick", "ingredients": {"cobblestone": 3, "stick": 2}},
    "iron_pick": {"output": "iron_pick", "ingredients": {"iron": 3, "stick": 2}},
    "diamond_pick": {"output": "diamond_pick", "ingredients": {"diamond": 3, "stick": 2}},
    "bread": {"output": "bread", "ingredients": {"wheat": 3}},
    "torch": {"output": "torch", "ingredients": {"coal": 1, "stick": 1}},
    "lantern": {"output": "lantern", "ingredients": {"iron": 8, "torch": 1}},
    "glowstone": {"output": "glowstone", "ingredients": {"emberwood": 1, "slate": 1}},
    "iron_helmet": {"output": "iron_helmet", "ingredients": {"iron": 5}},
    "iron_chestplate": {"output": "iron_chestplate", "ingredients": {"iron": 8}},
    "diamond_sword": {"output": "diamond_sword", "ingredients": {"diamond": 2, "stick": 1}}
}

static func all_content_names() -> Array[String]:
    var names: Array[String] = []
    for key in ITEMS: names.append(key)
    for key in RECIPES:
        if not names.has(key): names.append(key)
    return names

static func recipe(name: String) -> Dictionary:
    return RECIPES.get(name, {})
