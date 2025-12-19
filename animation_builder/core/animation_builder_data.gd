extends Resource

const AnimationData = preload("res://addons/animation_builder/core/animation_data.gd");
const ValueData = preload("res://addons/animation_builder/core/value_data.gd");

@export var frames_per_second: int;
@export var lib_name: String;
# for attacks: active_, recovery_
@export var texture: String;
@export var directions: int = 16;
@export var animations: Array[AnimationData];

func _to_string() -> String:
	var return_str: String = "{\n";
	return_str += "fps: %s\n" % frames_per_second;
	return_str += "lib_name: %s\n" % lib_name;
	return_str += "texture: %s\n" % texture;
	return_str += "directions: %s\n" % directions;
	return_str += "animations: %s\n" % animations;
	return_str += "}";
	return return_str
