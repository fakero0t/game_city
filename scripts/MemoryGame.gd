extends Control
## Flashcard Game
## Displays a single word and definition flashcard
## Features cat character with tail wiggle animation

const Colors = preload("res://scripts/VocabZooColors.gd")
const Anim = preload("res://scripts/VocabZooConstants.gd")
const THEME = preload("res://assets/vocab_zoo_theme.tres")

var word_text: String = ""
var definition_text: String = ""
var showing_word: bool = true  # true = showing word, false = showing definition

var fox_image: Sprite2D
var video_player: VideoStreamPlayer
var character_visible: bool = true
var announcement_player: AudioStreamPlayer
var explosion_player: AudioStreamPlayer

# Swipe and example sentence variables
var example_sentence: String = ""
var example_card: Control = null
var is_swiping: bool = false
var swipe_start_pos: Vector2 = Vector2.ZERO
var swipe_threshold: float = 100.0  # Minimum swipe distance

func _ready() -> void:
	# Setup retro sound effects for announcement
	announcement_player = AudioStreamPlayer.new()
	explosion_player = AudioStreamPlayer.new()
	add_child(announcement_player)
	add_child(explosion_player)
	
	# Load retro sci-fi sounds
	var power_up_sound = load("res://assets/Free Retro Sci-Fi Sound Fx/22 Retro Space Power Up #1.mp3")
	var explosion_sound = load("res://assets/Free Retro Sci-Fi Sound Fx/16 Retro Explosion #3.mp3")
	
	if power_up_sound:
		announcement_player.stream = power_up_sound
		announcement_player.volume_db = -8.0
	
	if explosion_sound:
		explosion_player.stream = explosion_sound
		explosion_player.volume_db = -10.0
	
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
	
	# Connect next button (flashcards are special - wait for user to press Next)
	if has_node("NextButton"):
		$NextButton.pressed.connect(_on_next_pressed)
		$NextButton.mouse_entered.connect(_on_button_hover_enter)
		$NextButton.mouse_exited.connect(_on_button_hover_exit)
		$NextButton.disabled = true
	
	# Hide grid container (memory match UI)
	if has_node("GridContainer"):
		$GridContainer.hide()
	
	# Wait for activity data to be loaded via load_activity_data()

## Load activity data from API
func load_activity_data(activity_data: Dictionary) -> void:
	var word_data = activity_data["word"]
	
	# Extract word and definition
	word_text = word_data.get("headword", "")
	definition_text = word_data.get("definition", "")
	
	# Extract example sentence from params.options
	var params = activity_data.get("params", {})
	var options = params.get("options", [])
	
	# Find the correct example sentence (contains the word)
	for option in options:
		if option is Dictionary:
			var sentence_text = option.get("text", "")
			# Check if this sentence contains the word
			if sentence_text.to_lower().contains(word_text.to_lower()):
				example_sentence = sentence_text
				break
	
	# Setup flashcard display
	_setup_flashcard()

func _setup_flashcard() -> void:
	# Show announcement first, then flashcard
	await _show_new_word_announcement()
	
	# Create or get flashcard button
	var flashcard_button: Button
	if has_node("FlashcardButton"):
		flashcard_button = $FlashcardButton
	else:
		# Create flashcard button if it doesn't exist
		flashcard_button = Button.new()
		flashcard_button.name = "FlashcardButton"
		flashcard_button.size = Vector2(400, 300)
		flashcard_button.position = Vector2(200, 150)
		add_child(flashcard_button)
	
	# Create white card stylebox with rounded edges and depth
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color.WHITE
	card_style.corner_radius_top_left = 16
	card_style.corner_radius_top_right = 16
	card_style.corner_radius_bottom_left = 16
	card_style.corner_radius_bottom_right = 16
	# Add subtle shadow for depth (matching image style)
	card_style.shadow_color = Color(0, 0, 0, 0.15)
	card_style.shadow_size = 6
	card_style.shadow_offset = Vector2(0, 3)
	
	# Setup flashcard button
	flashcard_button.text = word_text
	flashcard_button.autowrap_mode = TextServer.AUTOWRAP_WORD
	flashcard_button.add_theme_font_size_override("font_size", 32)
	flashcard_button.add_theme_stylebox_override("normal", card_style)
	flashcard_button.add_theme_stylebox_override("hover", card_style)
	flashcard_button.add_theme_stylebox_override("pressed", card_style)
	flashcard_button.add_theme_stylebox_override("disabled", card_style)
	# Set text color to black for ALL states - ensures text is always black
	flashcard_button.add_theme_color_override("font_color", Color.BLACK)
	flashcard_button.add_theme_color_override("font_hover_color", Color.BLACK)
	flashcard_button.add_theme_color_override("font_pressed_color", Color.BLACK)
	flashcard_button.add_theme_color_override("font_disabled_color", Color.BLACK)
	flashcard_button.add_theme_color_override("font_focus_color", Color.BLACK)
	flashcard_button.pressed.connect(_on_flashcard_pressed)
	
	showing_word = true
	
	# Next button stays disabled until user clicks the flashcard

