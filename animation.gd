extends AnimationPlayer


# called on first frame
func _ready():
	play("slide")


#  'delta' is the elapsed time since the previous frame. this is for
#  processing the animation in real-time.
func _process(delta):
	pass
