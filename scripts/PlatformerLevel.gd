extends Control
## Platformer Level - Pixel-perfect platformer game matching retro aesthetics

const GRAVITY = 800.0
const JUMP_VELOCITY = -400.0
const MOVE_SPEED = 200.0
const PLATFORM_TILE_SIZE = 16

var score = 0
var lives = 1
var deaths = 0
var collectibles_gathered = 0

@onready var game_world = $GameWorld
@onready var player = $GameWorld/Player
@onready var player_sprite = $GameWorld/Player/Sprite
@onready var platforms_node = $GameWorld/Platforms
@onready var collectibles_node = $GameWorld/Collectibles
@onready var background = $Background
@onready var score_label = $UI/TopBar/CenterUI/ScoreLabel
@onready var lives_label = $UI/TopBar/LeftUI/LivesLabel
@onready var deaths_label = $UI/BottomBar/DeathsLabel
@onready var pause_button = $UI/TopBar/RightUI/PauseButton
@onready var menu_button = $UI/TopBar/RightUI/MenuButton

# Platform colors from the image (purple/pink/dark tones)
var platform_colors = [
	Color(0.15, 0.08, 0.12),  # Dark base
	Color(0.25, 0.12, 0.18),  # Medium dark
	Color(0.35, 0.18, 0.25),  # Medium
	Color(0.45, 0.22, 0.32),  # Light medium
	Color(0.55, 0.28, 0.38),  # Light
]

