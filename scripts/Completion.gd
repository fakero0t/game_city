extends Control
## Completion Screen - Simple end screen showing activity completion

const Anim = preload("res://scripts/VocabZooConstants.gd")

func _ready() -> void:
	_display_completion_message()
	
	# Connect Play Again button
	$PlayAgainButton.pressed.connect(_on_play_again_pressed)
	$PlayAgainButton.mouse_entered.connect(_on_button_hover_enter)
	$PlayAgainButton.mouse_exited.connect(_on_button_hover_exit)

func _display_completion_message() -> void:
	# Get session stats from GameManager
	var activities_count = GameManager.activities_completed
	var elapsed_time = Time.get_unix_time_from_system() - GameManager.session_start_time
	var minutes = int(elapsed_time / 60)
	var seconds = int(elapsed_time) % 60
	
	# Show simple completion message with stats
	var message = "You completed %d activities in %d:%02d" % [activities_count, minutes, seconds]
	$CenterContent/VBoxContainer/MessageLabel.text = message

func _on_play_again_pressed() -> void:
	SoundManager.play_click_sound()
	Anim.animate_button_press($PlayAgainButton)
	await get_tree().create_timer(0.1).timeout
	
	GameManager.reset_flow()
	# Return to main screen
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_button_hover_enter() -> void:
	Anim.create_hover_scale($PlayAgainButton, true, 0.2)

func _on_button_hover_exit() -> void:
	Anim.create_hover_scale($PlayAgainButton, false, 0.2)
