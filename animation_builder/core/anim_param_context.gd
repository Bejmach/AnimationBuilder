extends Resource

var lib_name: String;
var facing_dir: int;
var directions: int;
var frame_time: float;
var iso_scale: float;
var start_direction: Vector2;
var direction_offset: float;

func _init(
	_lib_name: String,
	_facing_dir: int,
	_directions: int,
	_frame_time: float,
	_iso_scale: float,
	_start_direction: Vector2,
	_direction_offset: float,
) -> void:
	lib_name = _lib_name;
	facing_dir = _facing_dir;
	directions = _directions;
	frame_time = _frame_time;
	iso_scale = _iso_scale;
	start_direction = _start_direction;
	direction_offset = _direction_offset;
