extends Control
## Pac-Man Style Synonym/Antonym Game
## Navigate Pac-Man to the correct word using arrow keys
## Features Pac-Man sprite, ghost word options, and dot grid

const Colors = preload("res://scripts/VocabZooColors.gd")
const Anim = preload("res://scripts/VocabZooConstants.gd")

class RelationshipQuestion:
	var target_word: String
	var question_type: String  # "synonym" or "antonym"
	var correct_answer: String
	var options: Array[String] = []
	var correct_index: int = -1

class WordGhost:
	var word: String
	var is_correct: bool
	var sprite: Control  # Changed to Control for flexibility (ColorRect extends Control)
	var label: Label
	var position: Vector2
	var grid_x: int  # Grid X position
	var grid_y: int  # Grid Y position
	var color: Color
	var eaten: bool = false

var questions: Array[RelationshipQuestion] = []
var current_question_index: int = 0
var is_answering: bool = false
var game_active: bool = false
var can_move_backward: bool = false  # Allow backward movement after eating ghost

# Pac-Man properties
var pacman: Control  # Changed to Control since we use it as a container
var pacman_position: Vector2
var pacman_speed: float = 200.0
var pacman_size: float = 40.0
var pacman_direction: Vector2 = Vector2.RIGHT
var pacman_shape: Polygon2D  # Reference to the shape for animation
var chomp_timer: float = 0.0
var chomp_speed: float = 10.0  # Chomping animation speed

# Grid-based movement
var pacman_grid_x: int = 0  # Current grid X position
var pacman_grid_y: int = 0  # Current grid Y position
var is_moving: bool = false  # Whether Pac-Man is currently animating to next cell
var move_tween: Tween  # Tween for smooth grid movement

# Game board properties
var game_area: Control
var grid_size: Vector2 = Vector2(15, 10)  # Grid cells
var cell_size: float = 50.0
var dots: Array[ColorRect] = []
var dot_reflections: Array[ColorRect] = []  # Store reflections separately
var dot_positions: Array[Vector2] = []  # Store dot center positions
var word_ghosts: Array[WordGhost] = []
# Grid bounds for movement restrictions
var grid_start_x: float = 200.0
var grid_start_y: float = 150.0
var grid_end_x: float = 0.0  # Will be calculated
var grid_end_y: float = 0.0  # Will be calculated

# UI elements
var instruction_label: Label
var target_word_label: Label
var feedback_label: Label
# Next button removed - auto-navigation after celebration

func _ready() -> void:
	_setup_game_area()
	_setup_ui()
	# Wait for activity data to be loaded via load_activity_data()

func _setup_game_area() -> void:
	# Create game area container
	game_area = Control.new()
	game_area.name = "GameArea"
	game_area.set_anchors_preset(Control.PRESET_FULL_RECT)
	game_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(game_area)
	
	# Create Pac-Man sprite container
	pacman = Control.new()
	pacman.name = "PacMan"
	pacman.size = Vector2(pacman_size, pacman_size)
	# Initial position will be set in _display_question() after grid is created
	pacman.position = Vector2(0, 0)
	game_area.add_child(pacman)
	
	# Create Pac-Man shape with mouth
	_create_pacman_mouth()

func _create_pacman_mouth() -> void:
	# Create Pac-Man shape using Polygon2D - a circle with a mouth cutout
	pacman_shape = Polygon2D.new()
	pacman_shape.name = "PacManShape"
	pacman_shape.color = Color(1.0, 1.0, 0.0)  # Yellow
	pacman_shape.position = Vector2.ZERO
	pacman.add_child(pacman_shape)
	
	# Initial mouth shape (will be animated)
	_update_pacman_mouth(0.0)

