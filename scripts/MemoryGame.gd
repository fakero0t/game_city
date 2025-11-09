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
	
	# Setup flashcard display
	_setup_flashcard()

func _setup_flashcard() -> void:
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
	
	# Enable next button after a short delay (flashcards wait for user to press Next)
	await get_tree().create_timer(1.0).timeout
	if has_node("NextButton"):
		$NextButton.disabled = false

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
