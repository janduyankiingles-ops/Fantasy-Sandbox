extends AnimatedSprite2D

const ATLAS: Texture2D = preload("res://assets/player/player_atlas.png")
const CELL_WIDTH: int = 72
const CELL_HEIGHT: int = 81

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	position = Vector2(0, -17)
	z_index = 1
	_build_sprite_frames()
	play("idle_down")

func _build_sprite_frames() -> void:
	var frames: SpriteFrames = SpriteFrames.new()

	_add_direction_animations(frames, "down", 0)
	_add_direction_animations(frames, "right", 1)
	_add_direction_animations(frames, "up", 2)
	_add_direction_animations(frames, "left", 3)

	sprite_frames = frames

func _add_direction_animations(frames: SpriteFrames, direction_name: String, row: int) -> void:
	_add_animation(frames, "idle_" + direction_name, row, 0, 3, 3.0, true)
	_add_animation(frames, "walk_" + direction_name, row, 3, 4, 8.0, true)
	_add_animation(frames, "attack_" + direction_name, row, 7, 4, 18.0, false)
	_add_animation(frames, "gather_" + direction_name, row, 11, 4, 12.0, false)

func _add_animation(
	frames: SpriteFrames,
	animation_name: String,
	row: int,
	start_column: int,
	frame_count: int,
	fps: float,
	loop_animation: bool
) -> void:
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, fps)
	frames.set_animation_loop(animation_name, loop_animation)

	for index in range(frame_count):
		var atlas_frame: AtlasTexture = AtlasTexture.new()
		atlas_frame.atlas = ATLAS
		atlas_frame.region = Rect2(
			float((start_column + index) * CELL_WIDTH),
			float(row * CELL_HEIGHT),
			float(CELL_WIDTH),
			float(CELL_HEIGHT)
		)
		frames.add_frame(animation_name, atlas_frame)

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
