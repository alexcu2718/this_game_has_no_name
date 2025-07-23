extends Control

func _ready():
	visible = false

func _on_resume_button_pressed():
	get_tree().paused = false
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_quit_button_pressed():
	get_tree().quit()

func toggle_pause():
	visible = !visible
	get_tree().paused = visible
	
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED