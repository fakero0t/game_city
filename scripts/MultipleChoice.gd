extends Control
## Multiple Choice Game (Game 2 of 5)
## Pick the correct definition for each word
## Features dog character with tail wiggle animation

const CharacterHelper = preload("res://scripts/CharacterHelper.gd")
const Colors = preload("res://scripts/VocabCatColors.gd")
const Anim = preload("res://scripts/VocabCatConstants.gd")

class Question:
	var word: String
	var correct_definition: String
	var options: Array[String] = []  # 4 options, shuffled
	var correct_index: int = -1

var questions: Array[Question] = []
var current_question_index: int = 0
var score: int = 0
var total_questions: int = 10
var is_answering: bool = false

var answer_buttons: Array[Button] = []
var tail_base_x: float
var wiggle_timer: Timer

func _ready() -> void:
	# Create dog character
	var dog = CharacterHelper.create_dog($Character, Vector2.ZERO, Colors.ORANGE)
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
	# $NextButton.disabled = true  # Disabled for testing
	
	# Setup questions
	_generate_questions()
	_display_question()

func _generate_questions() -> void:
	# Get 10 random words
	var words = VocabularyManager.get_random_words(10)
	
	if words.size() < 10:
		push_error("Not enough vocabulary words")
		return
	
	for word_data in words:
		var q = Question.new()
		q.word = word_data["word"]
		q.correct_definition = word_data["definition"]
		
		# Get 3 distractor definitions
		var distractors = VocabularyManager.get_random_definitions(q.word, 3)
		
		# Build options array (explicit typed array to avoid type mismatch)
		var options_temp: Array[String] = []
		options_temp.append(q.correct_definition)
		for distractor in distractors:
			options_temp.append(distractor)
		options_temp.shuffle()
		q.options = options_temp
		
		# Find correct index
		q.correct_index = q.options.find(q.correct_definition)
		
		questions.append(q)

func _display_question() -> void:
	if current_question_index >= questions.size():
		return
	
	var q = questions[current_question_index]
	
	# Update question text
	$QuestionPanel/VBoxContainer/QuestionLabel.text = "What does \"" + q.word + "\" mean?"
	
	# Update progress
	$HeaderBar/ProgressLabel.text = "Question " + str(current_question_index + 1) + "/" + str(total_questions)
	
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
		_style_button_correct(answer_buttons[button_index])
		$FeedbackLabel.text = "Correct! 🎉"
		$FeedbackLabel.add_theme_color_override("font_color", Colors.SUCCESS)
		score += 1
		$FooterBar/ScoreLabel.text = "Score: " + str(score) + "/" + str(total_questions)
		_play_dog_celebration()
	else:
		# Wrong answer
		_style_button_wrong(answer_buttons[button_index])
		_style_button_correct(answer_buttons[q.correct_index])
		$FeedbackLabel.text = "Not quite. The answer is " + _get_letter(q.correct_index)
		$FeedbackLabel.add_theme_color_override("font_color", Colors.ERROR)
		_play_dog_sympathy()
	
	# Show feedback
	$FeedbackLabel.show()
	Anim.create_scale_bounce($FeedbackLabel, 1.0, 0.3)
	
	# Wait 2 seconds, then next question
	await get_tree().create_timer(2.0).timeout
	current_question_index += 1
	
	if current_question_index < total_questions:
		_display_question()
	else:
		_on_game_complete()

func _on_game_complete() -> void:
	# Show final score
	$FeedbackLabel.text = "You got " + str(score) + "/" + str(total_questions) + " correct!"
	$FeedbackLabel.add_theme_color_override("font_color", Colors.LIGHT_BASE)
	$FeedbackLabel.show()
	
	# Enable next button
	$NextButton.disabled = false
	Anim.create_scale_bounce($NextButton, 1.0, 0.3)
	
	# Record score
	GameManager.record_game_score(1, score)

func _style_button_correct(button: Button) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Colors.SUCCESS
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = Colors.SUCCESS
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)
	button.add_theme_color_override("font_color", Colors.LIGHT_BASE)

func _style_button_wrong(button: Button) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Colors.ERROR
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = Colors.ERROR
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)
	button.add_theme_color_override("font_color", Colors.LIGHT_BASE)

func _reset_button_style(button: Button) -> void:
	# Reset to default theme style
	button.remove_theme_stylebox_override("normal")
	button.remove_theme_stylebox_override("hover")
	button.remove_theme_stylebox_override("pressed")
	button.remove_theme_color_override("font_color")

func _get_letter(index: int) -> String:
	return ["A", "B", "C", "D"][index]

func _play_dog_celebration() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($Character, "rotation", -0.1, 0.15)
	tween.tween_property($Character, "rotation", 0.1, 0.15)
	tween.tween_property($Character, "rotation", 0, 0.15)

func _play_dog_sympathy() -> void:
	var original_y = $Character.position.y
	var tween = create_tween()
	tween.tween_property($Character, "position:y", original_y + 10, 0.2)
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
	Anim.animate_button_press($NextButton)
	await get_tree().create_timer(0.4).timeout
	GameManager.emit_signal("game_completed", "Pick the Meaning")

func _on_button_hover_enter() -> void:
	if not $NextButton.disabled:
		Anim.create_hover_scale($NextButton, true, 0.2)

func _on_button_hover_exit() -> void:
	Anim.create_hover_scale($NextButton, false, 0.2)
