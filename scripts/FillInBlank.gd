extends Control
## Fill-in-the-Blank Game (Game 3 of 5)
## Choose the correct word to complete each sentence
## Features rabbit character with tail wiggle animation

const CharacterHelper = preload("res://scripts/CharacterHelper.gd")
const Colors = preload("res://scripts/VocabZooColors.gd")
const Anim = preload("res://scripts/VocabZooConstants.gd")
const THEME = preload("res://assets/vocab_zoo_theme.tres")

class SentenceQuestion:
	var sentence: String  # with ___ placeholder
	var correct_word: String
	var options: Array[String] = []  # 4 word options
	var correct_index: int = -1

var questions: Array[SentenceQuestion] = []
var current_question_index: int = 0
var is_answering: bool = false

var answer_buttons: Array[Button] = []
var tail_base_x: float
var wiggle_timer: Timer
var encouraging_messages = [
	"Not quite! Try again - you've got this!",
	"Keep trying! You can figure this out!",
	"Good effort! Give it another try!",
	"So close! Try a different answer!",
	"Don't give up! Try again!"
]

func _ready() -> void:
	# Create rabbit character
	var rabbit = CharacterHelper.create_rabbit($Character, Vector2.ZERO, Colors.PRIMARY_BLUE)
	var tail_node = $Character.get_node_or_null("Tail")
	if tail_node:
		tail_base_x = tail_node.position.x
		
		# Setup tail wiggle
		wiggle_timer = Timer.new()
		wiggle_timer.wait_time = 2.0
		wiggle_timer.timeout.connect(_wiggle_tail)
		add_child(wiggle_timer)
		wiggle_timer.start()
	
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
	
	$NextButton.pressed.connect(_on_next_pressed)
	$NextButton.mouse_entered.connect(_on_button_hover_enter)
	$NextButton.mouse_exited.connect(_on_button_hover_exit)
	$NextButton.disabled = true
	
	# Wait for activity data to be loaded via load_activity_data()

## Load activity data from API
func load_activity_data(activity_data: Dictionary) -> void:
	var word_data = activity_data["word"]
	var params = activity_data["params"]
	
	questions.clear()
	current_question_index = 0
	
	var q = SentenceQuestion.new()
	q.sentence = params.get("sentence", "")
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
	# Get 10 random words
	var words = VocabularyManager.get_random_words(10)
	
	if words.size() < 10:
		push_error("Not enough vocabulary words")
		return
	
	for word_data in words:
		var q = SentenceQuestion.new()
		q.sentence = word_data["example_sentence"]
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
	
	# Update sentence text
	$QuestionPanel/VBoxContainer/SentenceLabel.text = q.sentence
	
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
		$FeedbackLabel.text = "Perfect! ✨"
		$FeedbackLabel.add_theme_color_override("font_color", Colors.SUCCESS)
		_play_rabbit_celebration()
		
		# Show feedback
		$FeedbackLabel.show()
		Anim.create_scale_bounce($FeedbackLabel, 1.0, 0.3)
		
		# Wait 2 seconds, then next question (ONLY for correct answers)
		await get_tree().create_timer(2.0).timeout
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
		_play_rabbit_sympathy()
		
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
	# Enable next button
	$NextButton.disabled = false
	Anim.create_scale_bounce($NextButton, 1.0, 0.3)

func _reset_button_style(button: Button) -> void:
	# Reset to default theme style
	button.remove_theme_stylebox_override("normal")
	button.remove_theme_stylebox_override("hover")
	button.remove_theme_stylebox_override("pressed")
	button.remove_theme_color_override("font_color")

func _play_rabbit_celebration() -> void:
	# Rabbit hop animation
	var original_y = $Character.position.y
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($Character, "position:y", original_y - 30, 0.2)
	tween.tween_property($Character, "position:y", original_y, 0.2)

func _play_rabbit_sympathy() -> void:
	# Rabbit droop animation
	var original_y = $Character.position.y
	var tween = create_tween()
	tween.tween_property($Character, "position:y", original_y + 8, 0.2)
	tween.tween_property($Character, "position:y", original_y, 0.2)

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

