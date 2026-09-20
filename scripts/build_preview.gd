extends Node2D

var piece_type: String = "floor"
var rotation_quarters: int = 0
var placement_valid: bool = false

func configure(new_piece_type: String, new_rotation_quarters: int, is_valid: bool) -> void:
	piece_type = new_piece_type
	rotation_quarters = posmod(new_rotation_quarters, 4)
	placement_valid = is_valid
	rotation = float(rotation_quarters) * PI / 2.0
	queue_redraw()

func _draw() -> void:
	var fill_color: Color = Color(0.25, 0.85, 0.35, 0.42) if placement_valid else Color(0.9, 0.2, 0.2, 0.42)
	var border_color: Color = Color(0.45, 1.0, 0.55, 0.9) if placement_valid else Color(1.0, 0.35, 0.35, 0.9)

	match piece_type:
		"floor":
			draw_rect(Rect2(-30, -30, 60, 60), fill_color, true)
			draw_rect(Rect2(-30, -30, 60, 60), border_color, false, 3.0)
		"wall":
			draw_rect(Rect2(-31, -8, 62, 16), fill_color, true)
			draw_rect(Rect2(-31, -8, 62, 16), border_color, false, 3.0)
		"door":
			draw_rect(Rect2(-31, -9, 14, 18), fill_color, true)
			draw_rect(Rect2(17, -9, 14, 18), fill_color, true)
			draw_rect(Rect2(-31, -9, 62, 7), fill_color, true)
			draw_rect(Rect2(-31, -9, 62, 18), border_color, false, 3.0)
