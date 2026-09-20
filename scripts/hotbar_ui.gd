extends Control

var selected_slot: int = 0

@onready var selected_label: Label = $HotbarBox/VBox/SelectedLabel
@onready var slot_1: PanelContainer = $HotbarBox/VBox/Slots/Slot1
@onready var slot_2: PanelContainer = $HotbarBox/VBox/Slots/Slot2
@onready var slot_3: PanelContainer = $HotbarBox/VBox/Slots/Slot3
@onready var slot_4: PanelContainer = $HotbarBox/VBox/Slots/Slot4
@onready var slot_5: PanelContainer = $HotbarBox/VBox/Slots/Slot5
@onready var slot_6: PanelContainer = $HotbarBox/VBox/Slots/Slot6
@onready var wood_count: Label = $HotbarBox/VBox/Slots/Slot1/Margin/VBox/Count
@onready var stone_count: Label = $HotbarBox/VBox/Slots/Slot2/Margin/VBox/Count

func _ready() -> void:
	select_slot(0)

func refresh_hotbar(wood_amount: int, stone_amount: int) -> void:
	wood_count.text = "x%d" % wood_amount
	stone_count.text = "x%d" % stone_amount

func select_slot(slot_index: int) -> void:
	var clamped_index: int = clampi(slot_index, 0, 5)
	selected_slot = clamped_index

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

	if selected_slot == 0:
		selected_label.text = "Selecionado: Madeira"
	elif selected_slot == 1:
		selected_label.text = "Selecionado: Pedra"
	else:
		selected_label.text = "Selecionado: Vazio"

func get_selected_slot() -> int:
	return selected_slot
