extends Resource

const AnimParam = preload("res://addons/animation_builder/core/anim_param.gd");

@export var path: String;
@export var frame: float;
@export var method_name: String;
@export var values: Array[AnimParam];

func _init(_path: String, _frame: float, _method_name: String, _values: Array[AnimParam]) -> void:
	path = _path;
	frame = _frame;
	method_name = _method_name;
	values = _values;

func _to_string() -> String:
	var return_str = "{";
	return_str += "path: %s; " % path;
	return_str += "frame: %s; " % frame;
	return_str += "method_name: %s; " % method_name;
	return_str += "values: %s; " % str(values);
	return_str += "}";
	return return_str;