func _show_new_word_announcement() -> void:
	# Create announcement label with retro font
	var announcement_label = Label.new()
	announcement_label.name = "AnnouncementLabel"
	announcement_label.text = "NEW WORD"
	announcement_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	announcement_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Load retro font
	var retro_font = load("res://assets/fonts/press-start-2p.ttf")
	if retro_font:
		announcement_label.add_theme_font_override("font", retro_font)
	
	# Style the label with bright retro colors
	announcement_label.add_theme_font_size_override("font_size", 48)
	announcement_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))  # Bright yellow
	announcement_label.add_theme_color_override("font_outline_color", Color(1.0, 0.3, 0.0))  # Orange outline
	announcement_label.add_theme_constant_override("outline_size", 8)
	
	# Position in center of screen
	announcement_label.position = Vector2(640 - 250, 360 - 50)
	announcement_label.size = Vector2(500, 100)
	
	# Start invisible and scaled down
	announcement_label.modulate.a = 0
	announcement_label.scale = Vector2.ZERO
	announcement_label.rotation = 0
	
	add_child(announcement_label)
	
	# Play power-up sound
	if announcement_player:
		announcement_player.play()
	
	# Animate spinning in
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	
	# Scale and fade in while spinning
	tween.tween_property(announcement_label, "scale", Vector2(1.2, 1.2), 0.6)
	tween.tween_property(announcement_label, "modulate:a", 1.0, 0.4)
	tween.tween_property(announcement_label, "rotation", TAU * 2, 0.6)  # Two full rotations
	
	await tween.finished
	
	# Pulse effect while displayed
	var pulse_tween = create_tween()
	pulse_tween.set_loops(3)
	pulse_tween.tween_property(announcement_label, "scale", Vector2(1.3, 1.3), 0.15)
	pulse_tween.tween_property(announcement_label, "scale", Vector2(1.2, 1.2), 0.15)
	
	await pulse_tween.finished
	
	# Wait a moment
	await get_tree().create_timer(0.3).timeout
	
	# Play explosion sound
	if explosion_player:
		explosion_player.play()
	
	# Explode out animation
	var explode_tween = create_tween()
	explode_tween.set_parallel(true)
	explode_tween.set_trans(Tween.TRANS_EXPO)
	explode_tween.set_ease(Tween.EASE_IN)
	
	explode_tween.tween_property(announcement_label, "scale", Vector2(3.0, 3.0), 0.3)
	explode_tween.tween_property(announcement_label, "modulate:a", 0.0, 0.3)
	explode_tween.tween_property(announcement_label, "rotation", TAU * 3, 0.3)
	
	await explode_tween.finished
	
	# Clean up
	announcement_label.queue_free()