func _update_pacman_mouth(timer: float) -> void:
	# Create animated chomping mouth (always facing right, directly on x-axis)
	# Timer cycles to create opening/closing animation
	var mouth_phase = sin(timer)  # -1 to 1, oscillating
	var mouth_width = deg_to_rad(30.0 + 20.0 * (1.0 - abs(mouth_phase)))  # Mouth opens and closes (30-50 degrees)
	
	var points = PackedVector2Array()
	var center = Vector2(pacman_size/2, pacman_size/2)
	var radius = pacman_size/2
	
	# Mouth opens directly to the right (x-axis), symmetric around horizontal (no upward tilt)
	# The mouth opening is centered at 0 degrees (pointing right)
	# Top edge of mouth opening (symmetric above horizontal)
	var top_angle = mouth_width/2
	# Bottom edge of mouth opening (symmetric below horizontal)
	var bottom_angle = -mouth_width/2
	# The arc spans from bottom edge, all around the circle, to top edge
	var arc_span = TAU - mouth_width
	
	# Start at center point
	points.append(center)
	
	# Top edge of mouth (upper right, at top_angle)
	var top_edge = center + Vector2(radius * cos(top_angle), radius * sin(top_angle))
	points.append(top_edge)
	
	# Arc around the circle (counter-clockwise from top edge, all the way around to bottom edge)
	var num_segments = 40
	for segment in range(num_segments + 1):
		var angle = top_angle + arc_span * (float(segment) / num_segments)
		var point = center + Vector2(radius * cos(angle), radius * sin(angle))
		points.append(point)
	
	# Bottom edge of mouth (lower right, at bottom_angle)
	var bottom_edge = center + Vector2(radius * cos(bottom_angle), radius * sin(bottom_angle))
	points.append(bottom_edge)
	
	# Update the polygon
	pacman_shape.polygon = points

func _setup_ui() -> void:
	# Instruction label at top
	instruction_label = Label.new()
	instruction_label.name = "InstructionLabel"
	instruction_label.position = Vector2(50, 20)
	instruction_label.size = Vector2(600, 40)
	instruction_label.add_theme_font_size_override("font_size", 24)
	instruction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instruction_label.add_theme_color_override("font_color", Colors.LIGHT_BASE)
	add_child(instruction_label)
	
	# Target word label
	target_word_label = Label.new()
	target_word_label.name = "TargetWordLabel"
	target_word_label.position = Vector2(50, 60)
	target_word_label.size = Vector2(600, 50)
	target_word_label.add_theme_font_size_override("font_size", 32)
	target_word_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	target_word_label.add_theme_color_override("font_color", Colors.SUCCESS)
	add_child(target_word_label)
	
	# Feedback label
	feedback_label = Label.new()
	feedback_label.name = "FeedbackLabel"
	feedback_label.position = Vector2(50, 550)
	feedback_label.size = Vector2(600, 60)
	feedback_label.add_theme_font_size_override("font_size", 20)
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.add_theme_color_override("font_color", Colors.LIGHT_BASE)
	feedback_label.visible = false
	add_child(feedback_label)
	
	# Next button removed - auto-navigation after celebration

## Load activity data from API
func load_activity_data(activity_data: Dictionary) -> void:
	var word_data = activity_data["word"]
	var params = activity_data["params"]
	
	questions.clear()
	current_question_index = 0
	
	var q = RelationshipQuestion.new()
	q.target_word = word_data.get("headword", "")
	q.question_type = "synonym"  # Default to synonym for synonym_mcq activity
	
	# Get correct answer from targetWord or first option
	var target_word_data = params.get("targetWord", {})
	q.correct_answer = target_word_data.get("headword", "")
	if q.correct_answer.is_empty():
		# Fallback: use first option
		var options = params.get("options", [])
		if options.size() > 0:
			if options[0] is Dictionary:
				q.correct_answer = options[0].get("headword", "")
			else:
				q.correct_answer = str(options[0])
	
	# Extract options (array of {wordId, headword} or strings)
	var options_array = params.get("options", [])
	var options_temp: Array[String] = []
	for option in options_array:
		if option is Dictionary:
			options_temp.append(option.get("headword", ""))
		else:
			options_temp.append(str(option))
	q.options = options_temp
	
	# Find correct index
	q.correct_index = q.options.find(q.correct_answer)
	if q.correct_index == -1:
		q.correct_index = 0
	
	questions.append(q)
	
	_display_question()

func _display_question() -> void:
	if current_question_index >= questions.size():
		return
	
	var q = questions[current_question_index]
	game_active = true
	
	# Clear previous game elements
	_clear_game_elements()
	
	# Update instruction
	instruction_label.text = "Which word is a SYNONYM for"
	instruction_label.add_theme_color_override("font_color", Colors.SUCCESS)
	
	# Update target word
	target_word_label.text = "\"" + q.target_word + "\"?"
	
	# Hide feedback
	feedback_label.visible = false
	# Next button removed - auto-navigation after celebration
	
	# Reset Pac-Man to grid position (0, 0) - first cell
	pacman_grid_x = 0
	pacman_grid_y = 0
	var half_pacman = pacman_size / 2.0
	# Calculate world position from grid position
	pacman_position = Vector2(grid_start_x + pacman_grid_x * cell_size, grid_start_y + pacman_grid_y * cell_size)
	pacman.position = pacman_position - Vector2(half_pacman, half_pacman)
	pacman_direction = Vector2.RIGHT
	chomp_timer = 0.0
	is_moving = false
	if move_tween:
		move_tween.kill()
	
	# Create dot grid
	_create_dot_grid()
	
	# Create word ghosts
	_create_word_ghosts(q)
	
	is_answering = false

