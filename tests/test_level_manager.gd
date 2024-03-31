extends GutTest

class TestMinimapCreation:
	extends GutTest

	var level_manager = null

	func before_each():
		level_manager = LevelManager.new()

	func test_room_dict_creation():
		var test_vector = Vector2(2,2)
		var room: Dictionary = level_manager._create_room_dict(test_vector)
		assert_eq(room.get("checked"), false)
		assert_eq(room.get("visited"), false)
		assert_eq(room.get("map_position"), test_vector)
		assert_eq(room.get("is_initial"), false)
		assert_eq(room.get("doors")["bottom"], false)
		assert_eq(room.get("doors")["top"], false)
		assert_eq(room.get("doors")["right"], false)
		assert_eq(room.get("doors")["left"], false)

	func test_base_minimap_grid_creation():
		var grid:Array[Dictionary] = level_manager._create_map_grid(Vector2(2,2))
		assert_eq(grid.size(), 4)
		
		var grid_3x3: Array[Dictionary] = level_manager._create_map_grid(Vector2(3,3))
		assert_eq(grid_3x3.size(), 9)

class TestIntegrationDoors:
	extends GutTest
	var level_manager = null
	var test_initial_position := 0
	var test_final_position := 3
	var grid: Array[Dictionary] = []

	func before_each():
		level_manager = LevelManager.new()
		grid = level_manager._create_map_grid(Vector2(2,2))

	func test_get_random_doors():
		var test_room = level_manager._create_room_dict(Vector2(1,0))
		var test_available_rooms = {
			"top": false,
			"right": false,
			"left": true,
			"bottom": true,
		}
		var random_doors:Dictionary = level_manager._get_random_doors(test_room, 1, test_available_rooms)
		assert_false(random_doors["top"])
		assert_false(random_doors["right"])
		var left_or_bottom: bool = random_doors["left"] or random_doors["bottom"]
		assert_true(left_or_bottom)

		var test_available2: Dictionary = test_available_rooms.duplicate(true)
		#only top and bottom will be true
		test_available2["left"] = false
		test_available2["top"] = true
		var random_doors2: Dictionary = level_manager._get_random_doors(test_room, 2, test_available2)
		
		assert_false(random_doors2["right"])
		assert_false(random_doors2["left"])
		var top_and_bottom: bool = random_doors2["top"] and random_doors2["bottom"]
		assert_true(top_and_bottom)

		var test_available3 = {
		"top": false,
		"right": false,
		"left": false,
		"bottom": false,
		}
		var random_doors3 = level_manager._get_random_doors(test_room, 3, {})
		assert_eq(test_available3, random_doors3)

		var random_doors4 = level_manager._get_random_doors(test_room, 4, test_available3)
		assert_eq(random_doors4, test_available3)

		var test_available4 = {
			"top": false,
			"right": true,
			"left": false,
			"bottom": false,
		}

		var random_doors5 = level_manager._get_random_doors(test_room, 4, test_available4)
		var true_values_count: int = random_doors5.values().count(true)
		assert_eq(true_values_count, 1, "there has to be only one true value")

		
		var test_available5 = {
			"top": false,
			"right": true,
			"left": true,
			"bottom": false,
		}
		
		var random_doors6 = level_manager._get_random_doors(test_room, 4, test_available5)
		true_values_count = random_doors6.values().count(true)
		assert_eq(true_values_count, 2, "there has to be only two true values")

	func test_match_single_doors_with_adjacent_doors():
		var test_grid = level_manager._create_map_grid(Vector2(2,2))
		var room_doors = test_grid[0]["doors"]
		room_doors["right"] = true
		level_manager._match_adjacent_room_doors(test_grid, 0, room_doors)
		assert_true(test_grid[0]["doors"]["right"], "current room should remain with its doors intact after matching doors")
		
		assert_true(test_grid[1]["doors"]["left"], "adjacent room should match its doors with the current room after matching doors")
		assert_eq(test_grid[2]["doors"], 
		{
			"top": false,
			"right": false,
			"left": false,
			"bottom": false,
		},
		"adjacent rooms should not match doors if current room doesn't have a door 'opened' in their direction")
		assert_eq(test_grid[3]["doors"], 
		{
			"top": false,
			"right": false,
			"left": false,
			"bottom": false,
		},
		"non adjacent rooms should not match doors with current room")

	func test_match_two_doors_with_adjacent_doors():
		var test_grid = level_manager._create_map_grid(Vector2(2,2))
		test_grid[0]["doors"]["right"] = true
		test_grid[0]["doors"]["bottom"] = true
		level_manager._match_adjacent_room_doors(test_grid, 0, test_grid[0]["doors"])
		
		assert_true(test_grid[0]["doors"]["right"])
		assert_true(test_grid[0]["doors"]["bottom"])
		assert_true(test_grid[1]["doors"]["left"])
		assert_true(test_grid[2]["doors"]["top"])

		test_grid = level_manager._create_map_grid(Vector2(2,2))
		test_grid[3]["doors"]["top"] = true
		test_grid[3]["doors"]["left"] = true
		level_manager._match_adjacent_room_doors(test_grid, 3, test_grid[3]["doors"])

		assert_true(test_grid[3]["doors"]["top"])
		assert_true(test_grid[3]["doors"]["left"])
		assert_true(test_grid[1]["doors"]["bottom"])
		assert_true(test_grid[2]["doors"]["right"])
		gut.p(test_grid)


	func test_select_next_room_from_first_position_in_rooms_list():
		var test_grid = level_manager._create_map_grid(Vector2(3,3))
		test_grid[0]["checked"] = true 
		var next = level_manager._select_next_room(grid, 0)
		var is_right_or_bottom: bool = next[1]["map_position"] == Vector2(1,0) or next[1]["map_position"] == Vector2(0,1)
		assert_true(is_right_or_bottom)
		assert_gt(next[0], -1)
		
	func test_select_next_room_from_center_with_two_adjacent_checked_rooms():
		var test_grid: Array[Dictionary] = level_manager._create_map_grid(Vector2(3,3))
		test_grid[4]["checked"] = true #check item in the center of the grid
		test_grid[3]["checked"] = true #check the one at the left of the center
		test_grid[1]["checked"] = true #check the one above the center
		var next = level_manager._select_next_room(test_grid, 4)
		assert_not_null(next[1])
		var is_right_or_bottom: bool = next[1]["map_position"] == Vector2(1,2) or next[1]["map_position"] == Vector2(2,1)
		assert_true(is_right_or_bottom)
		assert_gt(next[0], -1)

	func test_select_next_room_from_right_bottom_corner():
		var test_grid: Array[Dictionary] = level_manager._create_map_grid(Vector2(3,3))
		test_grid[8]["checked"] = true #check item at the right bottom corner
		var next = level_manager._select_next_room(test_grid, 8)
		var is_top_or_left: bool = next[1]["map_position"] == Vector2(2,1) or next[1]["map_position"] == Vector2(1,2)
		assert_true(is_top_or_left)
		assert_gt(next[0], -1)

	func test_select_next_room_from_right_bottom_corner_with_two_adjacent_checked_rooms():
		var test_grid: Array[Dictionary] = level_manager._create_map_grid(Vector2(2,2))

		#check all items but the left bottom corner
		test_grid[0]["checked"] = true 
		test_grid[1]["checked"] = true 
		test_grid[3]["checked"] = true 

		var next = level_manager._select_next_room(test_grid, 3)
		assert_not_null(next[1])
		var next_position = null
		if next[1]:
			next_position = next[1]["map_position"]

		assert_eq(next_position, Vector2(0,1))

