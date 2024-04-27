extends Control

var _main_scene = null

func _ready():
	_main_scene = get_tree().get_root()
	print(_main_scene)
	breakpoint
	

func _on_start_game_pressed():
	if _main_scene:
		queue_free()
		get_tree().change_scene_to_packed(_main_scene)
	pass # Replace with function body.


func _on_quit_game_pressed():
	get_tree().quit()
	pass # Replace with function body.

