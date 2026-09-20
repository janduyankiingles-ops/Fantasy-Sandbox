extends Node2D

@export var move_speed: float = 170.0

@onready var modular_player: Node2D = $ModularPlayer
@onready var direction_label: Label = $DirectionLabel as Label

func _ready() -> void:
	queue_redraw()

func _process(delta: float) -> void:
	var left: bool = Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)
	var right: bool = Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)
	var up: bool = Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
	var down: bool = Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)

	var input_vector: Vector2 = Vector2(
		float(int(right) - int(left)),
		float(int(down) - int(up))
	)

	if input_vector.length_squared() > 1.0:
		input_vector = input_vector.normalized()

	modular_player.position += input_vector * move_speed * delta
	modular_player.position.x = clampf(modular_player.position.x, 100.0, 1180.0)
	modular_player.position.y = clampf(modular_player.position.y, 150.0, 620.0)
	modular_player.call("set_move_input", input_vector)
	_update_direction_label()

	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://scenes/main.tscn")

func _update_direction_label() -> void:
	var direction_name: String = str(modular_player.call("get_facing_direction"))
	var translated_name: String = "BAIXO"

	match direction_name:
		"up":
			translated_name = "CIMA"
		"left":
			translated_name = "ESQUERDA"
		"right":
			translated_name = "DIREITA"

	direction_label.text = "Direção visual: " + translated_name

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1280, 720), Color("1d2b22"), true)

	var grid_color: Color = Color(0.18, 0.27, 0.21, 0.45)
	for x in range(0, 1281, 32):
		draw_line(Vector2(x, 0), Vector2(x, 720), grid_color, 1.0)
	for y in range(0, 721, 32):
		draw_line(Vector2(0, y), Vector2(1280, y), grid_color, 1.0)

	draw_rect(Rect2(82, 132, 1116, 506), Color(0.04, 0.06, 0.05, 0.22), false, 2.0)
