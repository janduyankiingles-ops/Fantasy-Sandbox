extends Node2D

const ResourceNodeScript = preload("res://scripts/resource_node.gd")

@export var world_size: int = 6144
@export var grid_size: int = 64

var resource_positions: Array[Dictionary] = [
	# Recursos grandes
	{"type": "tree", "pos": Vector2(260, 120)},
	{"type": "tree", "pos": Vector2(390, -90)},
	{"type": "tree", "pos": Vector2(-290, 180)},
	{"type": "tree", "pos": Vector2(-430, -210)},
	{"type": "tree", "pos": Vector2(90, -390)},
	{"type": "tree", "pos": Vector2(540, 330)},
	{"type": "rock", "pos": Vector2(160, 260)},
	{"type": "rock", "pos": Vector2(-170, -260)},
	{"type": "rock", "pos": Vector2(470, -300)},
	{"type": "rock", "pos": Vector2(-520, 90)},
	{"type": "rock", "pos": Vector2(-360, 390)},

	# Kit inicial espalhado no chão
	{"type": "stick", "pos": Vector2(75, 45)},
	{"type": "stick", "pos": Vector2(-90, 55)},
	{"type": "stick", "pos": Vector2(120, -70)},
	{"type": "stick", "pos": Vector2(-135, -80)},
	{"type": "stick", "pos": Vector2(30, 145)},
	{"type": "stick", "pos": Vector2(185, 35)},
	{"type": "stick", "pos": Vector2(-190, 20)},
	{"type": "stick", "pos": Vector2(210, -150)},

	{"type": "small_stone", "pos": Vector2(55, -115)},
	{"type": "small_stone", "pos": Vector2(-50, 125)},
	{"type": "small_stone", "pos": Vector2(155, 105)},
	{"type": "small_stone", "pos": Vector2(-165, -135)},
	{"type": "small_stone", "pos": Vector2(225, 75)},
	{"type": "small_stone", "pos": Vector2(-230, 155)},
	{"type": "small_stone", "pos": Vector2(105, 205)},
	{"type": "small_stone", "pos": Vector2(-110, -215)},

	{"type": "vine", "pos": Vector2(10, -155)},
	{"type": "vine", "pos": Vector2(-145, 5)},
	{"type": "vine", "pos": Vector2(145, 165)},
	{"type": "vine", "pos": Vector2(-215, -35)},
	{"type": "vine", "pos": Vector2(245, -85)},
	{"type": "vine", "pos": Vector2(-80, 230)}
]

func _ready() -> void:
	_spawn_resources()
	queue_redraw()

func _spawn_resources() -> void:
	for entry in resource_positions:
		var position_value: Variant = entry.get("pos", Vector2.ZERO)
		var type_name: String = str(entry.get("type", ""))

		if position_value is not Vector2:
			continue

		var node: StaticBody2D = StaticBody2D.new()
		node.set_script(ResourceNodeScript)
		node.position = position_value
		node.set("resource_type", type_name)
		node.z_index = 2
		add_child(node)

func _draw() -> void:
	var half: float = world_size / 2.0
	draw_rect(Rect2(-half, -half, world_size, world_size), Color("263528"), true)

	var minor: Color = Color(0.20, 0.30, 0.22, 0.45)
	var major: Color = Color(0.28, 0.40, 0.30, 0.65)
	var start: int = -int(half)
	var finish: int = int(half)

	for x in range(start, finish + 1, grid_size):
		var line_color: Color = major if x % (grid_size * 4) == 0 else minor
		draw_line(Vector2(x, -half), Vector2(x, half), line_color, 1.0)

	for y in range(start, finish + 1, grid_size):
		var line_color: Color = major if y % (grid_size * 4) == 0 else minor
		draw_line(Vector2(-half, y), Vector2(half, y), line_color, 1.0)

	for patch_position in [
		Vector2(620, 180),
		Vector2(-710, 330),
		Vector2(250, -650),
		Vector2(-560, -570)
	]:
		draw_circle(patch_position, 95.0, Color(0.28, 0.31, 0.20, 0.35))
