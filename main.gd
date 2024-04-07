extends Node2D

@onready var _shooter_manager: ShooterManager = get_node("ShooterManager")
var _level_scene = preload("res://level.tscn")
var _level_manager: LevelManager = LevelManager.new()
var _map_grid: Array[Dictionary] = []
var _map_index: int = -1
var _level = null

func _ready() -> void:
	var minimap: TileMap = get_node("TileMap")
	var map_size: Vector2 = Vector2(3, 3) 
	_map_grid = _level_manager.create_map(map_size)
	for room in _map_grid:
		if room["is_initial"]:
			var room_position: Vector2 = room["map_position"]
			_map_index = (map_size.x * room_position.y) + room_position.x
		var map_position: Vector2 = room["map_position"]
		var doors: Vector2i = get_doors_from_tileset(room["doors"])
		minimap.set_cell(0, map_position, 0, doors)
	_create_initial_level(_map_index)
	#var tile_set: TileSet = minimap.tile_set
	#var source: TileSetSource = tile_set.get_source(0)

func _create_level_from_dict(room: Dictionary):
	var level = _level_scene.instantiate()
	level.doors = room["doors"].duplicate(true)
	return level

func _create_initial_level(map_index: int):
	_level = _create_level_from_dict(_map_grid[map_index])
	add_child(_level)
	_connect_exit_level_signal(_level)
	
func _connect_exit_level_signal(level):
	level.exit_level.connect(
		func (direction: Vector2):
			match direction:
				Vector2.UP:
					var top = _level_manager._select_top(_map_grid, _map_index)
					var top_level = _create_level_from_dict(top[1])
					_map_index = top[0]
					_level.queue_free()
					_level = top_level
					_switch_level(top_level)
					
				Vector2.RIGHT:
					var right = _level_manager._select_right(_map_grid, _map_index)
					var right_level = _create_level_from_dict(right[1])
					_map_index = right[0]
					_level.queue_free()
					_level = right_level
					_switch_level(right_level)
				Vector2.LEFT:
					var left = _level_manager._select_left(_map_grid, _map_index)
					var left_level = _create_level_from_dict(left[1])
					_map_index = left[0]
					_level.queue_free()
					_level = left_level
					_switch_level(left_level)
				Vector2.DOWN:
					var bottom = _level_manager._select_bottom(_map_grid, _map_index)
					var bottom_level = _create_level_from_dict(bottom[1])
					_map_index = bottom[0]
					_level.queue_free()
					_level = bottom_level
					_switch_level(bottom_level)
				
	)

	
func get_doors_from_tileset(room: Dictionary) -> Vector2i:
	if room["right"] and room["bottom"] and not room["left"] and not room["top"]:
		return Vector2i(0,0)

	if room["right"] and room["left"] and room["bottom"] and not room["top"]:
		return Vector2i(1,0)

	if room["left"] and room["bottom"] and not room["right"] and not room["top"]:
		return Vector2i(2,0)

	if room["right"] and room["bottom"] and room["top"] and not room["left"]:
		return Vector2i(0,1)

	if room["right"] and room["left"] and room["top"] and room["bottom"]:
		return Vector2i(1,1)

	if room["bottom"] and room["left"] and room["top"] and not room["right"]:
		return Vector2i(2,1)

	if room["right"] and room["top"] and not room["left"] and not room["bottom"]:
		return Vector2i(0,2)
	
	if room["right"] and room["left"] and room["top"] and not room["bottom"]:
		return Vector2i(1,2)

	if room["left"] and room["top"] and not room["right"] and not room["bottom"]:
		return Vector2i(2,2)

	#---remaining six
	
	if room["top"] and room["bottom"] and not room["left"] and not room["right"]:
		return Vector2i(3,0)

	if room["left"] and room["right"] and not room["top"] and not room["bottom"]:
		return Vector2i(4,0)

	if room["left"] and not room["top"] and not room["right"] and not room["bottom"]:
		return Vector2i(5,0)

	if room["top"] and not room["left"] and not room["right"] and not room["bottom"]:
		return Vector2i(3,1)

	if room["right"] and not room["top"] and not room["right"] and not room["bottom"]:
		return Vector2i(4,1)
	
	if room["bottom"] and not room["top"] and not room["right"] and not room["left"]:
		return Vector2i(5,0)


	return Vector2i(1,1)

	

func _on_player_shoot(direction):
	_shooter_manager.shoot(direction)
	pass # Replace with function body.



func _on_shoot_timer_timeout():
	_shooter_manager.can_player_shoot = true
	pass # Replace with function body.



func _switch_level(current_level: Node2D):
	var me = self
	var player = get_node("Player")
	_level_manager.call_deferred("switch_level", self, current_level, func (new_level:Node2D):
		player.position = Vector2(100,100)
		await get_tree().create_timer(0.25).timeout
		me._connect_exit_level_signal(new_level)
	)

func _find_current_level_or_null() -> Node2D:
	var children = get_children()
	for child in children:
		if child.is_in_group("level"):
			return child
	return null
