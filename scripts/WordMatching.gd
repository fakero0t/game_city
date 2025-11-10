extends Control
## Space Invaders Word Matching Game
## Words float at top as ships, player shoots from bottom
## Features bird character with wing flap animation

const Colors = preload("res://scripts/VocabZooColors.gd")
const Anim = preload("res://scripts/VocabZooConstants.gd")
const THEME = preload("res://assets/vocab_zoo_theme.tres")

class MatchingQuestion:
	var definition: String
	var correct_word: String
	var options: Array[String] = []  # 4 word options
	var correct_index: int = -1

class WordShip:
	var word: String
	var is_correct: bool
	var button: Control  # Changed from Button to Control (ship container)
	var position: Vector2
	var hit: bool = false

class Bullet:
	var sprite: Sprite2D
	var position: Vector2
	var speed: float = 500.0
	var active: bool = true

var questions: Array[MatchingQuestion] = []
var current_question_index: int = 0
var is_answering: bool = false

var word_ships: Array[WordShip] = []
var bullets: Array[Bullet] = []
var shooter_position: float = 0.0
var shooter_speed: float = 675.0
var can_shoot: bool = true
var shoot_cooldown: float = 0.3
var last_mouse_pos: Vector2
var is_dragging: bool = false
var was_mouse_pressed: bool = false

var fox_image: Sprite2D
var video_player: VideoStreamPlayer
var character_visible: bool = true

# UI elements
var shooter: Control  # Now a container with classic Space Invaders base design
var game_area: Control
var definition_label: Label
var info_label: Label
var is_game_active: bool = false

func _ready() -> void:
	# Create fox image from fox.png
	fox_image = Sprite2D.new()
	fox_image.name = "FoxImage"
	var texture = load("res://assets/fox.png")
	if texture:
		fox_image.texture = texture
		fox_image.scale = Vector2(0.5, 0.5)  # Adjust scale as needed
	$Character.add_child(fox_image)
	
	# Create video player for fox animations (hidden initially)
	# Note: VideoStreamPlayer is a Control node, so we add it to the root Control, not Character
	video_player = VideoStreamPlayer.new()
	video_player.name = "VideoPlayer"
	video_player.size = Vector2(200, 200)
	video_player.position = $Character.position - Vector2(100, 100)  # Position relative to Character's world position
	video_player.visible = false
	add_child(video_player)
	video_player.finished.connect(_on_video_finished)
	
	# Hide old UI elements (QuestionPanel, HeaderBar, FooterBar, FeedbackLabel)
	if has_node("QuestionPanel"):
		$QuestionPanel.hide()
	if has_node("HeaderBar"):
		$HeaderBar.hide()
	if has_node("FooterBar"):
		$FooterBar.hide()
	if has_node("FeedbackLabel"):
		$FeedbackLabel.hide()
	
	# Setup game area
	_setup_game_area()
	
	# Initialize mouse position
	last_mouse_pos = get_global_mouse_position()
	
	# Next button removed - auto-navigation after celebration
	
	# Add activity progress indicator (bottom left)
	var activity_progress = GameManager.create_activity_progress_label()
	add_child(activity_progress)
	
	# Wait for activity data to be loaded via load_activity_data()

