extends Node2D

@onready var shadow: Node2D = $Shadow
@onready var leg_left: Node2D = $LegLeft
@onready var leg_right: Node2D = $LegRight
@onready var body: Node2D = $Body
@onready var arm_left: Node2D = $ArmLeft
@onready var arm_right: Node2D = $ArmRight
@onready var head: Node2D = $Head
@onready var scarf_left: Node2D = $ScarfLeft
@onready var scarf_right: Node2D = $ScarfRight
@onready var tool: Node2D = $Tool

var current_state: String = "idle"
var facing_direction: String = "down"
var selected_item_key: String = ""

var walk_phase: float = 0.0
var idle_phase: float = 0.0
var action_clock: float = 0.0

var shadow_base: Vector2 = Vector2(0, 15)
var leg_left_base: Vector2 = Vector2(-3, 7)
var leg_right_base: Vector2 = Vector2(3, 7)
var body_base: Vector2 = Vector2(0, -2)
var arm_left_base: Vector2 = Vector2(-7, -3)
var arm_right_base: Vector2 = Vector2(7, -3)
var head_base: Vector2 = Vector2(0, -14)
var scarf_left_base: Vector2 = Vector2(-3, -7)
var scarf_right_base: Vector2 = Vector2(3, -7)
var tool_base: Vector2 = Vector2.ZERO

func _ready() -> void:
	scale = Vector2(2.0, 2.0)
	_set_facing("down")
	_apply_idle_pose(0)
	tool.call("set_tool", "none", 0)

func set_visual_state(
	state_name: String,
	facing_vector: Vector2,
	item_key: String = ""
) -> void:
	var new_direction: String = _direction_from_vector(facing_vector)
	var state_changed: bool = state_name != current_state
	var direction_changed: bool = new_direction != facing_direction
	var item_changed: bool = item_key != selected_item_key

	if direction_changed:
		_set_facing(new_direction)

	if state_changed:
		current_state = state_name
		action_clock = 0.0

	if item_changed:
		selected_item_key = item_key

	if state_changed or direction_changed or item_changed:
		_update_tool_for_state()

func _process(delta: float) -> void:
	match current_state:
		"walk":
			walk_phase = fmod(walk_phase + delta * 2.8, 1.0)
			_animate_walk()
		"attack":
			action_clock += delta
			_animate_action(0.23, false)
		"gather":
			action_clock += delta
			_animate_action(0.34, true)
		_:
			idle_phase = fmod(idle_phase + delta * 0.8, 1.0)
			_animate_idle()

func _direction_from_vector(value: Vector2) -> String:
	if value == Vector2.ZERO:
		return facing_direction

	var abs_x: float = absf(value.x)
	var abs_y: float = absf(value.y)

	if abs_x > abs_y:
		return "right" if value.x > 0.0 else "left"
	if abs_y > abs_x:
		return "down" if value.y > 0.0 else "up"

	if facing_direction == "left" and value.x < 0.0:
		return "left"
	if facing_direction == "right" and value.x > 0.0:
		return "right"
	if facing_direction == "up" and value.y < 0.0:
		return "up"
	if facing_direction == "down" and value.y > 0.0:
		return "down"

	return "down" if value.y > 0.0 else "up"

func _set_facing(direction_name: String) -> void:
	facing_direction = direction_name

	var parts: Array[Node2D] = [
		shadow,
		leg_left,
		leg_right,
		body,
		arm_left,
		arm_right,
		head,
		scarf_left,
		scarf_right,
		tool
	]

	for part: Node2D in parts:
		part.call("set_facing", direction_name)

	_apply_direction_layout()

func _apply_direction_layout() -> void:
	match facing_direction:
		"up":
			leg_left_base = Vector2(-3, 7)
			leg_right_base = Vector2(3, 7)
			body_base = Vector2(0, -2)
			arm_left_base = Vector2(-7, -3)
			arm_right_base = Vector2(7, -3)
			head_base = Vector2(0, -14)
			scarf_left_base = Vector2(-3, -7)
			scarf_right_base = Vector2(3, -7)

			leg_left.z_index = -1
			leg_right.z_index = -1
			arm_left.z_index = 0
			arm_right.z_index = 0
			body.z_index = 1
			scarf_left.z_index = 2
			scarf_right.z_index = 2
			tool.z_index = 1
			head.z_index = 3

		"left":
			leg_left_base = Vector2(-2, 7)
			leg_right_base = Vector2(2, 7)
			body_base = Vector2(0, -2)
			arm_left_base = Vector2(-5, -3)
			arm_right_base = Vector2(5, -3)
			head_base = Vector2(-1, -14)
			scarf_left_base = Vector2(2, -7)
			scarf_right_base = Vector2(4, -7)

			leg_left.z_index = 0
			leg_right.z_index = -1
			arm_left.z_index = 2
			arm_right.z_index = 0
			body.z_index = 1
			scarf_left.z_index = 0
			scarf_right.z_index = 0
			tool.z_index = 3
			head.z_index = 4

		"right":
			leg_left_base = Vector2(-2, 7)
			leg_right_base = Vector2(2, 7)
			body_base = Vector2(0, -2)
			arm_left_base = Vector2(-5, -3)
			arm_right_base = Vector2(5, -3)
			head_base = Vector2(1, -14)
			scarf_left_base = Vector2(-4, -7)
			scarf_right_base = Vector2(-2, -7)

			leg_left.z_index = -1
			leg_right.z_index = 0
			arm_left.z_index = 0
			arm_right.z_index = 2
			body.z_index = 1
			scarf_left.z_index = 0
			scarf_right.z_index = 0
			tool.z_index = 3
			head.z_index = 4

		_:
			leg_left_base = Vector2(-3, 7)
			leg_right_base = Vector2(3, 7)
			body_base = Vector2(0, -2)
			arm_left_base = Vector2(-7, -3)
			arm_right_base = Vector2(7, -3)
			head_base = Vector2(0, -14)
			scarf_left_base = Vector2(-3, -7)
			scarf_right_base = Vector2(3, -7)

			leg_left.z_index = 0
			leg_right.z_index = 0
			arm_left.z_index = 2
			arm_right.z_index = 2
			body.z_index = 1
			scarf_left.z_index = 0
			scarf_right.z_index = 0
			tool.z_index = 3
			head.z_index = 4

	_apply_idle_pose(0)

