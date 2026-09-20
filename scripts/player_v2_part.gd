extends Node2D

@export_enum(
	"shadow",
	"leg_left",
	"leg_right",
	"body",
	"arm_left",
	"arm_right",
	"head",
	"scarf_left",
	"scarf_right",
	"tool"
) var part_type: String = "body"

var facing_direction: String = "down"
var tool_mode: String = "none"
var tool_pose: int = 0

const OUTLINE: Color = Color("1b1210")
const HAIR_DARK: Color = Color("2a1716")
const HAIR_MID: Color = Color("432321")
const SKIN: Color = Color("c9896f")
const SKIN_LIGHT: Color = Color("dea087")
const TUNIC_DARK: Color = Color("3a2822")
const TUNIC: Color = Color("604033")
const TUNIC_LIGHT: Color = Color("805543")
const BELT: Color = Color("261816")
const METAL: Color = Color("b99b75")
const TROUSER: Color = Color("343031")
const TROUSER_LIGHT: Color = Color("4a4240")
const BOOT: Color = Color("1c1716")
const BOOT_LIGHT: Color = Color("332725")
const SCARF_DARK: Color = Color("6d2024")
const SCARF: Color = Color("a83235")
const SCARF_LIGHT: Color = Color("c64c48")
const SHADOW: Color = Color(0.03, 0.03, 0.03, 0.38)

func _ready() -> void:
	queue_redraw()

func set_facing(direction_name: String) -> void:
	if direction_name == facing_direction:
		return

	facing_direction = direction_name
	queue_redraw()

func set_tool_state(mode_name: String, pose_index: int) -> void:
	if mode_name == tool_mode and pose_index == tool_pose:
		return

	tool_mode = mode_name
	tool_pose = pose_index
	queue_redraw()

func _draw() -> void:
	match part_type:
		"shadow":
			_draw_shadow()
		"leg_left":
			_draw_leg(false)
		"leg_right":
			_draw_leg(true)
		"body":
			_draw_body()
		"arm_left":
			_draw_arm(false)
		"arm_right":
			_draw_arm(true)
		"head":
			_draw_head()
		"scarf_left":
			_draw_scarf_tail(false)
		"scarf_right":
			_draw_scarf_tail(true)
		"tool":
			_draw_tool()

func _px(x: int, y: int, width: int, height: int, color: Color) -> void:
	draw_rect(
		Rect2(float(x), float(y), float(width), float(height)),
		color,
		true
	)

func _draw_shadow() -> void:
	var points: PackedVector2Array = PackedVector2Array([
		Vector2(-8, -1),
		Vector2(-5, -3),
		Vector2(5, -3),
		Vector2(8, -1),
		Vector2(5, 1),
		Vector2(-5, 1)
	])
	draw_colored_polygon(points, SHADOW)

func _draw_leg(mirrored: bool) -> void:
	if facing_direction == "left" or facing_direction == "right":
		_draw_side_leg(mirrored)
		return

	# Pernas frontais/traseiras mais longas para ficarem visíveis
	# abaixo da túnica.
	_px(-2, -5, 4, 9, OUTLINE)
	_px(-1, -4, 2, 7, TROUSER)

	var light_x: int = -1 if mirrored else 0
	_px(light_x, -4, 1, 5, TROUSER_LIGHT)

	# Bota grande e claramente separada da calça.
	_px(-2, 3, 4, 5, OUTLINE)
	_px(-1, 3, 3, 3, BOOT_LIGHT)
	_px(-2, 6, 5, 2, BOOT)

	if facing_direction == "up":
		_px(-1, 3, 3, 1, BOOT)

func _draw_side_leg(mirrored: bool) -> void:
	var front_leg: bool = (
		(facing_direction == "right" and not mirrored)
		or (facing_direction == "left" and mirrored)
	)

	_px(-2, -5, 4, 9, OUTLINE)
	_px(-1, -4, 2, 7, TROUSER)

	if front_leg:
		_px(0, -3, 1, 5, TROUSER_LIGHT)

	_px(-2, 3, 4, 5, OUTLINE)
	_px(-1, 3, 3, 3, BOOT_LIGHT)

	if facing_direction == "right":
		_px(-1, 6, 5, 2, BOOT)
	else:
		_px(-3, 6, 5, 2, BOOT)

