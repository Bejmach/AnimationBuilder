extends Resource

const AnimParam = preload("res://addons/animation_builder/core/anim_param.gd");

@export var path: String;
@export var frame: float;
@export var value: AnimParam;

func _init(_path: String, _frame: float, _value: AnimParam) -> void:
	path = _path;
	frame = _frame;
	value = _value;

func _to_string() -> String:
	var return_str = "{\n";
	return_str += "path: %s\n" % path;
	return_str += "frame: %s\n" % frame;
	return_str += "value: %s\n" % value;
	return_str += "}";
	return return_str;