func _ready() -> void:
	# Background is set in scene file (starfield image)
	
	# Create collision shape for player
	var player_collision = RectangleShape2D.new()
	player_collision.size = Vector2(20, 24)
	$GameWorld/Player/CollisionShape2D.shape = player_collision
	
	# Setup player sprite to look like the blob character in the image
	player_sprite.size = Vector2(24, 28)
	player_sprite.position = Vector2(-12, -14)
	# Add slight rounding to corners for blob effect
	var corner_radius = 6
	player_sprite.set_meta("has_rounded_corners", true)
	
	# Setup collectible collision
	var collectible_collision = CircleShape2D.new()
	collectible_collision.radius = 10
	$GameWorld/Collectibles/Collectible1/CollisionShape2D.shape = collectible_collision
	$GameWorld/Collectibles/Collectible1.body_entered.connect(_on_collectible_gathered)
	
	# Animate collectible (floating effect)
	_animate_collectible($GameWorld/Collectibles/Collectible1)
	
	# Generate platforms to match image layout
	_generate_platforms()
	
	# Connect UI buttons
	pause_button.pressed.connect(_on_pause_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	
	# Style UI buttons to match retro aesthetic
	_style_ui_buttons()
	
	# Update UI
	_update_ui()
	
	# Set pixel-perfect rendering
	get_viewport().snap_2d_transforms_to_pixel = true
	get_viewport().snap_2d_vertices_to_pixel = true

func _style_ui_buttons() -> void:
	# Style pause and menu buttons
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color(0.2, 0.15, 0.25)
	button_style.border_color = Color(1, 1, 1, 0.3)
	button_style.set_border_width_all(2)
	button_style.corner_radius_top_left = 4
	button_style.corner_radius_top_right = 4
	button_style.corner_radius_bottom_left = 4
	button_style.corner_radius_bottom_right = 4
	
	pause_button.add_theme_stylebox_override("normal", button_style.duplicate())
	pause_button.add_theme_stylebox_override("hover", button_style.duplicate())
	menu_button.add_theme_stylebox_override("normal", button_style.duplicate())
	menu_button.add_theme_stylebox_override("hover", button_style.duplicate())

# Background setup removed - starfield image is set in scene file

func _generate_platforms() -> void:
	# Platform layouts matching the image
	# Format: [x_tiles, y_tiles, width_tiles, height_tiles]
	var platform_layouts = [
		# Top left platform
		{"x": 2, "y": 2, "width": 15, "height": 3},
		# Top right platform
		{"x": 63, "y": 2, "width": 15, "height": 3},
		# Middle left floating platform
		{"x": 12, "y": 20, "width": 15, "height": 3},
		# Center main platform (where player stands)
		{"x": 42, "y": 30, "width": 25, "height": 3},
		# Bottom left platform
		{"x": 12, "y": 42, "width": 15, "height": 3},
		# Bottom area (large dark section)
		{"x": 0, "y": 48, "width": 80, "height": 10},
	]
	
	for platform_data in platform_layouts:
		_create_platform_group(
			platform_data.x,
			platform_data.y,
			platform_data.width,
			platform_data.height
		)

func _create_platform_group(grid_x: int, grid_y: int, width_tiles: int, height_tiles: int) -> void:
	var platform = StaticBody2D.new()
	platforms_node.add_child(platform)
	
	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(width_tiles * PLATFORM_TILE_SIZE, height_tiles * PLATFORM_TILE_SIZE)
	collision_shape.shape = rect_shape
	collision_shape.position = Vector2(
		(width_tiles * PLATFORM_TILE_SIZE) / 2.0,
		(height_tiles * PLATFORM_TILE_SIZE) / 2.0
	)
	platform.add_child(collision_shape)
	
	platform.position = Vector2(grid_x * PLATFORM_TILE_SIZE, grid_y * PLATFORM_TILE_SIZE)
	
	# Create textured look using multiple ColorRects
	for y in range(height_tiles):
		for x in range(width_tiles):
			var tile = ColorRect.new()
			tile.size = Vector2(PLATFORM_TILE_SIZE, PLATFORM_TILE_SIZE)
			tile.position = Vector2(x * PLATFORM_TILE_SIZE, y * PLATFORM_TILE_SIZE)
			
			# Create textured pattern
			var base_color_index = (x + y) % platform_colors.size()
			tile.color = platform_colors[base_color_index]
			
			platform.add_child(tile)
			
			# Add detail pixels for texture
			_add_tile_texture(tile)

func _add_tile_texture(tile: ColorRect) -> void:
	# Add small colored pixels to create the textured look from the image
	for i in range(3):
		var pixel = ColorRect.new()
		pixel.size = Vector2(2, 2)
		pixel.position = Vector2(
			randf_range(2, PLATFORM_TILE_SIZE - 4),
			randf_range(2, PLATFORM_TILE_SIZE - 4)
		)
		
		# Vary the color slightly
		var color_variation = randf_range(0.8, 1.2)
		pixel.color = Color(
			tile.color.r * color_variation,
			tile.color.g * color_variation,
			tile.color.b * color_variation
		)
		tile.add_child(pixel)

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not player.is_on_floor():
		player.velocity.y += GRAVITY * delta
	
	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and player.is_on_floor():
		player.velocity.y = JUMP_VELOCITY
	
	# Handle movement
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		player.velocity.x = direction * MOVE_SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, MOVE_SPEED * delta * 5)
	
	player.move_and_slide()
	
	# Check if player fell off screen
	if player.position.y > get_viewport_rect().size.y + 50:
		_player_died()

func _on_collectible_gathered(body: Node2D) -> void:
	if body == player:
		collectibles_gathered += 1
		score += 1000
		$GameWorld/Collectibles/Collectible1.queue_free()
		_update_ui()

func _player_died() -> void:
	deaths += 1
	player.position = Vector2(875, 475)
	player.velocity = Vector2.ZERO
	_update_ui()

func _update_ui() -> void:
	# Format score to match image style (hexadecimal-looking)
	score_label.text = "%07X" % score
	lives_label.text = str(lives)
	deaths_label.text = "DEATHS: %d" % deaths

func _on_pause_pressed() -> void:
	# Toggle pause
	get_tree().paused = !get_tree().paused
	pause_button.text = "▶" if get_tree().paused else "⏸"

func _on_menu_pressed() -> void:
	# Return to main menu
	get_tree().paused = false
	GameManager.return_to_menu()

func _animate_collectible(collectible: Node2D) -> void:
	# Create floating animation
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(collectible, "position:y", collectible.position.y - 10, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(collectible, "position:y", collectible.position.y + 10, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	# Add rotation animation
	var rotation_tween = create_tween()
	rotation_tween.set_loops()
	rotation_tween.tween_property(collectible.get_node("Sprite"), "rotation", TAU, 3.0)

