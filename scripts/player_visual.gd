extends Sprite2D

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
const ALPHA_CUTOFF: float = 0.15
const BASE_POSITION: Vector2 = Vector2(0, -17)

var animation_frames: Dictionary = {}
var current_state: String = "idle"
var current_direction: String = "down"
var current_animation_name: String = ""
var animation_clock: float = 0.0
var animation_frame_index: int = 0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	centered = true
	position = BASE_POSITION
	scale = Vector2(1.25, 1.25)
	z_index = 1

	_build_individual_frames()
	_switch_animation("idle", "down")

func _process(delta: float) -> void:
	_advance_animation(delta)

func _build_individual_frames() -> void:
	animation_frames.clear()

	var idle_image: Image = _get_source_image(IDLE_SHEET)
	var walk_image: Image = _get_source_image(WALK_SHEET)

	_add_sheet_frames("idle_down", idle_image, 0, 4)
	_add_sheet_frames("idle_left", idle_image, 1, 4)
	_add_sheet_frames("idle_up", idle_image, 2, 4)
	_add_sheet_frames("idle_right", idle_image, 3, 4)

	_add_sheet_frames("walk_down", walk_image, 0, 6)
	_add_sheet_frames("walk_left", walk_image, 1, 6)
	_add_sheet_frames("walk_up", walk_image, 2, 6)
	_add_sheet_frames("walk_right", walk_image, 3, 6)

	_add_single_row_frames("attack_down", ATTACK_DOWN, 6)
	_add_single_row_frames("attack_left", ATTACK_LEFT, 6)
	_add_single_row_frames("attack_up", ATTACK_UP, 6)
	_add_single_row_frames("attack_right", ATTACK_RIGHT, 6)

	_add_single_row_frames("gather_down", GATHER_DOWN, 5)
	_add_single_row_frames("gather_left", GATHER_LEFT, 5)
	_add_single_row_frames("gather_up", GATHER_UP, 5)
	_add_single_row_frames("gather_right", GATHER_RIGHT, 5)

func _get_source_image(source_texture: Texture2D) -> Image:
	var source_image: Image = source_texture.get_image()
	if source_image.get_format() != Image.FORMAT_RGBA8:
		source_image.convert(Image.FORMAT_RGBA8)
	return source_image

func _add_sheet_frames(
	animation_name: String,
	source_image: Image,
	row: int,
	frame_count: int
) -> void:
	var frames: Array = []

	for column in range(frame_count):
		var source_rect: Rect2i = Rect2i(
			column * CELL_SIZE,
			row * CELL_SIZE,
			CELL_SIZE,
			CELL_SIZE
		)
		frames.append(_make_individual_frame(source_image, source_rect))

	animation_frames[animation_name] = frames

func _add_single_row_frames(
	animation_name: String,
	source_texture: Texture2D,
	frame_count: int
) -> void:
	var source_image: Image = _get_source_image(source_texture)
	_add_sheet_frames(animation_name, source_image, 0, frame_count)

func _make_individual_frame(source_image: Image, source_rect: Rect2i) -> Texture2D:
	var source_frame: Image = source_image.get_region(source_rect)

	if source_frame.get_format() != Image.FORMAT_RGBA8:
		source_frame.convert(Image.FORMAT_RGBA8)

	var min_x: int = CELL_SIZE
	var min_y: int = CELL_SIZE
	var max_x: int = -1
	var max_y: int = -1

	# O PNG original possui pixels de fundo com alpha muito baixo.
	# Eles são removidos completamente antes da criação do frame.
	for y in range(CELL_SIZE):
		for x in range(CELL_SIZE):
			var pixel: Color = source_frame.get_pixel(x, y)

			if pixel.a < ALPHA_CUTOFF:
				source_frame.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
				continue

			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)

	if max_x < 0 or max_y < 0:
		var empty_image: Image = Image.create(
			CELL_SIZE,
			CELL_SIZE,
			false,
			Image.FORMAT_RGBA8
		)
		empty_image.fill(Color(0.0, 0.0, 0.0, 0.0))
		return ImageTexture.create_from_image(empty_image)

	# Usa a região inferior do personagem como âncora.
	# Assim cachecol, braços e arma não deslocam o corpo entre frames.
	var foot_band_start: int = maxi(min_y, max_y - 11)
	var foot_min_x: int = CELL_SIZE
	var foot_max_x: int = -1

	for y in range(foot_band_start, max_y + 1):
		for x in range(CELL_SIZE):
			var pixel: Color = source_frame.get_pixel(x, y)
			if pixel.a >= ALPHA_CUTOFF:
				foot_min_x = mini(foot_min_x, x)
				foot_max_x = maxi(foot_max_x, x)

	var anchor_x: float = (float(min_x) + float(max_x)) * 0.5
	if foot_max_x >= 0:
		anchor_x = (float(foot_min_x) + float(foot_max_x)) * 0.5

	var offset_x: int = roundi(31.5 - anchor_x)
	var offset_y: int = 62 - max_y

	var aligned_image: Image = Image.create(
		CELL_SIZE,
		CELL_SIZE,
		false,
		Image.FORMAT_RGBA8
	)
	aligned_image.fill(Color(0.0, 0.0, 0.0, 0.0))

	# Copia pixel por pixel para que cada quadro seja realmente independente.
	# Não há AtlasTexture nem risco de vazar para a célula vizinha.
	for y in range(CELL_SIZE):
		for x in range(CELL_SIZE):
			var pixel: Color = source_frame.get_pixel(x, y)
			if pixel.a < ALPHA_CUTOFF:
				continue

			var target_x: int = x + offset_x
			var target_y: int = y + offset_y

			if target_x < 0 or target_x >= CELL_SIZE:
				continue
			if target_y < 0 or target_y >= CELL_SIZE:
				continue

			aligned_image.set_pixel(target_x, target_y, pixel)

	return ImageTexture.create_from_image(aligned_image)

