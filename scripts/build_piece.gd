extends StaticBody2D

var piece_type: String = "floor"
var rotation_quarters: int = 0

func setup(new_piece_type: String, new_rotation_quarters: int) -> void:
	piece_type = new_piece_type
	rotation_quarters = posmod(new_rotation_quarters, 4)
	rotation = float(rotation_quarters) * PI / 2.0

func _ready() -> void:
	add_to_group("build_pieces")
	_create_collision()
	queue_redraw()

func _create_collision() -> void:
	if piece_type == "floor":
		return

	if piece_type == "wall":
		var collision: CollisionShape2D = CollisionShape2D.new()
		var shape: RectangleShape2D = RectangleShape2D.new()
		shape.size = Vector2(62, 14)
		collision.shape = shape
		add_child(collision)
		return

	if piece_type == "door":
		_create_door_post(Vector2(-24, 0))
		_create_door_post(Vector2(24, 0))

func _create_door_post(local_position: Vector2) -> void:
	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(14, 16)
	collision.shape = shape
	collision.position = local_position
	add_child(collision)

func _draw() -> void:
	match piece_type:
		"floor":
			_draw_floor()
		"wall":
			_draw_wall()
		"door":
			_draw_door()

func _draw_floor() -> void:
	draw_rect(Rect2(-30, -30, 60, 60), Color("8b633f"), true)
	draw_rect(Rect2(-30, -30, 60, 60), Color("513a27"), false, 2.0)

	for y in [-18.0, -6.0, 6.0, 18.0]:
		draw_line(Vector2(-28, y), Vector2(28, y), Color("a77a50"), 2.0)

func _draw_wall() -> void:
	draw_rect(Rect2(-31, -8, 62, 16), Color("6d4a31"), true)
	draw_rect(Rect2(-31, -8, 62, 16), Color("36271d"), false, 2.0)

	for x in [-22.0, -8.0, 8.0, 22.0]:
		draw_line(Vector2(x, -7), Vector2(x, 7), Color("9b7048"), 3.0)

func _draw_door() -> void:
	draw_rect(Rect2(-31, -9, 14, 18), Color("5f422d"), true)
	draw_rect(Rect2(17, -9, 14, 18), Color("5f422d"), true)
	draw_rect(Rect2(-31, -9, 62, 7), Color("7d5737"), true)
	draw_line(Vector2(-15, 8), Vector2(15, 8), Color("c39a62"), 2.0)
