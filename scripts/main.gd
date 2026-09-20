extends Node2D

@onready var player: CharacterBody2D = $Player as CharacterBody2D
@onready var position_label: Label = $HUD/Panel/Margin/VBox/PositionLabel
@onready var state_label: Label = $HUD/Panel/Margin/VBox/StateLabel
@onready var health_label: Label = $HUD/Panel/Margin/VBox/HealthLabel
@onready var hunger_label: Label = $HUD/Panel/Margin/VBox/HungerLabel
@onready var armor_label: Label = $HUD/Panel/Margin/VBox/ArmorLabel
@onready var building_label: Label = $HUD/Panel/Margin/VBox/BuildingLabel
@onready var progression_label: Label = $HUD/Panel/Margin/VBox/ProgressionLabel
@onready var inventory_label: Label = $HUD/Panel/Margin/VBox/InventoryLabel
@onready var interaction_panel: PanelContainer = $HUD/InteractionPanel
@onready var interaction_label: Label = $HUD/InteractionPanel/Margin/InteractionLabel
@onready var inventory_ui: Control = $HUD/InventoryUI as Control
@onready var hotbar_ui: Control = $HUD/HotbarUI as Control
@onready var crafting_ui: Control = $HUD/CraftingUI as Control
@onready var building_system: Node2D = $BuildingSystem as Node2D

func _ready() -> void:
	player.connect("inventory_changed", Callable(self, "_update_inventory"))
	crafting_ui.connect("craft_requested", Callable(self, "_on_craft_requested"))
	_update_inventory()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if not key_event.pressed or key_event.echo:
			return

		if key_event.keycode == KEY_I:
			crafting_ui.call("close_crafting")
			if bool(building_system.call("is_build_mode")):
				building_system.call("toggle_build_mode")
			inventory_ui.call("toggle_inventory")
			get_viewport().set_input_as_handled()
			return

		if key_event.keycode == KEY_C:
			inventory_ui.call("close_inventory")
			if bool(building_system.call("is_build_mode")):
				building_system.call("toggle_build_mode")
			crafting_ui.call("toggle_crafting")
			get_viewport().set_input_as_handled()
			return

		if key_event.keycode == KEY_B:
			inventory_ui.call("close_inventory")
			crafting_ui.call("close_crafting")
			building_system.call("toggle_build_mode")
			get_viewport().set_input_as_handled()
			return

		if bool(building_system.call("is_build_mode")):
			if key_event.keycode == KEY_Q:
				building_system.call("cycle_piece")
				get_viewport().set_input_as_handled()
				return

			if key_event.keycode == KEY_R:
				building_system.call("rotate_piece")
				get_viewport().set_input_as_handled()
				return

			if key_event.keycode == KEY_ENTER:
				building_system.call("try_place_piece")
				get_viewport().set_input_as_handled()
				return

			if key_event.keycode == KEY_ESCAPE:
				building_system.call("toggle_build_mode")
				get_viewport().set_input_as_handled()
				return

		if key_event.keycode == KEY_G:
			player.call("place_campfire")
			get_viewport().set_input_as_handled()
			return

		if key_event.keycode == KEY_H:
			player.call("toggle_armor")
			get_viewport().set_input_as_handled()
			return

		var selected_slot: int = -1
		match key_event.keycode:
			KEY_1:
				selected_slot = 0
			KEY_2:
				selected_slot = 1
			KEY_3:
				selected_slot = 2
			KEY_4:
				selected_slot = 3
			KEY_5:
				selected_slot = 4
			KEY_6:
				selected_slot = 5

		if selected_slot >= 0:
			hotbar_ui.call("select_slot", selected_slot)
			player.call("set_selected_hotbar_slot", selected_slot)
			get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	health_label.text = str(player.call("get_health_text"))
	hunger_label.text = str(player.call("get_hunger_text"))
	armor_label.text = str(player.call("get_armor_text"))
	building_label.text = str(building_system.call("get_status_text"))
	progression_label.text = str(player.call("get_progression_text"))
	position_label.text = "Posição: %d, %d" % [
		roundi(player.global_position.x),
		roundi(player.global_position.y)
	]

	var player_velocity: Vector2 = player.velocity
	var moving: bool = player_velocity.length() > 1.0
	var running: bool = Input.is_key_pressed(KEY_SHIFT) and moving

	if running:
		state_label.text = "Estado: CORRENDO"
	elif moving:
		state_label.text = "Estado: ANDANDO"
	else:
		state_label.text = "Estado: PARADO"

	var prompt: String = str(player.call("get_interaction_prompt"))
	interaction_label.text = prompt
	interaction_panel.visible = not prompt.is_empty()

func _on_craft_requested(item_key: String) -> void:
	var success: bool = bool(player.call("craft_item", item_key))
	var item_name: String = _get_item_name(item_key)
	crafting_ui.call("show_result", success, item_name)

func _get_item_name(item_key: String) -> String:
	match item_key:
		"improvised_axe":
			return "Machado Improvisado"
		"improvised_pickaxe":
			return "Picareta Improvisada"
		"improvised_knife":
			return "Faca Improvisada"
		"axe":
			return "Machado"
		"pickaxe":
			return "Picareta"
		"sword":
			return "Espada"
		"campfire_kit":
			return "Fogueira"
		"wolf_armor":
			return "Armadura de Pele"
		_:
			return "Item"

func _update_inventory() -> void:
	inventory_label.text = str(player.call("get_inventory_text"))

	var snapshot_value: Variant = player.call("get_inventory_snapshot")
	if snapshot_value is not Dictionary:
		return

	var snapshot: Dictionary = snapshot_value
	inventory_ui.call("refresh_inventory", snapshot)
	hotbar_ui.call("refresh_hotbar", snapshot)
	crafting_ui.call("refresh_crafting", snapshot)
