extends Control

signal respawn_requested

func _ready():
	visible = false

func show_death_screen():
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_respawn_button_pressed():
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	respawn_requested.emit()
