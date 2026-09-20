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
	"scarf_right"
) var part_type: String = "body"

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
const TROUSER: Color = Color("292626")
const BOOT: Color = Color("1c1716")
const SCARF_DARK: Color = Color("6d2024")
const SCARF: Color = Color("a83235")
const SCARF_LIGHT: Color = Color("c64c48")
const SHADOW: Color = Color(0.03, 0.03, 0.03, 0.38)

func _ready() -> void:
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
	var highlight_x: int = -1 if mirrored else 0

	_px(-2, -4, 4, 7, OUTLINE)
	_px(-1, -3, 2, 5, TROUSER)
	_px(highlight_x, -3, 1, 3, TUNIC_DARK)

	_px(-2, 2, 4, 4, OUTLINE)
	_px(-1, 2, 3, 2, BOOT)
	_px(-2, 5, 4, 1, BOOT)

func _draw_body() -> void:
	# Silhueta.
	_px(-6, -7, 12, 13, OUTLINE)
	_px(-7, -4, 14, 7, OUTLINE)

	# Couro/túnica.
	_px(-5, -6, 10, 10, TUNIC)
	_px(-6, -3, 12, 5, TUNIC)
	_px(-4, -5, 2, 7, TUNIC_LIGHT)
	_px(2, -5, 2, 7, TUNIC_DARK)

	# Gola sob o cachecol.
	_px(-4, -7, 8, 2, TUNIC_DARK)

	# Cinto.
	_px(-5, 2, 10, 2, BELT)
	_px(-1, 2, 2, 2, METAL)

	# Barra irregular para estética desenhada.
	_px(-5, 4, 3, 2, TUNIC_DARK)
	_px(-1, 4, 3, 2, TUNIC)
	_px(3, 4, 2, 2, TUNIC_DARK)

func _draw_arm(mirrored: bool) -> void:
	var light_x: int = -1 if mirrored else 0

	_px(-2, -4, 4, 10, OUTLINE)
	_px(-1, -3, 2, 7, TUNIC)
	_px(light_x, -3, 1, 5, TUNIC_LIGHT)

	# Luva/punho.
	_px(-2, 3, 4, 3, BELT)
	_px(-1, 5, 2, 2, SKIN)

func _draw_head() -> void:
	# Pescoço.
	_px(-2, 5, 4, 3, OUTLINE)
	_px(-1, 5, 2, 3, SKIN)

	# Rosto.
	_px(-5, -3, 10, 9, OUTLINE)
	_px(-4, -2, 8, 7, SKIN)
	_px(-3, -1, 6, 4, SKIN_LIGHT)
	_px(-4, 3, 8, 2, SKIN)

	# Orelhas.
	_px(-6, 0, 2, 3, OUTLINE)
	_px(-5, 0, 1, 2, SKIN)
	_px(4, 0, 2, 3, OUTLINE)
	_px(4, 0, 1, 2, SKIN)

	# Cabelo desalinhado.
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

	# Franja.
	_px(-3, -3, 2, 2, HAIR_MID)
	_px(1, -3, 3, 2, HAIR_DARK)

	# Olhos/sobrancelhas.
	_px(-3, 0, 2, 1, HAIR_DARK)
	_px(1, 0, 2, 1, HAIR_DARK)
	_px(-2, 1, 1, 1, OUTLINE)
	_px(2, 1, 1, 1, OUTLINE)

	# Nariz e boca discretos.
	_px(0, 2, 1, 1, Color("9c5f52"))
	_px(-1, 4, 3, 1, Color("793f3d"))

func _draw_scarf_tail(mirrored: bool) -> void:
	var direction: int = -1 if mirrored else 1

	_px(-2, -2, 4, 4, OUTLINE)
	_px(-1, -1, 2, 3, SCARF)

	_px(-1, 2, 3, 5, OUTLINE)
	if direction < 0:
		_px(-2, 2, 3, 5, OUTLINE)

	_px(-1 if direction > 0 else -1, 2, 2, 4, SCARF_DARK)
	_px(0 if direction > 0 else -1, 2, 1, 3, SCARF)
	_px(-1 if direction > 0 else -2, 6, 3, 1, SCARF_LIGHT)
