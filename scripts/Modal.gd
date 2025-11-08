extends Control
## Reusable Modal Component
## Displays centered modal with title, body text, and action button
## Includes entrance and exit animations per style guide

signal modal_action_pressed()
signal modal_closed()

@onready var overlay = $Overlay
@onready var modal_panel = $CenterContainer/ModalPanel
@onready var title_label = $CenterContainer/ModalPanel/ModalContent/TitleLabel
@onready var body_label = $CenterContainer/ModalPanel/ModalContent/BodyLabel
@onready var action_button = $CenterContainer/ModalPanel/ModalContent/ButtonContainer/ActionButton

func _ready() -> void:
	# Initially hidden
	modulate.a = 0
	modal_panel.scale = Vector2(0.9, 0.9)
	
	# Connect button
	action_button.pressed.connect(_on_action_button_pressed)
	
	# Connect hover animations
	action_button.mouse_entered.connect(_on_button_hover_enter)
	action_button.mouse_exited.connect(_on_button_hover_exit)

func show_modal(title: String, body: String, button_text: String) -> void:
	title_label.text = title
	body_label.text = body
	action_button.text = button_text
	
	show()
	_play_entrance_animation()

func hide_modal() -> void:
	_play_exit_animation()

func _play_entrance_animation() -> void:
	# Entrance animation per style guide:
	# - Overlay fades in 0→1 over 0.2s
	# - Panel scales 0.9→1.0 with TRANS_BACK bounce over 0.3s
	
	# Overlay fade in
	var overlay_tween = create_tween()
	overlay_tween.tween_property(self, "modulate:a", 1.0, 0.2).from(0.0)
	
	# Panel scale with bounce
	var panel_tween = create_tween()
	panel_tween.set_ease(Tween.EASE_OUT)
	panel_tween.set_trans(Tween.TRANS_BACK)
	panel_tween.tween_property(modal_panel, "scale", Vector2.ONE, 0.3).from(Vector2(0.9, 0.9))

func _play_exit_animation() -> void:
	# Exit animation per style guide:
	# - Panel scales to 0.95 + fades over 0.2s (EASE_IN)
	# - Overlay fades out over 0.2s
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN)
	
	# Panel scale down and fade
	tween.tween_property(modal_panel, "scale", Vector2(0.95, 0.95), 0.2)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	
	tween.finished.connect(func():
		emit_signal("modal_closed")
		queue_free()
	)

func _on_action_button_pressed() -> void:
	# Play click sound and use button press animation helper
	SoundManager.play_click_sound()
	const Anim = preload("res://scripts/VocabZooConstants.gd")
	Anim.animate_button_press(action_button)
	
	# Wait briefly for animation to start
	await get_tree().create_timer(0.1).timeout
	
	emit_signal("modal_action_pressed")

func _on_button_hover_enter() -> void:
	const Anim = preload("res://scripts/VocabZooConstants.gd")
	Anim.create_hover_scale(action_button, true, 0.2)

func _on_button_hover_exit() -> void:
	const Anim = preload("res://scripts/VocabZooConstants.gd")
	Anim.create_hover_scale(action_button, false, 0.2)

