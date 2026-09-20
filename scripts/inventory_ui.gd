extends Control

var item_order: Array[String] = [
	"stick",
	"small_stone",
	"vine",
	"wood",
	"stone",
	"improvised_axe",
	"improvised_pickaxe",
	"improvised_knife",
	"axe",
	"pickaxe",
	"sword",
	"raw_meat",
	"wolf_hide"
]

var item_names: Dictionary = {
	"stick": "Graveto",
	"small_stone": "Pedra Pequena",
	"vine": "Cipó",
	"wood": "Madeira",
	"stone": "Pedra",
	"improvised_axe": "Machado Improvisado",
	"improvised_pickaxe": "Picareta Improvisada",
	"improvised_knife": "Faca Improvisada",
	"axe": "Machado",
	"pickaxe": "Picareta",
	"sword": "Espada",
	"raw_meat": "Carne Crua",
	"wolf_hide": "Pele de Lobo"
}

@onready var slots: Array[PanelContainer] = [
	$InventoryPanel/Margin/VBox/Grid/Slot1,
	$InventoryPanel/Margin/VBox/Grid/Slot2,
	$InventoryPanel/Margin/VBox/Grid/Slot3,
	$InventoryPanel/Margin/VBox/Grid/Slot4,
	$InventoryPanel/Margin/VBox/Grid/Slot5,
	$InventoryPanel/Margin/VBox/Grid/Slot6,
	$InventoryPanel/Margin/VBox/Grid/Slot7,
	$InventoryPanel/Margin/VBox/Grid/Slot8,
	$InventoryPanel/Margin/VBox/Grid/Slot9,
	$InventoryPanel/Margin/VBox/Grid/Slot10,
	$InventoryPanel/Margin/VBox/Grid/Slot11,
	$InventoryPanel/Margin/VBox/Grid/Slot12,
	$InventoryPanel/Margin/VBox/Grid/Slot13,
	$InventoryPanel/Margin/VBox/Grid/Slot14,
	$InventoryPanel/Margin/VBox/Grid/Slot15,
	$InventoryPanel/Margin/VBox/Grid/Slot16
]

func _ready() -> void:
	visible = false
	_clear_slots()

func toggle_inventory() -> void:
	visible = not visible

func close_inventory() -> void:
	visible = false

func refresh_inventory(snapshot: Dictionary) -> void:
	_clear_slots()

	var slot_index: int = 0

	for index in range(item_order.size()):
		var item_key: String = item_order[index]
		var amount: int = int(snapshot.get(item_key, 0))

		if amount <= 0:
			continue
		if slot_index >= slots.size():
			break

		var slot: PanelContainer = slots[slot_index]
		var label: Label = slot.get_node("Label") as Label
		var display_name: String = str(item_names.get(item_key, item_key))

		label.text = "%s\nx%d" % [display_name, amount]
		slot.visible = true
		slot_index += 1

func _clear_slots() -> void:
	for index in range(slots.size()):
		var slot: PanelContainer = slots[index]
		slot.visible = false
