extends Control

@onready var wood_count_label: Label = $InventoryPanel/Margin/VBox/Grid/WoodSlot/Margin/VBox/Count
@onready var stone_count_label: Label = $InventoryPanel/Margin/VBox/Grid/StoneSlot/Margin/VBox/Count
@onready var axe_label: Label = $InventoryPanel/Margin/VBox/Grid/Empty3/Label
@onready var pickaxe_label: Label = $InventoryPanel/Margin/VBox/Grid/Empty4/Label
@onready var sword_label: Label = $InventoryPanel/Margin/VBox/Grid/Empty5/Label

func _ready() -> void:
	visible = false

func toggle_inventory() -> void:
	visible = not visible

func close_inventory() -> void:
	visible = false

func refresh_inventory(
	wood_amount: int,
	stone_amount: int,
	axe_amount: int,
	pickaxe_amount: int,
	sword_amount: int
) -> void:
	wood_count_label.text = "Quantidade: %d" % wood_amount
	stone_count_label.text = "Quantidade: %d" % stone_amount
	axe_label.text = "Machado\nx%d" % axe_amount
	pickaxe_label.text = "Picareta\nx%d" % pickaxe_amount
	sword_label.text = "Espada\nx%d" % sword_amount
