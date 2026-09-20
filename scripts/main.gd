extends Node2D

@onready var player: CharacterBody2D = $Player as CharacterBody2D
@onready var position_label: Label = $HUD/Panel/Margin/VBox/PositionLabel
@onready var state_label: Label = $HUD/Panel/Margin/VBox/StateLabel
@onready var inventory_label: Label = $HUD/Panel/Margin/VBox/InventoryLabel
@onready var interaction_panel: PanelContainer = $HUD/InteractionPanel
@onready var interaction_label: Label = $HUD/InteractionPanel/Margin/InteractionLabel

func _ready() -> void:
	player.connect("inventory_changed", Callable(self, "_update_inventory"))
	_update_inventory()

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
