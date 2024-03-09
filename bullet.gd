extends CharacterBody2D

@export var speed: int = 500
var _direction: Vector2 = Vector2.RIGHT
var test: float = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity = Vector2(_direction.x * speed, _direction.y * speed)
	var hello = Vector2()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move_and_slide()
	pass


func _on_timer_timeout():
	queue_free()
	pass # Replace with function body.



func _on_body_entered(body:Node2D):
	queue_free()
	pass # Replace with function body.



func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	pass # Replace with function body.
