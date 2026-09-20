extends CharacterBody2D

const CampfireScene = preload("res://scenes/campfire.tscn")

signal inventory_changed
signal health_changed

@export var walk_speed: float = 180.0
@export var run_speed: float = 290.0
@export var acceleration: float = 1300.0
@export var friction: float = 1600.0
@export var interaction_distance: float = 92.0
@export var interaction_cooldown: float = 0.25
@export var max_health: int = 100
@export var attack_range: float = 72.0
@export var attack_facing_dot: float = 0.15
@export var max_hunger: float = 100.0
@export var hunger_loss_per_second: float = 1.0
@export var starvation_damage: int = 5
@export var starvation_interval: float = 2.0

var facing: Vector2 = Vector2.DOWN
var is_attacking: bool = false
var attack_time: float = 0.0
var attack_was_down: bool = false
var interact_was_down: bool = false
var interact_cooldown_left: float = 0.0
var nearby_resource: Node2D = null
var selected_hotbar_slot: int = 0
var current_health: int = 100
var dead: bool = false
var respawn_time_left: float = 0.0
var spawn_position: Vector2 = Vector2.ZERO
var level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 100
var current_hunger: float = 100.0
var starvation_tick_left: float = 2.0
var eat_food_was_down: bool = false
var armor_equipped: bool = false
var armor_damage_reduction: float = 0.25

var inventory: Dictionary = {
	"stick": 0,
	"small_stone": 0,
	"vine": 0,
	"wood": 0,
	"stone": 0,
	"improvised_axe": 0,
	"improvised_pickaxe": 0,
	"improvised_knife": 0,
	"axe": 0,
	"pickaxe": 0,
	"sword": 0,
	"raw_meat": 0,
	"cooked_meat": 0,
	"wolf_hide": 0,
	"campfire_kit": 0,
	"wolf_armor": 0
}

func _ready() -> void:
	add_to_group("player")
	current_health = max_health
	current_hunger = max_hunger
	starvation_tick_left = starvation_interval
	spawn_position = global_position
	queue_redraw()

func _physics_process(delta: float) -> void:
	if dead:
		respawn_time_left = maxf(0.0, respawn_time_left - delta)
		velocity = Vector2.ZERO

		if respawn_time_left <= 0.0:
			_respawn()

		move_and_slide()
		queue_redraw()
		return

	_update_hunger(delta)
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
		_perform_attack()
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

	var eat_food_down: bool = Input.is_key_pressed(KEY_F)
	if eat_food_down and not eat_food_was_down:
		_try_eat_food()
	eat_food_was_down = eat_food_down

	move_and_slide()
	queue_redraw()

func _update_hunger(delta: float) -> void:
	if current_hunger > 0.0:
		current_hunger = maxf(0.0, current_hunger - hunger_loss_per_second * delta)
		starvation_tick_left = starvation_interval
		return

	starvation_tick_left = maxf(0.0, starvation_tick_left - delta)
	if starvation_tick_left <= 0.0:
		starvation_tick_left = starvation_interval
		_take_direct_damage(starvation_damage)

func _try_eat_food() -> void:
	if dead:
		return
	if current_hunger >= max_hunger:
		return

	var cooked_amount: int = int(inventory.get("cooked_meat", 0))
	if cooked_amount > 0:
		inventory["cooked_meat"] = cooked_amount - 1
		current_hunger = minf(max_hunger, current_hunger + 45.0)
		inventory_changed.emit()
		return

	var raw_amount: int = int(inventory.get("raw_meat", 0))
	if raw_amount <= 0:
		return

	inventory["raw_meat"] = raw_amount - 1
	current_hunger = minf(max_hunger, current_hunger + 20.0)
	inventory_changed.emit()

	# Carne crua é uma opção de emergência: alimenta, mas faz mal.
	_take_direct_damage(5)

func get_hunger_text() -> String:
	if current_hunger <= 0.0:
		return "Fome: 0/%d — FAMINTO" % roundi(max_hunger)
	return "Fome: %d/%d" % [roundi(current_hunger), roundi(max_hunger)]

func _perform_attack() -> void:
	var damage: int = _get_attack_damage()
	var best_target: Node2D = null
	var best_distance: float = attack_range
	var facing_direction: Vector2 = facing.normalized()

	if facing_direction == Vector2.ZERO:
		facing_direction = Vector2.DOWN

	for node in get_tree().get_nodes_in_group("damageable"):
		if not is_instance_valid(node):
			continue
		if not node.has_method("take_damage"):
			continue

		if node is not Node2D:
			continue

		var target: Node2D = node

		var offset: Vector2 = target.global_position - global_position
		var distance: float = offset.length()

		if distance <= 0.0 or distance > best_distance:
			continue

		var direction_to_target: Vector2 = offset.normalized()
		if facing_direction.dot(direction_to_target) < attack_facing_dot:
			continue

		best_distance = distance
		best_target = target

	if best_target != null:
		var damage_result: Variant = best_target.call("take_damage", damage)

		if damage_result is Dictionary:
			var result: Dictionary = damage_result
			if bool(result.get("killed", false)):
				var xp_reward: int = int(result.get("xp", 0))
				if xp_reward > 0:
					add_xp(xp_reward)

