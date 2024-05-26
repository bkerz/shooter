class_name LevelManager extends Node2D

var _random = RandomNumberGenerator.new()

func _create_new_level() -> Node:
	var level = preload("res://levels/level.tscn").instantiate()
	return level

func switch_level(parent: Node2D, current_level: Node2D, callback: Callable) -> void:
	parent.add_child(current_level)
	callback.call(current_level)

##create a list of dictionaries representing each room, not visited and no door opened
func _create_map_grid(size: Vector2) -> Array[Dictionary]:
	var grid: Array[Dictionary] = []
	var x_axis = 0
	var y_axis = 0
	var loop_amount = size.x * size.y

	for index in range(loop_amount):

		grid.append(_create_room_dict(Vector2(x_axis, y_axis)))
		if x_axis == size.x -1:
			x_axis = -1 
			y_axis += 1
			pass

		x_axis += 1
	return grid


func create_map(size: Vector2) -> Array[Dictionary]:
	# TODO: Fill this bidimensional array with Dictionaties
	#Then use a random number to select the initial room
	#Then run a method to select the adjacent not visited rooms
	#Randomly add the doors positions for each adjacent room
	#Repeat that process until all are visited
	#Implemente an A* or whatever path finding algorithm to select the Boss room

	var grid = _create_map_grid(size)
	var initial_room: Array = _select_initial_room(grid)

	var grid_with_doors = _create_conections(grid, initial_room[0])
	
	for item in grid:
		print(item)

	return grid_with_doors

func _create_conections(grid: Array[Dictionary], starting_point: int) -> Array[Dictionary]:
	var new_grid: Array[Dictionary] = []
	var last_item: Dictionary = grid[grid.size() - 1]
	var iterations: int = (last_item["map_position"].x + 1) * (last_item["map_position"].y + 1)
	var index:int = starting_point
	var current_room: Dictionary = grid[starting_point]
	_random.randomize()

	for i in range(iterations):
		#first we get the available directions of the doors to be set {directions: <Dictionary>, count: <int>}
		var available_directions: Dictionary = _get_directions_available(current_room, grid.duplicate(true))
		#then we count the current room doors already set
		var current_doors: int = _count_doors(current_room["doors"])
		var max_doors_number: int = 0
		if current_doors == 0:
			#now we set the maximun number of doors we will set
			max_doors_number = randi_range(1, available_directions["count"])
			var new_doors: Dictionary = _get_random_doors(current_room, max_doors_number, available_directions["directions"])
			current_room["doors"] = new_doors
		else:
			max_doors_number = randi_range(current_doors, available_directions["count"])
			var new_doors: Dictionary = _get_random_doors(current_room, max_doors_number, available_directions["directions"])
			var keys: Array = current_room["doors"].keys()
			var values: Array = current_room["doors"].values()
			for doors_index in range(keys.size() - 1):
				if not values[doors_index]:
					var door_position: String = keys[doors_index]
					current_room["doors"][door_position] = new_doors[door_position]

		_match_adjacent_room_doors(grid, index, current_room["doors"])
		current_room["checked"] = true
		new_grid.append(current_room)
		if i + 1 == iterations:
			continue
		else:
			var next: Array = _select_next_room(grid, index)
			if next[1] == null:
				continue
			current_room = next[1]
			index = next[0]
			

	new_grid.sort_custom(func (a, b):
			var a_position:Vector2 = a["map_position"]
			var b_position:Vector2 = b["map_position"]
			return ((a_position.y * iterations) + a_position.x) < ((b_position.y * iterations) + b_position.x)
	)
	return new_grid

##get the direction to which the doors can be set to true
##format: {directions: Dictionary, count: int}
func _get_directions_available(current_room: Dictionary, rooms: Array[Dictionary]) -> Dictionary:
	var opened_doors: Array[String] = []

	#filter doors "opened" in opened_doors array
	for key in current_room["doors"].keys():
		if current_room["doors"][key]:
			opened_doors.append(key) 

	#get the maximum amount of columns the grid can have
	var max_columns: int = rooms[rooms.size() - 1]["map_position"].x + 1
	var current_position: Vector2 = current_room["map_position"]
	# var starting_point: int = rooms.find(func (item): return item["map_position"].x == position.x and item["map_position"].y == position.y)
	var starting_point: int = int((current_position.y * max_columns) + current_position.x)
	var bottom_room = _select_bottom(rooms, starting_point)
	var top_room = _select_top(rooms, starting_point)
	var left_room = _select_left(rooms, starting_point)
	var right_room = _select_right(rooms, starting_point)
	var count: int = 0
	var directions: Dictionary = {}
	var list: Array[Dictionary] = [{"direction": "top", "value": top_room}, {"direction": "left", "value": left_room},
	{"direction": "bottom", "value":bottom_room}, {"value": right_room, "direction": "right"}]

	for item in list:
		var room = item["value"]
		var direction:String = item["direction"]
		if room[1] != null and not opened_doors.has(direction):
			directions[direction] = true
			count += 1
		else:
			directions[direction] = false

	return {
		"directions": directions,
		"count": count
	}
	

