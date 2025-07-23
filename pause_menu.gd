extends Control

@onready var fov_slider = $VBoxContainer/FOVContainer/FOVSlider
@onready var fov_value_label = $VBoxContainer/FOVContainer/FOVValue

func _ready():
	visible = false
	var camera = get_viewport().get_camera_3d()
	if camera:
		fov_slider.value = camera.fov
		fov_value_label.text = str(int(camera.fov))

func _on_resume_button_pressed():
	get_tree().paused = false
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_quit_button_pressed():
	get_tree().quit()

func _on_fov_slider_value_changed(value):
	var camera = get_viewport().get_camera_3d()
	if camera:
		camera.fov = value
		fov_value_label.text = str(int(value))

func toggle_pause():
	visible = !visible
	get_tree().paused = visible
	
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		var camera = get_viewport().get_camera_3d()
		if camera:
			fov_slider.value = camera.fov
			fov_value_label.text = str(int(camera.fov))
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED