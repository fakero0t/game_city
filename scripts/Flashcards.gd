extends Control
## Flashcards Game (Game 1 of 4)
## Features fox image

const Colors = preload("res://scripts/VocabZooColors.gd")
const Anim = preload("res://scripts/VocabZooConstants.gd")

var fox_image: Sprite2D
var video_player: VideoStreamPlayer

func _ready() -> void:
	# Create fox image from fox.png
	fox_image = Sprite2D.new()
	fox_image.name = "FoxImage"
	# Try loading the texture - if it fails, the image needs to be reimported in Godot
	var texture = load("res://assets/fox.png")
	if texture:
		fox_image.texture = texture
		fox_image.scale = Vector2(0.5, 0.5)  # Adjust scale as needed
	else:
		push_error("Failed to load fox.png - please reimport the image in Godot (right-click -> Reimport)")
	$Character.add_child(fox_image)
	
	# Create video player for animations (hidden initially)
	# Note: VideoStreamPlayer is a Control node, so we add it to the root Control, not Character
	video_player = VideoStreamPlayer.new()
	video_player.name = "VideoPlayer"
	video_player.size = Vector2(200, 200)
	video_player.position = $Character.position - Vector2(100, 100)  # Position relative to Character's world position
	video_player.visible = false
	add_child(video_player)
	video_player.finished.connect(_on_video_finished)
	
	# Connect next button
	$NextButton.pressed.connect(_on_next_pressed)
	$NextButton.mouse_entered.connect(_on_button_hover_enter)
	$NextButton.mouse_exited.connect(_on_button_hover_exit)

func _on_video_finished() -> void:
	# Hide video player and show fox image again
	video_player.visible = false
	fox_image.visible = true

func _play_fox_jump() -> void:
	# Play fox_jump video (must be .ogv format for Godot)
	# Convert your MP4 to Ogg Theora (.ogv) format
	fox_image.visible = false
	var stream = load("res://assets/fox_jump.ogv")  # Changed from .mp4 to .ogv
	if stream:
		video_player.stream = stream
		video_player.visible = true
		video_player.play()
	else:
		push_warning("fox_jump.ogv not found - convert fox_jump.mp4 to Ogg Theora format")
		fox_image.visible = true

func _play_fox_shake() -> void:
	# Play fox_shake video (must be .ogv format for Godot)
	# Convert your MP4 to Ogg Theora (.ogv) format
	fox_image.visible = false
	var stream = load("res://assets/fox_shake.ogv")  # Changed from .mp4 to .ogv
	if stream:
		video_player.stream = stream
		video_player.visible = true
		video_player.play()
	else:
		push_warning("fox_shake.ogv not found - convert fox_shake.mp4 to Ogg Theora format")
		fox_image.visible = true

func _on_next_pressed() -> void:
	SoundManager.play_click_sound()
	Anim.animate_button_press($NextButton)
	await get_tree().create_timer(0.1).timeout
	GameManager.emit_signal("game_completed", "Flashcards")

func _on_button_hover_enter() -> void:
	Anim.create_hover_scale($NextButton, true, 0.2)

func _on_button_hover_exit() -> void:
	Anim.create_hover_scale($NextButton, false, 0.2)

