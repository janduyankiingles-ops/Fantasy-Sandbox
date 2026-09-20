extends AnimatedSprite2D

const IDLE_SHEET: Texture2D = preload("res://assets/player/idle.png")
const WALK_SHEET: Texture2D = preload("res://assets/player/walk.png")
const ATTACK_SHEET: Texture2D = preload("res://assets/player/attack.png")
const GATHER_SHEET: Texture2D = preload("res://assets/player/gather.png")

const CELL_SIZE: int = 44

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	position = Vector2(0, -17)
	scale = Vector2(1.75, 1.75)
	z_index = 1
	_build_sprite_frames()
	play("idle_down")

func _build_sprite_frames() -> void:
	var frames: SpriteFrames = SpriteFrames.new()

	# Ordem real das linhas nas folhas:
	# 0 = frente, 1 = esquerda, 2 = costas, 3 = direita.
	_add_direction_animations(frames, "down", 0)
	_add_direction_animations(frames, "left", 1)
	_add_direction_animations(frames, "up", 2)
	_add_direction_animations(frames, "right", 3)

	sprite_frames = frames

func _add_direction_animations(
	frames: SpriteFrames,
	direction_name: String,
	row: int
) -> void:
	_add_animation(frames, "idle_" + direction_name, IDLE_SHEET, row, 4, 4.0, true)
	_add_animation(frames, "walk_" + direction_name, WALK_SHEET, row, 6, 10.0, true)
	_add_animation(frames, "attack_" + direction_name, ATTACK_SHEET, row, 6, 26.0, false)
	_add_animation(frames, "gather_" + direction_name, GATHER_SHEET, row, 5, 15.0, false)

func _add_animation(
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

func set_visual_state(state_name: String, facing_direction: Vector2) -> void:
	var direction_name: String = _get_direction_name(facing_direction)
	var desired_animation: String = state_name + "_" + direction_name

	if not sprite_frames.has_animation(desired_animation):
		desired_animation = "idle_" + direction_name

	if animation != desired_animation:
		play(desired_animation)
	elif not is_playing() and (state_name == "idle" or state_name == "walk"):
		play(desired_animation)

func _get_direction_name(direction: Vector2) -> String:
	if direction == Vector2.ZERO:
		return "down"

	if absf(direction.x) > absf(direction.y):
		return "right" if direction.x > 0.0 else "left"

	return "down" if direction.y > 0.0 else "up"
