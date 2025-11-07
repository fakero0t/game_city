extends Node
## GameManager - Singleton for managing game flow and state
## Tracks current game, handles transitions, and coordinates modals

# Signals
signal game_completed(game_name: String)
signal show_info_modal()
signal show_ready_modal(completed_game: String, next_game: String)
signal load_game_scene(scene_path: String)
signal show_completion_screen()

# Game data structure
var games = [
	{
		"name": "Memory Match",
		"scene_path": "res://scenes/MemoryGame.tscn",
		"color": "#8B5CF6",  # Primary Purple
		"character": "Cat"
	},
	{
		"name": "Pick the Meaning",
		"scene_path": "res://scenes/MultipleChoice.tscn",
		"color": "#F97316",  # Orange
		"character": "Dog"
	},
	{
		"name": "Complete the Sentence",
		"scene_path": "res://scenes/FillInBlank.tscn",
		"color": "#3B82F6",  # Primary Blue
		"character": "Rabbit"
	},
	{
		"name": "Word Relationships",
		"scene_path": "res://scenes/SynonymAntonym.tscn",
		"color": "#F97316",  # Orange (Fox)
		"character": "Fox"
	},
	{
		"name": "Match the Meaning",
		"scene_path": "res://scenes/WordMatching.tscn",
		"color": "#10B981",  # Primary Green
		"character": "Bird"
	}
]

# Score tracking: [score, total] for each game
var game_scores: Array = [
	[0, 8],   # Memory: 8 pairs
	[0, 10],  # Multiple Choice: 10 questions
	[0, 10],  # Fill-in-Blank: 10 questions
	[0, 10],  # Synonym/Antonym: 10 questions
	[0, 8]    # Word Matching: 8 questions
]

var current_game_index: int = -1

func _ready() -> void:
	game_completed.connect(_on_game_completed)

func get_current_game_name() -> String:
	if current_game_index >= 0 and current_game_index < games.size():
		return games[current_game_index]["name"]
	return ""

func get_current_game_scene() -> String:
	if current_game_index >= 0 and current_game_index < games.size():
		return games[current_game_index]["scene_path"]
	return ""

func get_next_game_name() -> String:
	var next_index = current_game_index + 1
	if next_index >= 0 and next_index < games.size():
		return games[next_index]["name"]
	return ""

func advance_to_next_game() -> void:
	current_game_index += 1
	if current_game_index < games.size():
		var scene_path = games[current_game_index]["scene_path"]
		emit_signal("load_game_scene", scene_path)
	else:
		# All games completed
		emit_signal("show_completion_screen")

func reset_flow() -> void:
	current_game_index = -1
	# Reset all scores
	for i in range(game_scores.size()):
		game_scores[i][0] = 0
	# Reset vocabulary word usage tracking
	VocabularyManager.reset_usage_tracking()

func is_last_game() -> bool:
	return current_game_index == games.size() - 1

func record_game_score(game_index: int, score: int) -> void:
	if game_index >= 0 and game_index < game_scores.size():
		game_scores[game_index][0] = score

func get_total_score() -> int:
	var total = 0
	for score_data in game_scores:
		total += score_data[0]
	return total

func get_total_possible() -> int:
	var total = 0
	for score_data in game_scores:
		total += score_data[1]
	return total

func get_game_score_text(game_index: int) -> String:
	if game_index >= 0 and game_index < game_scores.size():
		return str(game_scores[game_index][0]) + "/" + str(game_scores[game_index][1])
	return "0/0"

func _on_game_completed(game_name: String) -> void:
	if is_last_game():
		# Last game completed, go to completion screen
		emit_signal("show_completion_screen")
	else:
		# Show ready modal for next game
		var next_game = get_next_game_name()
		emit_signal("show_ready_modal", game_name, next_game)

