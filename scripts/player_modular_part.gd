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
var tool_kind: String = "none"
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
const METAL_DARK: Color = Color("596264")
const METAL: Color = Color("aab5b4")
const METAL_LIGHT: Color = Color("d8dfdc")
const TROUSER: Color = Color("343031")
const TROUSER_LIGHT: Color = Color("4a4240")
const BOOT: Color = Color("1c1716")
const BOOT_LIGHT: Color = Color("332725")
const WOOD: Color = Color("6c472f")
const WOOD_LIGHT: Color = Color("8c6242")
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

func set_tool(kind: String, pose_index: int) -> void:
	if kind == tool_kind and pose_index == tool_pose:
		return
	tool_kind = kind
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
			_draw_scarf(false)
		"scarf_right":
			_draw_scarf(true)
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
	_px(-2, -5, 4, 9, OUTLINE)
	_px(-1, -4, 2, 7, TROUSER)

	var light_x: int = -1 if mirrored else 0
	_px(light_x, -4, 1, 5, TROUSER_LIGHT)

	_px(-2, 3, 4, 5, OUTLINE)
	_px(-1, 3, 3, 3, BOOT_LIGHT)

	if facing_direction == "left":
		_px(-3, 6, 5, 2, BOOT)
	elif facing_direction == "right":
		_px(-1, 6, 5, 2, BOOT)
	else:
		_px(-2, 6, 5, 2, BOOT)

func _draw_body() -> void:
	var side_view: bool = facing_direction == "left" or facing_direction == "right"

	if side_view:
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

		_px(-4, 2, 8, 2, BELT)
		_px(-4, 4, 3, 2, TUNIC_DARK)
		_px(0, 4, 4, 2, TUNIC)
		return

	_px(-6, -7, 12, 13, OUTLINE)
	_px(-7, -4, 14, 7, OUTLINE)
	_px(-5, -6, 10, 10, TUNIC)
	_px(-6, -3, 12, 5, TUNIC)

	if facing_direction == "up":
		_px(-4, -5, 2, 7, TUNIC_DARK)
		_px(2, -5, 2, 7, TUNIC_LIGHT)
		_px(-1, -5, 2, 7, TUNIC_DARK)
	else:
		_px(-4, -5, 2, 7, TUNIC_LIGHT)
		_px(2, -5, 2, 7, TUNIC_DARK)

	_px(-4, -7, 8, 2, TUNIC_DARK)
	_px(-5, 2, 10, 2, BELT)

	if facing_direction == "down":
		_px(-1, 2, 2, 2, METAL)

	_px(-5, 4, 3, 2, TUNIC_DARK)
	_px(-1, 4, 3, 2, TUNIC)
	_px(3, 4, 2, 2, TUNIC_DARK)

func _draw_arm(mirrored: bool) -> void:
	_px(-2, -4, 4, 10, OUTLINE)
	_px(-1, -3, 2, 7, TUNIC)

	var light_x: int = -1 if mirrored else 0
	if facing_direction == "up":
		light_x = 0 if mirrored else -1
	_px(light_x, -3, 1, 5, TUNIC_LIGHT)

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
	_px(-2, 5, 4, 3, OUTLINE)
	_px(-1, 5, 2, 3, SKIN)
	_px(-5, -3, 10, 9, OUTLINE)
	_px(-4, -2, 8, 7, SKIN)
	_px(-3, -1, 6, 4, SKIN_LIGHT)
	_px(-5, -7, 10, 5, OUTLINE)
	_px(-4, -8, 3, 2, OUTLINE)
	_px(1, -8, 3, 2, OUTLINE)
	_px(-4, -6, 8, 4, HAIR_DARK)

	if looking_right:
		_px(4, 0, 3, 3, OUTLINE)
		_px(4, 0, 2, 2, SKIN)
		_px(1, 1, 1, 1, OUTLINE)
		_px(2, 4, 2, 1, Color("793f3d"))
		_px(-5, -5, 4, 7, HAIR_DARK)
		_px(-3, -6, 2, 4, HAIR_MID)
	else:
		_px(-7, 0, 3, 3, OUTLINE)
		_px(-6, 0, 2, 2, SKIN)
		_px(-2, 1, 1, 1, OUTLINE)
		_px(-4, 4, 2, 1, Color("793f3d"))
		_px(1, -5, 4, 7, HAIR_DARK)
		_px(1, -6, 2, 4, HAIR_MID)

func _draw_scarf(mirrored: bool) -> void:
	var x_offset: int = -1 if mirrored else 0

	_px(-2, -2, 4, 4, OUTLINE)
	_px(-1, -1, 2, 3, SCARF)

	if facing_direction == "left":
		x_offset -= 1
	elif facing_direction == "right":
		x_offset += 1

	_px(x_offset - 1, 2, 3, 5, OUTLINE)
	_px(x_offset, 2, 2, 4, SCARF_DARK)
	_px(x_offset, 2, 1, 3, SCARF)
	_px(x_offset - 1, 6, 3, 1, SCARF_LIGHT)

func _draw_tool() -> void:
	if tool_kind == "none":
		return

	var root: Vector2 = Vector2.ZERO
	var tip: Vector2 = Vector2.ZERO
	var pose_shift: int = tool_pose - 1

	match facing_direction:
		"left":
			root = Vector2(-3, 0)
			tip = Vector2(-12, float(pose_shift * 5))
		"right":
			root = Vector2(3, 0)
			tip = Vector2(12, float(pose_shift * 5))
		"up":
			root = Vector2(-3, -1)
			tip = Vector2(float(-pose_shift * 5), -12)
		_:
			root = Vector2(3, 0)
			tip = Vector2(float(pose_shift * 5), 12)

	if tool_kind == "knife":
		tip = root + (tip - root) * 0.65

	_draw_tool_handle(root, tip)

	if tool_kind == "sword" or tool_kind == "knife":
		_draw_blade(root, tip, tool_kind == "sword")
	elif tool_kind == "pickaxe":
		_draw_pickaxe_head(tip)
	else:
		_draw_axe_head(tip)

func _draw_tool_handle(root: Vector2, tip: Vector2) -> void:
	draw_line(root, tip, OUTLINE, 4.0, false)
	draw_line(root, tip, WOOD, 2.0, false)
	draw_line(root, tip, WOOD_LIGHT, 1.0, false)

func _draw_blade(root: Vector2, tip: Vector2, long_blade: bool) -> void:
	var blade_start: Vector2 = root.lerp(tip, 0.32 if long_blade else 0.48)
	draw_line(blade_start, tip, METAL_DARK, 4.0, false)
	draw_line(blade_start, tip, METAL, 2.0, false)
	draw_line(blade_start, tip, METAL_LIGHT, 1.0, false)

func _draw_axe_head(tip: Vector2) -> void:
	_px(roundi(tip.x) - 3, roundi(tip.y) - 2, 6, 4, OUTLINE)
	_px(roundi(tip.x) - 2, roundi(tip.y) - 1, 5, 2, METAL)
	_px(roundi(tip.x), roundi(tip.y) - 1, 2, 1, METAL_LIGHT)

func _draw_pickaxe_head(tip: Vector2) -> void:
	_px(roundi(tip.x) - 5, roundi(tip.y) - 1, 10, 3, OUTLINE)
	_px(roundi(tip.x) - 4, roundi(tip.y), 8, 1, METAL)