func _clear_game_elements() -> void:
	# Remove all dots
	for dot in dots:
		if is_instance_valid(dot):
			dot.queue_free()
	dots.clear()
	
	# Remove all dot reflections
	for reflection in dot_reflections:
		if is_instance_valid(reflection):
			reflection.queue_free()
	dot_reflections.clear()
	dot_positions.clear()
	
	# Remove border if it exists
	if game_area.has_node("GridBorder"):
		game_area.get_node("GridBorder").queue_free()
	
	# Remove all word labels (ghosts are now just labels)
	for ghost in word_ghosts:
		if is_instance_valid(ghost.label):
			ghost.label.queue_free()
	word_ghosts.clear()

func _create_dot_grid() -> void:
	# Create dots in a grid pattern (like Pac-Man)
	var viewport_size = get_viewport_rect().size
	grid_start_x = 200.0
	grid_start_y = 150.0
	var spacing = cell_size
	var border_width = 2.0
	var border_radius = 8.0
	
	# Calculate grid bounds for border
	var grid_width = (grid_size.x - 1) * spacing
	var grid_height = (grid_size.y - 1) * spacing
	var border_padding = 20.0
	
	# Store grid end positions for movement restrictions
	grid_end_x = grid_start_x + grid_width
	grid_end_y = grid_start_y + grid_height
	
	# Create border around grid (rounded rectangle using PanelContainer with StyleBoxFlat)
	var border_container = PanelContainer.new()
	border_container.name = "GridBorder"
	border_container.position = Vector2(grid_start_x - border_padding, grid_start_y - border_padding)
	border_container.size = Vector2(grid_width + border_padding * 2, grid_height + border_padding * 2)
	
	# Use StyleBoxFlat for thin grey border with rounded corners
	var border_style = StyleBoxFlat.new()
	border_style.bg_color = Color(0, 0, 0, 0)  # Transparent background
	border_style.border_width_left = border_width
	border_style.border_width_top = border_width
	border_style.border_width_right = border_width
	border_style.border_width_bottom = border_width
	border_style.border_color = Color(0.5, 0.5, 0.5, 1.0)  # Grey border
	border_style.corner_radius_top_left = border_radius
	border_style.corner_radius_top_right = border_radius
	border_style.corner_radius_bottom_left = border_radius
	border_style.corner_radius_bottom_right = border_radius
	border_container.add_theme_stylebox_override("panel", border_style)
	game_area.add_child(border_container)
	
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			# Skip dots near Pac-Man start
			var dot_pos = Vector2(grid_start_x + x * spacing, grid_start_y + y * spacing)
			if dot_pos.distance_to(pacman_position) < 80:
				continue
			
			# Skip the last two columns on the right side where ghosts will be positioned
			if x >= grid_size.x - 2:
				continue
			
			# Create dot - dark grey, fully opaque
			var dot = ColorRect.new()
			dot.size = Vector2(8, 8)
			dot.position = dot_pos - Vector2(4, 4)
			dot.color = Color(0.3, 0.3, 0.3, 1.0)  # Dark grey, opacity 100%
			game_area.add_child(dot)
			dots.append(dot)
			dot_positions.append(dot_pos)  # Store center position
			
			# Create reflection (lower half) - dark grey, fully opaque
			var reflection = ColorRect.new()
			reflection.size = Vector2(8, 8)
			reflection.position = Vector2(dot_pos.x - 4, viewport_size.y - (dot_pos.y - 4) + 20)
			reflection.color = Color(0.3, 0.3, 0.3, 1.0)  # Dark grey, opacity 100%
			game_area.add_child(reflection)
			dot_reflections.append(reflection)

