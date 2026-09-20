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

var current_state: String = "idle"
var current_direction: String = "down"
var current_animation_name: String = ""
var animation_clock: float = 0.0
var animation_frame_index: int = 0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	centered = true
	position = Vector2(0, -17)
	scale = Vector2(1.25, 1.25)
	z_index = 1

	_build_sprite_frames()
	_switch_animation("idle", "down")

func _process(delta: float) -> void:
	_advance_animation(delta)

func _build_sprite_frames() -> void:
	var frames: SpriteFrames = SpriteFrames.new()

	if frames.has_animation("default"):
		frames.remove_animation("default")

	# Ordem das linhas nas folhas Idle/Walk:
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
		var frame_texture: AtlasTexture = _make_frame_texture(
			sheet,
			Rect2(
				float(index * CELL_SIZE),
				float(row * CELL_SIZE),
				float(CELL_SIZE),
				float(CELL_SIZE)
			)
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
		var frame_texture: AtlasTexture = _make_frame_texture(
			sheet,
			Rect2(
				float(index * CELL_SIZE),
				0.0,
				float(CELL_SIZE),
				float(CELL_SIZE)
			)
		)
		frames.add_frame(animation_name, frame_texture)

func _make_frame_texture(sheet: Texture2D, frame_region: Rect2) -> AtlasTexture:
	var frame_texture: AtlasTexture = AtlasTexture.new()
	frame_texture.atlas = sheet
	frame_texture.region = frame_region

	# Impede que pixels do quadro vizinho apareçam nas bordas quando
	# o atlas é escalado.
	frame_texture.filter_clip = true

	return frame_texture

func set_visual_state(state_name: String, facing_direction: Vector2) -> void:
	var direction_name: String = _get_direction_name(facing_direction)
	var final_state: String = state_name
	var desired_animation: String = final_state + "_" + direction_name

	if not sprite_frames.has_animation(desired_animation):
		final_state = "idle"
		desired_animation = "idle_" + direction_name

	if final_state == current_state and direction_name == current_direction:
		return

	_switch_animation(final_state, direction_name)

func _switch_animation(state_name: String, direction_name: String) -> void:
	var desired_animation: String = state_name + "_" + direction_name

	if not sprite_frames.has_animation(desired_animation):
		state_name = "idle"
		desired_animation = "idle_" + direction_name

	current_state = state_name
	current_direction = direction_name
	current_animation_name = desired_animation
	animation_clock = 0.0
	animation_frame_index = 0

	# A animação é avançada manualmente em _process().
	# Assim não dependemos do estado interno de play/pause do AnimatedSprite2D.
	stop()
	animation = current_animation_name
	frame = 0

func _advance_animation(delta: float) -> void:
	if current_animation_name.is_empty():
		return
	if sprite_frames == null:
		return
	if not sprite_frames.has_animation(current_animation_name):
		return

	var frame_count: int = sprite_frames.get_frame_count(current_animation_name)
	if frame_count <= 1:
		frame = 0
		return

	var fps: float = sprite_frames.get_animation_speed(current_animation_name)
	if fps <= 0.0:
		return

	var frame_duration: float = 1.0 / fps
	animation_clock += delta

	while animation_clock >= frame_duration:
		animation_clock -= frame_duration

		if sprite_frames.get_animation_loop(current_animation_name):
			animation_frame_index = (animation_frame_index + 1) % frame_count
		else:
			animation_frame_index = mini(animation_frame_index + 1, frame_count - 1)

		frame = animation_frame_index

func _get_direction_name(direction: Vector2) -> String:
	if direction == Vector2.ZERO:
		return current_direction

	var abs_x: float = absf(direction.x)
	var abs_y: float = absf(direction.y)

	if abs_x > abs_y + 0.05:
		return "right" if direction.x > 0.0 else "left"

	if abs_y > abs_x + 0.05:
		return "down" if direction.y > 0.0 else "up"

	# Em diagonais perfeitas, mantém a direção visual anterior enquanto
	# ela ainda fizer parte do movimento.
	if current_direction == "left" and direction.x < 0.0:
		return "left"
	if current_direction == "right" and direction.x > 0.0:
		return "right"
	if current_direction == "up" and direction.y < 0.0:
		return "up"
	if current_direction == "down" and direction.y > 0.0:
		return "down"

	return "down" if direction.y > 0.0 else "up"
