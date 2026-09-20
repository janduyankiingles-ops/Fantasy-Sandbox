extends Node2D

const IDLE_SHEET: Texture2D = preload("res://assets/player/idle.png")
const WALK_SHEET: Texture2D = preload("res://assets/player/walk.png")

const CELL_SIZE: int = 64
const ALPHA_CUTOFF: float = 0.06
const TARGET_CENTER_X: float = 32.0
const TARGET_BOTTOM_Y: int = 62

@onready var sprite: Sprite2D = $Sprite as Sprite2D
@onready var tool: Node2D = $Tool as Node2D

var frames_by_animation: Dictionary = {}
var current_state: String = "idle"
var current_direction: String = "down"
var selected_item_key: String = ""
var animation_clock: float = 0.0
var current_frame: int = 0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	scale = Vector2(1.25, 1.25)
	position = Vector2(0, -17)

	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.centered = true

	_build_original_sprite_frames()
	_apply_frame("idle_down", 0)
	tool.call("set_facing", "down")
	tool.call("set_tool", "none", 0)

func set_visual_state(
	state_name: String,
	facing_vector: Vector2,
	item_key: String = ""
) -> void:
	var direction_name: String = _direction_from_vector(facing_vector)
	var changed: bool = false

	if state_name != current_state:
		current_state = state_name
		animation_clock = 0.0
		current_frame = 0
		changed = true

	if direction_name != current_direction:
		current_direction = direction_name
		animation_clock = 0.0
		current_frame = 0
		tool.call("set_facing", current_direction)
		changed = true

	if item_key != selected_item_key:
		selected_item_key = item_key
		changed = true

	if changed:
		_refresh_immediately()

func _process(delta: float) -> void:
	match current_state:
		"walk":
			_advance_loop(delta, "walk_" + current_direction, 10.0)
		"attack":
			_animate_action(delta, 0.23, false)
		"gather":
			_animate_action(delta, 0.34, true)
		_:
			_advance_loop(delta, "idle_" + current_direction, 4.0)

func _build_original_sprite_frames() -> void:
	frames_by_animation.clear()

	var idle_image: Image = IDLE_SHEET.get_image()
	var walk_image: Image = WALK_SHEET.get_image()

	if idle_image.get_format() != Image.FORMAT_RGBA8:
		idle_image.convert(Image.FORMAT_RGBA8)
	if walk_image.get_format() != Image.FORMAT_RGBA8:
		walk_image.convert(Image.FORMAT_RGBA8)

	_add_sheet_row("idle_down", idle_image, 0, 4)
	_add_sheet_row("idle_left", idle_image, 1, 4)
	_add_sheet_row("idle_up", idle_image, 2, 4)
	_add_sheet_row("idle_right", idle_image, 3, 4)

	_add_sheet_row("walk_down", walk_image, 0, 6)
	_add_sheet_row("walk_left", walk_image, 1, 6)
	_add_sheet_row("walk_up", walk_image, 2, 6)
	_add_sheet_row("walk_right", walk_image, 3, 6)

func _add_sheet_row(
	animation_name: String,
	source_image: Image,
	row: int,
	frame_count: int
) -> void:
	var result_frames: Array[Texture2D] = []

	for column in range(frame_count):
		var source_rect: Rect2i = Rect2i(
			column * CELL_SIZE,
			row * CELL_SIZE,
			CELL_SIZE,
			CELL_SIZE
		)
		var source_frame: Image = source_image.get_region(source_rect)
		var aligned_frame: Image = _clean_and_align_frame(source_frame)
		var frame_texture: ImageTexture = ImageTexture.create_from_image(aligned_frame)
		result_frames.append(frame_texture)

	frames_by_animation[animation_name] = result_frames

func _clean_and_align_frame(source_frame: Image) -> Image:
	if source_frame.get_format() != Image.FORMAT_RGBA8:
		source_frame.convert(Image.FORMAT_RGBA8)

	var clean_frame: Image = source_frame.duplicate()

	var min_x: int = CELL_SIZE
	var min_y: int = CELL_SIZE
	var max_x: int = -1
	var max_y: int = -1

	for y in range(CELL_SIZE):
		for x in range(CELL_SIZE):
			var pixel: Color = clean_frame.get_pixel(x, y)

			if pixel.a < ALPHA_CUTOFF:
				clean_frame.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
				continue

			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)

	if max_x < 0 or max_y < 0:
		return clean_frame

	# O sprite original muda de posição dentro de cada célula.
	# Recentralizamos a silhueta inteira e mantemos os pés na mesma linha.
	var visible_center_x: float = (
		float(min_x) + float(max_x)
	) * 0.5

	var offset_x: int = roundi(TARGET_CENTER_X - visible_center_x)
	var offset_y: int = TARGET_BOTTOM_Y - max_y

	var aligned_frame: Image = Image.create(
		CELL_SIZE,
		CELL_SIZE,
		false,
		Image.FORMAT_RGBA8
	)
	aligned_frame.fill(Color(0.0, 0.0, 0.0, 0.0))

	for y in range(CELL_SIZE):
		for x in range(CELL_SIZE):
			var pixel: Color = clean_frame.get_pixel(x, y)
			if pixel.a < ALPHA_CUTOFF:
				continue

			var target_x: int = x + offset_x
			var target_y: int = y + offset_y

			if target_x < 0 or target_x >= CELL_SIZE:
				continue
			if target_y < 0 or target_y >= CELL_SIZE:
				continue

			aligned_frame.set_pixel(target_x, target_y, pixel)

	return aligned_frame

