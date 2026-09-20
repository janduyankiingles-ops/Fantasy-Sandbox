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

	_apply_idle_pose(0)

func set_move_input(value: Vector2) -> void:
	move_input = value

func _process(delta: float) -> void:
	if move_input.length_squared() > 0.0:
		walk_phase = fmod(walk_phase + delta * 2.6, 1.0)
		_animate_walk()
	else:
		idle_phase = fmod(idle_phase + delta * 0.8, 1.0)
		_animate_idle()

func _animate_walk() -> void:
	var wave: float = sin(walk_phase * TAU)
	var opposite_wave: float = sin((walk_phase + 0.5) * TAU)

	var left_step: int = roundi(wave * 2.0)
	var right_step: int = roundi(opposite_wave * 2.0)
	var body_bob: int = -roundi(absf(wave))
	var arm_left_step: int = roundi(opposite_wave)
	var arm_right_step: int = roundi(wave)

	leg_left.position = leg_left_base + Vector2(0, left_step)
	leg_right.position = leg_right_base + Vector2(0, right_step)

	arm_left.position = arm_left_base + Vector2(0, arm_left_step)
	arm_right.position = arm_right_base + Vector2(0, arm_right_step)

	body.position = body_base + Vector2(0, body_bob)
	head.position = head_base + Vector2(0, body_bob)

	var scarf_swing: int = roundi(wave)
	scarf_left.position = scarf_left_base + Vector2(scarf_swing, body_bob)
	scarf_right.position = scarf_right_base + Vector2(-scarf_swing, body_bob)

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
