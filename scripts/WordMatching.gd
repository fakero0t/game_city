extends Control
## Word Matching Game (Game 5 of 5)
## Match definitions to their correct words
## Features bird character with wing flap animation

const Colors = preload("res://scripts/VocabZooColors.gd")
const Anim = preload("res://scripts/VocabZooConstants.gd")
const THEME = preload("res://assets/vocab_zoo_theme.tres")

class MatchingQuestion:
	var definition: String
	var correct_word: String
	var options: Array[String] = []  # 4 word options
	var correct_index: int = -1

var questions: Array[MatchingQuestion] = []
var current_question_index: int = 0
var is_answering: bool = false

var answer_buttons: Array[Button] = []
var fox_image: Sprite2D
var video_player: VideoStreamPlayer
var character_visible: bool = true
var encouraging_messages = [
	"Not quite! Try again - you've got this!",
	"Keep trying! You can figure this out!",
	"Good effort! Give it another try!",
	"So close! Try a different answer!",
	"Don't give up! Try again!"
]

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
	
	# Get answer buttons
	answer_buttons = [
		$QuestionPanel/VBoxContainer/AnswerA,
		$QuestionPanel/VBoxContainer/AnswerB,
		$QuestionPanel/VBoxContainer/AnswerC,
		$QuestionPanel/VBoxContainer/AnswerD
	]
	
	# Connect buttons
	for i in range(4):
		answer_buttons[i].pressed.connect(_on_answer_pressed.bind(i))
	
	# Next button removed - auto-navigation after celebration
	
	# Wait for activity data to be loaded via load_activity_data()

## Load activity data from API
func load_activity_data(activity_data: Dictionary) -> void:
	var word_data = activity_data["word"]
	var params = activity_data["params"]
	
	questions.clear()
	current_question_index = 0
	
	var q = MatchingQuestion.new()
	q.definition = word_data.get("definition", "")
	q.correct_word = word_data.get("headword", "")
	
	# Extract options
	var options_array = params.get("options", [])
	var options_temp: Array[String] = []
	for option in options_array:
		options_temp.append(str(option))
	q.options = options_temp
	
	# Find correct index
	q.correct_index = q.options.find(q.correct_word)
	if q.correct_index == -1:
		q.correct_index = 0
	
	questions.append(q)
	
	_display_question()

func _generate_questions() -> void:
	# Get 8 random words
	var words = VocabularyManager.get_random_words(8)
	
	if words.size() < 8:
		push_error("Not enough vocabulary words")
		return
	
	for word_data in words:
		var q = MatchingQuestion.new()
		q.definition = word_data["definition"]
		q.correct_word = word_data["word"]
		
		# Get 3 distractor words
		var distractors = VocabularyManager.get_random_word_strings(q.correct_word, 3)
		
		# Build options array (explicit typed array to avoid type mismatch)
		var options_temp: Array[String] = []
		options_temp.append(q.correct_word)
		for distractor in distractors:
			options_temp.append(distractor)
		options_temp.shuffle()
		q.options = options_temp
		
		# Find correct index
		q.correct_index = q.options.find(q.correct_word)
		
		questions.append(q)

func _display_question() -> void:
	if current_question_index >= questions.size():
		return
	
	var q = questions[current_question_index]
	
	# Update instruction
	$QuestionPanel/VBoxContainer/InstructionLabel.text = "Which word means:"
	
	# Display definition
	$QuestionPanel/VBoxContainer/DefinitionLabel.text = "\"" + q.definition + "\""
	
	# Update answer buttons
	for i in range(4):
		answer_buttons[i].text = q.options[i]
		_reset_button_style(answer_buttons[i])
		answer_buttons[i].disabled = false
	
	# Hide feedback
	$FeedbackLabel.hide()
	
	is_answering = false

