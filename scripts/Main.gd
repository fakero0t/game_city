extends Control
## Main Screen - Entry point for Vocabulary Cat
## Handles main menu, modals, and game container loading

var modal_scene = preload("res://scenes/Modal.tscn")
var error_scene = preload("res://scenes/VocabularyError.tscn")
var modal_instance = null

const Colors = preload("res://scripts/VocabCatColors.gd")
const Anim = preload("res://scripts/VocabCatConstants.gd")

@onready var title_label = $MenuContainer/VBoxContainer/TitleLabel
@onready var start_button = $MenuContainer/VBoxContainer/StartButton
@onready var menu_container = $MenuContainer
@onready var game_container = $GameContainer
@onready var modal_layer = $ModalLayer

func _ready() -> void:
	# Connect vocabulary signals
	VocabularyManager.vocabulary_load_failed.connect(_on_vocabulary_load_failed)
	VocabularyManager.vocabulary_loaded_successfully.connect(_on_vocabulary_loaded)
	
	# Connect Start button
	start_button.pressed.connect(_on_start_pressed)
	start_button.mouse_entered.connect(_on_start_button_hover_enter)
	start_button.mouse_exited.connect(_on_start_button_hover_exit)
	
	# Connect GameManager signals
	GameManager.load_game_scene.connect(_on_load_game_scene)
	GameManager.show_info_modal.connect(_show_info_modal)
	GameManager.show_ready_modal.connect(_show_ready_modal)
	GameManager.show_completion_screen.connect(_show_completion_screen)
	
	# Initially hide game container
	game_container.hide()

func _on_start_pressed() -> void:
	# Check if vocabulary is loaded
	if not VocabularyManager.is_vocabulary_ready():
		_on_vocabulary_load_failed(VocabularyManager.get_load_error())
		return
	
	# Animate button press
	Anim.animate_button_press(start_button)
	
	# Wait briefly for animation
	await get_tree().create_timer(0.1).timeout
	
	# Hide main menu
	menu_container.hide()
	
	# Show info modal
	_show_info_modal()

func _show_info_modal() -> void:
	modal_instance = modal_scene.instantiate()
	modal_layer.add_child(modal_instance)
	
	var body_text = "[center]You have [b]five awesome games[/b] to complete today:\n\n"
	body_text += "🧠 [b]Memory Match[/b] - Find the pairs!\n"
	body_text += "✅ [b]Pick the Meaning[/b] - Choose the definition\n"
	body_text += "✏️ [b]Complete the Sentence[/b] - Fill in the blank\n"
	body_text += "🔄 [b]Word Relationships[/b] - Find synonyms & antonyms\n"
	body_text += "🎯 [b]Match the Meaning[/b] - Which word fits?\n\n"
	body_text += "Ready to start? Let's go![/center]"
	
	modal_instance.show_modal("Welcome, Friend! 🎉", body_text, "Let's Go!")
	modal_instance.modal_action_pressed.connect(_on_info_modal_action)

func _on_info_modal_action() -> void:
	modal_instance.hide_modal()
	await modal_instance.modal_closed
	modal_instance = null
	
	# Load first game
	GameManager.advance_to_next_game()

func _show_ready_modal(completed_game: String, next_game: String) -> void:
	modal_instance = modal_scene.instantiate()
	modal_layer.add_child(modal_instance)
	
	var body_text = "[center]You completed [b]%s[/b]!\n\n" % completed_game
	body_text += "Are you ready for the next game?[/center]"
	
	modal_instance.show_modal("Great Job! 🎉", body_text, "Next Game")
	modal_instance.modal_action_pressed.connect(_on_ready_modal_action)

func _on_ready_modal_action() -> void:
	modal_instance.hide_modal()
	await modal_instance.modal_closed
	modal_instance = null
	
	# Advance to next game
	GameManager.advance_to_next_game()

func _on_load_game_scene(scene_path: String) -> void:
	# Clear previous game if exists
	for child in game_container.get_children():
		child.queue_free()
	
	# Load new game
	var game_scene = load(scene_path).instantiate()
	game_container.add_child(game_scene)
	game_container.show()

func _show_completion_screen() -> void:
	# Clear game container
	for child in game_container.get_children():
		child.queue_free()
	
	# Load completion screen
	var completion_scene = load("res://scenes/Completion.tscn").instantiate()
	game_container.add_child(completion_scene)
	game_container.show()

func _on_start_button_hover_enter() -> void:
	Anim.create_hover_scale(start_button, true, 0.2)

func _on_start_button_hover_exit() -> void:
	Anim.create_hover_scale(start_button, false, 0.2)

func _on_vocabulary_load_failed(error_message: String) -> void:
	# Hide main menu
	menu_container.hide()
	
	# Show error screen
	var error_screen = error_scene.instantiate()
	game_container.add_child(error_screen)
	error_screen.set_error_message(error_message)
	error_screen._play_entrance_animation()
	game_container.show()

func _on_vocabulary_loaded() -> void:
	print("Vocabulary ready: ", VocabularyManager.get_all_words().size(), " words loaded")
