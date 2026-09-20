extends Control

var selected_slot: int = 0
var axe_amount: int = 0
var pickaxe_amount: int = 0
var sword_amount: int = 0

@onready var selected_label: Label = $HotbarBox/VBox/SelectedLabel
@onready var slot_1: PanelContainer = $HotbarBox/VBox/Slots/Slot1
@onready var slot_2: PanelContainer = $HotbarBox/VBox/Slots/Slot2
@onready var slot_3: PanelContainer = $HotbarBox/VBox/Slots/Slot3
@onready var slot_4: PanelContainer = $HotbarBox/VBox/Slots/Slot4
@onready var slot_5: PanelContainer = $HotbarBox/VBox/Slots/Slot5
@onready var slot_6: PanelContainer = $HotbarBox/VBox/Slots/Slot6
@onready var wood_count: Label = $HotbarBox/VBox/Slots/Slot1/Margin/VBox/Count
@onready var stone_count: Label = $HotbarBox/VBox/Slots/Slot2/Margin/VBox/Count
@onready var axe_label: Label = $HotbarBox/VBox/Slots/Slot3/Label
@onready var pickaxe_label: Label = $HotbarBox/VBox/Slots/Slot4/Label
@onready var sword_label: Label = $HotbarBox/VBox/Slots/Slot5/Label

func _ready() -> void:
	select_slot(0)

func refresh_hotbar(
	wood_amount: int,
	stone_amount: int,
	new_axe_amount: int,
	new_pickaxe_amount: int,
	new_sword_amount: int
) -> void:
	axe_amount = new_axe_amount
	pickaxe_amount = new_pickaxe_amount
	sword_amount = new_sword_amount

	wood_count.text = "x%d" % wood_amount
	stone_count.text = "x%d" % stone_amount
	axe_label.text = "3\nMachado\nx%d" % axe_amount
	pickaxe_label.text = "4\nPicareta\nx%d" % pickaxe_amount
	sword_label.text = "5\nEspada\nx%d" % sword_amount
	_update_selected_label()

func select_slot(slot_index: int) -> void:
	selected_slot = clampi(slot_index, 0, 5)

	var slots: Array[PanelContainer] = [
		slot_1,
		slot_2,
		slot_3,
		slot_4,
		slot_5,
		slot_6
	]

	for i in range(slots.size()):
		if i == selected_slot:
			slots[i].modulate = Color(1.0, 0.82, 0.48, 1.0)
		else:
			slots[i].modulate = Color.WHITE

	_update_selected_label()

func _update_selected_label() -> void:
	match selected_slot:
		0:
			selected_label.text = "Selecionado: Madeira"
		1:
			selected_label.text = "Selecionado: Pedra"
		2:
			selected_label.text = "Selecionado: Machado" if axe_amount > 0 else "Selecionado: Machado (não possui)"
		3:
			selected_label.text = "Selecionado: Picareta" if pickaxe_amount > 0 else "Selecionado: Picareta (não possui)"
		4:
			selected_label.text = "Selecionado: Espada" if sword_amount > 0 else "Selecionado: Espada (não possui)"
		_:
			selected_label.text = "Selecionado: Vazio"

func get_selected_slot() -> int:
	return selected_slot
