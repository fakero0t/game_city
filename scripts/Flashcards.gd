extends Control
## Flashcards Game - API-driven flashcard activity
## User clicks card to cycle through word, definition, and example

const Colors = preload("res://scripts/VocabZooColors.gd")
const Anim = preload("res://scripts/VocabZooConstants.gd")

var activity_data: Dictionary = {}
var current_side: int = 0  # 0 = word, 1 = definition, 2 = example
var has_completed_cycle: bool = false
var fox_image: Sprite2D
var video_player: VideoStreamPlayer
var title_label: Label
var card_type_label: Label

@onready var card = $CardContainer/Card
@onready var front_side = $CardContainer/Card/FrontSide
@onready var back_side = $CardContainer/Card/BackSide
@onready var example_side = $CardContainer/Card/ExampleSide
@onready var word_label = $CardContainer/Card/FrontSide/WordLabel
@onready var definition_label = $CardContainer/Card/BackSide/DefinitionLabel
@onready var example_label = $CardContainer/Card/ExampleSide/ExampleLabel
@onready var progress_label = $ProgressLabel
@onready var next_button = $NextButton

func _ready() -> void:
	# Create fox image from fox.png
	fox_image = Sprite2D.new()
	fox_image.name = "FoxImage"
	var texture = load("res://assets/fox.png")
	if texture:
		fox_image.texture = texture
		fox_image.scale = Vector2(0.5, 0.5)
	else:
		push_error("Failed to load fox.png - please reimport the image in Godot (right-click -> Reimport)")
	$Character.add_child(fox_image)
	
	# Create video player for animations (hidden initially)
	video_player = VideoStreamPlayer.new()
	video_player.name = "VideoPlayer"
	video_player.size = Vector2(200, 200)
	video_player.position = $Character.position - Vector2(100, 100)
	video_player.visible = false
	add_child(video_player)
	video_player.finished.connect(_on_video_finished)
	
	# Create hovering title "NEW WORD UNLOCKED!!!"
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "NEW WORD UNLOCKED!!!"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Style the title
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", Colors.PRIMARY_BLUE)
	title_label.add_theme_color_override("font_outline_color", Colors.DARK_BASE)
	title_label.add_theme_constant_override("outline_size", 3)
	
	# Position at top center - span full width for proper centering
	var viewport_size = get_viewport_rect().size
	title_label.position = Vector2(0, 60)
	title_label.size = Vector2(viewport_size.x, 50)
	add_child(title_label)
	
	# Create card type label (shows current side: word, definition, or example)
	card_type_label = Label.new()
	card_type_label.name = "CardTypeLabel"
	card_type_label.text = "WORD"
	card_type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card_type_label.add_theme_font_size_override("font_size", 18)
	card_type_label.add_theme_color_override("font_color", Colors.PRIMARY_BLUE)
	card_type_label.position = Vector2(0, 110)
	card_type_label.size = Vector2(viewport_size.x, 30)
	add_child(card_type_label)
	
	# Add floating animation like space invader ships
	_animate_title_hover()
	
	# Enable mouse input on the entire card and set cursor to pointing hand
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	# Connect card click
	card.gui_input.connect(_on_card_gui_input)
	
	# Connect next button (starts disabled)
	next_button.disabled = true
	next_button.pressed.connect(_on_next_pressed)
	next_button.mouse_entered.connect(_on_button_hover_enter)
	next_button.mouse_exited.connect(_on_button_hover_exit)

func load_activity_data(data: Dictionary) -> void:
	activity_data = data
	_setup_flashcard()

func _setup_flashcard() -> void:
	# Extract word data from API response
	var word_data = activity_data.get("word", {})
	var params = activity_data.get("params", {})
	var phase_progress = activity_data.get("phaseProgress", {})
	
	# Set word and definition
	word_label.text = word_data.get("headword", "Word")
	definition_label.text = word_data.get("definition", "Definition")
	
	# Set example sentence (try both camelCase and snake_case for compatibility)
	var example_sentence = word_data.get("exampleSentence", "")
	if example_sentence.is_empty():
		example_sentence = word_data.get("example_sentence", "")
	if example_sentence.is_empty():
		example_sentence = "Example: This is a sentence using the word."
	example_label.text = example_sentence
	
	# Set progress
	var current = phase_progress.get("current", 1)
	var total = phase_progress.get("total", 1)
	progress_label.text = "%d of %d" % [current, total]
	
	# Reset states
	current_side = 0
	has_completed_cycle = false
	front_side.visible = true
	back_side.visible = false
	example_side.visible = false
	next_button.disabled = true
	card_type_label.text = "WORD"

