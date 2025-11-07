extends Control
## Completion Screen - Shows after all 5 games are completed
## Features all 5 characters and celebration animations per style guide

const CharacterHelper = preload("res://scripts/CharacterHelper.gd")
const Colors = preload("res://scripts/VocabZooColors.gd")
const Anim = preload("res://scripts/VocabZooConstants.gd")

func _ready() -> void:
	_create_characters()
	_display_scores()
	_play_entrance_animation()
	
	# Connect Play Again button
	$PlayAgainButton.pressed.connect(_on_play_again_pressed)
	$PlayAgainButton.mouse_entered.connect(_on_button_hover_enter)
	$PlayAgainButton.mouse_exited.connect(_on_button_hover_exit)

func _create_characters() -> void:
	# Create small versions of all 5 characters (50% scale ~125px tall each)
	# Positioned in CharactersRow HBoxContainer
	
	# Cat (purple)
	var cat_container = $CenterContent/VBoxContainer/CharactersRow/CatContainer
	var cat = CharacterHelper.create_cat(cat_container, Vector2(0, 0), Colors.PRIMARY_PURPLE)
	cat.scale = Vector2(0.5, 0.5)
	
	# Dog (orange)
	var dog_container = $CenterContent/VBoxContainer/CharactersRow/DogContainer
	var dog = CharacterHelper.create_dog(dog_container, Vector2(0, 0), Colors.ORANGE)
	dog.scale = Vector2(0.5, 0.5)
	
	# Rabbit (blue)
	var rabbit_container = $CenterContent/VBoxContainer/CharactersRow/RabbitContainer
	var rabbit = CharacterHelper.create_rabbit(rabbit_container, Vector2(0, 0), Colors.PRIMARY_BLUE)
	rabbit.scale = Vector2(0.5, 0.5)
	
	# Fox (red-orange)
	var fox_container = $CenterContent/VBoxContainer/CharactersRow/FoxContainer
	var fox = CharacterHelper.create_fox(fox_container, Vector2(0, 0), Colors.ORANGE)
	fox.scale = Vector2(0.5, 0.5)
	
	# Bird (green)
	var bird_container = $CenterContent/VBoxContainer/CharactersRow/BirdContainer
	var bird = CharacterHelper.create_bird(bird_container, Vector2(0, 0), Colors.PRIMARY_GREEN)
	bird.scale = Vector2(0.5, 0.5)

func _display_scores() -> void:
	# Get total score from GameManager
	var total_score = GameManager.get_total_score()
	var total_possible = GameManager.get_total_possible()
	
	# Update message label
	$CenterContent/VBoxContainer/MessageLabel.text = "WOW! You answered " + str(total_score) + "/" + str(total_possible) + " questions correctly!"

func _play_entrance_animation() -> void:
	# SUCCESS MOMENT ANIMATION per Style Guide:
	# 1. Screen flash (white, 0.1s)
	# 2. Celebratory text pops in with scale bounce
	# 3. Characters pop in with staggered delay
	
	# 1. Screen flash (brief white overlay)
	var flash = ColorRect.new()
	flash.color = Color(1, 1, 1, 0.8)
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(flash)
	
	var flash_tween = create_tween()
	flash_tween.tween_property(flash, "modulate:a", 0, 0.1)  # 0.1s per style guide
	flash_tween.finished.connect(func(): flash.queue_free())
	
	# 2. Title scale bounce (celebratory text pop-in)
	var title = $CenterContent/VBoxContainer/TitleLabel
	title.scale = Vector2(0.5, 0.5)
	var title_tween = create_tween()
	title_tween.set_trans(Tween.TRANS_BACK)  # Bounce easing per style guide
	title_tween.set_ease(Tween.EASE_OUT)
	title_tween.tween_property(title, "scale", Vector2.ONE, 0.4)  # Character animation timing
	
	# 3. Characters pop in with staggered delay (scale bounce) - now includes 5 characters
	var char_containers = [
		$CenterContent/VBoxContainer/CharactersRow/CatContainer,
		$CenterContent/VBoxContainer/CharactersRow/DogContainer,
		$CenterContent/VBoxContainer/CharactersRow/RabbitContainer,
		$CenterContent/VBoxContainer/CharactersRow/FoxContainer,
		$CenterContent/VBoxContainer/CharactersRow/BirdContainer
	]
	
	for i in range(5):  # Changed from 4 to 5
		var char_container = char_containers[i]
		char_container.modulate.a = 0
		var initial_scale = char_container.scale
		char_container.scale = initial_scale * 0.3
		
		await get_tree().create_timer(0.1 * i).timeout  # 0.1s stagger
		
		var char_tween = create_tween()
		char_tween.set_parallel(true)
		char_tween.tween_property(char_container, "modulate:a", 1, 0.3)  # UI transition timing
		char_tween.tween_property(char_container, "scale", initial_scale, 0.3).set_trans(Tween.TRANS_BACK)

func _on_play_again_pressed() -> void:
	Anim.animate_button_press($PlayAgainButton)
	await get_tree().create_timer(0.1).timeout
	
	GameManager.reset_flow()
	# Return to main screen
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_button_hover_enter() -> void:
	Anim.create_hover_scale($PlayAgainButton, true, 0.2)

func _on_button_hover_exit() -> void:
	Anim.create_hover_scale($PlayAgainButton, false, 0.2)
