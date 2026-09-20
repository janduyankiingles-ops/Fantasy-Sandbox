extends Node2D

@onready var player = $Player
@onready var position_label: Label = $HUD/Panel/Margin/VBox/PositionLabel
@onready var state_label: Label = $HUD/Panel/Margin/VBox/StateLabel
@onready var inventory_label: Label = $HUD/Panel/Margin/VBox/InventoryLabel
@onready var interaction_label: Label = $HUD/InteractionPanel/Margin/InteractionLabel

func _ready() -> void:
	player.inventory_changed.connect(_update_inventory)
	_update_inventory()

func _process(_delta: float) -> void:
	position_label.text = "Posição: %d, %d" % [roundi(player.global_position.x), roundi(player.global_position.y)]
	var running := Input.is_key_pressed(KEY_SHIFT) and player.velocity.length() > 1.0
	var moving := player.velocity.length() > 1.0
	state_label.text = "Estado: %s" % ("CORRENDO" if running else ("ANDANDO" if moving else "PARADO"))

	var prompt := player.get_interaction_prompt()
	interaction_label.text = prompt
	$HUD/InteractionPanel.visible = not prompt.is_empty()

func _update_inventory() -> void:
	inventory_label.text = player.get_inventory_text()