class TestGetAvailableRooms:
	extends GutTest
	var level_manager = null
	var grid: Array[Dictionary] = []

	func before_each():
		level_manager = LevelManager.new()
		grid = level_manager._create_map_grid(Vector2(2,2))

	func test_left_top_doors_are_always_false_for_the_first_room():
		var available_directions = level_manager._get_directions_available(grid[0].duplicate(true), grid.duplicate(true))
		var directions = available_directions["directions"]
		assert_false(directions["left"])
		assert_false(directions["top"])

	func test_bottom_left_corner_will_have_available_only_right_top_doors_even_with_true_doors_already():
		var test_grid = level_manager._create_map_grid(Vector2(2,2))
		test_grid[0]["doors"]["bottom"] = true
		test_grid[2]["doors"]["top"] = true

		var available_directions = level_manager._get_directions_available(test_grid[2].duplicate(true), test_grid.duplicate(true))
		var directions_from_left_bottom_corner = available_directions["directions"]
		assert_false(directions_from_left_bottom_corner["left"])
		assert_false(directions_from_left_bottom_corner["bottom"])

	func test_bottom_right_corner_will_have_available_only_left_top_doors():
		var test_grid = level_manager._create_map_grid(Vector2(2,2))
		test_grid[0]["doors"]["right"] = true
		test_grid[1]["doors"]["left"] = true

		#get available directions from right bottom corner
		var available_directions = level_manager._get_directions_available(test_grid[3].duplicate(true), test_grid.duplicate(true))
		var directions_from_right_bottom_corner = available_directions["directions"]
		assert_false(directions_from_right_bottom_corner["right"])
		assert_false(directions_from_right_bottom_corner["bottom"])