func _draw_body() -> void:
	if facing_direction == "left" or facing_direction == "right":
		_draw_side_body()
		return

	_px(-6, -7, 12, 13, OUTLINE)
	_px(-7, -4, 14, 7, OUTLINE)

	_px(-5, -6, 10, 10, TUNIC)
	_px(-6, -3, 12, 5, TUNIC)

	if facing_direction == "down":
		_px(-4, -5, 2, 7, TUNIC_LIGHT)
		_px(2, -5, 2, 7, TUNIC_DARK)
	else:
		# Costas: menos brilho e faixa central de couro.
		_px(-4, -5, 2, 7, TUNIC_DARK)
		_px(2, -5, 2, 7, TUNIC_LIGHT)
		_px(-1, -5, 2, 7, TUNIC_DARK)

	_px(-4, -7, 8, 2, TUNIC_DARK)

	_px(-5, 2, 10, 2, BELT)
	if facing_direction == "down":
		_px(-1, 2, 2, 2, METAL)

	_px(-5, 4, 3, 2, TUNIC_DARK)
	_px(-1, 4, 3, 2, TUNIC)
	_px(3, 4, 2, 2, TUNIC_DARK)

func _draw_side_body() -> void:
	_px(-5, -7, 10, 13, OUTLINE)
	_px(-6, -3, 12, 7, OUTLINE)

	_px(-4, -6, 8, 10, TUNIC)
	_px(-5, -2, 10, 5, TUNIC)

	if facing_direction == "right":
		_px(1, -5, 2, 7, TUNIC_LIGHT)
		_px(-3, -5, 2, 7, TUNIC_DARK)
	else:
		_px(-3, -5, 2, 7, TUNIC_LIGHT)
		_px(1, -5, 2, 7, TUNIC_DARK)

	_px(-4, -7, 8, 2, TUNIC_DARK)
	_px(-4, 2, 8, 2, BELT)
	_px(-4, 4, 3, 2, TUNIC_DARK)
	_px(0, 4, 4, 2, TUNIC)

func _draw_arm(mirrored: bool) -> void:
	if facing_direction == "left" or facing_direction == "right":
		_draw_side_arm(mirrored)
		return

	_px(-2, -4, 4, 10, OUTLINE)
	_px(-1, -3, 2, 7, TUNIC)

	var light_x: int = -1 if mirrored else 0
	if facing_direction == "up":
		light_x = 0 if mirrored else -1
	_px(light_x, -3, 1, 5, TUNIC_LIGHT)

	_px(-2, 3, 4, 3, BELT)
	_px(-1, 5, 2, 2, SKIN)

func _draw_side_arm(mirrored: bool) -> void:
	var front_arm: bool = (
		(facing_direction == "right" and not mirrored)
		or (facing_direction == "left" and mirrored)
	)

	_px(-2, -4, 4, 10, OUTLINE)
	_px(-1, -3, 2, 7, TUNIC)

	if front_arm:
		_px(0, -3, 1, 5, TUNIC_LIGHT)
	else:
		_px(-1, -3, 1, 5, TUNIC_DARK)

	_px(-2, 3, 4, 3, BELT)
	_px(-1, 5, 2, 2, SKIN)

func _draw_head() -> void:
	match facing_direction:
		"up":
			_draw_head_back()
		"left":
			_draw_head_side(false)
		"right":
			_draw_head_side(true)
		_:
			_draw_head_front()

func _draw_head_front() -> void:
	_px(-2, 5, 4, 3, OUTLINE)
	_px(-1, 5, 2, 3, SKIN)

	_px(-5, -3, 10, 9, OUTLINE)
	_px(-4, -2, 8, 7, SKIN)
	_px(-3, -1, 6, 4, SKIN_LIGHT)
	_px(-4, 3, 8, 2, SKIN)

	_px(-6, 0, 2, 3, OUTLINE)
	_px(-5, 0, 1, 2, SKIN)
	_px(4, 0, 2, 3, OUTLINE)
	_px(4, 0, 1, 2, SKIN)

	_draw_hair_front()

	_px(-3, 0, 2, 1, HAIR_DARK)
	_px(1, 0, 2, 1, HAIR_DARK)
	_px(-2, 1, 1, 1, OUTLINE)
	_px(2, 1, 1, 1, OUTLINE)
	_px(0, 2, 1, 1, Color("9c5f52"))
	_px(-1, 4, 3, 1, Color("793f3d"))

func _draw_hair_front() -> void:
	_px(-5, -7, 10, 5, OUTLINE)
	_px(-4, -8, 3, 2, OUTLINE)
	_px(1, -8, 3, 2, OUTLINE)
	_px(-6, -5, 3, 5, OUTLINE)
	_px(3, -5, 3, 5, OUTLINE)

	_px(-4, -6, 8, 4, HAIR_DARK)
	_px(-3, -7, 2, 3, HAIR_MID)
	_px(1, -7, 2, 2, HAIR_MID)
	_px(-5, -4, 2, 4, HAIR_DARK)
	_px(3, -4, 2, 4, HAIR_DARK)

	_px(-3, -3, 2, 2, HAIR_MID)
	_px(1, -3, 3, 2, HAIR_DARK)

