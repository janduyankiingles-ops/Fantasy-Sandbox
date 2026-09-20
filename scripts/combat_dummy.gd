extends StaticBody2D

@export var max_health: int = 20
@export var respawn_delay: float = 1.5

var current_health: int = 20
var flash_time: float = 0.0
var respawn_time_left: float = 0.0
var alive: bool = true

func _ready() -> void:
	add_to_group("damageable")
	current_health = max_health
	_create_collision()
	queue_redraw()

func _create_collision() -> void:
	var collision: CollisionShape2D = CollisionShape2D.new()
	collision.name = "CollisionShape2D"

	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(28, 42)
	collision.shape = shape
	collision.position = Vector2(0, -4)
	add_child(collision)

func _process(delta: float) -> void:
	if flash_time > 0.0:
		flash_time = maxf(0.0, flash_time - delta)
		queue_redraw()

	if not alive:
		respawn_time_left -= delta
		if respawn_time_left <= 0.0:
			alive = true
			current_health = max_health
			queue_redraw()

func take_damage(amount: int) -> void:
	if not alive or amount <= 0:
		return

	current_health = maxi(0, current_health - amount)
	flash_time = 0.12

	if current_health <= 0:
		alive = false
		respawn_time_left = respawn_delay

	queue_redraw()

func _draw() -> void:
	if not alive:
		draw_circle(Vector2(0, 12), 24.0, Color(0.08, 0.08, 0.08, 0.45))
		draw_line(Vector2(-18, -6), Vector2(18, 30), Color("8b2c2c"), 5.0)
		draw_line(Vector2(18, -6), Vector2(-18, 30), Color("8b2c2c"), 5.0)
		return

	var body_color: Color = Color("b77a45") if flash_time <= 0.0 else Color("f0d2b5")

	draw_circle(Vector2(0, 20), 20.0, Color(0.03, 0.03, 0.03, 0.28))
	draw_rect(Rect2(-13, -24, 26, 42), body_color, true)
	draw_circle(Vector2(0, -31), 12.0, Color("c9955d"))
	draw_line(Vector2(-26, -5), Vector2(26, -5), Color("8b5b34"), 6.0)
	draw_line(Vector2(-9, 18), Vector2(-14, 36), Color("704726"), 6.0)
	draw_line(Vector2(9, 18), Vector2(14, 36), Color("704726"), 6.0)

	# Barra de vida
	draw_rect(Rect2(-22, -54, 44, 6), Color(0.12, 0.12, 0.12, 0.9), true)
	var health_ratio: float = float(current_health) / float(max_health)
	draw_rect(Rect2(-21, -53, 42.0 * health_ratio, 4), Color("b83a3a"), true)
