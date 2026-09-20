extends Node2D

@onready var player: CharacterBody2D = $Player as CharacterBody2D
@onready var position_label: Label = $HUD/Panel/Margin/VBox/PositionLabel
@onready var state_label: Label = $HUD/Panel/Margin/VBox/StateLabel
@onready var inventory_label: Label = $HUD/Panel/Margin/VBox/InventoryLabel
@onready var interaction_panel: PanelContainer = $HUD/InteractionPanel
@onready var interaction_label: Label = $HUD/InteractionPanel/Margin/InteractionLabel
@onready var inventory_ui: Control = $HUD/InventoryUI as Control
@onready var hotbar_ui: Control = $HUD/HotbarUI as Control

func _ready() -> void:
	player.connect("inventory_changed", Callable(self, "_update_inventory"))
	_update_inventory()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if not key_event.pressed or key_event.echo:
			return

		if key_event.keycode == KEY_I:
			inventory_ui.call("toggle_inventory")
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
			get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
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

func _update_inventory() -> void:
	inventory_label.text = str(player.call("get_inventory_text"))

	var wood_amount: int = int(player.call("get_inventory_amount", "wood"))
	var stone_amount: int = int(player.call("get_inventory_amount", "stone"))

	inventory_ui.call("refresh_inventory", wood_amount, stone_amount)
	hotbar_ui.call("refresh_hotbar", wood_amount, stone_amount)
