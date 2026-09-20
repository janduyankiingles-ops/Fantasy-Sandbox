extends Control

@onready var wood_count_label: Label = $InventoryPanel/Margin/VBox/Grid/WoodSlot/Margin/VBox/Count
@onready var stone_count_label: Label = $InventoryPanel/Margin/VBox/Grid/StoneSlot/Margin/VBox/Count

func _ready() -> void:
	visible = false

func toggle_inventory() -> void:
	visible = not visible

func refresh_inventory(wood_amount: int, stone_amount: int) -> void:
	wood_count_label.text = "Quantidade: %d" % wood_amount
	stone_count_label.text = "Quantidade: %d" % stone_amount