func _input(event: InputEvent) -> void:
	# Handle spacebar to flip card
	if event.is_action_pressed("ui_accept"):
		_flip_card()

func _on_card_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_flip_card()

func _flip_card() -> void:
	# Play click sound
	SoundManager.play_click_sound()
	
	# Animate flip
	var tween = create_tween()
	tween.set_parallel(false)
	
	# Shrink horizontally to simulate flip
	tween.tween_property(card, "scale:x", 0.0, 0.15)
	
	# Switch sides at the middle of animation
	tween.tween_callback(func():
		# Cycle to next side
		current_side = (current_side + 1) % 3
		
		# Update visibility based on current side
		front_side.visible = (current_side == 0)
		back_side.visible = (current_side == 1)
		example_side.visible = (current_side == 2)
		
		# Update card type label
		match current_side:
			0:
				card_type_label.text = "WORD"
			1:
				card_type_label.text = "DEFINITION"
			2:
				card_type_label.text = "EXAMPLE"
		
		# Mark as completed cycle if we've returned to start
		if current_side == 0 and !has_completed_cycle:
			has_completed_cycle = true
			next_button.disabled = false
	)
	
	# Expand back to normal
	tween.tween_property(card, "scale:x", 1.0, 0.15)
	
	# Play fox animation when flipping to definition
	if current_side == 1:
		_play_fox_jump()

func _on_video_finished() -> void:
	video_player.visible = false
	fox_image.visible = true

func _play_fox_jump() -> void:
	fox_image.visible = false
	var stream = load("res://assets/fox_jump.ogv")
	if stream:
		video_player.stream = stream
		video_player.visible = true
		video_player.play()
	else:
		push_warning("fox_jump.ogv not found - convert fox_jump.mp4 to Ogg Theora format")
		fox_image.visible = true

func _play_fox_shake() -> void:
	fox_image.visible = false
	var stream = load("res://assets/fox_shake.ogv")
	if stream:
		video_player.stream = stream
		video_player.visible = true
		video_player.play()
	else:
		push_warning("fox_shake.ogv not found - convert fox_shake.mp4 to Ogg Theora format")
		fox_image.visible = true

func _on_next_pressed() -> void:
	SoundManager.play_click_sound()
	Anim.animate_button_press(next_button)
	await get_tree().create_timer(0.1).timeout
	GameManager.emit_signal("game_completed", "Flashcards")

func _animate_title_hover() -> void:
	# First, pulse 3 times (larger to smaller)
	var pulse_tween = create_tween()
	pulse_tween.set_trans(Tween.TRANS_SINE)
	pulse_tween.set_ease(Tween.EASE_IN_OUT)
	
	# Pulse 3 times
	for i in range(3):
		pulse_tween.tween_property(title_label, "scale", Vector2(1.2, 1.2), 0.3)
		pulse_tween.tween_property(title_label, "scale", Vector2(1.0, 1.0), 0.3)
	
	# After pulsing, start floating animation (gentle up and down movement)
	await pulse_tween.finished
	
	var base_y = title_label.position.y
	var float_tween = create_tween()
	float_tween.set_loops()
	float_tween.set_ease(Tween.EASE_IN_OUT)
	float_tween.set_trans(Tween.TRANS_SINE)
	float_tween.tween_property(title_label, "position:y", base_y - 8, 1.5)
	float_tween.tween_property(title_label, "position:y", base_y + 8, 1.5)

func _on_button_hover_enter() -> void:
	if !next_button.disabled:
		Anim.create_hover_scale(next_button, true, 0.2)

func _on_button_hover_exit() -> void:
	Anim.create_hover_scale(next_button, false, 0.2)