func _on_answer_pressed(button_index: int) -> void:
	if is_answering:
		return
	
	is_answering = true
	var q = questions[current_question_index]
	
	# Disable all buttons
	for btn in answer_buttons:
		btn.disabled = true
	
	if button_index == q.correct_index:
		# Correct answer
		SoundManager.play_correct_sound()
		answer_buttons[button_index].add_theme_stylebox_override("normal", THEME.get_stylebox("button_answer_correct", "Button"))
		answer_buttons[button_index].add_theme_stylebox_override("hover", THEME.get_stylebox("button_answer_correct", "Button"))
		answer_buttons[button_index].add_theme_stylebox_override("pressed", THEME.get_stylebox("button_answer_correct", "Button"))
		answer_buttons[button_index].add_theme_color_override("font_color", Colors.LIGHT_BASE)
		$FeedbackLabel.text = "Correct! \"" + q.correct_word + "\" means " + q.definition
		$FeedbackLabel.add_theme_color_override("font_color", Colors.SUCCESS)
		_play_bird_celebration()
		
		# Show feedback
		$FeedbackLabel.show()
		Anim.create_scale_bounce($FeedbackLabel, 1.0, 0.3)
		
		# Wait for celebration, then auto-navigate to next activity
		await get_tree().create_timer(2.5).timeout
		_on_game_complete()
	else:
		# Wrong answer - NEW BEHAVIOR
		SoundManager.play_incorrect_sound()
		answer_buttons[button_index].add_theme_stylebox_override("normal", THEME.get_stylebox("button_answer_wrong", "Button"))
		answer_buttons[button_index].add_theme_stylebox_override("hover", THEME.get_stylebox("button_answer_wrong", "Button"))
		answer_buttons[button_index].add_theme_stylebox_override("pressed", THEME.get_stylebox("button_answer_wrong", "Button"))
		answer_buttons[button_index].add_theme_color_override("font_color", Colors.LIGHT_BASE)
		
		# Show encouraging feedback with random message
		var random_msg = encouraging_messages[randi() % encouraging_messages.size()]
		$FeedbackLabel.text = random_msg
		$FeedbackLabel.add_theme_color_override("font_color", Colors.WARNING)  # Orange instead of red
		_play_bird_sympathy()
		
		# Show feedback label
		$FeedbackLabel.show()
		Anim.create_scale_bounce($FeedbackLabel, 1.0, 0.3)
		
		# Wait briefly, then re-enable buttons for retry
		await get_tree().create_timer(0.5).timeout
		
		# Re-enable all answer buttons
		for btn in answer_buttons:
			btn.disabled = false
		
		# Reset button styles for retry
		_reset_button_style(answer_buttons[button_index])
		
		# Set is_answering to false to allow retry
		is_answering = false
		
		# DO NOT advance to next question - student must try again
		return  # Exit without advancing

func _on_game_complete() -> void:
	# Automatically navigate to next activity
	await get_tree().create_timer(0.5).timeout
	GameManager.request_next_activity()

func _reset_button_style(button: Button) -> void:
	# Reset to default theme style
	button.remove_theme_stylebox_override("normal")
	button.remove_theme_stylebox_override("hover")
	button.remove_theme_stylebox_override("pressed")
	button.remove_theme_color_override("font_color")

func _play_bird_celebration() -> void:
	# Play fox_jump video (must be .ogv format for Godot)
	fox_image.visible = false
	var stream = load("res://assets/fox_jump.ogv")
	if stream:
		video_player.stream = stream
		video_player.visible = true
		video_player.play()
	else:
		push_warning("fox_jump.ogv not found - convert fox_jump.mp4 to Ogg Theora format")
		fox_image.visible = true

func _play_bird_sympathy() -> void:
	# Play fox_shake video (must be .ogv format for Godot)
	fox_image.visible = false
	var stream = load("res://assets/fox_shake.ogv")
	if stream:
		video_player.stream = stream
		video_player.visible = true
		video_player.play()
	else:
		push_warning("fox_shake.ogv not found - convert fox_shake.mp4 to Ogg Theora format")
		fox_image.visible = true

func _on_video_finished() -> void:
	# Hide video player and show fox image again
	video_player.visible = false
	fox_image.visible = true

# Next button removed - auto-navigation after celebration

