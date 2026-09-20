extends CharacterBody2D

signal inventory_changed

@export var walk_speed: float = 180.0
@export var run_speed: float = 290.0
@export var acceleration: float = 1300.0
@export var friction: float = 1600.0
@export var interaction_distance: float = 92.0
@export var interaction_cooldown: float = 0.25

var facing: Vector2 = Vector2.DOWN
var is_attacking: bool = false
var attack_time: float = 0.0
var attack_was_down: bool = false
var interact_was_down: bool = false
var interact_cooldown_left: float = 0.0
var nearby_resource: Node2D = null
var selected_hotbar_slot: int = 0

var inventory: Dictionary = {
	"wood": 0,
	"stone": 0,
	"axe": 1,
	"pickaxe": 1
}

func _ready() -> void:
	queue_redraw()

func _physics_process(delta: float) -> void:
	interact_cooldown_left = maxf(0.0, interact_cooldown_left - delta)

	var left: bool = Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)
	var right: bool = Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)
	var up: bool = Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
	var down: bool = Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)

	var input_vector: Vector2 = Vector2(
		float(int(right) - int(left)),
		float(int(down) - int(up))
	).normalized()

	if input_vector.length() > 0.0:
		facing = input_vector

	var running: bool = Input.is_key_pressed(KEY_SHIFT)
	var current_speed: float = run_speed if running else walk_speed
	var target_velocity: Vector2 = input_vector * current_speed
	var change_rate: float = acceleration if input_vector.length() > 0.0 else friction
	velocity = velocity.move_toward(target_velocity, change_rate * delta)

	var attack_down: bool = Input.is_key_pressed(KEY_SPACE)
	if attack_down and not attack_was_down and not is_attacking:
		is_attacking = true
		attack_time = 0.18
	attack_was_down = attack_down

	if is_attacking:
		attack_time -= delta
		if attack_time <= 0.0:
			is_attacking = false

	_update_nearby_resource()

	var interact_down: bool = Input.is_key_pressed(KEY_E)
	if interact_down and not interact_was_down and interact_cooldown_left <= 0.0:
		_try_harvest()
	interact_was_down = interact_down

	move_and_slide()
	queue_redraw()

func _update_nearby_resource() -> void:
	nearby_resource = null
	var best_distance: float = interaction_distance

	for node in get_tree().get_nodes_in_group("resource_nodes"):
		if not is_instance_valid(node):
			continue

		var resource_node: Node2D = node as Node2D
		if resource_node == null:
			continue

		var distance: float = global_position.distance_to(resource_node.global_position)
		if distance <= best_distance:
			best_distance = distance
			nearby_resource = resource_node

func _try_harvest() -> void:
	if nearby_resource == null or not is_instance_valid(nearby_resource):
		return
	if not nearby_resource.has_method("harvest"):
		return

	var selected_tool: String = get_selected_tool()
	var result: Dictionary = nearby_resource.call("harvest", selected_tool)
	var amount: int = int(result.get("amount", 0))

	if amount <= 0:
		return

	var resource_type: String = str(result.get("type", ""))
	if resource_type == "tree":
		inventory["wood"] = int(inventory.get("wood", 0)) + amount
	elif resource_type == "rock":
		inventory["stone"] = int(inventory.get("stone", 0)) + amount
	else:
		return

	interact_cooldown_left = interaction_cooldown
	inventory_changed.emit()

func set_selected_hotbar_slot(slot_index: int) -> void:
	selected_hotbar_slot = clampi(slot_index, 0, 5)

func get_selected_tool() -> String:
	if selected_hotbar_slot == 2 and int(inventory.get("axe", 0)) > 0:
		return "axe"
	if selected_hotbar_slot == 3 and int(inventory.get("pickaxe", 0)) > 0:
		return "pickaxe"
	return ""

func get_interaction_prompt() -> String:
	if nearby_resource != null and is_instance_valid(nearby_resource) and nearby_resource.has_method("get_interaction_text"):
		return str(nearby_resource.call("get_interaction_text", get_selected_tool()))
	return ""

func get_inventory_text() -> String:
	return "Madeira: %d    Pedra: %d" % [
		int(inventory.get("wood", 0)),
		int(inventory.get("stone", 0))
	]

func get_inventory_amount(item_key: String) -> int:
	return int(inventory.get(item_key, 0))

func _draw() -> void:
	draw_circle(Vector2(0, 13), 14.0, Color(0.05, 0.05, 0.06, 0.35))

	var cape: PackedVector2Array = PackedVector2Array([
		Vector2(-14, -10), Vector2(14, -10), Vector2(17, 17),
		Vector2(5, 12), Vector2(0, 20), Vector2(-6, 12), Vector2(-17, 17)
	])
	draw_colored_polygon(cape, Color("6d0f1f"))

	draw_rect(Rect2(-10, -14, 20, 30), Color("15151a"), true)
	draw_circle(Vector2(0, -23), 9.5, Color("e5d7d2"))
	draw_rect(Rect2(-9, -34, 18, 8), Color("111117"), true)

	var eye_pos: Vector2 = facing.normalized() * 5.0 + Vector2(0, -23)
	draw_circle(eye_pos, 2.2, Color("e32636"))

	if is_attacking:
		var dir: Vector2 = facing.normalized()
		if dir == Vector2.ZERO:
			dir = Vector2.RIGHT

		var center: Vector2 = dir * 30.0
		draw_arc(center, 24.0, -1.1, 1.1, 18, Color("ef3340"), 5.0)