func _animate_walk() -> void:
	tool.call("set_tool", "none", 0)

	var wave: float = sin(walk_phase * TAU)
	var opposite_wave: float = -wave
	var left_step: int = roundi(wave * 2.0)
	var right_step: int = roundi(opposite_wave * 2.0)
	var body_bob: int = -roundi(absf(wave))
	var left_arm_step: int = roundi(opposite_wave)
	var right_arm_step: int = roundi(wave)

	if facing_direction == "left" or facing_direction == "right":
		var sign_x: int = 1 if facing_direction == "right" else -1

		leg_left.position = leg_left_base + Vector2(
			sign_x * roundi(wave),
			left_step
		)
		leg_right.position = leg_right_base + Vector2(
			sign_x * roundi(opposite_wave),
			right_step
		)
		arm_left.position = arm_left_base + Vector2(
			sign_x * roundi(opposite_wave),
			left_arm_step
		)
		arm_right.position = arm_right_base + Vector2(
			sign_x * roundi(wave),
			right_arm_step
		)
	else:
		leg_left.position = leg_left_base + Vector2(0, left_step)
		leg_right.position = leg_right_base + Vector2(0, right_step)
		arm_left.position = arm_left_base + Vector2(0, left_arm_step)
		arm_right.position = arm_right_base + Vector2(0, right_arm_step)

	body.position = body_base + Vector2(0, body_bob)
	head.position = head_base + Vector2(0, body_bob)

	var scarf_shift: int = roundi(wave)
	scarf_left.position = scarf_left_base + Vector2(scarf_shift, body_bob)
	scarf_right.position = scarf_right_base + Vector2(-scarf_shift, body_bob)

	shadow.position = shadow_base + Vector2(0, roundi(absf(wave)))
	tool.position = tool_base

func _animate_idle() -> void:
	tool.call("set_tool", "none", 0)

	var breathe: float = sin(idle_phase * TAU)
	var body_bob: int = -1 if breathe > 0.55 else 0
	_apply_idle_pose(body_bob)

func _animate_action(duration: float, gathering: bool) -> void:
	var progress: float = clampf(action_clock / duration, 0.0, 1.0)
	var pose: int = 0

	if progress >= 0.66:
		pose = 2
	elif progress >= 0.28:
		pose = 1

	var tool_name: String = _get_tool_kind(gathering)
	tool.call("set_tool", tool_name, pose)

	leg_left.position = leg_left_base
	leg_right.position = leg_right_base
	scarf_left.position = scarf_left_base
	scarf_right.position = scarf_right_base
	shadow.position = shadow_base
	head.position = head_base

	var reach: int = 0
	var lift: int = 0

	match pose:
		0:
			reach = -1
			lift = -2
		1:
			reach = 2
			lift = 0
		_:
			reach = 1
			lift = 2

	if gathering:
		lift -= 1

	match facing_direction:
		"left":
			arm_left.position = arm_left_base + Vector2(-reach, lift)
			arm_right.position = arm_right_base + Vector2(-reach, lift)
			body.position = body_base + Vector2(-1 if pose == 1 else 0, 0)
		"right":
			arm_left.position = arm_left_base + Vector2(reach, lift)
			arm_right.position = arm_right_base + Vector2(reach, lift)
			body.position = body_base + Vector2(1 if pose == 1 else 0, 0)
		"up":
			arm_left.position = arm_left_base + Vector2(0, -reach + lift)
			arm_right.position = arm_right_base + Vector2(0, -reach + lift)
			body.position = body_base + Vector2(0, -1 if pose == 1 else 0)
		_:
			arm_left.position = arm_left_base + Vector2(0, reach + lift)
			arm_right.position = arm_right_base + Vector2(0, reach + lift)
			body.position = body_base + Vector2(0, 1 if pose == 1 else 0)

	tool.position = tool_base

func _get_tool_kind(gathering: bool) -> String:
	if selected_item_key == "sword":
		return "sword"
	if selected_item_key == "pickaxe" or selected_item_key == "improvised_pickaxe":
		return "pickaxe"
	if selected_item_key == "axe" or selected_item_key == "improvised_axe":
		return "axe"
	if selected_item_key == "improvised_knife":
		return "knife"

	return "axe" if gathering else "none"

func _update_tool_for_state() -> void:
	if current_state == "attack":
		tool.call("set_tool", _get_tool_kind(false), 0)
	elif current_state == "gather":
		tool.call("set_tool", _get_tool_kind(true), 0)
	else:
		tool.call("set_tool", "none", 0)

func _apply_idle_pose(body_bob: int) -> void:
	leg_left.position = leg_left_base
	leg_right.position = leg_right_base
	arm_left.position = arm_left_base + Vector2(0, body_bob)
	arm_right.position = arm_right_base + Vector2(0, body_bob)
	body.position = body_base + Vector2(0, body_bob)
	head.position = head_base + Vector2(0, body_bob)
	scarf_left.position = scarf_left_base + Vector2(0, body_bob)
	scarf_right.position = scarf_right_base + Vector2(0, body_bob)
	shadow.position = shadow_base
	tool.position = tool_base
