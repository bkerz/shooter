extends Control

var _main_menu_scene = preload("res://ui/main_menu/main_menu_ui.tscn")

func _on_quit_pressed():
	queue_free()
	get_tree().change_scene_to_packed(_main_menu_scene)
	pass # Replace with function body.

func _on_restart_pressed():
	get_tree().reload_current_scene()
	pass # Replace with function body.