func _create_word_ghosts(q: RelationshipQuestion) -> void:
	# Position words in the last two columns of the grid, replacing dots
	# Distribute words vertically across available grid cells in those columns
	var words_per_column = q.options.size() / 2
	if q.options.size() % 2 == 1:
		words_per_column += 1
	
	# Calculate starting Y position to center words vertically
	var total_words = q.options.size()
	var start_y_offset = max(0, (grid_size.y - total_words) / 2)
	
	for i in range(q.options.size()):
		var ghost = WordGhost.new()
		ghost.word = q.options[i]
		ghost.is_correct = (i == q.correct_index)
		
		# Determine which column (second-to-last or last)
		var column_x = grid_size.x - 2 if i < words_per_column else grid_size.x - 1
		var row_y = start_y_offset + (i % words_per_column)
		
		# Store grid position
		ghost.grid_x = column_x
		ghost.grid_y = row_y
		
		# Calculate world position at grid cell center
		ghost.position = Vector2(
			grid_start_x + column_x * cell_size,
			grid_start_y + row_y * cell_size
		)
		
		# Create word label centered at grid cell
		ghost.label = Label.new()
		ghost.label.text = ghost.word
		ghost.label.size = Vector2(cell_size - 10, cell_size - 10)  # Slightly smaller than cell
		ghost.label.position = ghost.position - Vector2(ghost.label.size.x / 2.0, ghost.label.size.y / 2.0)
		ghost.label.add_theme_font_size_override("font_size", 16)
		ghost.label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ghost.label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		ghost.label.add_theme_color_override("font_color", Colors.LIGHT_BASE)
		game_area.add_child(ghost.label)
		
		# Use label as sprite for collision detection
		ghost.sprite = ghost.label
		
		word_ghosts.append(ghost)

func _process(delta: float) -> void:
	if not game_active or is_answering:
		return
	
	# Handle grid-based movement - only move if not already moving
	if not is_moving:
		var requested_direction = Vector2.ZERO
		var backward_direction = -pacman_direction
		
		if Input.is_action_pressed("ui_up"):
			requested_direction = Vector2.UP
		elif Input.is_action_pressed("ui_down"):
			requested_direction = Vector2.DOWN
		elif Input.is_action_pressed("ui_left"):
			requested_direction = Vector2.LEFT
		elif Input.is_action_pressed("ui_right"):
			# Check if at right edge
			if pacman_grid_x < grid_size.x - 3:  # Leave space for word labels
				requested_direction = Vector2.RIGHT
		
		# If a direction is requested, try to move one cell in that direction
		if requested_direction != Vector2.ZERO:
			# Check backward movement flag
			if can_move_backward and requested_direction == backward_direction:
				can_move_backward = false
			
			# Calculate target grid position
			var target_grid_x = pacman_grid_x + int(requested_direction.x)
			var target_grid_y = pacman_grid_y + int(requested_direction.y)
			
			# Check bounds
			if target_grid_x >= 0 and target_grid_x < grid_size.x - 2 and \
			   target_grid_y >= 0 and target_grid_y < grid_size.y:
				# Update direction
				pacman_direction = requested_direction
				# Move to next cell
				_move_to_grid_cell(target_grid_x, target_grid_y)
	
	# Update chomping animation (only when moving)
	if is_moving:
		chomp_timer += delta * chomp_speed
		_update_pacman_mouth(chomp_timer)
	else:
		# When not moving, keep mouth slightly open
		chomp_timer = 0.0
		_update_pacman_mouth(0.0)
	
	# Check for dots to eat and ghost collisions
	_check_dot_collision()
	_check_ghost_collision()

func _move_to_grid_cell(target_x: int, target_y: int) -> void:
	# Mark as moving
	is_moving = true
	
	# Update grid position
	pacman_grid_x = target_x
	pacman_grid_y = target_y
	
	# Calculate target world position (center of grid cell)
	var target_position = Vector2(
		grid_start_x + target_x * cell_size,
		grid_start_y + target_y * cell_size
	)
	
	# Create smooth tween animation to target position
	var half_pacman = pacman_size / 2.0
	var target_visual_pos = target_position - Vector2(half_pacman, half_pacman)
	
	# Kill any existing tween
	if move_tween:
		move_tween.kill()
	
	# Create new tween for smooth movement
	move_tween = create_tween()
	move_tween.set_ease(Tween.EASE_OUT)
	move_tween.set_trans(Tween.TRANS_QUAD)
	
	# Calculate movement duration based on cell size and speed
	var move_distance = cell_size
	var move_duration = move_distance / pacman_speed
	
	# Animate position
	move_tween.tween_property(pacman, "position", target_visual_pos, move_duration)
	move_tween.tween_callback(func(): 
		# Update pacman_position to match
		pacman_position = target_position
		is_moving = false
	)

func _check_dot_collision() -> void:
	# Check if Pac-Man is at a grid cell with a dot
	# Dots are positioned at grid cell centers, so check if current grid position has a dot
	var current_cell_center = Vector2(
		grid_start_x + pacman_grid_x * cell_size,
		grid_start_y + pacman_grid_y * cell_size
	)
	
	# Check dots in reverse order to safely remove them
	for i in range(dots.size() - 1, -1, -1):
		if i >= dots.size() or i >= dot_positions.size():
			continue
		
		var dot_pos = dot_positions[i]
		# Check if dot is at the same grid cell (within small tolerance)
		var distance = current_cell_center.distance_to(dot_pos)
		
		if distance < 5.0:  # Small tolerance for grid alignment
			# Eat the dot
			_eat_dot(i)