func _advance_loop(delta: float, animation_name: String, fps: float) -> void:
	var frames: Array[Texture2D] = _get_frames(animation_name)
	if frames.is_empty():
		return

	animation_clock += delta
	var frame_duration: float = 1.0 / fps

	while animation_clock >= frame_duration:
		animation_clock -= frame_duration
		current_frame = (current_frame + 1) % frames.size()

	_apply_texture(frames[current_frame])
	sprite.position = Vector2.ZERO
	tool.call("set_tool", "none", 0)

func _animate_action(delta: float, duration: float, gathering: bool) -> void:
	animation_clock += delta

	var idle_frames: Array[Texture2D] = _get_frames(
		"idle_" + current_direction
	)
	if not idle_frames.is_empty():
		_apply_texture(idle_frames[0])

	var progress: float = clampf(animation_clock / duration, 0.0, 1.0)
	var pose: int = 0

	if progress >= 0.66:
		pose = 2
	elif progress >= 0.28:
		pose = 1

	var lunge: int = 0
	if pose == 1:
		lunge = 2
	elif pose == 2:
		lunge = 1

	sprite.position = _direction_vector(current_direction) * float(lunge)

	var tool_kind: String = _get_tool_kind(gathering)
	tool.call("set_tool", tool_kind, pose)

func _refresh_immediately() -> void:
	var animation_name: String = "idle_" + current_direction

	if current_state == "walk":
		animation_name = "walk_" + current_direction

	_apply_frame(animation_name, 0)
	sprite.position = Vector2.ZERO

	if current_state == "attack":
		tool.call("set_tool", _get_tool_kind(false), 0)
	elif current_state == "gather":
		tool.call("set_tool", _get_tool_kind(true), 0)
	else:
		tool.call("set_tool", "none", 0)

func _apply_frame(animation_name: String, frame_index: int) -> void:
	var frames: Array[Texture2D] = _get_frames(animation_name)
	if frames.is_empty():
		return

	var safe_index: int = clampi(frame_index, 0, frames.size() - 1)
	_apply_texture(frames[safe_index])

func _apply_texture(frame_texture: Texture2D) -> void:
	sprite.texture = frame_texture

func _get_frames(animation_name: String) -> Array[Texture2D]:
	var value: Variant = frames_by_animation.get(animation_name, null)
	if value is Array:
		var frames: Array[Texture2D] = []
		for item: Variant in value:
			if item is Texture2D:
				frames.append(item)
		return frames

	return []

func _get_tool_kind(gathering: bool) -> String:
	if selected_item_key == "sword":
		return "sword"
	if selected_item_key == "pickaxe" or selected_item_key == "improvised_pickaxe":
		return "pickaxe"
	if selected_item_key == "axe" or selected_item_key == "improvised_axe":
		return "axe"
	if selected_item_key == "improvised_knife":
		return "knife"

	return "axe" if gathering else "none"

func _direction_from_vector(value: Vector2) -> String:
	if value == Vector2.ZERO:
		return current_direction

	var abs_x: float = absf(value.x)
	var abs_y: float = absf(value.y)

	if abs_x > abs_y:
		return "right" if value.x > 0.0 else "left"
	if abs_y > abs_x:
		return "down" if value.y > 0.0 else "up"

	if current_direction == "left" and value.x < 0.0:
		return "left"
	if current_direction == "right" and value.x > 0.0:
		return "right"
	if current_direction == "up" and value.y < 0.0:
		return "up"
	if current_direction == "down" and value.y > 0.0:
		return "down"

	return "down" if value.y > 0.0 else "up"

func _direction_vector(direction_name: String) -> Vector2:
	match direction_name:
		"left":
			return Vector2.LEFT
		"right":
			return Vector2.RIGHT
		"up":
			return Vector2.UP
		_:
			return Vector2.DOWN
