extends Node2D

var pulse_time: float = 0.0

func _ready() -> void:
	add_to_group("resource_nodes")
	z_index = 3
	queue_redraw()

func _process(delta: float) -> void:
	pulse_time += delta
	queue_redraw()

func harvest(_tool_key: String = "") -> Dictionary:
	return {
		"action": "cook"
	}

func get_interaction_text(_tool_key: String = "") -> String:
	return "E - Assar 1 Carne Crua"

func _draw() -> void:
	draw_circle(Vector2(0, 12), 25.0, Color(0.03, 0.03, 0.03, 0.28))

	# Pedras ao redor.
	for index in range(8):
		var angle: float = TAU * float(index) / 8.0
		var stone_pos: Vector2 = Vector2(cos(angle), sin(angle)) * 19.0
		draw_circle(stone_pos + Vector2(0, 7), 5.0, Color("77736b"))

	# Lenha.
	draw_line(Vector2(-14, 15), Vector2(14, 2), Color("704329"), 7.0)
	draw_line(Vector2(-14, 2), Vector2(14, 15), Color("825238"), 7.0)

	# Chama simples com leve pulsação.
	var pulse: float = 1.0 + sin(pulse_time * 7.0) * 0.08
	var outer_flame: PackedVector2Array = PackedVector2Array([
		Vector2(-11, 9),
		Vector2(-7, -7) * pulse,
		Vector2(0, -23) * pulse,
		Vector2(6, -8) * pulse,
		Vector2(12, 9)
	])
	draw_colored_polygon(outer_flame, Color("e66b2e"))

	var inner_flame: PackedVector2Array = PackedVector2Array([
		Vector2(-6, 8),
		Vector2(-3, -4) * pulse,
		Vector2(1, -14) * pulse,
		Vector2(6, 8)
	])
	draw_colored_polygon(inner_flame, Color("f1c24b"))
