extends CharacterBody3D

const SPEED = 5.0
const CROUCH_SPEED = 2.5
const JUMP_VELOCITY = 4.5
const FRICTION = 25
const HORIZONTAL_ACCELERATION = 30
const MAX_SPEED = 5
const DEATH_HEIGHT = -10.0
const MAX_CHARGE_TIME = 1.0  
const MAX_CHARGE_MULTIPLIER = 3.0  # max jump height multiplier
#to be made editable via GUI TODO!

# Get the gravity from to sync with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var spawn_position = Vector3(0, 1, 0)
var spawn_rotation = Vector3()
var is_crouching = false
var jump_charge = 0.0
var is_charging = false

@onready var camera = $Camera3D
@onready var collision_shape = $CollisionShape3D
@onready var mesh = $CSGMesh3D

signal player_died

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	spawn_position = global_position
	spawn_rotation = rotation

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * .005) #need to make these based on sensitivies in a GUI TODO!
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func crouch():
	is_crouching = true
	# scale down the character and camera when crouching
	collision_shape.scale.y = 0.6
	mesh.scale.y = 0.6
	camera.position.y = 1.0
	
func stand():
	is_crouching = false
	#restore original scale when standing
	collision_shape.scale.y = 1.0
	mesh.scale.y = 1.0
	camera.position.y = 1.5

func _unhandled_key_input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		var pause_menu = get_node_or_null("/root/World/PauseMenu")
		if pause_menu:
			pause_menu.toggle_pause()

func _physics_process(delta):
	#  check ded
	if global_position.y < DEATH_HEIGHT:
		player_died.emit()
		return
		
	# remember its the negative
	if not is_on_floor():
		velocity.y -= gravity * delta

	# charge jump logic
	if is_on_floor() and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if Input.is_action_pressed("ui_accept"):
			is_charging = true
			jump_charge = min(jump_charge + delta, MAX_CHARGE_TIME)
		elif Input.is_action_just_released("ui_accept") and is_charging:
			# jump force based on charge time
			var jump_multiplier = 1.0 + (jump_charge / MAX_CHARGE_TIME) * (MAX_CHARGE_MULTIPLIER - 1.0)
			velocity.y = JUMP_VELOCITY * jump_multiplier
			
			# Reset charge
			jump_charge = 0.0
			is_charging = false
	elif !is_on_floor():
		# reset jump charge if not on floor
		jump_charge = 0.0
		is_charging = false
		

	if Input.is_action_pressed("crouch") and is_on_floor() and !is_crouching:
		crouch()
	elif !Input.is_action_pressed("crouch") and is_crouching:
		stand()

	var input_dir = Vector3.ZERO
	var movetoward = Vector3.ZERO
	input_dir.x = Input.get_vector("move_left", "move_right", "move_forward", "move_backward").x
	input_dir.y = Input.get_vector("move_left", "move_right", "move_forward", "move_backward").y
	input_dir = input_dir.normalized()
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var current_speed = CROUCH_SPEED if is_crouching else SPEED
	direction *= current_speed
	
	velocity.x = move_toward(velocity.x, direction.x, HORIZONTAL_ACCELERATION * delta)
	velocity.z = move_toward(velocity.z, direction.z, HORIZONTAL_ACCELERATION * delta)

	#var angle = 5
	#var t = delta * 6
	
	#TODO! consider how i want to do the view movementr
	#if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: 
	#	rotation_degrees = rotation_degrees.lerp(Vector3(input_dir.normalized().y * angle, rotation_degrees.y, -input_dir.normalized().x * angle), t)
	
	move_and_slide()
	force_update_transform()

func respawn():
	global_position = spawn_position
	rotation = spawn_rotation
	velocity = Vector3.ZERO
