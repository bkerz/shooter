extends Node2D

signal exit_level

var doors: Dictionary = {
		"right": false,
		"left": false,
		"top": false,
		"bottom": false,
	}

func _ready():
	var door_right: Area2D = get_node("DoorRight")
	door_right.visible = false

	var door_top: Area2D = get_node("DoorTop")
	door_top.visible = false

	var door_left: Area2D = get_node("DoorLeft")
	door_left.visible = false

	var door_bottom: Area2D = get_node("DoorBottom")
	door_bottom.visible = false

	if doors["right"]:
		door_right.visible = true
		door_right.leave.connect(_on_right_door_leave)
	if doors["top"]:
		door_top.visible = true
		door_top.leave.connect(_on_top_door_leave)
	if doors["left"]:
		door_left.visible = true
		door_left.leave.connect(_on_left_door_leave)
	if doors["bottom"]:
		door_bottom.visible = true
		door_bottom.leave.connect(_on_bottom_door_leave)
	pass

func _on_top_door_leave():
	exit_level.emit(Vector2.UP)
	pass # Replace with function body.

func _on_right_door_leave():
	exit_level.emit(Vector2.RIGHT)
	pass # Replace with function body.

func _on_left_door_leave():
	exit_level.emit(Vector2.LEFT)
	pass # Replace with function body.

func _on_bottom_door_leave():
	exit_level.emit(Vector2.DOWN)
	pass # Replace with function body.