class TestSelectAdjacentRooms:
	extends GutTest
	var level_manager = null
	var grid: Array[Dictionary] = []
	var test_initial_position = 0
	var test_final_position = 3

	func before_each():
		level_manager = LevelManager.new()
		grid = level_manager._create_map_grid(Vector2(2,2))
		

	func test_select_top_room():
		assert_null(level_manager._select_top(grid, test_initial_position)[1],  "[-1, null] when selecting non existing room")
		assert_eq(level_manager._select_top(grid, test_initial_position)[0], -1, "[-1, null] when selecting non existing room")
		var test_selection1: Array = level_manager._select_top(grid, test_final_position)
		gut.p(test_selection1)
		assert_not_null(test_selection1[1], "if selecting top adjacent room from last one should not be null")
		assert_gt(test_selection1[0], -1, "if selecting top adjacent room from last one, index should not be less than 0")
		
		var test_selection2: Array = level_manager._select_top(grid, 1)
		assert_null(test_selection2[1], "if selecting top adjacent room from first row should be null")
		assert_eq(test_selection2[0], -1, "if selecting top adjacent room from first row, index should be -1")
	
	func test_select_bottom_room():
		assert_not_null(level_manager._select_bottom(grid, test_initial_position)[1],  "[-1, null] when selecting non existing room")
		assert_gt(level_manager._select_bottom(grid, test_initial_position)[0], -1, "[-1, null] when selecting non existing room")
		var test_selection1: Array = level_manager._select_bottom(grid, test_final_position)

		assert_null(test_selection1[1], "if selecting top adjacent room from last one should not be null")
		assert_eq(test_selection1[0], -1, "if selecting top adjacent room from last one, index should not be less than 0")
		
		var test_selection2: Array = level_manager._select_bottom(grid, 1)
		assert_not_null(test_selection2[1], "if selecting top adjacent room from first row should be null")
		assert_gt(test_selection2[0], -1, "if selecting top adjacent room from first row, index should be -1")
		assert_eq(test_selection2[1]["map_position"], grid[3]["map_position"])

	func test_select_bottom_from_left_bottom_corner():
		var test_selection: Array = level_manager._select_bottom(grid, 2)
		assert_null(test_selection[1], "we are in the left bottom corner, so there's shouldn't be anything below")
		assert_eq(test_selection[0], -1)

	func test_select_right_room():
		var test_selection = level_manager._select_right(grid, test_initial_position)
		assert_not_null([1],  "[-1, null] when selecting non existing room")
		assert_eq(test_selection[1]["map_position"], grid[1]["map_position"])
		assert_gt(test_selection[0], -1)

		var test_selection1: Array = level_manager._select_right(grid, test_final_position)

		assert_null(test_selection1[1], "if selecting top adjacent room from last one should not be null")
		assert_eq(test_selection1[0], -1, "if selecting top adjacent room from last one, index should not be less than 0")
		
		var test_selection2: Array = level_manager._select_right(grid, 1)
		assert_null(test_selection2[1])
		assert_eq(test_selection2[0], -1, "if selecting top adjacent room from last one, index should not be less than 0")

	func test_select_left_room():
		
		assert_null(level_manager._select_left(grid, test_initial_position)[1],  "null when selecting non existing room")
		assert_eq(level_manager._select_left(grid, test_initial_position)[0], -1, "-1 when selecting non existing room")

		var test_selection1: Array = level_manager._select_left(grid, test_final_position)
		assert_not_null(test_selection1[1], "if selecting top adjacent room from last one should not be null")
		assert_gt(test_selection1[0], -1, "if selecting top adjacent room from last one, index should not be less than 0")
		assert_eq(test_selection1[1]["map_position"], grid[2]["map_position"])
		
		var test_selection2: Array = level_manager._select_left(grid, 2)
		assert_null(test_selection2[1], "if selecting top adjacent room from first row should be null")
		assert_eq(test_selection2[0], -1, "if selecting top adjacent room from first row, index should be -1")

	func test_select_left_from_center_in_3x3_grid():
		var test_grid = level_manager._create_map_grid(Vector2(3,3))
		var left_room = level_manager._select_left(test_grid, 4)
		assert_not_null(left_room[1], "the left room from the center room shouldn't be null")

class TestDoorsConnections:
	extends GutTest
	var level_manager = null
	var grid: Array[Dictionary] = []

	func before_each():
		level_manager = LevelManager.new()
		grid = level_manager._create_map_grid(Vector2(2,2))

	func test_connect_rooms_for_2x2_grid():
		var grid_with_initial_value = grid.duplicate(true)
		grid_with_initial_value[0]["is_initial"] = true
		var grid_with_connections:Array[Dictionary] = level_manager._create_conections(grid_with_initial_value, 0)

		print(grid_with_connections)

		#get doors for each position
		var first_doors = grid_with_connections[0]["doors"]
		var second_doors = grid_with_connections[1]["doors"]
		var third_doors = grid_with_connections[2]["doors"]
		var fourth_doors = grid_with_connections[3]["doors"]

		#check if each corner (there are only corners) have the right connections
		var is_left_top_corner_ok:bool = first_doors["left"] == false and first_doors["top"] == false
		var is_right_top_corner_ok:bool = second_doors["right"] == false and second_doors["top"] == false
		var is_left_bottom_corner_ok:bool = third_doors["left"] == false and third_doors["bottom"] == false
		var is_right_bottom_corner_ok:bool = fourth_doors["right"] == false and fourth_doors["bottom"] == false

		#check every corner has the right door directions set to false
		assert_true(is_left_top_corner_ok)
		assert_true(is_right_top_corner_ok)
		assert_true(is_right_bottom_corner_ok)
		assert_true(is_left_bottom_corner_ok)

		#check all rooms have doors set to true
		assert_gt(first_doors.values().count(true), 0)
		assert_gt(second_doors.values().count(true), 0)
		assert_gt(third_doors.values().count(true), 0)
		assert_gt(fourth_doors.values().count(true), 0)

