extends AnimatedSprite2D

const IDLE_SHEET: Texture2D = preload("res://assets/player/idle.png")
const WALK_SHEET: Texture2D = preload("res://assets/player/walk.png")

const ATTACK_DOWN: Texture2D = preload("res://assets/player/attack_down.png")
const ATTACK_LEFT: Texture2D = preload("res://assets/player/attack_left.png")
const ATTACK_UP: Texture2D = preload("res://assets/player/attack_up.png")
const ATTACK_RIGHT: Texture2D = preload("res://assets/player/attack_right.png")

const GATHER_DOWN: Texture2D = preload("res://assets/player/gather_down.png")
const GATHER_LEFT: Texture2D = preload("res://assets/player/gather_left.png")
const GATHER_UP: Texture2D = preload("res://assets/player/gather_up.png")
const GATHER_RIGHT: Texture2D = preload("res://assets/player/gather_right.png")

const CELL_SIZE: int = 64

var current_state: String = ""
var current_direction: String = "down"

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	position = Vector2(0, -17)
	scale = Vector2(1.2, 1.2)
	z_index = 1
	_build_sprite_frames()
	current_state = "idle"
	current_direction = "down"
	play("idle_down")

func _build_sprite_frames() -> void:
	var frames: SpriteFrames = SpriteFrames.new()

	# Ordem das linhas das folhas Idle/Walk:
	# 0 = frente, 1 = esquerda, 2 = costas, 3 = direita.
	_add_direction_animations(frames, "down", 0, ATTACK_DOWN, GATHER_DOWN)
	_add_direction_animations(frames, "left", 1, ATTACK_LEFT, GATHER_LEFT)
	_add_direction_animations(frames, "up", 2, ATTACK_UP, GATHER_UP)
	_add_direction_animations(frames, "right", 3, ATTACK_RIGHT, GATHER_RIGHT)

	sprite_frames = frames

func _add_direction_animations(
	frames: SpriteFrames,
	direction_name: String,
	row: int,
	attack_sheet: Texture2D,
	gather_sheet: Texture2D
) -> void:
	_add_sheet_animation(
		frames,
		"idle_" + direction_name,
		IDLE_SHEET,
		row,
		4,
		4.0,
		true
	)
	_add_sheet_animation(
		frames,
		"walk_" + direction_name,
		WALK_SHEET,
		row,
		6,
		10.0,
		true
	)
	_add_row_animation(
		frames,
		"attack_" + direction_name,
		attack_sheet,
		6,
		26.0,
		false
	)
	_add_row_animation(
		frames,
		"gather_" + direction_name,
		gather_sheet,
		5,
		15.0,
		false
	)

func _add_sheet_animation(
	frames: SpriteFrames,
	animation_name: String,
	sheet: Texture2D,
	row: int,
	frame_count: int,
	fps: float,
	loop_animation: bool
) -> void:
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, fps)
	frames.set_animation_loop(animation_name, loop_animation)

	for index in range(frame_count):
		var frame_texture: AtlasTexture = AtlasTexture.new()
		frame_texture.atlas = sheet
		frame_texture.region = Rect2(
			float(index * CELL_SIZE),
			float(row * CELL_SIZE),
			float(CELL_SIZE),
			float(CELL_SIZE)
		)
		frames.add_frame(animation_name, frame_texture)

func _add_row_animation(
	frames: SpriteFrames,
	animation_name: String,
	sheet: Texture2D,
	frame_count: int,
	fps: float,
	loop_animation: bool
) -> void:
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, fps)
	frames.set_animation_loop(animation_name, loop_animation)

	for index in range(frame_count):
		var frame_texture: AtlasTexture = AtlasTexture.new()
		frame_texture.atlas = sheet
		frame_texture.region = Rect2(
			float(index * CELL_SIZE),
			0.0,
			float(CELL_SIZE),
			float(CELL_SIZE)
		)
		frames.add_frame(animation_name, frame_texture)

func set_visual_state(state_name: String, facing_direction: Vector2) -> void:
	var direction_name: String = _get_direction_name(facing_direction)
	var final_state: String = state_name
	var desired_animation: String = final_state + "_" + direction_name

	if not sprite_frames.has_animation(desired_animation):
		final_state = "idle"
		desired_animation = "idle_" + direction_name

	# Não reinicia a animação a cada frame.
	# Enquanto estado e direção não mudarem, o AnimatedSprite2D continua
	# avançando normalmente pelos frames atuais.
	if final_state == current_state and direction_name == current_direction:
		return

	current_state = final_state
	current_direction = direction_name
	play(desired_animation)

func _get_direction_name(direction: Vector2) -> String:
	if direction == Vector2.ZERO:
		return current_direction

	var abs_x: float = absf(direction.x)
	var abs_y: float = absf(direction.y)

	if abs_x > abs_y + 0.05:
		return "right" if direction.x > 0.0 else "left"

	if abs_y > abs_x + 0.05:
		return "down" if direction.y > 0.0 else "up"

	# Em diagonais perfeitas, preserva a direção anterior somente quando
	# ela ainda faz parte do movimento atual. Isso evita piscar entre
	# duas animações enquanto duas teclas permanecem pressionadas.
	if current_direction == "left" and direction.x < 0.0:
		return "left"
	if current_direction == "right" and direction.x > 0.0:
		return "right"
	if current_direction == "up" and direction.y < 0.0:
		return "up"
	if current_direction == "down" and direction.y > 0.0:
		return "down"

	return "down" if direction.y > 0.0 else "up"
