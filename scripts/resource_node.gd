extends StaticBody2D

@export_enum("tree", "rock", "stick", "small_stone", "vine") var resource_type: String = "tree"
@export var hit_points: int = 3
@export var amount_per_hit: int = 1
@export var final_bonus: int = 2

var current_hit_points: int
var flash_time: float = 0.0

func _ready() -> void:
	add_to_group("resource_nodes")
	_configure_for_type()
	current_hit_points = hit_points
	_create_collision()
	queue_redraw()

func setup(type_name: String) -> void:
	resource_type = type_name
	_configure_for_type()
	current_hit_points = hit_points
	queue_redraw()

func _configure_for_type() -> void:
	match resource_type:
		"rock":
			hit_points = 4
			amount_per_hit = 1
			final_bonus = 2
		"tree":
			hit_points = 3
			amount_per_hit = 1
			final_bonus = 2
		_:
			hit_points = 1
			amount_per_hit = 1
			final_bonus = 0

func _create_collision() -> void:
	if _is_ground_pickup():
		return
	if get_node_or_null("CollisionShape2D") != null:
		return

	var collision: CollisionShape2D = CollisionShape2D.new()
	collision.name = "CollisionShape2D"

	var shape: CircleShape2D = CircleShape2D.new()
	if resource_type == "rock":
		shape.radius = 23.0
	elif resource_type == "tree":
		shape.radius = 18.0
	else:
		shape.radius = 9.0

	collision.shape = shape

	if resource_type == "rock":
		collision.position = Vector2(0, 4)
	elif resource_type == "tree":
		collision.position = Vector2(0, 14)
	else:
		collision.position = Vector2.ZERO

	add_child(collision)

func _process(delta: float) -> void:
	if flash_time > 0.0:
		flash_time = maxf(0.0, flash_time - delta)
		queue_redraw()

func harvest(tool_key: String = "") -> Dictionary:
	if current_hit_points <= 0:
		return {"type": resource_type, "amount": 0}

	if _is_ground_pickup():
		current_hit_points = 0
		call_deferred("queue_free")
		return {"type": resource_type, "amount": 1}

	if not _can_harvest_large_resource(tool_key):
		return {"type": resource_type, "amount": 0, "blocked": true}

	var effective_tool: bool = false

	if resource_type == "tree":
		effective_tool = tool_key == "axe"
	elif resource_type == "rock":
		effective_tool = tool_key == "pickaxe"

	var damage: int = 2 if effective_tool else 1
	var actual_damage: int = mini(damage, current_hit_points)

	current_hit_points -= actual_damage
	flash_time = 0.10

	var amount: int = amount_per_hit * actual_damage
	if current_hit_points <= 0:
		amount += final_bonus
		call_deferred("queue_free")

	queue_redraw()

	return {
		"type": resource_type,
		"amount": amount,
		"effective_tool": effective_tool
	}

func _is_ground_pickup() -> bool:
	return resource_type == "stick" or resource_type == "small_stone" or resource_type == "vine"

func _can_harvest_large_resource(tool_key: String) -> bool:
	if resource_type == "tree":
		return tool_key == "improvised_axe" or tool_key == "axe"
	if resource_type == "rock":
		return tool_key == "improvised_pickaxe" or tool_key == "pickaxe"
	return true

func get_interaction_text(tool_key: String = "") -> String:
	match resource_type:
		"stick":
			return "E - Pegar Graveto"
		"small_stone":
			return "E - Pegar Pedra Pequena"
		"vine":
			return "E - Pegar Cipó"
		"tree":
			if tool_key == "axe":
				return "E - Cortar Árvore com Machado  (%d/%d)" % [current_hit_points, hit_points]
			if tool_key == "improvised_axe":
				return "E - Cortar Árvore com Machado Improvisado  (%d/%d)" % [current_hit_points, hit_points]
			return "Você precisa de um Machado Improvisado ou Machado"
		"rock":
			if tool_key == "pickaxe":
				return "E - Minerar Rocha com Picareta  (%d/%d)" % [current_hit_points, hit_points]
			if tool_key == "improvised_pickaxe":
				return "E - Minerar Rocha com Picareta Improvisada  (%d/%d)" % [current_hit_points, hit_points]
			return "Você precisa de uma Picareta Improvisada ou Picareta"

	return ""

func _draw() -> void:
	var flash: bool = flash_time > 0.0

	match resource_type:
		"rock":
			_draw_rock(flash)
		"tree":
			_draw_tree(flash)
		"stick":
			_draw_stick()
		"small_stone":
			_draw_small_stone()
		"vine":
			_draw_vine()

func _draw_tree(flash: bool) -> void:
	_draw_flat_ellipse(Vector2(0, 27), Vector2(30, 11), Color(0.03, 0.04, 0.03, 0.30))
	draw_rect(Rect2(-7, 4, 14, 34), Color("7b4a2d") if not flash else Color("d6b08d"), true)
	draw_rect(Rect2(-4, 7, 4, 29), Color("9b6540"), true)

	var leaf: Color = Color("315f36") if not flash else Color("91b895")
	draw_circle(Vector2(-15, -7), 23.0, leaf)
	draw_circle(Vector2(13, -10), 25.0, leaf.darkened(0.08))
	draw_circle(Vector2(0, -28), 27.0, leaf.lightened(0.04))
	draw_circle(Vector2(0, -7), 28.0, leaf)

func _draw_rock(flash: bool) -> void:
	_draw_flat_ellipse(Vector2(0, 20), Vector2(31, 10), Color(0.03, 0.04, 0.03, 0.28))

	var main_color: Color = Color("66706c") if not flash else Color("b9c2bd")
	var points: PackedVector2Array = PackedVector2Array([
		Vector2(-27, 13), Vector2(-19, -13), Vector2(-5, -25),
		Vector2(19, -18), Vector2(28, 3), Vector2(19, 20),
		Vector2(-8, 24)
	])

	draw_colored_polygon(points, main_color)
	draw_polyline(
		PackedVector2Array([Vector2(-18, -11), Vector2(-4, -4), Vector2(-8, 19)]),
		Color("8c9691"),
		3.0
	)
	draw_polyline(
		PackedVector2Array([Vector2(-3, -23), Vector2(7, -8), Vector2(23, -3)]),
		Color("4c5551"),
		3.0
	)

func _draw_stick() -> void:
	draw_line(Vector2(-11, 5), Vector2(11, -5), Color("93613b"), 5.0)
	draw_line(Vector2(2, -1), Vector2(7, -9), Color("93613b"), 3.0)

func _draw_small_stone() -> void:
	var points: PackedVector2Array = PackedVector2Array([
		Vector2(-9, 4), Vector2(-5, -6), Vector2(4, -8),
		Vector2(10, -1), Vector2(6, 7), Vector2(-4, 8)
	])
	draw_colored_polygon(points, Color("7e8884"))

func _draw_vine() -> void:
	draw_arc(Vector2.ZERO, 9.0, -2.5, 2.2, 16, Color("4f8b4f"), 3.0)
	draw_arc(Vector2(5, 2), 6.0, -1.5, 2.6, 12, Color("65a85f"), 2.0)

func _draw_flat_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()

	for i in range(24):
		var angle: float = TAU * float(i) / 24.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))

	draw_colored_polygon(points, color)
