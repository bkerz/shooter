@tool
class_name ShooterManager
extends Node
## Manager for the "shoot" mechanic.
##
## Has all the utility methods each level will need to use in order to perform the
## shooting (showing bullets, setting its position, etc)

## The Player Scene instance the manager will use to work with the Player signals
@export var player_scene: CharacterBody2D
## Boolean used to know when the player should shoot
var can_player_shoot: bool = true

@onready var _bullet = preload("res://bullet.tscn")
@onready var _shoot_timer = Timer.new() as Timer
var _last_shoot_direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
		update_configuration_warnings()
		_shoot_timer.timeout.connect(_on_timer_timeout)
		pass

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()
	pass

## Performs the "shoot" mechanic showing a Bullet Scene and setting its position
## for it to work as intented. The Bullet will move to the [param direction] it
## receives
func shoot(direction: Vector2) -> void:
	if _bullet != null:
		add_child(Node2D.new())

	if player_scene == null:
		push_error("Player Scene must be defined before shooting. Please assign a valid Player Node to Player Scene in the inspector")
		return
		pass

	if can_player_shoot:
		var bullet_instance = _bullet.instantiate()
		var player = player_scene
		bullet_instance.position.y = player.position.y
		bullet_instance.position.x = player.position.x
		bullet_instance.rotation_degrees = 90
		print("bullet position")
		print(bullet_instance.position)
		if direction.x == 0 and direction.y == 0:
			bullet_instance._direction = _last_shoot_direction 
		else:
			_last_shoot_direction = direction
			bullet_instance._direction = _last_shoot_direction 

		get_parent().add_child(bullet_instance)
		_init_shoot_timer()
		can_player_shoot = false
	pass # Replace with function body.

func _on_timer_timeout() -> void:
	can_player_shoot = true
	pass

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray([])

	var parent = get_parent()
	if parent.get_class() != "Level":
		warnings.append("This class should be used only as a child of Level classes")
		pass

	if player_scene == null or player_scene.get_class() != "CharacterBody2D":
		warnings.append("A Player scene (CharacterBody2D) must be given to this class for it to work properly")
		pass

	return warnings

func _init_shoot_timer() -> void:
	if get_child_count() > 0:
		for index in get_child_count():
			var child = get_child(index)
			if child.get_class() == "Timer" and child == _shoot_timer:
				_shoot_timer.start()
			else:
				add_child(_shoot_timer)
				_shoot_timer.start()
				pass
	else:
		add_child(_shoot_timer)
		_shoot_timer.start()
		pass
	pass