func _eat_dot(index: int) -> void:
	if index >= dots.size() or index >= dot_reflections.size() or index >= dot_positions.size():
		return
	
	# Immediately remove dot - no exceptions, instant removal
	if index < dots.size() and is_instance_valid(dots[index]):
		var dot = dots[index]
		dot.visible = false  # Hide immediately
		dot.color.a = 0.0  # Make transparent immediately
		# Remove from scene tree immediately
		if dot.get_parent():
			dot.get_parent().remove_child(dot)
		dot.free()  # Free immediately (not queue_free)
	
	if index < dot_reflections.size() and is_instance_valid(dot_reflections[index]):
		var reflection = dot_reflections[index]
		reflection.visible = false  # Hide immediately
		reflection.color.a = 0.0  # Make transparent immediately
		# Remove from scene tree immediately
		if reflection.get_parent():
			reflection.get_parent().remove_child(reflection)
		reflection.free()  # Free immediately (not queue_free)
	
	# Remove from arrays immediately
	if index < dots.size():
		dots.remove_at(index)
	if index < dot_reflections.size():
		dot_reflections.remove_at(index)
	if index < dot_positions.size():
		dot_positions.remove_at(index)

func _check_ghost_collision() -> void:
	# Check if Pac-Man is at a word's grid cell
	for ghost in word_ghosts:
		if ghost.eaten:
			continue
		
		# Check if Pac-Man is at the same grid cell as this word
		if pacman_grid_x == ghost.grid_x and pacman_grid_y == ghost.grid_y:
			_eat_ghost(ghost)
			break

func _eat_ghost(ghost: WordGhost) -> void:
	if is_answering:
		return
	
	is_answering = true
	game_active = false
	ghost.eaten = true
	
	var q = questions[current_question_index]
	
	# Treat ghost like a dot - allow backward movement once
	can_move_backward = true
	
	if ghost.is_correct:
		# Correct answer - eating animation
		SoundManager.play_correct_sound()
		_play_eating_animation(ghost)
		
		# Show success feedback
		feedback_label.text = "Correct! " + ghost.word + " is a synonym of " + q.target_word + "!"
		feedback_label.add_theme_color_override("font_color", Colors.SUCCESS)
		feedback_label.visible = true
		Anim.create_scale_bounce(feedback_label, 1.0, 0.3)
		
		# Wait for animation, then auto-navigate to next activity
		await get_tree().create_timer(2.0).timeout
		_on_game_complete()
	else:
		# Wrong answer - eating animation
		SoundManager.play_incorrect_sound()
		_play_eating_animation(ghost)
		
		# Show feedback
		feedback_label.text = "Not quite! Try another word!"
		feedback_label.add_theme_color_override("font_color", Colors.WARNING)
		feedback_label.visible = true
		Anim.create_scale_bounce(feedback_label, 1.0, 0.3)
		
		# Reset ghost (label) after animation
		await get_tree().create_timer(1.0).timeout
		ghost.eaten = false
		ghost.label.modulate = Color(1, 1, 1, 1)
		ghost.label.add_theme_color_override("font_color", Colors.LIGHT_BASE)
		
		# Re-enable game - allow backward movement to navigate back
		feedback_label.visible = false
		is_answering = false
		game_active = true
		# can_move_backward remains true so Pac-Man can move backward once

func _play_eating_animation(ghost: WordGhost) -> void:
	# Animate Pac-Man "eating" the word
	# Make word label fade out and shrink
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade out word label
	tween.tween_property(ghost.label, "modulate:a", 0.0, 0.5)
	
	# Shrink word label
	tween.tween_property(ghost.label, "scale", Vector2(0, 0), 0.5)
	
	# Animate Pac-Man chomping (faster chomp during eating)
	var original_timer = chomp_timer
	for i in range(3):  # 3 quick chomps
		chomp_timer += 0.5
		_update_pacman_mouth(chomp_timer)
		await get_tree().create_timer(0.1).timeout
	chomp_timer = original_timer

func _on_game_complete() -> void:
	# Automatically navigate to next activity
	await get_tree().create_timer(0.5).timeout
	GameManager.request_next_activity()

# Next button removed - auto-navigation after celebration
