extends Resource

var facing_dir: int;
var directions: int;
var frame_time: float;

func _init(_facing_dir: int, _directions: int, _frame_time: float) -> void:
	facing_dir = _facing_dir;
	directions = _directions;
	frame_time = _frame_time;