##select the next room to be checked
func _select_next_room(grid: Array[Dictionary], starting_point: int) -> Array:
	var _previous: Dictionary = grid[starting_point]
	var top: Array = _select_top(grid, starting_point)
	var bottom: Array = _select_bottom(grid, starting_point)
	var right: Array = _select_right(grid, starting_point)
	var left: Array = _select_left(grid, starting_point)
	var adjacent_rooms: Array = [top, left, bottom, right]

	if adjacent_rooms.all(func (room): return room[1] == null and room[0] < 0):
		return [-1, null]
	var are_all_checked: bool = adjacent_rooms.filter(func (item): return item[1] != null).all(func (room): return room[1] != null and room[1]["checked"])
	if are_all_checked:
		#select a new item that hasn't been checked before
		var found: Dictionary = {}
		var index: int = 0
		for item in grid:
			if item["checked"]:
				continue
			found = item
			index += 1
		return [index, found]
	#keep only the rooms not null
	adjacent_rooms = adjacent_rooms.filter(func (item): return item[1] != null)
	var next: Array = adjacent_rooms.pick_random()

	#if next is checked, loop through adjacent_rooms until finding an unchecked item
	while next[1] != null and next[1]["checked"] == true:
		next = adjacent_rooms.pick_random()
	return next
	

func _match_adjacent_room_doors(grid: Array[Dictionary], room_index: int, doors: Dictionary) -> void:
	# var door_directions: Array[String] = []
	var keys: Array = doors.keys()
	var values: Array = doors.values()
	for index in range(4):
		var value: bool = values[index]
		var key: String = keys[index]
		if value:
			if key == "top":
				var item = _select_top(grid, room_index)[1]
				if item != null:
					var top: Dictionary = item
					top["doors"]["bottom"] = true

			if key == "bottom":
				var item = _select_bottom(grid, room_index)[1]
				if item != null:
					var bottom: Dictionary = item
					bottom["doors"]["top"] = true

			if key == "right":
				var item = _select_right(grid, room_index)[1]
				if item != null:
					var right: Dictionary = item
					right["doors"]["left"] = true

			if key == "left":
				var item = _select_left(grid, room_index)[1]
				if item != null:
					var left: Dictionary = item
					left["doors"]["right"] = true

## get number of doors set as true
func _count_doors(current_room: Dictionary) -> int:
	var values: Array = current_room.values()
	var keys: Array = current_room.keys()
	var counter: int = 0
	for index in range(keys.size() - 1):
		var value: bool = values[index]
		if value:
			counter += 1

	return counter
		


##create a dictionary with the doors to be "open" in the current room
func _get_random_doors(room: Dictionary, max_doors: int, available_doors: Dictionary) -> Dictionary:
	var current_doors:Dictionary = room["doors"].duplicate(true)
	#list of keys of opened doors
	var keys: Array[String] = []
	for key in available_doors:
		if available_doors[key]:
			keys.append(key)

	var new_doors: Dictionary = {}
	var interator: int = max_doors
	if keys.is_empty():
		return {
		"top": false,
		"left": false,
		"right": false,
		"bottom": false,
		}
	while interator > 0 and not new_doors.keys().size() == keys.size():
		var direction:String = keys.pick_random()
		if new_doors.has(direction):
			continue
		new_doors[direction] = true
		interator -= 1

	current_doors.merge(new_doors, true)
	return current_doors
		

func _select_bottom(grid: Array[Dictionary], starting_point: int) -> Array:
	var last_room: Dictionary = grid[grid.size() -1]
	var pos:Vector2 = last_room["map_position"]
	var multiplier: int = int(pos.x) + 1
	var index = multiplier + starting_point 
	if index < 0 or index > grid.size() -1:
		return [-1, null]
	return [index, grid[index]]

func _select_top(grid: Array[Dictionary], starting_point: int) -> Array:
	var last_room: Dictionary = grid[grid.size() -1]
	var pos:Vector2 = last_room["map_position"]
	var multiplier: int = int(pos.x) + 1
	var index = starting_point - multiplier
	if index < 0 or index > grid.size() - 1:
		return [-1, null]
	return [index, grid[index]]

func _select_right(grid: Array[Dictionary], starting_point: int) -> Array:
	var current_position: Vector2 = grid[starting_point]["map_position"]
	var last_room_position: Vector2 = grid[grid.size() -1]["map_position"]
	if current_position.x + 1 <= last_room_position.x:
		var index = starting_point + 1
		if index < 0 or index > grid.size() - 1:
			return [-1, null]
		return [index, grid[index]]
	return [-1, null]

func _select_left(grid: Array[Dictionary], starting_point: int) -> Array:
	var current_position: Vector2 = grid[starting_point]["map_position"]
	# var last_room_position: Vector2 = grid[grid.size() -1]["map_position"]
	if current_position.x -1 >= 0:
		var index = starting_point - 1
		if index < 0 or index > grid.size() - 1:
			return [-1, null]
		return [index, grid[index]]
	return [-1, null]

func _select_initial_room(grid: Array[Dictionary]) -> Array:
	var random_gen = RandomNumberGenerator.new()
	random_gen.randomize()
	var index = randi_range(0, grid.size() -1)
	var initial_room: Dictionary = grid[index]
	initial_room["is_initial"] = true
	return [index, initial_room]


##creates a room object
func _create_room_dict(map_position: Vector2) -> Dictionary:
	return {
		"doors": {
			"top": false,
			"bottom": false,
			"right": false,
			"left": false,
		},
		"map_position": map_position,
		"visited": false,
		"checked": false,
		"is_initial": false
	}
