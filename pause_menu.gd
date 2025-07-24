extends Control

@onready var fov_slider = $VBoxContainer/FOVContainer/FOVSlider
@onready var fov_value_label = $VBoxContainer/FOVContainer/FOVValue
@onready var third_person_button = $VBoxContainer/ThirdPersonButton

func _ready():
	visible = false
	var camera = get_viewport().get_camera_3d()
	if camera:
		fov_slider.value = camera.fov
		fov_value_label.text = str(int(camera.fov))
	update_third_person_button_text()

func _on_resume_button_pressed():
	get_tree().paused = false
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_third_person_button_pressed():
	var character = get_node("/root/World/character")
	if character:
		character.toggle_camera_mode()
		update_third_person_button_text()

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
		update_third_person_button_text()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func update_third_person_button_text():
	var character = get_node("/root/World/character")
	if character:
		if character.is_third_person:
			third_person_button.text = "First Person"
		else:
			third_person_button.text = "Third Person"