func _draw_head_back() -> void:
	_px(-2, 5, 4, 3, OUTLINE)
	_px(-1, 5, 2, 3, SKIN)

	_px(-5, -3, 10, 9, OUTLINE)
	_px(-4, -2, 8, 7, HAIR_DARK)
	_px(-5, -7, 10, 7, OUTLINE)
	_px(-4, -8, 3, 2, OUTLINE)
	_px(1, -8, 3, 2, OUTLINE)

	_px(-4, -6, 8, 6, HAIR_DARK)
	_px(-3, -7, 2, 4, HAIR_MID)
	_px(1, -7, 2, 3, HAIR_MID)
	_px(-3, 1, 2, 4, HAIR_MID)
	_px(1, 1, 2, 4, HAIR_DARK)

func _draw_head_side(looking_right: bool) -> void:
	var direction_sign: int = 1 if looking_right else -1

	_px(-2, 5, 4, 3, OUTLINE)
	_px(-1, 5, 2, 3, SKIN)

	_px(-5, -3, 10, 9, OUTLINE)
	_px(-4, -2, 8, 7, SKIN)
	_px(-3, -1, 6, 4, SKIN_LIGHT)

	# Nariz em perfil.
	if direction_sign > 0:
		_px(4, 0, 3, 3, OUTLINE)
		_px(4, 0, 2, 2, SKIN)
		_px(1, 1, 1, 1, OUTLINE)
		_px(2, 4, 2, 1, Color("793f3d"))
	else:
		_px(-7, 0, 3, 3, OUTLINE)
		_px(-6, 0, 2, 2, SKIN)
		_px(-2, 1, 1, 1, OUTLINE)
		_px(-4, 4, 2, 1, Color("793f3d"))

	_px(-5, -7, 10, 5, OUTLINE)
	_px(-4, -8, 3, 2, OUTLINE)
	_px(1, -8, 3, 2, OUTLINE)
	_px(-4, -6, 8, 4, HAIR_DARK)

	if direction_sign > 0:
		_px(-5, -5, 4, 7, HAIR_DARK)
		_px(-3, -6, 2, 4, HAIR_MID)
	else:
		_px(1, -5, 4, 7, HAIR_DARK)
		_px(1, -6, 2, 4, HAIR_MID)

func _draw_scarf_tail(mirrored: bool) -> void:
	if facing_direction == "up":
		_draw_scarf_back(mirrored)
		return

	var direction: int = -1 if mirrored else 1

	if facing_direction == "left":
		direction = -1
	elif facing_direction == "right":
		direction = 1

	_px(-2, -2, 4, 4, OUTLINE)
	_px(-1, -1, 2, 3, SCARF)

	_px(-1, 2, 3, 5, OUTLINE)
	if direction < 0:
		_px(-2, 2, 3, 5, OUTLINE)

	_px(-1, 2, 2, 4, SCARF_DARK)
	_px(0 if direction > 0 else -1, 2, 1, 3, SCARF)
	_px(-1 if direction > 0 else -2, 6, 3, 1, SCARF_LIGHT)

func _draw_scarf_back(mirrored: bool) -> void:
	var offset_x: int = -2 if mirrored else 0
	_px(-2, -2, 4, 4, OUTLINE)
	_px(-1, -1, 2, 3, SCARF)
	_px(offset_x, 2, 3, 5, OUTLINE)
	_px(offset_x + 1, 2, 2, 4, SCARF_DARK)
	_px(offset_x, 6, 3, 1, SCARF_LIGHT)

func _draw_tool() -> void:
	if tool_mode == "none":
		return

	if tool_mode == "attack":
		_draw_sword()
		return

	if tool_mode == "gather":
		_draw_axe()

func _draw_sword() -> void:
	var blade: Color = Color("c8d0cf")
	var blade_light: Color = Color("edf0e9")
	var guard: Color = METAL
	var handle: Color = BELT

	var points: Array[Vector2i] = _get_tool_points(true)
	var handle_point: Vector2i = points[0]
	var guard_point: Vector2i = points[1]
	var tip_point: Vector2i = points[2]

	draw_line(
		Vector2(handle_point),
		Vector2(tip_point),
		OUTLINE,
		4.0,
		false
	)
	draw_line(
		Vector2(guard_point),
		Vector2(tip_point),
		blade,
		2.0,
		false
	)
	draw_line(
		Vector2(guard_point),
		Vector2(tip_point),
		blade_light,
		1.0,
		false
	)

	_px(handle_point.x - 1, handle_point.y - 1, 3, 3, handle)
	_px(guard_point.x - 2, guard_point.y - 1, 5, 2, guard)

