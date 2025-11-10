extends Control
## Main Screen - Entry point for vocab console
## Handles main menu, modals, and game container loading

var modal_scene = preload("res://scenes/Modal.tscn")
var error_scene = preload("res://scenes/VocabularyError.tscn")
var modal_instance = null

const Colors = preload("res://scripts/VocabZooColors.gd")
const Anim = preload("res://scripts/VocabZooConstants.gd")

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
	GameManager.show_error_toast.connect(_show_error_toast)
	GameManager.show_completion_screen.connect(_show_completion_screen)
	
	# Initially hide game container
	game_container.hide()

func _input(event: InputEvent) -> void:
	# Check for spacebar press on main menu
	if event.is_action_pressed("ui_accept") and menu_container.visible:
		start_button.emit_signal("pressed")
		get_viewport().set_input_as_handled()

func _on_start_pressed() -> void:
	# Check if vocabulary is loaded
	if not VocabularyManager.is_vocabulary_ready():
		_on_vocabulary_load_failed(VocabularyManager.get_load_error())
		return
	
	# Play click sound and animate button press
	SoundManager.play_click_sound()
	Anim.animate_button_press(start_button)
	
	# Wait briefly for animation
	await get_tree().create_timer(0.1).timeout
	
	# Hide main menu
	menu_container.hide()
	
	# Request first activity directly (skip modal)
	GameManager.request_next_activity()

func _show_info_modal() -> void:
	modal_instance = modal_scene.instantiate()
	modal_layer.add_child(modal_instance)
	
	var body_text = "[center]Ready to start? Let's go![/center]"
	
	modal_instance.show_modal("Welcome, Friend! 🎉", body_text, "Let's Go!")
	modal_instance.modal_action_pressed.connect(_on_info_modal_action)

func _on_info_modal_action() -> void:
	modal_instance.hide_modal()
	await modal_instance.modal_closed
	modal_instance = null
	
	# Request first activity
	GameManager.request_next_activity()

func _on_load_game_scene(scene_path: String, activity_data: Dictionary = {}) -> void:
	# Clear previous game if exists
	for child in game_container.get_children():
		child.queue_free()
	
	# Load new game
	var game_scene = load(scene_path).instantiate()
	game_container.add_child(game_scene)
	game_container.show()
	
	# Pass activity data to game if provided
	if not activity_data.is_empty():
		if game_scene.has_method("load_activity_data"):
			game_scene.load_activity_data(activity_data)

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

func _show_error_toast(message: String) -> void:
	# Create simple toast notification
	var toast = Label.new()
	toast.text = message
	toast.add_theme_color_override("font_color", Colors.LIGHT_BASE)
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Position at bottom center
	toast.position = Vector2(get_viewport_rect().size.x / 2 - 150, get_viewport_rect().size.y - 100)
	toast.size = Vector2(300, 50)
	add_child(toast)
	
	# Fade in, wait, fade out, remove
	toast.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(toast, "modulate:a", 1.0, 0.3)
	tween.tween_interval(2.0)
	tween.tween_property(toast, "modulate:a", 0.0, 0.3)
	tween.tween_callback(toast.queue_free)

func _load_platformer_level() -> void:
	# Clear previous game if exists
	for child in game_container.get_children():
		child.queue_free()
	
	# Load platformer level
	var platformer_scene = load("res://scenes/PlatformerLevel.tscn").instantiate()
	game_container.add_child(platformer_scene)
	game_container.show()
