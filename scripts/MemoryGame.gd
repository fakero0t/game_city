extends Control
## Memory Match Game (Game 1 of 5)
## Match 8 word-definition pairs by flipping cards
## Features cat character with tail wiggle animation

const CharacterHelper = preload("res://scripts/CharacterHelper.gd")
const Colors = preload("res://scripts/VocabZooColors.gd")
const Anim = preload("res://scripts/VocabZooConstants.gd")
const THEME = preload("res://assets/vocab_zoo_theme.tres")

class Card:
	var content: String
	var is_word: bool  # true if word, false if definition
	var pair_id: int
	var is_flipped: bool = false
	var is_matched: bool = false
	var button: Button
	var font_size: int = 18  # Pre-calculated font size for content

var cards: Array[Card] = []
var selected_cards: Array[Card] = []
var matches_found: int = 0
var total_pairs: int = 8
var is_checking: bool = false  # Prevent clicks during check

# Tail animation
var tail_base_x: float
var wiggle_timer: Timer

func _ready() -> void:
	# Create cat character
	var cat = CharacterHelper.create_cat($Character, Vector2.ZERO, Colors.PRIMARY_PURPLE)
	var tail_node = $Character.get_node_or_null("Tail")
	if tail_node:
		tail_base_x = tail_node.position.x
		
		# Setup tail wiggle timer
		wiggle_timer = Timer.new()
		wiggle_timer.wait_time = 2.0
		wiggle_timer.timeout.connect(_wiggle_tail)
		add_child(wiggle_timer)
		wiggle_timer.start()
	
	# Setup game
	_setup_game()
	
	# Connect next button
	$NextButton.pressed.connect(_on_next_pressed)
	$NextButton.mouse_entered.connect(_on_button_hover_enter)
	$NextButton.mouse_exited.connect(_on_button_hover_exit)
	$NextButton.disabled = true

func _setup_game() -> void:
	# Get 8 random words from vocabulary
	var words = VocabularyManager.get_random_words(8)
	
	if words.size() < 8:
		push_error("Not enough vocabulary words")
		return
	
	# Create card data (8 word cards + 8 definition cards)
	var card_data = []
	var button_size = Vector2(140, 95)  # Fixed size from scene
	
	for i in range(8):
		# Word card
		var word_card = Card.new()
		word_card.content = words[i]["word"]
		word_card.is_word = true
		word_card.pair_id = i
		word_card.font_size = _calculate_font_size_for_card(word_card.content, button_size)
		card_data.append(word_card)
		
		# Definition card
		var def_card = Card.new()
		def_card.content = words[i]["definition"]
		def_card.is_word = false
		def_card.pair_id = i
		def_card.font_size = _calculate_font_size_for_card(def_card.content, button_size)
		card_data.append(def_card)
	
	# Shuffle cards
	card_data.shuffle()
	
	# Assign to buttons in GridContainer
	var grid = $GridContainer
	for i in range(16):
		var card = card_data[i]
		var button = grid.get_child(i) as Button
		card.button = button
		cards.append(card)
		
		# Setup button
		button.text = ""  # Face-down state (empty)
		button.pressed.connect(_on_card_pressed.bind(i))
		button.add_theme_stylebox_override("normal", THEME.get_stylebox("button_memory_down", "Button"))
		button.add_theme_stylebox_override("hover", THEME.get_stylebox("button_memory_down", "Button"))
		button.add_theme_stylebox_override("pressed", THEME.get_stylebox("button_memory_down", "Button"))
		button.add_theme_color_override("font_color", Colors.LIGHT_BASE)

func _calculate_font_size_for_card(text: String, button_size: Vector2) -> int:
	# Create temporary label for size calculation
	var temp_label = Label.new()
	temp_label.text = text
	temp_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	
	# Calculate available space (button size minus padding)
	var available_width = button_size.x - 32  # 16px padding each side
	var available_height = button_size.y - 32  # 16px padding top/bottom
	
	# Start with default size and reduce until it fits
	var font_size = 18
	var min_font_size = 12
	
	while font_size >= min_font_size:
		temp_label.add_theme_font_size_override("font_size", font_size)
		temp_label.size = Vector2(available_width, 0)  # Set width constraint
		var text_size = temp_label.get_minimum_size()
		
		# Check if text fits
		if text_size.x <= available_width and text_size.y <= available_height:
			temp_label.queue_free()
			return font_size
		
		font_size -= 1
	
	# If we get here, use minimum font size
	temp_label.queue_free()
	return min_font_size

