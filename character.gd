extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MAX_CHARGE_TIME = 2.0 # seconds
const MAX_CHARGE_MULTIPLIER = 4.0  #
# The maximum multiplier for the jump velocity when fully charged.

# gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var jump_charge = 0.0
var is_charging = false

@onready var camera = $Camera3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func toggle_fullscreen():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _unhandled_key_input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: 
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event.keycode == KEY_F11:
		toggle_fullscreen()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if is_on_floor() and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var jump_label = get_tree().root.get_node("JumpChargeLabel")
		
		if Input.is_action_pressed("jump"):
			is_charging = true
			jump_charge = min(jump_charge + delta, MAX_CHARGE_TIME)
		elif Input.is_action_just_released("jump") and is_charging:
			var jump_multiplier = 1.0 + (jump_charge / MAX_CHARGE_TIME) * (MAX_CHARGE_MULTIPLIER - 1.0)
			velocity.y = JUMP_VELOCITY * jump_multiplier
			
			jump_charge = 0.0
			is_charging = false
	else:
		jump_charge = 0.0
		is_charging = false

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
	force_update_transform()