func _setup_game_area() -> void:
	# Create game area container
	game_area = Control.new()
	game_area.name = "GameArea"
	game_area.set_anchors_preset(Control.PRESET_FULL_RECT)
	game_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(game_area)
	
	# Add space background sprite
	var background_sprite = Sprite2D.new()
	background_sprite.name = "BackgroundSprite"
	var bg_texture = load("res://assets/SpaceShooter/Backgrounds/Space_01-Sheet.png")
	if bg_texture:
		background_sprite.texture = bg_texture
		var viewport_size = get_viewport_rect().size
		# Scale background to cover viewport
		var texture_size = bg_texture.get_size()
		if texture_size.x > 0 and texture_size.y > 0:
			var scale_x = viewport_size.x / texture_size.x
			var scale_y = viewport_size.y / texture_size.y
			background_sprite.scale = Vector2(max(scale_x, scale_y), max(scale_x, scale_y))
		background_sprite.position = viewport_size / 2.0
		background_sprite.z_index = -10  # Behind everything
	game_area.add_child(background_sprite)
	
	# Create definition label at top (centered)
	definition_label = Label.new()
	definition_label.name = "DefinitionLabel"
	var viewport_size = get_viewport_rect().size
	definition_label.position = Vector2(50, 40)
	definition_label.size = Vector2(viewport_size.x - 100, 80)
	definition_label.add_theme_font_size_override("font_size", 28)
	definition_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	definition_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	definition_label.add_theme_color_override("font_color", Colors.LIGHT_BASE)
	game_area.add_child(definition_label)
	
	# Create shooter at bottom - using a single enemy ship as the player base
	var shooter_container = Control.new()
	shooter_container.name = "ShooterContainer"
	shooter_container.size = Vector2(80, 60)
	var viewport_width = get_viewport_rect().size.x
	shooter_position = viewport_width / 2.0
	shooter_container.position = Vector2(shooter_position - 40, get_viewport_rect().size.y - 120.0)
	game_area.add_child(shooter_container)
	
	# Create player sprite using a single ship asset (CrabShip or Gunship work well as player base)
	var player_sprite = Sprite2D.new()
	player_sprite.name = "PlayerSprite"
	# Use CrabShip as player base - it's a single sprite, not a sheet
	var player_texture = load("res://assets/SpaceShooter/Enemies/CrabShip.png")
	if player_texture:
		player_sprite.texture = player_texture
		# Scale to appropriate size for player base
		var texture_size = player_texture.get_size()
		if texture_size.x > 0 and texture_size.y > 0:
			var scale_factor = 60.0 / max(texture_size.y, 1.0)
			player_sprite.scale = Vector2(scale_factor, scale_factor)
		player_sprite.position = Vector2(40, 30)  # Center in container
		# Flip vertically so ship points upward (shooting up at enemies)
		player_sprite.flip_v = true
	player_sprite.z_index = 3  # Above background, below bullets
	shooter_container.add_child(player_sprite)
	
	# Update shooter reference to container for positioning
	shooter = shooter_container

func _process(delta: float) -> void:
	if not is_game_active:
		return
	
	# Handle input for shooter movement
	var move_direction = 0.0
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		move_direction = -1.0
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		move_direction = 1.0
	
	# Move shooter
	var viewport_width = get_viewport_rect().size.x
	shooter_position += move_direction * shooter_speed * delta
	shooter_position = clamp(shooter_position, 50.0, viewport_width - 150.0)
	shooter.position.x = shooter_position - 50  # Center the 100-wide base
	shooter.position.y = get_viewport_rect().size.y - 120.0
	
	# Handle shooting (spacebar, enter, or click without drag)
	if Input.is_action_just_pressed("ui_accept") and can_shoot:
		_shoot_bullet()
	
	# Handle mouse/touch input
	var mouse_pos = get_global_mouse_position()
	var is_mouse_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
	if is_mouse_pressed:
		if not is_dragging and was_mouse_pressed:
			# Check if this is a drag (mouse moved) or click
			if mouse_pos.distance_to(last_mouse_pos) > 5.0:
				is_dragging = true
			last_mouse_pos = mouse_pos
		
		if is_dragging:
			# Move shooter to mouse position
			shooter_position = clamp(mouse_pos.x, 50.0, viewport_width - 150.0)
			shooter.position.x = shooter_position - 50  # Center the 100-wide base
		elif not was_mouse_pressed:
			# Just pressed - initialize
			last_mouse_pos = mouse_pos
	else:
		# Mouse released - check if it was a click (not drag)
		if was_mouse_pressed and not is_dragging and can_shoot:
			# It was a click, shoot
			_shoot_bullet()
		
		if is_dragging:
			is_dragging = false
	
	was_mouse_pressed = is_mouse_pressed
	
	# Update bullets
	_update_bullets(delta)
	
	# Update shoot cooldown
	if not can_shoot:
		shoot_cooldown -= delta
		if shoot_cooldown <= 0:
			can_shoot = true
			shoot_cooldown = 0.3