func set_visual_state(state_name: String, facing_direction: Vector2) -> void:
	var direction_name: String = _get_direction_name(facing_direction)
	var final_state: String = state_name
	var desired_animation: String = final_state + "_" + direction_name

	if not animation_frames.has(desired_animation):
		final_state = "idle"
		desired_animation = "idle_" + direction_name

	if final_state == current_state and direction_name == current_direction:
		return

	_switch_animation(final_state, direction_name)

func _switch_animation(state_name: String, direction_name: String) -> void:
	var desired_animation: String = state_name + "_" + direction_name

	if not animation_frames.has(desired_animation):
		state_name = "idle"
		desired_animation = "idle_" + direction_name

	current_state = state_name
	current_direction = direction_name
	current_animation_name = desired_animation
	animation_clock = 0.0
	animation_frame_index = 0
	position = BASE_POSITION

	_apply_current_frame()

func _advance_animation(delta: float) -> void:
	var frames_value: Variant = animation_frames.get(current_animation_name, null)
	if frames_value is not Array:
		return

	var frames: Array = frames_value
	var frame_count: int = frames.size()

	if frame_count <= 1:
		animation_frame_index = 0
		_apply_current_frame()
		return

	var fps: float = _get_animation_fps(current_state)
	if fps <= 0.0:
		return

	var frame_duration: float = 1.0 / fps
	animation_clock += delta

	var changed_frame: bool = false

	while animation_clock >= frame_duration:
		animation_clock -= frame_duration

		if _is_looping_state(current_state):
			animation_frame_index = (animation_frame_index + 1) % frame_count
		else:
			animation_frame_index = mini(animation_frame_index + 1, frame_count - 1)

		changed_frame = true

	if changed_frame:
		_apply_current_frame()

func _apply_current_frame() -> void:
	var frames_value: Variant = animation_frames.get(current_animation_name, null)
	if frames_value is not Array:
		return

	var frames: Array = frames_value
	if frames.is_empty():
		return

	animation_frame_index = clampi(animation_frame_index, 0, frames.size() - 1)

	var texture_value: Variant = frames[animation_frame_index]
	if texture_value is Texture2D:
		texture = texture_value

	# Um bob de 1 pixel reforça visualmente o passo sem deformar a arte.
	if current_state == "walk":
		var walk_bob: Array[int] = [0, 1, 0, -1, 0, 1]
		var bob_index: int = animation_frame_index % walk_bob.size()
		position = BASE_POSITION + Vector2(0.0, float(walk_bob[bob_index]))
	else:
		position = BASE_POSITION

func _get_animation_fps(state_name: String) -> float:
	match state_name:
		"idle":
			return 4.0
		"walk":
			return 10.0
		"attack":
			return 26.0
		"gather":
			return 15.0
		_:
			return 1.0

func _is_looping_state(state_name: String) -> bool:
	return state_name == "idle" or state_name == "walk"

func _get_direction_name(direction: Vector2) -> String:
	if direction == Vector2.ZERO:
		return current_direction

	var abs_x: float = absf(direction.x)
	var abs_y: float = absf(direction.y)

	if abs_x > abs_y + 0.05:
		return "right" if direction.x > 0.0 else "left"

	if abs_y > abs_x + 0.05:
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
