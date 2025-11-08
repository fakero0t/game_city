extends Control
## Sentence Builder Game (Game 4 of 4)
## Features fox character with tail wiggle animation
## Special: Last game goes directly to completion screen

const CharacterHelper = preload("res://scripts/CharacterHelper.gd")
const Colors = preload("res://scripts/VocabZooColors.gd")
const Anim = preload("res://scripts/VocabZooConstants.gd")

var tail_base_x: float
var wiggle_timer: Timer

func _ready() -> void:
	# Create fox character
	var fox = CharacterHelper.create_fox($Character, Vector2.ZERO, Colors.ORANGE)
	
	# Get tail reference and store base position
	var tail_node = $Character.get_node("Tail")
	if tail_node:
		tail_base_x = tail_node.position.x
		
		# Setup tail wiggle timer (2-second cycle per style guide)
		wiggle_timer = Timer.new()
		wiggle_timer.wait_time = 2.0
		wiggle_timer.timeout.connect(_wiggle_tail)
		add_child(wiggle_timer)
		wiggle_timer.start()
	
	# Connect next button
	$NextButton.pressed.connect(_on_next_pressed)
	$NextButton.mouse_entered.connect(_on_button_hover_enter)
	$NextButton.mouse_exited.connect(_on_button_hover_exit)

func _wiggle_tail() -> void:
	var tail_node = $Character.get_node("Tail")
	if tail_node:
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(tail_node, "position:x", tail_base_x + 10, 0.25)
		tween.tween_property(tail_node, "position:x", tail_base_x - 10, 0.25)
		tween.tween_property(tail_node, "position:x", tail_base_x, 0.25)

func _on_next_pressed() -> void:
	SoundManager.play_click_sound()
	Anim.animate_button_press($NextButton)
	await get_tree().create_timer(0.1).timeout
	
	# Last game - go straight to completion screen (no ready modal)
	GameManager.emit_signal("show_completion_screen")

func _on_button_hover_enter() -> void:
	Anim.create_hover_scale($NextButton, true, 0.2)

func _on_button_hover_exit() -> void:
	Anim.create_hover_scale($NextButton, false, 0.2)