func _update_bullets(delta: float) -> void:
	var bullets_to_remove = []
	
	for i in range(bullets.size()):
		var bullet = bullets[i]
		if not bullet.active:
			continue
		
		# Move bullet upward
		bullet.position.y -= bullet.speed * delta
		bullet.sprite.position = bullet.position
		
		# Remove if off screen
		if bullet.position.y < 0:
			bullet.active = false
			bullets_to_remove.append(i)
			continue
		
		# Check collision with word ships
		for ship in word_ships:
			if ship.hit:
				continue
			
			# Validate ship.button is still valid before accessing
			if not is_instance_valid(ship.button):
				continue
			
			var ship_rect = Rect2(ship.button.position, ship.button.size)
			# Use sprite size for collision if available, otherwise default
			var bullet_size = Vector2(8, 16)
			if bullet.sprite and bullet.sprite.texture:
				bullet_size = bullet.sprite.texture.get_size() * bullet.sprite.scale
			var bullet_rect = Rect2(bullet.position, bullet_size)
			
			if ship_rect.intersects(bullet_rect):
				# Hit detected!
				_handle_ship_hit(ship, bullet)
				bullet.active = false
				bullets_to_remove.append(i)
				break
	
	# Remove inactive bullets
	for i in range(bullets_to_remove.size() - 1, -1, -1):
		var idx = bullets_to_remove[i]
		if is_instance_valid(bullets[idx].sprite):
			bullets[idx].sprite.queue_free()
		bullets.remove_at(idx)

func _shoot_bullet() -> void:
	if not is_game_active:
		return
		
	can_shoot = false
	shoot_cooldown = 0.3
	
	var bullet = Bullet.new()
	bullet.position = Vector2(shooter_position, shooter.position.y)
	
	# Create projectile sprite
	bullet.sprite = Sprite2D.new()
	var projectile_texture = load("res://assets/SpaceShooter/Projectiles And Explosions/Projectile01.png")
	if projectile_texture:
		bullet.sprite.texture = projectile_texture
		# Scale projectile to appropriate size
		var texture_size = projectile_texture.get_size()
		if texture_size.x > 0:
			bullet.sprite.scale = Vector2(0.5, 0.5)  # Adjust scale as needed
	bullet.sprite.position = bullet.position
	bullet.sprite.z_index = 5  # Above ships
	game_area.add_child(bullet.sprite)
	
	bullets.append(bullet)
	SoundManager.play_laser_sound()

func _handle_ship_hit(ship: WordShip, bullet: Bullet) -> void:
	ship.hit = true
	
	if ship.is_correct:
		# Correct word - explode and turn green
		SoundManager.play_correct_sound()
		_explode_ship(ship, true)
		_play_bird_celebration()
		
		# Wait briefly for explosion animation, then auto-navigate to next activity
		await get_tree().create_timer(0.8).timeout
		_on_game_complete()
	else:
		# Incorrect word - shake and turn red
		SoundManager.play_incorrect_sound()
		_shake_ship(ship)
		_turn_ship_red(ship)
		_play_bird_sympathy()

func _explode_ship(ship: WordShip, is_correct: bool) -> void:
	# Validate ship.button is still valid
	if not is_instance_valid(ship.button):
		return
	
	# Turn green
	ship.button.modulate = Colors.SUCCESS
	
	# Explosion animation using sprite sheet
	var center_pos = ship.button.position + ship.button.size / 2
	
	# Create animated explosion sprite
	var explosion = AnimatedSprite2D.new()
	explosion.name = "Explosion"
	explosion.position = center_pos
	explosion.z_index = 10  # Above everything
	
	# Create SpriteFrames resource for explosion animation
	var sprite_frames = SpriteFrames.new()
	sprite_frames.add_animation("explode")
	
	# Load explosion sheet and set up frames
	# For simplicity, we'll use the first frame of the sheet as a single frame
	# In a full implementation, you'd parse the sheet into individual frames
	var explosion_texture = load("res://assets/SpaceShooter/Projectiles And Explosions/Explosion01-Sheet.png")
	if explosion_texture:
		# Add the texture as a frame (if it's a single image, use it directly)
		# If it's a sprite sheet, you'd need to extract frames, but for now we'll use it as-is
		sprite_frames.add_frame("explode", explosion_texture, 0.1)
		# Add multiple copies to create animation effect
		for i in range(5):
			sprite_frames.add_frame("explode", explosion_texture, 0.1)
		
		explosion.sprite_frames = sprite_frames
		explosion.play("explode")
		
		# Scale explosion appropriately
		var texture_size = explosion_texture.get_size()
		if texture_size.x > 0:
			var scale_factor = 80.0 / max(texture_size.x, texture_size.y)
			explosion.scale = Vector2(scale_factor, scale_factor)
	
		game_area.add_child(explosion)
	
	# Remove explosion after animation
	await get_tree().create_timer(0.6).timeout
	if is_instance_valid(explosion):
		explosion.queue_free()
	
	# Ship explosion - just fade out (explosion sprite handles the visual)
	if is_instance_valid(ship.button):
		var ship_tween = create_tween()
		ship_tween.tween_property(ship.button, "modulate:a", 0.0, 0.4)

