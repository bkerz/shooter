extends Node2D

var _last_shoot_direction: Vector2 = Vector2.RIGHT
var _can_player_shoot: bool = true
var bullet = preload("res://bullet.tscn")

func _on_player_shoot(direction):
	if _can_player_shoot:
		var bullet_instance = bullet.instantiate()
		bullet_instance.position.x = $Player.position.x
		bullet_instance.position.y = $Player.position.y
		bullet_instance.rotation_degrees = 90
		if direction.x == 0 and direction.y == 0:
			bullet_instance._direction = _last_shoot_direction 
		else:
			_last_shoot_direction = direction
			bullet_instance._direction = _last_shoot_direction 

		add_child(bullet_instance)
		var shoot_timer: Timer = get_node("ShootTimer")
		shoot_timer.start()
		_can_player_shoot = false
	pass # Replace with function body.



func _on_shoot_timer_timeout():
	_can_player_shoot = true
	pass # Replace with function body.

