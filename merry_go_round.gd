extends Node3D

@export var radius = 4.0
@export var speed = 0.5
@export var height = 1.0
@export var num_platforms = 4

var time = 0.0
var platform_nodes = []
var move_areas = []

func _ready():
	# create centre pole, the collision is fucked no idea why
	var center_pole_body = StaticBody3D.new()
	center_pole_body.collision_layer = 6
	center_pole_body.collision_mask = 7
	add_child(center_pole_body)
	
	var center_pole = CSGCylinder3D.new()
	center_pole.radius = 0.3
	center_pole.height = 4.0
	center_pole.material = StandardMaterial3D.new()
	center_pole.material.albedo_color = Color(0.6, 0.4, 0.2)  #red-brownish
	center_pole.use_collision = true
	center_pole_body.add_child(center_pole)
	
	var pole_collision = CollisionShape3D.new()
	var pole_shape = CylinderShape3D.new()
	pole_shape.radius = 0.3
	pole_shape.height = 4.0
	pole_collision.shape = pole_shape
	center_pole_body.add_child(pole_collision)
	
	#this is fucked
	var canopy_body = StaticBody3D.new()
	canopy_body.collision_layer = 6
	canopy_body.collision_mask = 7
	canopy_body.position.y = 3.0
	add_child(canopy_body)
	
	var canopy = CSGCylinder3D.new()
	canopy.radius = radius + 1.0
	canopy.height = 0.2
	canopy.material = StandardMaterial3D.new()
	canopy.material.albedo_color = Color(0.8, 0.2, 0.2)  # light red?
	canopy.use_collision = true
	canopy_body.add_child(canopy)
	
	var canopy_collision = CollisionShape3D.new()
	var canopy_shape = CylinderShape3D.new()
	canopy_shape.radius = radius + 1.0
	canopy_shape.height = 0.2
	canopy_collision.shape = canopy_shape
	canopy_body.add_child(canopy_collision)
	
	for i in range(num_platforms):
		var angle = 2 * PI * i / num_platforms #look mum math is useful
		var x = cos(angle) * radius
		var z = sin(angle) * radius
		
		# add platform body
		var platform_body = StaticBody3D.new()
		platform_body.collision_layer = 6
		platform_body.collision_mask = 7
		platform_body.position = Vector3(x, height, z)
		add_child(platform_body)
		
		# create base
		var platform = CSGBox3D.new()
		platform.size = Vector3(2.0, 0.2, 1.5)
		platform.use_collision = true
		
		# add random texture i found
		var material = load("res://textures/grass_texture.tres").duplicate()
		if i % 2 == 0:
			material = load("res://textures/sand_texture.tres").duplicate()
		platform.material = material
		platform_body.add_child(platform)
		
		# tried to add collision to the platform but it was fucked
		var platform_collision = CollisionShape3D.new()
		var platform_shape = BoxShape3D.new()
		platform_shape.size = Vector3(2.0, 0.2, 1.5)
		platform_collision.shape = platform_shape
		platform_body.add_child(platform_collision)
		
		# make a pole for each platform
		var pole = CSGCylinder3D.new()
		pole.radius = 0.1
		pole.height = 2.5
		pole.position = Vector3(0, 1.0, 0)
		pole.material = StandardMaterial3D.new()
		pole.material.albedo_color = Color(0.9, 0.9, 0.9)  #almost white
		pole.use_collision = true
		platform_body.add_child(pole)
		
		# Add collision to pole
		var pole_collision_shape = CollisionShape3D.new()
		var pole_collision_cylinder = CylinderShape3D.new()
		pole_collision_cylinder.radius = 0.1
		pole_collision_cylinder.height = 2.5
		pole_collision_shape.shape = pole_collision_cylinder
		pole_collision_shape.position = Vector3(0, 1.0, 0)
		platform_body.add_child(pole_collision_shape)
		

		#collision broken
		var seat = CSGSphere3D.new()
		seat.radius = 0.3
		seat.position = Vector3(0, 2.5, 0)
		seat.material = StandardMaterial3D.new()
		seat.material.albedo_color = Color(0.2, 0.4, 0.8)  # Blue color
		seat.use_collision = true
		platform_body.add_child(seat)
		
		#collision broken
		var seat_collision = CollisionShape3D.new()
		var seat_shape = SphereShape3D.new()
		seat_shape.radius = 0.3
		seat_collision.shape = seat_shape
		seat_collision.position = Vector3(0, 2.5, 0)
		platform_body.add_child(seat_collision)
		
		var move_area = Area3D.new()
		move_area.collision_layer = 0
		move_area.collision_mask = 2  # Player is on layer 2
		platform_body.add_child(move_area)
		
		var area_shape = CollisionShape3D.new()
		var box_shape = BoxShape3D.new()
		box_shape.size = Vector3(2.0, 1.0, 1.5)  #make box taller than player 
		area_shape.shape = box_shape
		area_shape.position.y = 0.5  
		move_area.add_child(area_shape)
		
		move_areas.append(move_area)
		platform_nodes.append(platform_body)
		
	position.y = height

func _physics_process(delta):
	time += delta * speed
	
	# rotate entire structure
	rotation.y = time
	
	# cant get this to work
	for area in move_areas:
		for body in area.get_overlapping_bodies():
			if body is CharacterBody3D:
				# get the rotation change this frame
				var rotation_delta = delta * speed
				
				# the tangential velocity at the player's position
				var player_pos = body.global_position
				var dir_to_player = (player_pos - global_position).normalized() # need to normalise because vectors
				
				#  tangential velocity (perpendicular to radius)
				var tangential_direction = Vector3(-dir_to_player.z, 0, dir_to_player.x)
				var distance_from_center = (player_pos - global_position).length()
				var tangential_speed = rotation_delta * distance_from_center * 25  # i tried a stupid number here, no work.
				
				body.velocity.x += tangential_direction.x * tangential_speed
				body.velocity.z += tangential_direction.z * tangential_speed