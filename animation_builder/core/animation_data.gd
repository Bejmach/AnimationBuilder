extends Resource

@export var anim_name: String = "";
@export var start: int = 0;
@export var length: int = 0;
@export var directions: int = 16;
@export var looping: bool = true;
@export var method_locations: Dictionary[String, int] = {};
@export var method_params: Dictionary[String, Array] = {};

func _init(_anim_name: String, _start: int, _length: int,
	_looping: bool = true, _directions: int = 16,
	_method_locations: Dictionary[String, int] = {},
	_method_params: Dictionary[String, Array] = {}
	) -> void:
		anim_name = _anim_name;
		start = _start;
		length = _length;
		directions = _directions;
		looping = _looping;
		method_locations = _method_locations;
		method_params = _method_params;

func _to_string() -> String:
	var return_str: String = "{\n";
	return_str += "anim_name: %s\n" % anim_name;
	return_str += "start: %s\n" % start;
	return_str += "length: %s\n" % length;
	return_str += "directions: %s\n" % directions;
	return_str += "looping: %s\n" % looping;
	return_str += "mathod_locations: %s\n" % method_locations;
	return_str += "method_params: %s\n" % method_params;
	return_str += "}";
	return return_str;
