extends Control

signal craft_requested(item_key: String)

@onready var resources_label: Label = $CraftingPanel/Margin/VBox/Resources
@onready var improvised_axe_button: Button = $CraftingPanel/Margin/VBox/Recipes/ImprovisedAxeButton
@onready var improvised_pickaxe_button: Button = $CraftingPanel/Margin/VBox/Recipes/ImprovisedPickaxeButton
@onready var improvised_knife_button: Button = $CraftingPanel/Margin/VBox/Recipes/ImprovisedKnifeButton
@onready var axe_button: Button = $CraftingPanel/Margin/VBox/Recipes/AxeButton
@onready var pickaxe_button: Button = $CraftingPanel/Margin/VBox/Recipes/PickaxeButton
@onready var sword_button: Button = $CraftingPanel/Margin/VBox/Recipes/SwordButton
@onready var campfire_button: Button = $CraftingPanel/Margin/VBox/Recipes/CampfireButton
@onready var wolf_armor_button: Button = $CraftingPanel/Margin/VBox/Recipes/WolfArmorButton
@onready var status_label: Label = $CraftingPanel/Margin/VBox/Status

var snapshot: Dictionary = {}

var recipe_costs: Dictionary = {
	"improvised_axe": {"stick": 2, "small_stone": 1, "vine": 1},
	"improvised_pickaxe": {"stick": 2, "small_stone": 2, "vine": 1},
	"improvised_knife": {"stick": 1, "small_stone": 1, "vine": 1},
	"axe": {"wood": 3, "stone": 2},
	"pickaxe": {"wood": 2, "stone": 3},
	"sword": {"wood": 2, "stone": 4},
	"campfire_kit": {"wood": 3, "stone": 3},
	"wolf_armor": {"wolf_hide": 3, "vine": 2}
}

func _ready() -> void:
	visible = false

	improvised_axe_button.pressed.connect(_on_improvised_axe_pressed)
	improvised_pickaxe_button.pressed.connect(_on_improvised_pickaxe_pressed)
	improvised_knife_button.pressed.connect(_on_improvised_knife_pressed)
	axe_button.pressed.connect(_on_axe_pressed)
	pickaxe_button.pressed.connect(_on_pickaxe_pressed)
	sword_button.pressed.connect(_on_sword_pressed)
	campfire_button.pressed.connect(_on_campfire_pressed)
	wolf_armor_button.pressed.connect(_on_wolf_armor_pressed)

	_refresh_buttons()

func toggle_crafting() -> void:
	visible = not visible
	if visible:
		status_label.text = "Fabrique primeiro ferramentas improvisadas."

func close_crafting() -> void:
	visible = false

func refresh_crafting(new_snapshot: Dictionary) -> void:
	snapshot = new_snapshot.duplicate()

	resources_label.text = "Chão: Graveto %d | Pedra Pequena %d | Cipó %d\nGrandes: Madeira %d | Pedra %d | Pele %d" % [
		int(snapshot.get("stick", 0)),
		int(snapshot.get("small_stone", 0)),
		int(snapshot.get("vine", 0)),
		int(snapshot.get("wood", 0)),
		int(snapshot.get("stone", 0)),
		int(snapshot.get("wolf_hide", 0))
	]

	_refresh_buttons()

func show_result(success: bool, item_name: String) -> void:
	if success:
		status_label.text = "%s fabricado com sucesso." % item_name
	else:
		status_label.text = "Não foi possível fabricar %s." % item_name

func _refresh_buttons() -> void:
	improvised_axe_button.disabled = not _can_craft("improvised_axe")
	improvised_pickaxe_button.disabled = not _can_craft("improvised_pickaxe")
	improvised_knife_button.disabled = not _can_craft("improvised_knife")
	axe_button.disabled = not _can_craft("axe")
	pickaxe_button.disabled = not _can_craft("pickaxe")
	sword_button.disabled = not _can_craft("sword")
	campfire_button.disabled = not _can_craft("campfire_kit")
	wolf_armor_button.disabled = not _can_craft("wolf_armor")

	improvised_axe_button.text = "Machado Improvisado — 2 Gravetos + 1 Pedra Pequena + 1 Cipó" + _crafted_suffix("improvised_axe")
	improvised_pickaxe_button.text = "Picareta Improvisada — 2 Gravetos + 2 Pedras Pequenas + 1 Cipó" + _crafted_suffix("improvised_pickaxe")
	improvised_knife_button.text = "Faca Improvisada — 1 Graveto + 1 Pedra Pequena + 1 Cipó" + _crafted_suffix("improvised_knife")
	axe_button.text = "Machado — 3 Madeira + 2 Pedra" + _crafted_suffix("axe")
	pickaxe_button.text = "Picareta — 2 Madeira + 3 Pedra" + _crafted_suffix("pickaxe")
	sword_button.text = "Espada — 2 Madeira + 4 Pedra" + _crafted_suffix("sword")
	campfire_button.text = "Fogueira — 3 Madeira + 3 Pedra" + _crafted_suffix("campfire_kit")
	wolf_armor_button.text = "Armadura de Pele — 3 Peles de Lobo + 2 Cipós" + _crafted_suffix("wolf_armor")

func _can_craft(item_key: String) -> bool:
	if int(snapshot.get(item_key, 0)) > 0:
		return false

	var costs_value: Variant = recipe_costs.get(item_key, {})
	if costs_value is not Dictionary:
		return false

	var costs: Dictionary = costs_value
	if costs.is_empty():
		return false

	for resource_key in costs.keys():
		var needed: int = int(costs[resource_key])
		var available: int = int(snapshot.get(resource_key, 0))
		if available < needed:
			return false

	return true

func _crafted_suffix(item_key: String) -> String:
	if int(snapshot.get(item_key, 0)) > 0:
		return "  [CRIADO]"
	return ""

func _on_improvised_axe_pressed() -> void:
	craft_requested.emit("improvised_axe")

func _on_improvised_pickaxe_pressed() -> void:
	craft_requested.emit("improvised_pickaxe")

func _on_improvised_knife_pressed() -> void:
	craft_requested.emit("improvised_knife")

func _on_axe_pressed() -> void:
	craft_requested.emit("axe")

func _on_pickaxe_pressed() -> void:
	craft_requested.emit("pickaxe")

func _on_sword_pressed() -> void:
	craft_requested.emit("sword")

func _on_campfire_pressed() -> void:
	craft_requested.emit("campfire_kit")

func _on_wolf_armor_pressed() -> void:
	craft_requested.emit("wolf_armor")
