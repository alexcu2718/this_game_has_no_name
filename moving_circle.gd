extends Node3D

@export var radius = 2.0
@export var speed = 1.0
@export var height = 2.0

var time = 0.0
var platform_mesh: CSGBox3D

func _ready():
	platform_mesh = CSGBox3D.new()
	platform_mesh.size = Vector3(2.0, 0.3, 2.0)
	
	var material = load("res://textures/sand_texture.tres").duplicate()
	platform_mesh.material = material
	
	add_child(platform_mesh)
	
	position.y = height

func _process(delta):
	time += delta * speed
	
	var x = cos(time) * radius
	var z = sin(time) * radius
	
	platform_mesh.position = Vector3(x, 0, z)
