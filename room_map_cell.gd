extends Object

var doors_position: Dictionary = {
	"top": false,
	"bottom": false,
	"left": false,
	"right": false,
}
var visited: bool = false
var is_initial: bool = false
var _random: RandomNumberGenerator = RandomNumberGenerator.new()

func _init() -> void:
	_random.randomize()
	for position in doors_position:
		doors_position[position] = bool(randi_range(0, 1))

	pass
