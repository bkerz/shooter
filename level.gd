extends Node2D

signal exit_level

func _ready():
	pass


func _on_door_leave():
	exit_level.emit()
	pass # Replace with function body.

