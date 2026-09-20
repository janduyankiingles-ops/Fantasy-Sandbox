extends Control

signal craft_requested(item_key: String)

@onready var wood_label: Label = $CraftingPanel/Margin/VBox/Resources
@onready var axe_button: Button = $CraftingPanel/Margin/VBox/Recipes/AxeButton
@onready var pickaxe_button: Button = $CraftingPanel/Margin/VBox/Recipes/PickaxeButton
@onready var sword_button: Button = $CraftingPanel/Margin/VBox/Recipes/SwordButton
@onready var status_label: Label = $CraftingPanel/Margin/VBox/Status

var wood_amount: int = 0
var stone_amount: int = 0
var axe_amount: int = 0
var pickaxe_amount: int = 0
var sword_amount: int = 0

func _ready() -> void:
	visible = false
	axe_button.pressed.connect(_on_axe_pressed)
	pickaxe_button.pressed.connect(_on_pickaxe_pressed)
	sword_button.pressed.connect(_on_sword_pressed)
	_refresh_buttons()

func toggle_crafting() -> void:
	visible = not visible
	if visible:
		status_label.text = "Escolha uma receita."

func close_crafting() -> void:
	visible = false

func refresh_crafting(
	new_wood_amount: int,
	new_stone_amount: int,
	new_axe_amount: int,
	new_pickaxe_amount: int,
	new_sword_amount: int
) -> void:
	wood_amount = new_wood_amount
	stone_amount = new_stone_amount
	axe_amount = new_axe_amount
	pickaxe_amount = new_pickaxe_amount
	sword_amount = new_sword_amount

	wood_label.text = "Recursos: Madeira %d | Pedra %d" % [wood_amount, stone_amount]
	_refresh_buttons()

func show_result(success: bool, item_name: String) -> void:
	if success:
		status_label.text = "%s fabricado com sucesso." % item_name
	else:
		status_label.text = "Não foi possível fabricar %s." % item_name

func _refresh_buttons() -> void:
	axe_button.disabled = axe_amount > 0 or wood_amount < 3 or stone_amount < 2
	pickaxe_button.disabled = pickaxe_amount > 0 or wood_amount < 2 or stone_amount < 3
	sword_button.disabled = sword_amount > 0 or wood_amount < 2 or stone_amount < 4

	axe_button.text = "Machado — 3 Madeira + 2 Pedra" + ("  [CRIADO]" if axe_amount > 0 else "")
	pickaxe_button.text = "Picareta — 2 Madeira + 3 Pedra" + ("  [CRIADA]" if pickaxe_amount > 0 else "")
	sword_button.text = "Espada — 2 Madeira + 4 Pedra" + ("  [CRIADA]" if sword_amount > 0 else "")

func _on_axe_pressed() -> void:
	craft_requested.emit("axe")

func _on_pickaxe_pressed() -> void:
	craft_requested.emit("pickaxe")

func _on_sword_pressed() -> void:
	craft_requested.emit("sword")