func _animate_ship(ship_container: Control, index: int) -> void:
	# Entrance animation - fade in and scale up
	ship_container.modulate.a = 0.0
	ship_container.scale = Vector2(0.8, 0.8)
	
	# Stagger entrance animations
	await get_tree().create_timer(index * 0.1).timeout
	
	var entrance_tween = create_tween()
	entrance_tween.set_parallel(true)
	entrance_tween.tween_property(ship_container, "modulate:a", 1.0, 0.5)
	entrance_tween.tween_property(ship_container, "scale", Vector2(1.0, 1.0), 0.5)
	entrance_tween.set_ease(Tween.EASE_OUT)
	entrance_tween.set_trans(Tween.TRANS_BACK)
	
	# Floating animation (gentle up and down movement)
	var base_y = ship_container.position.y
	var float_tween = create_tween()
	float_tween.set_loops()
	float_tween.set_ease(Tween.EASE_IN_OUT)
	float_tween.set_trans(Tween.TRANS_SINE)
	float_tween.tween_property(ship_container, "position:y", base_y - 8, 1.5 + (index * 0.1))
	float_tween.tween_property(ship_container, "position:y", base_y + 8, 1.5 + (index * 0.1))

func _shake_ship(ship: WordShip) -> void:
	# Validate ship.button is still valid
	if not is_instance_valid(ship.button):
		return
	
	var original_pos = ship.button.position
	var shake_amount = 10.0
	var shake_duration = 0.3
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	
	# Shake left-right
	for i in range(6):
		var offset = shake_amount if i % 2 == 0 else -shake_amount
		tween.tween_property(ship.button, "position:x", original_pos.x + offset, shake_duration / 6.0)
	
	tween.tween_property(ship.button, "position:x", original_pos.x, shake_duration / 6.0)

func _turn_ship_red(ship: WordShip) -> void:
	# Validate ship.button is still valid
	if not is_instance_valid(ship.button):
		return
	
	# Turn red - use modulate to affect all children
	ship.button.modulate = Color(1.0, 0.3, 0.3, 1.0)  # Red tint
	
	# Reset after delay
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(ship.button):
		ship.button.modulate = Color.WHITE  # Reset to normal
		ship.hit = false

## Load activity data from API
func load_activity_data(activity_data: Dictionary) -> void:
	var word_data = activity_data["word"]
	var params = activity_data["params"]
	
	questions.clear()
	current_question_index = 0
	
	var q = MatchingQuestion.new()
	q.definition = word_data.get("definition", "")
	q.correct_word = word_data.get("headword", "")
	
	# Extract options
	var options_array = params.get("options", [])
	var options_temp: Array[String] = []
	for option in options_array:
		options_temp.append(str(option))
	q.options = options_temp
	
	# Find correct index
	q.correct_index = q.options.find(q.correct_word)
	if q.correct_index == -1:
		q.correct_index = 0
	
	questions.append(q)
	
	_display_question()

func _display_question() -> void:
	if current_question_index >= questions.size():
		return
	
	var q = questions[current_question_index]
	
	# Clear existing ships and bullets
	_clear_game()
	
	# Update definition label
	definition_label.text = "Which word means: \"" + q.definition + "\"?"
	
	# Create word ships at top
	_create_word_ships(q)
	
	# Activate game
	is_game_active = true

