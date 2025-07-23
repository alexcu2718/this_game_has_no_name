extends Node3D

func _ready():
	#make death ui
	var player = $character
	player.player_died.connect(_on_player_died)
	
	#r espawn signal from death screen
	var death_screen = $UI/DeathScreen
	death_screen.respawn_requested.connect(_on_respawn_requested)
	
	# register crouch action
	if not InputMap.has_action("crouch"):
		InputMap.add_action("crouch")
		var event = InputEventKey.new()
		event.keycode = KEY_SHIFT
		InputMap.action_add_event("crouch", event)

func _on_player_died():
	$UI/DeathScreen.show_death_screen()

func _on_respawn_requested():
	$character.respawn()

func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel"):
		$UI/PauseMenu.toggle_pause()