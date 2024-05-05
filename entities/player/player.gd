extends CharacterBody2D

signal shoot
signal death

@export var bullet: PackedScene


const SPEED = 300.0
const JUMP_VELOCITY = -1200.0
const MAX_HITS = 3

var _hits_received: int = 0
var _is_dead: bool = true


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _process(delta: float):
	var horizontal = Input.get_axis("ui_left", "ui_right")
	var vertical = Input.get_axis("ui_up", "ui_down")
	if Input.is_action_just_pressed("shoot"):
		shoot.emit(Vector2(horizontal, vertical))
	pass

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * 3.7 * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = 0

	move_and_slide()
	pass



func _on_area_2d_body_entered(body:Node2D):
	if body.get_groups().has("enemy"):
		_hits_received += 1

		if _hits_received > MAX_HITS:
			emit_signal("death")
	
	pass # Replace with function body.

