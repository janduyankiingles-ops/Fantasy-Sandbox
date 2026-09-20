extends Node2D

const ResourceNodeScript = preload("res://scripts/resource_node.gd")

@export var world_size: int = 6144
@export var grid_size: int = 64

var resource_positions := [
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
	{"type": "rock", "pos": Vector2(-360, 390)}
]

func _ready() -> void:
	_spawn_resources()
	queue_redraw()

func _spawn_resources() -> void:
	for entry in resource_positions:
		var node := StaticBody2D.new()
		node.set_script(ResourceNodeScript)
		node.position = entry["pos"]
		node.set("resource_type", entry["type"])
		node.z_index = 2
		add_child(node)

func _draw() -> void:
	var half := world_size / 2.0
	draw_rect(Rect2(-half, -half, world_size, world_size), Color("263528"), true)

	var minor := Color(0.20, 0.30, 0.22, 0.45)
	var major := Color(0.28, 0.40, 0.30, 0.65)
	var start := -int(half)
	var finish := int(half)

	for x in range(start, finish + 1, grid_size):
		var color := major if x % (grid_size * 4) == 0 else minor
		draw_line(Vector2(x, -half), Vector2(x, half), color, 1.0)

	for y in range(start, finish + 1, grid_size):
		var color := major if y % (grid_size * 4) == 0 else minor
		draw_line(Vector2(-half, y), Vector2(half, y), color, 1.0)

	# Dirt patches make movement easier to perceive and start giving the map a world feel.
	for p in [Vector2(620, 180), Vector2(-710, 330), Vector2(250, -650), Vector2(-560, -570)]:
		draw_circle(p, 95.0, Color(0.28, 0.31, 0.20, 0.35))
