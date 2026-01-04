extends Resource

const AnimationData = preload("res://addons/animation_builder/core/animation_data.gd");
const TrackData = preload("res://addons/animation_builder/core/track_data.gd");

@export var frames_per_second: int;
@export var lib_name: String;
# for attacks: active_, recovery_
@export var texture: String;
@export var directions: int = 16;
@export var animations: Array[AnimationData];

# optional parameters
## tile height divided by width
@export var iso_scale: float = 1.0;

func _to_string() -> String:
	var return_str: String = "{\n";
	return_str += "fps: %s\n" % frames_per_second;
	return_str += "lib_name: %s\n" % lib_name;
	return_str += "texture: %s\n" % texture;
	return_str += "directions: %s\n" % directions;
	return_str += "animations: %s\n" % animations;
	return_str += "iso_scale: %s\n" % iso_scale;
	return_str += "}";
	return return_str