func _create_word_ships(q: MatchingQuestion) -> void:
	var viewport_width = get_viewport_rect().size.x
	var viewport_height = get_viewport_rect().size.y
	# Reduce spacing - use narrower area for ships (60% of screen width centered)
	var ships_area_width = viewport_width * 0.6
	var ship_spacing = ships_area_width / (q.options.size() + 1)
	var start_offset = (viewport_width - ships_area_width) / 2
	var ship_y = viewport_height / 2.0 - 50.0  # Center on horizontal axis
	
	for i in range(q.options.size()):
		var word = q.options[i]
		var is_correct = (i == q.correct_index)
		
		var ship = WordShip.new()
		ship.word = word
		ship.is_correct = is_correct
		
		# Create ship container with enemy sprite
		var ship_container = Control.new()
		ship_container.size = Vector2(120, 100)
		ship_container.position = Vector2(start_offset + ship_spacing * (i + 1) - 60, ship_y)
		
		# Randomly select enemy ship type for variety
		var enemy_ship_paths = [
			"res://assets/SpaceShooter/Enemies/CrabShip.png",
			"res://assets/SpaceShooter/Enemies/fighter1.png",
			"res://assets/SpaceShooter/Enemies/fighter2.png",
			"res://assets/SpaceShooter/Enemies/Gunship.png"
		]
		var selected_ship_path = enemy_ship_paths[i % enemy_ship_paths.size()]
		
		# Create enemy ship sprite
		var ship_sprite = Sprite2D.new()
		ship_sprite.name = "ShipSprite"
		var ship_texture = load(selected_ship_path)
		if ship_texture:
			ship_sprite.texture = ship_texture
			# Scale sprite to fit container
			var texture_size = ship_texture.get_size()
			if texture_size.x > 0 and texture_size.y > 0:
				var scale_factor = min(80.0 / texture_size.y, 80.0 / texture_size.x)
				ship_sprite.scale = Vector2(scale_factor, scale_factor)
			ship_sprite.position = Vector2(60, 40)  # Center in container
		ship_sprite.z_index = 2  # Above background
		ship_container.add_child(ship_sprite)
		
		# Word label on ship (positioned below the ship)
		var word_label = Label.new()
		word_label.text = word
		word_label.size = Vector2(120, 30)
		word_label.position = Vector2(0, 95)
		word_label.add_theme_font_size_override("font_size", 16)
		word_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		word_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		word_label.add_theme_color_override("font_color", Colors.LIGHT_BASE)
		word_label.z_index = 3
		ship_container.add_child(word_label)
		
		# Update container size to include label
		ship_container.size = Vector2(120, 95)
		
		# Use ship_container as the button for hit detection
		ship.button = ship_container
		ship.button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		game_area.add_child(ship.button)
		ship.position = ship.button.position
		
		# Animate the ship (floating, engine pulsing)
		_animate_ship(ship_container, i)
		
		word_ships.append(ship)

func _clear_game() -> void:
	# Deactivate game to prevent shooting
	is_game_active = false
	
	# Remove all ships
	for ship in word_ships:
		if is_instance_valid(ship.button):
			ship.button.queue_free()
	word_ships.clear()
	
	# Remove all bullets
	for bullet in bullets:
		if is_instance_valid(bullet.sprite):
			bullet.sprite.queue_free()
	bullets.clear()
	
	can_shoot = true

func _on_game_complete() -> void:
	# Automatically navigate to next activity
	GameManager.request_next_activity()

func _play_bird_celebration() -> void:
	# Play fox_jump.mp4 video
	fox_image.visible = false
	video_player.stream = load("res://assets/fox_jump.mp4")
	video_player.visible = true
	video_player.play()

func _play_bird_sympathy() -> void:
	# Play fox_shake.mp4 video
	fox_image.visible = false
	video_player.stream = load("res://assets/fox_shake.mp4")
	video_player.visible = true
	video_player.play()

func _on_video_finished() -> void:
	# Hide video player and show fox image again
	video_player.visible = false
	fox_image.visible = true

# Next button removed - auto-navigation after celebration

