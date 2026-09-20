extends CharacterBody2D

@export var max_health: int = 24
@export var move_speed: float = 115.0
@export var detection_range: float = 300.0
@export var disengage_range: float = 430.0
@export var attack_range: float = 48.0
@export var attack_damage: int = 8
@export var attack_cooldown: float = 1.1
@export var wander_radius: float = 130.0

var current_health: int = 24
var alive: bool = true
var flash_time: float = 0.0
var attack_cooldown_left: float = 0.0
var home_position: Vector2 = Vector2.ZERO
var wander_target: Vector2 = Vector2.ZERO
var wander_time_left: float = 0.0
var chasing: bool = false
var player_target: CharacterBody2D = null
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	add_to_group("damageable")
	add_to_group("wolves")
	current_health = max_health
	home_position = global_position
	rng.randomize()
	_find_player()
	_choose_wander_target()
	_create_collision()
	queue_redraw()

func _create_collision() -> void:
	var collision: CollisionShape2D = CollisionShape2D.new()
	collision.name = "CollisionShape2D"

	var shape: CapsuleShape2D = CapsuleShape2D.new()
	shape.radius = 13.0
	shape.height = 34.0
	collision.shape = shape
	collision.position = Vector2(0, 5)
	add_child(collision)

func _physics_process(delta: float) -> void:
	if not alive:
		velocity = Vector2.ZERO
		return

	if flash_time > 0.0:
		flash_time = maxf(0.0, flash_time - delta)

	attack_cooldown_left = maxf(0.0, attack_cooldown_left - delta)

	if player_target == null or not is_instance_valid(player_target):
		_find_player()

	if player_target == null:
		_wander(delta)
		move_and_slide()
		queue_redraw()
		return

	var distance_to_player: float = global_position.distance_to(player_target.global_position)

	if chasing:
		if distance_to_player > disengage_range:
			chasing = false
			_choose_wander_target()
	else:
		if distance_to_player <= detection_range:
			chasing = true

	if chasing:
		_chase_player(distance_to_player)
	else:
		_wander(delta)

	move_and_slide()
	queue_redraw()

func _find_player() -> void:
	var candidate: Node = get_tree().get_first_node_in_group("player")
	if candidate is CharacterBody2D:
		player_target = candidate

func _chase_player(distance_to_player: float) -> void:
	if player_target == null:
		return

	if distance_to_player <= attack_range:
		velocity = Vector2.ZERO
		_try_attack()
		return

	var direction: Vector2 = (player_target.global_position - global_position).normalized()
	velocity = direction * move_speed

func _try_attack() -> void:
	if attack_cooldown_left > 0.0:
		return
	if player_target == null or not player_target.has_method("take_damage"):
		return

	player_target.call("take_damage", attack_damage)
	attack_cooldown_left = attack_cooldown

func _wander(delta: float) -> void:
	wander_time_left -= delta

	if wander_time_left <= 0.0 or global_position.distance_to(wander_target) <= 12.0:
		_choose_wander_target()

	var offset: Vector2 = wander_target - global_position
	if offset.length() <= 8.0:
		velocity = Vector2.ZERO
		return

	velocity = offset.normalized() * (move_speed * 0.45)

func _choose_wander_target() -> void:
	var angle: float = rng.randf_range(0.0, TAU)
	var distance: float = rng.randf_range(35.0, wander_radius)
	wander_target = home_position + Vector2(cos(angle), sin(angle)) * distance
	wander_time_left = rng.randf_range(2.0, 4.5)

func take_damage(amount: int) -> void:
	if not alive or amount <= 0:
		return

	current_health = maxi(0, current_health - amount)
	flash_time = 0.12
	chasing = true

	if current_health <= 0:
		_die()

	queue_redraw()

func _die() -> void:
	alive = false
	velocity = Vector2.ZERO
	remove_from_group("damageable")

	var collision: CollisionShape2D = get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision != null:
		collision.set_deferred("disabled", true)

func is_dead() -> bool:
	return not alive

func _draw() -> void:
	if not alive:
		_draw_corpse()
		return

	var body_color: Color = Color("6f7376") if flash_time <= 0.0 else Color("d9d9d9")
	var dark_color: Color = Color("3d4144")

	draw_circle(Vector2(0, 14), 19.0, Color(0.03, 0.03, 0.03, 0.28))
	draw_ellipse_shape(Vector2(0, 0), Vector2(25, 14), body_color)
	draw_circle(Vector2(19, -5), 11.0, body_color)

	var ear_left: PackedVector2Array = PackedVector2Array([
		Vector2(12, -12), Vector2(14, -25), Vector2(20, -14)
	])
	var ear_right: PackedVector2Array = PackedVector2Array([
		Vector2(20, -13), Vector2(27, -23), Vector2(29, -9)
	])
	draw_colored_polygon(ear_left, dark_color)
	draw_colored_polygon(ear_right, dark_color)

	draw_line(Vector2(-22, -1), Vector2(-34, -11), dark_color, 6.0)
	draw_line(Vector2(-13, 10), Vector2(-16, 25), dark_color, 5.0)
	draw_line(Vector2(10, 10), Vector2(13, 25), dark_color, 5.0)
	draw_circle(Vector2(23, -7), 2.0, Color("e7c84c"))
	draw_circle(Vector2(30, -2), 2.5, Color("222222"))

	draw_rect(Rect2(-22, -31, 44, 6), Color(0.12, 0.12, 0.12, 0.9), true)
	var ratio: float = float(current_health) / float(max_health)
	draw_rect(Rect2(-21, -30, 42.0 * ratio, 4), Color("b83a3a"), true)

func _draw_corpse() -> void:
	draw_ellipse_shape(Vector2(0, 8), Vector2(27, 12), Color("4e5052"))
	draw_circle(Vector2(21, 7), 10.0, Color("4e5052"))
	draw_line(Vector2(-10, 2), Vector2(15, 15), Color("7b2626"), 4.0)

func draw_ellipse_shape(center: Vector2, radius: Vector2, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()

	for index in range(24):
		var angle: float = TAU * float(index) / 24.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))

	draw_colored_polygon(points, color)
