extends Resource

const AnimParam = preload("res://addons/animation_builder/core/anim_param.gd");

@export var interpolation: int;
@export var path: String;
@export var frame: float;
@export var value: AnimParam;

func _init(_path: String, _frame: float, _value: AnimParam, _interpolation: int) -> void:
	path = _path;
	frame = _frame;
	value = _value;
	interpolation = _interpolation;

func _to_string() -> String:
	var return_str = "{";
	return_str += "path: %s; " % path;
	return_str += "frame: %s; " % frame;
	return_str += "value: %s; " % value;
	return_str += "interpolation: %s" % interpolation;
	return_str += "}";
	return return_str;