func _on_card_pressed(card_index: int) -> void:
	if is_checking:
		return
	
	var card = cards[card_index]
	
	# Can't click already flipped or matched cards
	if card.is_flipped or card.is_matched:
		return
	
	# Flip card
	_flip_card(card)
	selected_cards.append(card)
	
	# Check if we have 2 cards selected
	if selected_cards.size() == 2:
		is_checking = true
		await get_tree().create_timer(0.5).timeout
		_check_match()

func _flip_card(card: Card) -> void:
	card.is_flipped = true
	card.button.text = card.content
	card.button.autowrap_mode = TextServer.AUTOWRAP_WORD  # Enable text wrapping
	card.button.add_theme_font_size_override("font_size", card.font_size)  # Apply pre-calculated size
	card.button.add_theme_stylebox_override("normal", THEME.get_stylebox("button_memory_up", "Button"))
	card.button.add_theme_stylebox_override("hover", THEME.get_stylebox("button_memory_up", "Button"))
	card.button.add_theme_stylebox_override("pressed", THEME.get_stylebox("button_memory_up", "Button"))
	card.button.add_theme_color_override("font_color", Colors.DARK_BASE)
	
	# Flip animation
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(card.button, "scale", Vector2(1.1, 1.1), 0.15)
	tween.tween_property(card.button, "scale", Vector2.ONE, 0.15)

func _check_match() -> void:
	var card1 = selected_cards[0]
	var card2 = selected_cards[1]
	
	if card1.pair_id == card2.pair_id:
		# Match found!
		card1.is_matched = true
		card2.is_matched = true
		card1.button.add_theme_stylebox_override("normal", THEME.get_stylebox("button_memory_matched", "Button"))
		card1.button.add_theme_stylebox_override("hover", THEME.get_stylebox("button_memory_matched", "Button"))
		card1.button.add_theme_stylebox_override("pressed", THEME.get_stylebox("button_memory_matched", "Button"))
		card1.button.add_theme_color_override("font_color", Colors.LIGHT_BASE)
		card2.button.add_theme_stylebox_override("normal", THEME.get_stylebox("button_memory_matched", "Button"))
		card2.button.add_theme_stylebox_override("hover", THEME.get_stylebox("button_memory_matched", "Button"))
		card2.button.add_theme_stylebox_override("pressed", THEME.get_stylebox("button_memory_matched", "Button"))
		card2.button.add_theme_color_override("font_color", Colors.LIGHT_BASE)
		
		matches_found += 1
		$HeaderBar/ScoreLabel.text = "Score: " + str(matches_found) + "/" + str(total_pairs)
		
		# Cat celebration animation
		_play_cat_celebration()
		
		# Check if all matched
		if matches_found == total_pairs:
			_on_game_won()
	else:
		# No match - flip back after delay
		await get_tree().create_timer(1.5).timeout
		_flip_card_back(card1)
		_flip_card_back(card2)
	
	selected_cards.clear()
	is_checking = false

func _flip_card_back(card: Card) -> void:
	card.is_flipped = false
	card.button.text = ""
	card.button.add_theme_stylebox_override("normal", THEME.get_stylebox("button_memory_down", "Button"))
	card.button.add_theme_stylebox_override("hover", THEME.get_stylebox("button_memory_down", "Button"))
	card.button.add_theme_stylebox_override("pressed", THEME.get_stylebox("button_memory_down", "Button"))
	card.button.add_theme_color_override("font_color", Colors.LIGHT_BASE)

func _play_cat_celebration() -> void:
	# Cat bounce animation
	var original_y = $Character.position.y
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($Character, "position:y", original_y - 20, 0.2)
	tween.tween_property($Character, "position:y", original_y, 0.2)

func _on_game_won() -> void:
	# Show win message
	$WinMessage.show()
	$WinMessage.text = "All Matched! 🎉"
	
	# Animate message
	$WinMessage.modulate.a = 0
	$WinMessage.scale = Vector2(0.5, 0.5)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($WinMessage, "modulate:a", 1.0, 0.3)
	tween.tween_property($WinMessage, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK)
	
	# Wait 2 seconds, then enable Next button
	await get_tree().create_timer(2.0).timeout
	$NextButton.disabled = false
	Anim.create_scale_bounce($NextButton, 1.0, 0.3)
	
	# Record score
	GameManager.record_game_score(0, matches_found)

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
	GameManager.emit_signal("game_completed", "Memory Match")

func _on_button_hover_enter() -> void:
	if not $NextButton.disabled:
		Anim.create_hover_scale($NextButton, true, 0.2)

func _on_button_hover_exit() -> void:
	Anim.create_hover_scale($NextButton, false, 0.2)

