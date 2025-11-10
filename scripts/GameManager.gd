extends Node
## GameManager - Singleton for managing game flow and state
## Handles API-driven activity loading and session management

# Signals
signal game_completed(game_name: String)
signal show_info_modal()
signal load_game_scene(scene_path: String, activity_data: Dictionary)
signal show_completion_screen()
signal next_activity_requested(session_id: String)
signal activity_data_received(activity_data: Dictionary)
signal activity_load_failed(error_message: String)
signal show_error_toast(message: String)

# API-driven session data
var current_session_id: String = ""
var current_activity_data: Dictionary = {}
var session_start_time: float = 0.0
var session_duration_seconds: float = 600.0  # 10 minutes
var activities_completed: int = 0
var total_activities: int = 0

func _ready() -> void:
	game_completed.connect(_on_game_completed)

## Initialize a new session
func initialize_session() -> void:
	current_session_id = "test-session-" + str(Time.get_unix_time_from_system())
	session_start_time = Time.get_unix_time_from_system()
	activities_completed = 0
	# Reset API simulator progress to start from beginning
	APISimulator.reset_progress()
	# Get total activities from API simulator
	total_activities = APISimulator.get_total_activities()

## Check if session should end (time limit or data exhausted)
func should_end_session() -> bool:
	# Check time limit (10 minutes)
	var elapsed_time = Time.get_unix_time_from_system() - session_start_time
	if elapsed_time >= session_duration_seconds:
		return true
	
	# Check if test data exhausted (no more activities available)
	if APISimulator.is_test_data_exhausted():
		return true
	
	return false

## Request next activity from API simulator
func request_next_activity() -> void:
	if current_session_id.is_empty():
		initialize_session()
	
	# Check if session should end
	if should_end_session():
		emit_signal("show_completion_screen")
		return
	
	emit_signal("next_activity_requested", current_session_id)
	
	# Call APISimulator (await the async call)
	var activity_data = await APISimulator.request_next_activity(current_session_id)
	
	if activity_data.is_empty():
		emit_signal("activity_load_failed", "Failed to load activity data")
		_show_error_toast("Failed to load activity. Please try again.")
		return
	
	current_activity_data = activity_data
	emit_signal("activity_data_received", activity_data)
	load_game_from_activity(activity_data)

## Load game scene from activity data
func load_game_from_activity(activity_data: Dictionary) -> void:
	var activity_type = activity_data.get("activityType", "")
	var scene_path = ActivityMapper.get_scene_path(activity_type)
	
	if scene_path.is_empty():
		push_error("Invalid activity type: " + activity_type)
		emit_signal("activity_load_failed", "Invalid activity type")
		_show_error_toast("Invalid activity type. Skipping to next activity.")
		# Try loading next activity
		request_next_activity()
		return
	
	emit_signal("load_game_scene", scene_path, activity_data)

## Show error toast notification
func _show_error_toast(message: String) -> void:
	emit_signal("show_error_toast", message)

## Reset session and flow
func reset_flow() -> void:
	current_session_id = ""
	current_activity_data = {}
	session_start_time = 0.0
	activities_completed = 0

## Handle game completion - request next activity
func _on_game_completed(game_name: String) -> void:
	# Request next activity directly (no modal)
	await request_next_activity()

## Return to main menu
func return_to_menu() -> void:
	reset_flow()
	get_tree().reload_current_scene()

## Create and return a progress label for activity screens
func create_activity_progress_label() -> Label:
	var progress_label = Label.new()
	progress_label.name = "ActivityProgressLabel"
	
	# Get current progress
	var current = APISimulator.get_current_activity_number()
	var total = total_activities
	
	# Set text
	progress_label.text = "%d/%d" % [current, total]
	
	# Style the label
	const Colors = preload("res://scripts/VocabZooColors.gd")
	progress_label.add_theme_font_size_override("font_size", 18)
	progress_label.add_theme_color_override("font_color", Colors.LIGHT_BASE)
	
	# Position at bottom left
	progress_label.position = Vector2(40, 680)
	progress_label.size = Vector2(100, 30)
	
	return progress_label

