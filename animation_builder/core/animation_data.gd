extends Resource

const TrackData = preload("res://addons/animation_builder/core/track_data.gd")

@export var anim_name: String = "";
@export var start: int = 0;
@export var length: int = 0;
@export var looping: bool = true;
## Dictionary[String, Array[TrackData]]
@export var values: Dictionary[String, Array] = {};
## Dictionary[String, Array[MethodData]]
@export var methods: Dictionary[String, Array] = {};

func _init(_anim_name: String, _start: int, _length: int,
	_looping: bool = true, _values: Dictionary[String, Array] = {},
	_methods: Dictionary[String, Array] = {},
	) -> void:
		anim_name = _anim_name;
		start = _start;
		length = _length;
		looping = _looping;
		values = _values;
		methods = _methods;

func _to_string() -> String:
	var return_str: String = "{\n";
	return_str += "anim_name: %s\n" % anim_name;
	return_str += "start: %s\n" % start;
	return_str += "length: %s\n" % length;
	return_str += "looping: %s\n" % looping;
	return_str += "values: %s\n" % values;
	return_str += "methods: %s\n" % methods;
	return_str += "}";
	return return_str;
