class_name LevelManager extends Node2D

var _random = RandomNumberGenerator.new()

func _create_new_level() -> Node:
	var level = preload("res://level.tscn").instantiate()
	return level

func switch_level(parent: Node2D, current_level: Node2D, callback: Callable) -> void:
	var hello: String = ""
	current_level.queue_free()
	var new_level = _create_new_level()
	parent.add_child(new_level)
	callback.call(new_level)

func create_map(size: Vector2) -> Array[Dictionary]:
	# TODO: Fill this bidimensional array with Dictionaties
	#Then use a random number to select the initial room
	#Then run a method to select the adjacent not visited rooms
	#Randomly add the doors positions for each adjacent room
	#Repeat that process until all are visited
	#Implemente an A* or whatever path finding algorithm to select the Boss room
	var grid: Array[Dictionary]
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

	var initial_room: Array = _select_initial_room(grid)
	# var top = _select_top(grid, initial_room[0])
	# var bottom = _select_bottom(grid, initial_room[0])
	# print("testing if setting the doors is working")
	# print(initial_room)
	# var total_doors = randi_range(1, 4)
	# print("initial_room with doors: ", _get_random_doors(initial_room[1], total_doors))
	# initial_room[1]["doors"] = _get_random_doors(initial_room[1], total_doors)
	# _match_adjacent_room_doors(grid, initial_room[0], initial_room[1]["doors"].duplicate())
	# print("adjacent_top: ", _select_top(grid, initial_room[0]))
	# print("adjacent_bottom: ", _select_bottom(grid, initial_room[0]))
	# print("adjacent_right: ", _select_right(grid, initial_room[0]))
	# print("adjacent_left: ", _select_left(grid, initial_room[0]))

	var grid_with_doors = _create_conections(grid, initial_room[0])
	print("this is the grid with doors")
	for item in grid:
		print(item)

	return grid

func _create_conections(grid: Array[Dictionary], starting_point: int) -> Array[Dictionary]:
	var new_grid: Array[Dictionary] = []
	var last_item: Dictionary = grid[grid.size() - 1]
	var iterations: int = (last_item["map_position"].x + 1) * (last_item["map_position"].y + 1)
	var index:int = starting_point
	var current_room: Dictionary = grid[starting_point]
	_random.randomize()

	for i in range(iterations):
		var current_doors:int = _count_doors(current_room)
		var total_doors: int = 0
		if current_doors == 0:
			total_doors = randi_range(1, 4)
			print("total_doors: ", total_doors)
			print("")
			var new_doors: Dictionary = _get_random_doors(current_room, total_doors)
			print("new_doors: ", new_doors)
			print("")
			current_room["doors"] = new_doors
			print("new_doors: ", new_doors)
			print("current_room: ", current_room)
			print("")
		else:
			total_doors = randi_range(current_doors, 4)
			print("total_doors: ", total_doors)
			print("")
			var new_doors: Dictionary = _get_random_doors(current_room, total_doors)
			print("new_doors: ", new_doors)
			print("")
			var keys: Array = current_room["doors"].keys()
			var values: Array = current_room["doors"].values()
			for doors_index in range(keys.size() - 1):
				if not values[doors_index]:
					var door_position: String = keys[doors_index]
					current_room["doors"][door_position] = new_doors[door_position]
			
			print("new_doors: ", new_doors)
			print("current_room: ", current_room)
			print("")
			
		_match_adjacent_room_doors(grid, index, current_room["doors"].duplicate())
		print("current_room: ", current_room)
		print("")
		current_room["checked"] = true
		print("current_room: ", current_room)
		print("")
		new_grid.append(current_room)
		print("new_grid: ", new_grid)
		print("")
		if i + 1 == iterations:
			continue
		else:
			print("interation numbber: ", i)
			var next: Array = _select_next_room(grid, index)
			print("next: ", next)
			print("")
			current_room = next[1]
			print("current_room: ", current_room)
			print("")
			index = next[0]
			print("index: ", index)
			print("---------------")
		
	return new_grid

func _select_next_room(grid: Array[Dictionary], starting_point: int) -> Array:
	var previous: Dictionary = grid[starting_point]
	var top: Array = _select_top(grid, starting_point)
	var bottom: Array = _select_bottom(grid, starting_point)
	var right: Array = _select_right(grid, starting_point)
	var left: Array = _select_left(grid, starting_point)
	if top[1]["checked"] and bottom[1]["checked"] and right[1]["checked"] and left[1]["checked"]:
		var found: Dictionary = {}
		var index: int = 0
		for item in grid:
			if item["checked"]:
				continue
			found = item
			index += 1
		return [index, found]
	var adjacent_room: Array[Array] = [
		top,
		bottom,
		right,
		left
	]
	var next: Array = adjacent_room.pick_random()
	while next[1]["checked"] == true:
		next = adjacent_room.pick_random()
	return next
	

func _match_adjacent_room_doors(grid: Array[Dictionary], room_index: int, doors: Dictionary) -> void:
	var door_directions: Array[String] = []
	var keys: Array = doors.keys()
	var values: Array = doors.values()
	for index in range(doors.keys().size() - 1):
		var value: bool = values[index]
		var key: String = keys[index]
		if value:
			if key == "top":
				var top: Dictionary = _select_top(grid, room_index)[1]
				top["doors"]["bottom"] = true

			if key == "bottom":
				var bottom: Dictionary = _select_bottom(grid, room_index)[1]
				bottom["doors"]["top"] = true

			if key == "right":
				var right: Dictionary = _select_right(grid, room_index)[1]
				right["doors"]["right"] = true

			if key == "left":
				var left: Dictionary = _select_left(grid, room_index)[1]
				left["doors"]["left"] = true

func _count_doors(room: Dictionary) -> int:
	var values: Array = room["doors"].values()
	var keys: Array = room.keys()
	var counter: int = 0
	for index in range(keys.size() - 1):
		var value: bool = values[index]
		if value:
			counter += 1

	return counter
		


func _get_random_doors(room: Dictionary, total_doors: int) -> Dictionary:
	var current_doors:Dictionary = room["doors"].duplicate()
	var keys: Array = current_doors.keys()
	var new_doors: Dictionary = {}
	var interator: int = total_doors
	while interator > 0:
		var direction: String = keys.pick_random()
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
		index = starting_point
	return [index, grid[index]]

func _select_top(grid: Array[Dictionary], starting_point: int) -> Array:
	var last_room: Dictionary = grid[grid.size() -1]
	var pos:Vector2 = last_room["map_position"]
	var multiplier: int = int(pos.x) + 1
	var index = starting_point - multiplier
	if index < 0 or index > grid.size() - 1:
		index = starting_point
	return [index, grid[index]]

func _select_right(grid: Array[Dictionary], starting_point: int) -> Array:
	var index = starting_point + 1
	if index < 0 or index > grid.size() - 1:
		index = starting_point
	return [index, grid[index]]

func _select_left(grid: Array[Dictionary], starting_point: int) -> Array:
	var index = starting_point - 1
	if index < 0 or index > grid.size() - 1:
		index = starting_point
	return [index, grid[index]]

func _select_initial_room(grid: Array[Dictionary]) -> Array:
	_random.randomize()
	var index = randi_range(0, grid.size() -1)
	var initial_room: Dictionary = grid[index]
	initial_room["is_initial"] = true
	return [index, initial_room]


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
