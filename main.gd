extends Node2D

@onready var _shooter_manager: ShooterManager = get_node("ShooterManager")
var _level_manager: LevelManager = LevelManager.new()

func _ready() -> void:
	var minimap: TileMap = get_node("TileMap")
	var grid: Array[Dictionary] = _level_manager.create_map(Vector2(2, 2))
	for room in grid:
		var map_position: Vector2 = room["map_position"]
		var doors: Vector2i = get_doors_from_tileset(room["doors"])
		minimap.set_cell(0, map_position, 0, doors)
	#var tile_set: TileSet = minimap.tile_set
	#var source: TileSetSource = tile_set.get_source(0)
	
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
		return Vector2i(4,0)
	
	if room["bottom"] and not room["top"] and not room["right"] and not room["left"]:
		return Vector2i(5,0)


	return Vector2i(1,1)

	

func _on_player_shoot(direction):
	_shooter_manager.shoot(direction)
	pass # Replace with function body.



func _on_shoot_timer_timeout():
	_shooter_manager.can_player_shoot = true
	pass # Replace with function body.



func _on_level_exit_level():
	var current_level = _find_current_level_or_null()
	if current_level != null:
		_switch_level(current_level)
	

func _switch_level(current_level: Node2D):
	var me = self
	var player = get_node("Player")
	_level_manager.call_deferred("switch_level", self, current_level, func (new_level:Node2D):
		player.position = Vector2(100,100)
		await get_tree().create_timer(0.25).timeout
		new_level.exit_level.connect(me._on_level_exit_level)
	)

func _find_current_level_or_null() -> Node2D:
	var children = get_children()
	for child in children:
		if child.is_in_group("level"):
			return child
	return null
