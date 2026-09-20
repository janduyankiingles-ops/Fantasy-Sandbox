extends Node2D

const BuildPieceScene = preload("res://scenes/build_piece.tscn")
const BuildPreviewScene = preload("res://scenes/build_preview.tscn")

const GRID_SIZE: float = 64.0
const BUILD_DISTANCE: float = 96.0

var build_mode: bool = false
var selected_index: int = 0
var rotation_quarters: int = 0
var preview: Node2D = null
var player: CharacterBody2D = null
var current_position: Vector2 = Vector2.ZERO
var current_valid: bool = false
var current_block_reason: String = ""

var piece_types: Array[String] = ["floor", "wall", "door"]

var piece_names: Dictionary = {
	"floor": "Chão de Madeira",
	"wall": "Parede",
	"door": "Porta"
}

var piece_costs: Dictionary = {
	"floor": {"wood": 1},
	"wall": {"wood": 2, "stone": 1},
	"door": {"wood": 2, "stone": 1}
}

func _ready() -> void:
	_create_preview()
	_find_player()

func _process(_delta: float) -> void:
	if not build_mode:
		return

	if player == null or not is_instance_valid(player):
		_find_player()

	if player == null:
		current_valid = false
		_refresh_preview()
		return

	_update_preview_position()
	current_valid = _can_place_current_piece()
	_refresh_preview()

func _create_preview() -> void:
	var preview_node: Node = BuildPreviewScene.instantiate()
	if preview_node is not Node2D:
		return

	preview = preview_node
	add_child(preview)
	preview.visible = false

func _find_player() -> void:
	var candidate: Node = get_tree().get_first_node_in_group("player")
	if candidate is CharacterBody2D:
		player = candidate

func toggle_build_mode() -> bool:
	build_mode = not build_mode

	if preview != null:
		preview.visible = build_mode

	if build_mode:
		_update_preview_position()
		current_valid = _can_place_current_piece()
		_refresh_preview()

	return build_mode

func cycle_piece() -> void:
	if not build_mode:
		return

	selected_index = (selected_index + 1) % piece_types.size()
	rotation_quarters = 0
	current_valid = _can_place_current_piece()
	_refresh_preview()

func rotate_piece() -> void:
	if not build_mode:
		return

	var piece_type: String = get_selected_piece_type()
	if piece_type == "floor":
		return

	rotation_quarters = (rotation_quarters + 1) % 4
	current_valid = _can_place_current_piece()
	_refresh_preview()

func try_place_piece() -> bool:
	if not build_mode or player == null:
		return false

	_update_preview_position()
	current_valid = _can_place_current_piece()
	if not current_valid:
		_refresh_preview()
		return false

	var piece_type: String = get_selected_piece_type()
	var costs_value: Variant = piece_costs.get(piece_type, {})
	if costs_value is not Dictionary:
		return false

	var costs: Dictionary = costs_value

	var piece_node: Node = BuildPieceScene.instantiate()
	if piece_node is not Node2D:
		return false

	var parent_node: Node = get_parent()
	if parent_node == null:
		return false

	var paid: bool = bool(player.call("consume_build_resources", costs))
	if not paid:
		current_valid = false
		_refresh_preview()
		return false

	var piece: Node2D = piece_node
	piece.call("setup", piece_type, rotation_quarters)
	parent_node.add_child(piece)
	piece.global_position = current_position

	current_valid = _can_place_current_piece()
	_refresh_preview()
	return true

func get_selected_piece_type() -> String:
	return piece_types[selected_index]

func get_status_text() -> String:
	if not build_mode:
		return "Construção: desligada [B]"

	var piece_type: String = get_selected_piece_type()
	var piece_name: String = str(piece_names.get(piece_type, piece_type))
	var cost_text: String = _get_cost_text(piece_type)
	var validity: String = "VÁLIDO"
	if not current_valid:
		validity = current_block_reason
		if validity.is_empty():
			validity = "BLOQUEADO"

	return "Construção: %s | %s | %s" % [piece_name, cost_text, validity]

func is_build_mode() -> bool:
	return build_mode

func _update_preview_position() -> void:
	if player == null:
		return

	var direction_value: Variant = player.get("facing")
	var direction: Vector2 = Vector2.DOWN
	if direction_value is Vector2:
		direction = direction_value

	if direction == Vector2.ZERO:
		direction = Vector2.DOWN

	var raw_position: Vector2 = player.global_position + direction.normalized() * BUILD_DISTANCE
	current_position = Vector2(
		roundf(raw_position.x / GRID_SIZE) * GRID_SIZE,
		roundf(raw_position.y / GRID_SIZE) * GRID_SIZE
	)

	if preview != null:
		preview.global_position = current_position

func _can_place_current_piece() -> bool:
	current_block_reason = ""

	if player == null:
		current_block_reason = "SEM JOGADOR"
		return false

	if player.global_position.distance_to(current_position) < 48.0:
		current_block_reason = "MUITO PERTO"
		return false

	var piece_type: String = get_selected_piece_type()
	var costs_value: Variant = piece_costs.get(piece_type, {})
	if costs_value is not Dictionary:
		current_block_reason = "CUSTO INVÁLIDO"
		return false

	var costs: Dictionary = costs_value
	if not bool(player.call("has_build_resources", costs)):
		current_block_reason = "SEM RECURSOS"
		return false

	for node in get_tree().get_nodes_in_group("build_obstacles"):
		if not is_instance_valid(node):
			continue
		if node is not Node2D:
			continue

		var obstacle: Node2D = node
		if obstacle.global_position.distance_to(current_position) < 46.0:
			current_block_reason = "ESPAÇO OCUPADO"
			return false

	return true

func _refresh_preview() -> void:
	if preview == null:
		return

	preview.call(
		"configure",
		get_selected_piece_type(),
		rotation_quarters,
		current_valid
	)

func _get_cost_text(piece_type: String) -> String:
	match piece_type:
		"floor":
			return "1 Madeira"
		"wall":
			return "2 Madeira + 1 Pedra"
		"door":
			return "2 Madeira + 1 Pedra"
		_:
			return ""
