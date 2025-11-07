extends Control

func _ready():
	# This scene is shown when vocabulary fails to load
	# Error message is set by Main.gd
	pass

func set_error_message(message: String) -> void:
	$CenterContainer/ErrorPanel/VBoxContainer/ErrorMessage.text = message

func _play_entrance_animation() -> void:
	# Error panel scale bounce entrance
	$CenterContainer/ErrorPanel.scale = Vector2(0.9, 0.9)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($CenterContainer/ErrorPanel, "scale", Vector2.ONE, 0.4)
