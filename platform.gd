@tool
extends StaticBody2D

enum Axis {
	Horizontal,
	Vertical
}

@export var direction: Axis


# Called when the node enters the scene tree for the first time.
func _ready():
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if direction == Axis.Vertical:
		var collision_shape: CollisionShape2D = get_node("CollisionShape2D")
		var size_x = collision_shape.shape.size.x
		var size_y = collision_shape.shape.size.y
		collision_shape.shape.size.y = size_x
		collision_shape.shape.size.x = size_y
	pass