func _draw_axe() -> void:
	var wood: Color = Color("6c472f")
	var wood_light: Color = Color("8c6242")
	var metal_dark: Color = Color("596264")
	var metal_light: Color = Color("aab5b4")

	var points: Array[Vector2i] = _get_tool_points(false)
	var handle_point: Vector2i = points[0]
	var head_point: Vector2i = points[1]
	var tip_point: Vector2i = points[2]

	draw_line(
		Vector2(handle_point),
		Vector2(tip_point),
		OUTLINE,
		4.0,
		false
	)
	draw_line(
		Vector2(handle_point),
		Vector2(tip_point),
		wood,
		2.0,
		false
	)
	draw_line(
		Vector2(handle_point),
		Vector2(tip_point),
		wood_light,
		1.0,
		false
	)

	_px(head_point.x - 2, head_point.y - 2, 5, 4, OUTLINE)
	_px(head_point.x - 1, head_point.y - 1, 4, 2, metal_dark)
	_px(head_point.x, head_point.y - 1, 3, 1, metal_light)

func _get_tool_points(is_sword: bool) -> Array[Vector2i]:
	var length_bonus: int = 2 if is_sword else 0
	var handle_point: Vector2i = Vector2i(0, 3)
	var middle_point: Vector2i = Vector2i(0, -1)
	var tip_point: Vector2i = Vector2i(0, -8 - length_bonus)

	match facing_direction:
		"down":
			match tool_pose:
				0:
					handle_point = Vector2i(4, -1)
					middle_point = Vector2i(7, -4)
					tip_point = Vector2i(10, -9 - length_bonus)
				1:
					handle_point = Vector2i(5, 0)
					middle_point = Vector2i(8, 1)
					tip_point = Vector2i(11, 4 + length_bonus)
				2:
					handle_point = Vector2i(4, 1)
					middle_point = Vector2i(4, 5)
					tip_point = Vector2i(3, 9 + length_bonus)
				_:
					handle_point = Vector2i(4, 0)
					middle_point = Vector2i(7, -2)
					tip_point = Vector2i(9, -7 - length_bonus)
		"up":
			match tool_pose:
				0:
					handle_point = Vector2i(-4, -1)
					middle_point = Vector2i(-7, -4)
					tip_point = Vector2i(-10, -9 - length_bonus)
				1:
					handle_point = Vector2i(-5, 0)
					middle_point = Vector2i(-8, 1)
					tip_point = Vector2i(-11, 4 + length_bonus)
				2:
					handle_point = Vector2i(-4, 1)
					middle_point = Vector2i(-4, 5)
					tip_point = Vector2i(-3, 9 + length_bonus)
				_:
					handle_point = Vector2i(-4, 0)
					middle_point = Vector2i(-7, -2)
					tip_point = Vector2i(-9, -7 - length_bonus)
		"left":
			match tool_pose:
				0:
					handle_point = Vector2i(-3, -1)
					middle_point = Vector2i(-6, -5)
					tip_point = Vector2i(-10 - length_bonus, -8)
				1:
					handle_point = Vector2i(-4, 0)
					middle_point = Vector2i(-8, 0)
					tip_point = Vector2i(-12 - length_bonus, 1)
				2:
					handle_point = Vector2i(-3, 1)
					middle_point = Vector2i(-6, 5)
					tip_point = Vector2i(-10 - length_bonus, 8)
				_:
					handle_point = Vector2i(-3, 0)
					middle_point = Vector2i(-7, -3)
					tip_point = Vector2i(-11 - length_bonus, -6)
		_:
			match tool_pose:
				0:
					handle_point = Vector2i(3, -1)
					middle_point = Vector2i(6, -5)
					tip_point = Vector2i(10 + length_bonus, -8)
				1:
					handle_point = Vector2i(4, 0)
					middle_point = Vector2i(8, 0)
					tip_point = Vector2i(12 + length_bonus, 1)
				2:
					handle_point = Vector2i(3, 1)
					middle_point = Vector2i(6, 5)
					tip_point = Vector2i(10 + length_bonus, 8)
				_:
					handle_point = Vector2i(3, 0)
					middle_point = Vector2i(7, -3)
					tip_point = Vector2i(11 + length_bonus, -6)

	return [handle_point, middle_point, tip_point]
