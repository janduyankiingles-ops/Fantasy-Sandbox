extends Control

var selected_slot: int = 0
var snapshot: Dictionary = {}

var slot_item_keys: Array[String] = [
	"improvised_axe",
	"improvised_pickaxe",
	"improvised_knife",
	"axe",
	"pickaxe",
	"sword"
]

var item_names: Dictionary = {
	"improvised_axe": "Machado Improvisado",
	"improvised_pickaxe": "Picareta Improvisada",
	"improvised_knife": "Faca Improvisada",
	"axe": "Machado",
	"pickaxe": "Picareta",
	"sword": "Espada"
}

@onready var slots: Array[PanelContainer] = [
	$HotbarBox/VBox/Slots/Slot1,
	$HotbarBox/VBox/Slots/Slot2,
	$HotbarBox/VBox/Slots/Slot3,
	$HotbarBox/VBox/Slots/Slot4,
	$HotbarBox/VBox/Slots/Slot5,
	$HotbarBox/VBox/Slots/Slot6
]

@onready var labels: Array[Label] = [
	$HotbarBox/VBox/Slots/Slot1/Label,
	$HotbarBox/VBox/Slots/Slot2/Label,
	$HotbarBox/VBox/Slots/Slot3/Label,
	$HotbarBox/VBox/Slots/Slot4/Label,
	$HotbarBox/VBox/Slots/Slot5/Label,
	$HotbarBox/VBox/Slots/Slot6/Label
]

@onready var selected_label: Label = $HotbarBox/VBox/SelectedLabel

func _ready() -> void:
	select_slot(0)

func refresh_hotbar(new_snapshot: Dictionary) -> void:
	snapshot = new_snapshot.duplicate()

	for index in range(slot_item_keys.size()):
		var item_key: String = slot_item_keys[index]
		var amount: int = int(snapshot.get(item_key, 0))
		var display_name: String = str(item_names.get(item_key, item_key))

		if amount > 0:
			labels[index].text = "%d\n%s\nx%d" % [index + 1, display_name, amount]
		else:
			labels[index].text = "%d\nVazio" % [index + 1]

	_update_selected_label()

func select_slot(slot_index: int) -> void:
	selected_slot = clampi(slot_index, 0, 5)

	for index in range(slots.size()):
		if index == selected_slot:
			slots[index].modulate = Color(1.0, 0.82, 0.48, 1.0)
		else:
			slots[index].modulate = Color.WHITE

	_update_selected_label()

func _update_selected_label() -> void:
	var item_key: String = slot_item_keys[selected_slot]
	var amount: int = int(snapshot.get(item_key, 0))

	if amount <= 0:
		selected_label.text = "Selecionado: Vazio"
		return

	selected_label.text = "Selecionado: %s" % str(item_names.get(item_key, item_key))

func get_selected_slot() -> int:
	return selected_slot
