extends Control
## Flashcard Game
## Displays a single word and definition flashcard
## Features cat character with tail wiggle animation

const CharacterHelper = preload("res://scripts/CharacterHelper.gd")
const Colors = preload("res://scripts/VocabZooColors.gd")
const Anim = preload("res://scripts/VocabZooConstants.gd")
const THEME = preload("res://assets/vocab_zoo_theme.tres")

var word_text: String = ""
var definition_text: String = ""
var showing_word: bool = true  # true = showing word, false = showing definition

# Tail animation
var tail_base_x: float
var wiggle_timer: Timer

func _ready() -> void:
	# Create cat character
	var cat = CharacterHelper.create_cat($Character, Vector2.ZERO, Colors.PRIMARY_PURPLE)
	var tail_node = $Character.get_node_or_null("Tail")
	if tail_node:
		tail_base_x = tail_node.position.x
		
		# Setup tail wiggle timer
		wiggle_timer = Timer.new()
		wiggle_timer.wait_time = 2.0
		wiggle_timer.timeout.connect(_wiggle_tail)
		add_child(wiggle_timer)
		wiggle_timer.start()
	
	# Connect next button
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
	
	# Setup flashcard button
	flashcard_button.text = word_text
	flashcard_button.autowrap_mode = TextServer.AUTOWRAP_WORD
	flashcard_button.add_theme_font_size_override("font_size", 32)
	flashcard_button.add_theme_stylebox_override("normal", THEME.get_stylebox("button_memory_up", "Button"))
	flashcard_button.add_theme_stylebox_override("hover", THEME.get_stylebox("button_memory_up", "Button"))
	flashcard_button.add_theme_stylebox_override("pressed", THEME.get_stylebox("button_memory_up", "Button"))
	flashcard_button.add_theme_color_override("font_color", Colors.DARK_BASE)
	flashcard_button.pressed.connect(_on_flashcard_pressed)
	
	showing_word = true
	
	# Enable next button after a short delay
	await get_tree().create_timer(1.0).timeout
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
	
	# Flip animation
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(flashcard_button, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_property(flashcard_button, "scale", Vector2.ONE, 0.1)


func _wiggle_tail() -> void:
	var tail_node = $Character.get_node_or_null("Tail")
	if not tail_node:
		return
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(tail_node, "position:x", tail_base_x + 10, 0.25)
	tween.tween_property(tail_node, "position:x", tail_base_x - 10, 0.25)
	tween.tween_property(tail_node, "position:x", tail_base_x, 0.25)

func _on_next_pressed() -> void:
	SoundManager.play_click_sound()
	Anim.animate_button_press($NextButton)
	await get_tree().create_timer(0.4).timeout
	# Request next activity instead of fixed sequence
	GameManager.request_next_activity()

func _on_button_hover_enter() -> void:
	if not $NextButton.disabled:
		Anim.create_hover_scale($NextButton, true, 0.2)

func _on_button_hover_exit() -> void:
	Anim.create_hover_scale($NextButton, false, 0.2)