func _on_flashcard_pressed() -> void:
	SoundManager.play_click_sound()
	
	# Flip between word and definition
	showing_word = !showing_word
	var flashcard_button = $FlashcardButton
	
	# Update text
	if showing_word:
		flashcard_button.text = word_text
	else:
		flashcard_button.text = definition_text
	
	# Enable next button after first flip (when showing definition)
	if not showing_word and has_node("NextButton"):
		$NextButton.disabled = false
	
	# Ensure text color remains black after flip (all states)
	flashcard_button.add_theme_color_override("font_color", Color.BLACK)
	flashcard_button.add_theme_color_override("font_hover_color", Color.BLACK)
	flashcard_button.add_theme_color_override("font_pressed_color", Color.BLACK)
	flashcard_button.add_theme_color_override("font_disabled_color", Color.BLACK)
	flashcard_button.add_theme_color_override("font_focus_color", Color.BLACK)
	
	# Flip animation
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(flashcard_button, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_property(flashcard_button, "scale", Vector2.ONE, 0.1)


func _on_video_finished() -> void:
	# Hide video player and show fox image again
	video_player.visible = false
	fox_image.visible = true

func _input(event: InputEvent) -> void:
	# Detect swipe gestures
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			# Touch/click started
			swipe_start_pos = event.position
			is_swiping = true
		else:
			# Touch/click released
			if is_swiping:
				var swipe_end_pos = event.position
				var swipe_vector = swipe_end_pos - swipe_start_pos
				var swipe_distance = swipe_vector.length()
				
				if swipe_distance > swipe_threshold:
					# Determine swipe direction (vertical only)
					var swipe_direction = swipe_vector.normalized()
					
					# Swipe up (negative Y)
					if swipe_direction.y < -0.5 and example_card == null and not example_sentence.is_empty():
						_show_example_sentence_card()
						get_viewport().set_input_as_handled()
					
					# Swipe down (positive Y)
					elif swipe_direction.y > 0.5 and example_card != null:
						_hide_example_sentence_card()
						get_viewport().set_input_as_handled()
				
				is_swiping = false

func _show_example_sentence_card() -> void:
	# Create card container
	example_card = Control.new()
	example_card.name = "ExampleCard"
	example_card.z_index = 100  # Above everything
	
	# Calculate card size and position
	var viewport_size = get_viewport_rect().size
	var card_width = viewport_size.x * 0.8
	var card_height = 200.0  # Will expand based on text
	
	example_card.size = Vector2(card_width, card_height)
	example_card.position = Vector2(
		(viewport_size.x - card_width) / 2.0,
		viewport_size.y  # Start off-screen at bottom
	)
	
	add_child(example_card)
	
	# Create white card background with rounded corners
	var card_bg = Panel.new()
	card_bg.name = "Background"
	card_bg.size = Vector2(card_width, card_height)
	
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color.WHITE
	card_style.corner_radius_top_left = 16
	card_style.corner_radius_top_right = 16
	card_style.corner_radius_bottom_left = 16
	card_style.corner_radius_bottom_right = 16
	card_style.shadow_color = Color(0, 0, 0, 0.2)
	card_style.shadow_size = 8
	card_style.shadow_offset = Vector2(0, 4)
	
	card_bg.add_theme_stylebox_override("panel", card_style)
	example_card.add_child(card_bg)
	
	# Create RichTextLabel for highlighted text
	var text_label = RichTextLabel.new()
	text_label.name = "TextLabel"
	text_label.size = Vector2(card_width - 40, card_height - 40)
	text_label.position = Vector2(20, 20)
	text_label.bbcode_enabled = true
	text_label.fit_content = true
	text_label.scroll_active = false
	text_label.add_theme_font_size_override("normal_font_size", 20)
	text_label.add_theme_color_override("default_color", Color.BLACK)
	
	# Highlight the word in the sentence
	var highlighted_text = example_sentence.replace(
		word_text,
		"[b][color=#8B5CF6]" + word_text + "[/color][/b]"
	)
	# Handle case insensitive
	var lower_word = word_text.to_lower()
	var lower_sentence = example_sentence.to_lower()
	var word_pos = lower_sentence.find(lower_word)
	if word_pos >= 0:
		var actual_word = example_sentence.substr(word_pos, word_text.length())
		highlighted_text = example_sentence.replace(
			actual_word,
			"[b][color=#8B5CF6]" + actual_word + "[/color][/b]"
		)
	
	text_label.text = "[center]" + highlighted_text + "[/center]"
	example_card.add_child(text_label)
	
	# Play power-up sound
	if announcement_player:
		announcement_player.play()
	
	# Animate sliding up
	var target_y = viewport_size.y - card_height - 40  # 40px from bottom
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(example_card, "position:y", target_y, 0.3)

func _hide_example_sentence_card() -> void:
	if example_card == null:
		return
	
	# Play sound
	SoundManager.play_click_sound()
	
	# Animate sliding down off-screen
	var viewport_size = get_viewport_rect().size
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(example_card, "position:y", viewport_size.y, 0.25)
	
	await tween.finished
	
	# Clean up
	if is_instance_valid(example_card):
		example_card.queue_free()
	example_card = null

func _on_next_pressed() -> void:
	SoundManager.play_click_sound()
	Anim.animate_button_press($NextButton)
	await get_tree().create_timer(0.4).timeout
	# Request next activity
	GameManager.request_next_activity()

func _on_button_hover_enter() -> void:
	if has_node("NextButton") and not $NextButton.disabled:
		Anim.create_hover_scale($NextButton, true, 0.2)

func _on_button_hover_exit() -> void:
	if has_node("NextButton"):
		Anim.create_hover_scale($NextButton, false, 0.2)