func _get_attack_damage() -> int:
	var item_key: String = get_selected_item_key()

	match item_key:
		"improvised_knife":
			return 3
		"improvised_axe":
			return 2
		"improvised_pickaxe":
			return 2
		"axe":
			return 4
		"pickaxe":
			return 4
		"sword":
			return 7
		_:
			return 1

func take_damage(amount: int) -> void:
	if amount <= 0:
		return

	var final_damage: int = amount
	if armor_equipped and int(inventory.get("wolf_armor", 0)) > 0:
		final_damage = maxi(1, roundi(float(amount) * (1.0 - armor_damage_reduction)))

	_apply_damage(final_damage)

func _take_direct_damage(amount: int) -> void:
	_apply_damage(amount)

func _apply_damage(amount: int) -> void:
	if amount <= 0 or current_health <= 0 or dead:
		return

	current_health = maxi(0, current_health - amount)
	health_changed.emit()

	if current_health <= 0:
		dead = true
		respawn_time_left = 2.0
		velocity = Vector2.ZERO

	queue_redraw()

func _respawn() -> void:
	dead = false
	current_health = max_health
	current_hunger = max_hunger
	starvation_tick_left = starvation_interval
	global_position = spawn_position
	is_attacking = false
	attack_time = 0.0
	attack_was_down = false
	interact_was_down = false
	eat_food_was_down = false
	nearby_resource = null
	health_changed.emit()
	queue_redraw()

func get_health_text() -> String:
	if dead:
		return "Vida: 0/%d — REAPARECENDO" % max_health
	return "Vida: %d/%d" % [current_health, max_health]

func get_current_health() -> int:
	return current_health

func get_max_health() -> int:
	return max_health

func toggle_armor() -> bool:
	if int(inventory.get("wolf_armor", 0)) <= 0:
		armor_equipped = false
		return false

	armor_equipped = not armor_equipped
	queue_redraw()
	return armor_equipped

func get_armor_text() -> String:
	if int(inventory.get("wolf_armor", 0)) <= 0:
		return "Armadura: nenhuma"

	if armor_equipped:
		return "Armadura: Pele de Lobo — EQUIPADA (-25% dano)"

	return "Armadura: Pele de Lobo — guardada [H para equipar]"

func is_armor_equipped() -> bool:
	return armor_equipped

func add_xp(amount: int) -> void:
	if amount <= 0:
		return

	current_xp += amount

	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		level += 1
		xp_to_next_level = level * 100

func get_progression_text() -> String:
	return "Nível: %d | XP: %d/%d" % [level, current_xp, xp_to_next_level]

func get_level() -> int:
	return level

func get_current_xp() -> int:
	return current_xp


func is_dead() -> bool:
	return dead

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

	var selected_tool: String = get_selected_item_key()
	var result: Dictionary = nearby_resource.call("harvest", selected_tool)

	var action: String = str(result.get("action", ""))
	if action == "cook":
		_try_cook_raw_meat()
		return

	var amount: int = int(result.get("amount", 0))
	if amount <= 0:
		return

	var resource_type: String = str(result.get("type", ""))
	var inventory_key: String = _resource_type_to_inventory_key(resource_type)
	if inventory_key.is_empty():
		return

	inventory[inventory_key] = int(inventory.get(inventory_key, 0)) + amount
	interact_cooldown_left = interaction_cooldown
	inventory_changed.emit()

func _try_cook_raw_meat() -> void:
	var raw_amount: int = int(inventory.get("raw_meat", 0))
	if raw_amount <= 0:
		return

	inventory["raw_meat"] = raw_amount - 1
	inventory["cooked_meat"] = int(inventory.get("cooked_meat", 0)) + 1
	interact_cooldown_left = interaction_cooldown
	inventory_changed.emit()

func place_campfire() -> bool:
	var kit_amount: int = int(inventory.get("campfire_kit", 0))
	if kit_amount <= 0 or dead:
		return false

	var campfire_node: Node = CampfireScene.instantiate()
	if campfire_node is not Node2D:
		return false

	var campfire: Node2D = campfire_node
	var parent_node: Node = get_parent()
	if parent_node == null:
		return false

	parent_node.add_child(campfire)

	var placement_direction: Vector2 = facing.normalized()
	if placement_direction == Vector2.ZERO:
		placement_direction = Vector2.DOWN

	campfire.global_position = global_position + placement_direction * 82.0
	inventory["campfire_kit"] = kit_amount - 1
	inventory_changed.emit()
	return true

