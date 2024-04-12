extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var _timer: Timer = null
var _direction: int = -1 #left as default

func _ready():
	var _timer = get_node("Timer")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	velocity.x = _direction * SPEED

	move_and_slide()


func _on_timer_timeout():
	_direction *= -1
	pass # Replace with function body.
