extends RefCounted
class_name ActivityMapper
## ActivityMapper - Maps activity types to game scene paths
## Utility class for converting API activity types to Godot scene files

## Get the scene path for a given activity type
static func get_scene_path(activity_type: String) -> String:
	var mapping = {
		"connect_def": "res://scenes/WordMatching.tscn",
		"context_cloze": "res://scenes/FillInBlank.tscn",
		"synonym_mcq": "res://scenes/SynonymAntonym.tscn",
		"flashcard_usage": "res://scenes/MemoryGame.tscn"
	}
	
	# Default fallback to MultipleChoice if activity type not found
	return mapping.get(activity_type, "res://scenes/MultipleChoice.tscn")

## Check if an activity type is valid
static func is_valid_activity_type(activity_type: String) -> bool:
	var valid_types = [
		"connect_def",
		"context_cloze",
		"synonym_mcq",
		"flashcard_usage"
	]
	return activity_type in valid_types