func _resource_type_to_inventory_key(resource_type: String) -> String:
	match resource_type:
		"stick":
			return "stick"
		"small_stone":
			return "small_stone"
		"vine":
			return "vine"
		"tree":
			return "wood"
		"rock":
			return "stone"
		"raw_meat":
			return "raw_meat"
		"wolf_hide":
			return "wolf_hide"
		"cooked_meat":
			return "cooked_meat"
		_:
			return ""

func set_selected_hotbar_slot(slot_index: int) -> void:
	selected_hotbar_slot = clampi(slot_index, 0, 5)

func get_selected_item_key() -> String:
	var key: String = ""

	match selected_hotbar_slot:
		0:
			key = "improvised_axe"
		1:
			key = "improvised_pickaxe"
		2:
			key = "improvised_knife"
		3:
			key = "axe"
		4:
			key = "pickaxe"
		5:
			key = "sword"

	if int(inventory.get(key, 0)) <= 0:
		return ""

	return key

func get_interaction_prompt() -> String:
	if nearby_resource != null and is_instance_valid(nearby_resource) and nearby_resource.has_method("get_interaction_text"):
		return str(nearby_resource.call("get_interaction_text", get_selected_item_key()))
	return ""

func get_inventory_text() -> String:
	return "Gravetos: %d | Pedrinhas: %d | Cipó: %d\nMadeira: %d | Pedra: %d" % [
		int(inventory.get("stick", 0)),
		int(inventory.get("small_stone", 0)),
		int(inventory.get("vine", 0)),
		int(inventory.get("wood", 0)),
		int(inventory.get("stone", 0))
	]

func get_inventory_amount(item_key: String) -> int:
	return int(inventory.get(item_key, 0))

func get_inventory_snapshot() -> Dictionary:
	return inventory.duplicate()

func craft_item(item_key: String) -> bool:
	var costs: Dictionary = _get_recipe_costs(item_key)
	if costs.is_empty():
		return false

	if int(inventory.get(item_key, 0)) > 0:
		return false

	for resource_key in costs.keys():
		var needed: int = int(costs[resource_key])
		var available: int = int(inventory.get(resource_key, 0))
		if available < needed:
			return false

	for resource_key in costs.keys():
		var needed: int = int(costs[resource_key])
		inventory[resource_key] = int(inventory.get(resource_key, 0)) - needed

	inventory[item_key] = 1
	inventory_changed.emit()
	return true

func _get_recipe_costs(item_key: String) -> Dictionary:
	match item_key:
		"improvised_axe":
			return {"stick": 2, "small_stone": 1, "vine": 1}
		"improvised_pickaxe":
			return {"stick": 2, "small_stone": 2, "vine": 1}
		"improvised_knife":
			return {"stick": 1, "small_stone": 1, "vine": 1}
		"axe":
			return {"wood": 3, "stone": 2}
		"pickaxe":
			return {"wood": 2, "stone": 3}
		"sword":
			return {"wood": 2, "stone": 4}
		"campfire_kit":
			return {"wood": 3, "stone": 3}
		"wolf_armor":
			return {"wolf_hide": 3, "vine": 2}
		_:
			return {}

func _draw() -> void:
	draw_circle(Vector2(0, 13), 14.0, Color(0.05, 0.05, 0.06, 0.35))

	var cape: PackedVector2Array = PackedVector2Array([
		Vector2(-14, -10), Vector2(14, -10), Vector2(17, 17),
		Vector2(5, 12), Vector2(0, 20), Vector2(-6, 12), Vector2(-17, 17)
	])
	draw_colored_polygon(cape, Color("6d0f1f"))

	draw_rect(Rect2(-10, -14, 20, 30), Color("15151a"), true)

	if armor_equipped and int(inventory.get("wolf_armor", 0)) > 0:
		var armor_shape: PackedVector2Array = PackedVector2Array([
			Vector2(-12, -13),
			Vector2(12, -13),
			Vector2(10, 12),
			Vector2(0, 16),
			Vector2(-10, 12)
		])
		draw_colored_polygon(armor_shape, Color("705846"))
		draw_line(Vector2(-8, -7), Vector2(8, 8), Color("a3886c"), 3.0)

	draw_circle(Vector2(0, -23), 9.5, Color("e5d7d2"))
	draw_rect(Rect2(-9, -34, 18, 8), Color("111117"), true)

	var eye_pos: Vector2 = facing.normalized() * 5.0 + Vector2(0, -23)
	draw_circle(eye_pos, 2.2, Color("e32636"))

	if is_attacking:
		var dir: Vector2 = facing.normalized()
		if dir == Vector2.ZERO:
			dir = Vector2.RIGHT

		var center: Vector2 = dir * 30.0
		var attack_angle: float = dir.angle()
		draw_arc(
			center,
			24.0,
			attack_angle - 1.1,
			attack_angle + 1.1,
			18,
			Color("ef3340"),
			5.0
		)
