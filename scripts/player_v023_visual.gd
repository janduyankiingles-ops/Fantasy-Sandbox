extends Sprite2D

const CELL_SIZE: int = 64

const IDLE_DOWN: Texture2D = preload("res://assets/player_v023/idle_down.png")
const IDLE_LEFT: Texture2D = preload("res://assets/player_v023/idle_left.png")
const IDLE_UP: Texture2D = preload("res://assets/player_v023/idle_up.png")
const IDLE_RIGHT: Texture2D = preload("res://assets/player_v023/idle_right.png")

const WALK_DOWN: Texture2D = preload("res://assets/player_v023/walk_down.png")
const WALK_LEFT: Texture2D = preload("res://assets/player_v023/walk_left.png")
const WALK_UP: Texture2D = preload("res://assets/player_v023/walk_up.png")
const WALK_RIGHT: Texture2D = preload("res://assets/player_v023/walk_right.png")

const ATTACK_DOWN: Texture2D = preload("res://assets/player_v023/attack_down.png")
const ATTACK_LEFT: Texture2D = preload("res://assets/player_v023/attack_left.png")
const ATTACK_UP: Texture2D = preload("res://assets/player_v023/attack_up.png")
const ATTACK_RIGHT: Texture2D = preload("res://assets/player_v023/attack_right.png")

const GATHER_DOWN: Texture2D = preload("res://assets/player_v023/gather_down.png")
const GATHER_LEFT: Texture2D = preload("res://assets/player_v023/gather_left.png")
const GATHER_UP: Texture2D = preload("res://assets/player_v023/gather_up.png")
const GATHER_RIGHT: Texture2D = preload("res://assets/player_v023/gather_right.png")

var frame_cache: Dictionary = {}

var current_state: String = "idle"
var current_direction: String = "down"
var current_animation: String = "idle_down"
var current_frame: int = 0
var animation_clock: float = 0.0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	centered = true
	position = Vector2(0, -17)
	scale = Vector2(1.25, 1.25)
	z_index = 1

	_build_frame_cache()
	_apply_current_frame()

func _process(delta: float) -> void:
	var frame_count: int = _get_frame_count(current_state)
	if frame_count <= 1:
		return

	var fps: float = _get_fps(current_state)
	if fps <= 0.0:
		return

	animation_clock += delta
	var frame_duration: float = 1.0 / fps
	var changed: bool = false

	while animation_clock >= frame_duration:
		animation_clock -= frame_duration

		if _is_looping(current_state):
			current_frame = (current_frame + 1) % frame_count
		else:
			current_frame = mini(current_frame + 1, frame_count - 1)

		changed = true

	if changed:
		_apply_current_frame()

func set_visual_state(
	state_name: String,
	facing_vector: Vector2,
	_item_key: String = ""
) -> void:
	var direction_name: String = _get_direction_name(facing_vector)
	var final_state: String = state_name

	if final_state != "idle" and final_state != "walk" and final_state != "attack" and final_state != "gather":
		final_state = "idle"

	var desired_animation: String = final_state + "_" + direction_name

	if desired_animation == current_animation:
		return

	current_state = final_state
	current_direction = direction_name
	current_animation = desired_animation
	current_frame = 0
	animation_clock = 0.0
	_apply_current_frame()

func _build_frame_cache() -> void:
	frame_cache.clear()

	_add_strip("idle_down", IDLE_DOWN, 4)
	_add_strip("idle_left", IDLE_LEFT, 4)
	_add_strip("idle_up", IDLE_UP, 4)
	_add_strip("idle_right", IDLE_RIGHT, 4)

	_add_strip("walk_down", WALK_DOWN, 6)
	_add_strip("walk_left", WALK_LEFT, 6)
	_add_strip("walk_up", WALK_UP, 6)
	_add_strip("walk_right", WALK_RIGHT, 6)

	_add_strip("attack_down", ATTACK_DOWN, 4)
	_add_strip("attack_left", ATTACK_LEFT, 4)
	_add_strip("attack_up", ATTACK_UP, 4)
	_add_strip("attack_right", ATTACK_RIGHT, 4)

	_add_strip("gather_down", GATHER_DOWN, 4)
	_add_strip("gather_left", GATHER_LEFT, 4)
	_add_strip("gather_up", GATHER_UP, 4)
	_add_strip("gather_right", GATHER_RIGHT, 4)

func _add_strip(
	animation_name: String,
	strip_texture: Texture2D,
	frame_count: int
) -> void:
	var frames: Array[Texture2D] = []

	for index in range(frame_count):
		var frame_texture: AtlasTexture = AtlasTexture.new()
		frame_texture.atlas = strip_texture
		frame_texture.region = Rect2(
			float(index * CELL_SIZE),
			0.0,
			float(CELL_SIZE),
			float(CELL_SIZE)
		)
		frame_texture.filter_clip = true
		frames.append(frame_texture)

	frame_cache[animation_name] = frames

func _apply_current_frame() -> void:
	var value: Variant = frame_cache.get(current_animation, null)
	if value is not Array:
		return

	var source_frames: Array = value
	if source_frames.is_empty():
		return

	current_frame = clampi(current_frame, 0, source_frames.size() - 1)

	var frame_value: Variant = source_frames[current_frame]
	if frame_value is Texture2D:
		texture = frame_value as Texture2D

func _get_frame_count(state_name: String) -> int:
	if state_name == "walk":
		return 6
	return 4

func _get_fps(state_name: String) -> float:
	match state_name:
		"idle":
			return 4.0
		"walk":
			return 10.0
		"attack":
			return 17.0
		"gather":
			return 12.0
		_:
			return 4.0

func _is_looping(state_name: String) -> bool:
	return state_name == "idle" or state_name == "walk"

func _get_direction_name(direction: Vector2) -> String:
	if direction == Vector2.ZERO:
		return current_direction

	var abs_x: float = absf(direction.x)
	var abs_y: float = absf(direction.y)

	if abs_x > abs_y:
		return "right" if direction.x > 0.0 else "left"

	if abs_y > abs_x:
		return "down" if direction.y > 0.0 else "up"

	if current_direction == "left" and direction.x < 0.0:
		return "left"
	if current_direction == "right" and direction.x > 0.0:
		return "right"
	if current_direction == "up" and direction.y < 0.0:
		return "up"
	if current_direction == "down" and direction.y > 0.0:
		return "down"

	return "down" if direction.y > 0.0 else "up"
