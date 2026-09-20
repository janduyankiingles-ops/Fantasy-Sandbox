extends StaticBody2D

@export_enum("tree", "rock") var resource_type: String = "tree"
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
	if resource_type == "rock":
		hit_points = 4
		amount_per_hit = 1
		final_bonus = 2
	else:
		hit_points = 3
		amount_per_hit = 1
		final_bonus = 2

func _create_collision() -> void:
	if get_node_or_null("CollisionShape2D") != null:
		return
	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	var shape := CircleShape2D.new()
	shape.radius = 23.0 if resource_type == "rock" else 18.0
	collision.shape = shape
	collision.position = Vector2(0, 4 if resource_type == "rock" else 14)
	add_child(collision)

func _process(delta: float) -> void:
	if flash_time > 0.0:
		flash_time = maxf(0.0, flash_time - delta)
		queue_redraw()

func harvest() -> Dictionary:
	if current_hit_points <= 0:
		return {"type": resource_type, "amount": 0}

	current_hit_points -= 1
	flash_time = 0.10
	var amount := amount_per_hit
	if current_hit_points <= 0:
		amount += final_bonus
		call_deferred("queue_free")

	queue_redraw()
	return {"type": resource_type, "amount": amount}

func get_interaction_text() -> String:
	var label := "Árvore" if resource_type == "tree" else "Pedra"
	return "E - Coletar %s  (%d/%d)" % [label, current_hit_points, hit_points]

func _draw() -> void:
	var flash := flash_time > 0.0
	if resource_type == "rock":
		_draw_rock(flash)
	else:
		_draw_tree(flash)

func _draw_tree(flash: bool) -> void:
	# Shadow
	draw_ellipse(Vector2(0, 27), Vector2(30, 11), Color(0.03, 0.04, 0.03, 0.30))
	# Trunk
	draw_rect(Rect2(-7, 4, 14, 34), Color("7b4a2d") if not flash else Color("d6b08d"), true)
	draw_rect(Rect2(-4, 7, 4, 29), Color("9b6540"), true)
	# Crown
	var leaf := Color("315f36") if not flash else Color("91b895")
	draw_circle(Vector2(-15, -7), 23.0, leaf)
	draw_circle(Vector2(13, -10), 25.0, leaf.darkened(0.08))
	draw_circle(Vector2(0, -28), 27.0, leaf.lightened(0.04))
	draw_circle(Vector2(0, -7), 28.0, leaf)

func _draw_rock(flash: bool) -> void:
	draw_ellipse(Vector2(0, 20), Vector2(31, 10), Color(0.03, 0.04, 0.03, 0.28))
	var main_color := Color("66706c") if not flash else Color("b9c2bd")
	var points := PackedVector2Array([
		Vector2(-27, 13), Vector2(-19, -13), Vector2(-5, -25),
		Vector2(19, -18), Vector2(28, 3), Vector2(19, 20),
		Vector2(-8, 24)
	])
	draw_colored_polygon(points, main_color)
	draw_polyline(PackedVector2Array([Vector2(-18,-11), Vector2(-4,-4), Vector2(-8,19)]), Color("8c9691"), 3.0)
	draw_polyline(PackedVector2Array([Vector2(-3,-23), Vector2(7,-8), Vector2(23,-3)]), Color("4c5551"), 3.0)

func draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(24):
		var a := TAU * float(i) / 24.0
		points.append(center + Vector2(cos(a) * radius.x, sin(a) * radius.y))
	draw_colored_polygon(points, color)
