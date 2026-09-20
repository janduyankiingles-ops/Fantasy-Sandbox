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

var move_input: Vector2 = Vector2.ZERO
var facing_direction: String = "down"
var walk_phase: float = 0.0
var idle_phase: float = 0.0

var shadow_base: Vector2
var leg_left_base: Vector2
var leg_right_base: Vector2
var body_base: Vector2
var arm_left_base: Vector2
var arm_right_base: Vector2
var head_base: Vector2
var scarf_left_base: Vector2
var scarf_right_base: Vector2

func _ready() -> void:
	scale = Vector2(3.0, 3.0)

	shadow_base = shadow.position
	leg_left_base = leg_left.position
	leg_right_base = leg_right.position
	body_base = body.position
	arm_left_base = arm_left.position
	arm_right_base = arm_right.position
	head_base = head.position
	scarf_left_base = scarf_left.position
	scarf_right_base = scarf_right.position

	_set_facing("down")
	_apply_idle_pose(0)

func set_move_input(value: Vector2) -> void:
	move_input = value

	if move_input.length_squared() <= 0.0:
		return

	var new_direction: String = _direction_from_input(move_input)
	if new_direction != facing_direction:
		_set_facing(new_direction)

func _process(delta: float) -> void:
	if move_input.length_squared() > 0.0:
		walk_phase = fmod(walk_phase + delta * 2.6, 1.0)
		_animate_walk()
	else:
		idle_phase = fmod(idle_phase + delta * 0.8, 1.0)
		_animate_idle()

func _direction_from_input(value: Vector2) -> String:
	var abs_x: float = absf(value.x)
	var abs_y: float = absf(value.y)

	if abs_x > abs_y:
		return "right" if value.x > 0.0 else "left"

	if abs_y > abs_x:
		return "down" if value.y > 0.0 else "up"

	# Em diagonal perfeita, mantém a direção anterior se ela ainda
	# participa do movimento.
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

	shadow.call("set_facing", direction_name)
	leg_left.call("set_facing", direction_name)
	leg_right.call("set_facing", direction_name)
	body.call("set_facing", direction_name)
	arm_left.call("set_facing", direction_name)
	arm_right.call("set_facing", direction_name)
	head.call("set_facing", direction_name)
	scarf_left.call("set_facing", direction_name)
	scarf_right.call("set_facing", direction_name)

	_apply_direction_layout()
	_apply_idle_pose(0)

func _apply_direction_layout() -> void:
	# Posições-base específicas de cada orientação.
	# Isso mantém pernas e braços legíveis sem redesenhar o personagem
	# inteiro em cada frame.
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
			head.z_index = 3

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
			head.z_index = 3

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
			head.z_index = 3

func _animate_walk() -> void:
	var wave: float = sin(walk_phase * TAU)
	var opposite_wave: float = sin((walk_phase + 0.5) * TAU)

	var left_step: int = roundi(wave * 2.0)
	var right_step: int = roundi(opposite_wave * 2.0)
	var body_bob: int = -roundi(absf(wave))
	var arm_left_step: int = roundi(opposite_wave)
	var arm_right_step: int = roundi(wave)

	if facing_direction == "left" or facing_direction == "right":
		var horizontal_sign: int = 1 if facing_direction == "right" else -1

		leg_left.position = leg_left_base + Vector2(
			horizontal_sign * roundi(wave),
			left_step
		)
		leg_right.position = leg_right_base + Vector2(
			horizontal_sign * roundi(opposite_wave),
			right_step
		)

		arm_left.position = arm_left_base + Vector2(
			horizontal_sign * roundi(opposite_wave),
			arm_left_step
		)
		arm_right.position = arm_right_base + Vector2(
			horizontal_sign * roundi(wave),
			arm_right_step
		)
	else:
		leg_left.position = leg_left_base + Vector2(0, left_step)
		leg_right.position = leg_right_base + Vector2(0, right_step)
		arm_left.position = arm_left_base + Vector2(0, arm_left_step)
		arm_right.position = arm_right_base + Vector2(0, arm_right_step)

	body.position = body_base + Vector2(0, body_bob)
	head.position = head_base + Vector2(0, body_bob)

	var scarf_swing: int = roundi(wave)
	var scarf_abs: int = scarf_swing if scarf_swing >= 0 else -scarf_swing

	match facing_direction:
		"left":
			scarf_left.position = scarf_left_base + Vector2(
				scarf_abs,
				body_bob
			)
			scarf_right.position = scarf_right_base + Vector2(
				scarf_abs,
				body_bob
			)
		"right":
			scarf_left.position = scarf_left_base + Vector2(
				-scarf_abs,
				body_bob
			)
			scarf_right.position = scarf_right_base + Vector2(
				-scarf_abs,
				body_bob
			)
		_:
			scarf_left.position = scarf_left_base + Vector2(
				scarf_swing,
				body_bob
			)
			scarf_right.position = scarf_right_base + Vector2(
				-scarf_swing,
				body_bob
			)

	var shadow_pulse: int = roundi(absf(wave))
	shadow.position = shadow_base + Vector2(0, shadow_pulse)

func _animate_idle() -> void:
	var breathe: float = sin(idle_phase * TAU)
	var body_bob: int = -1 if breathe > 0.55 else 0
	_apply_idle_pose(body_bob)

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

func get_facing_direction() -> String:
	return facing_direction
