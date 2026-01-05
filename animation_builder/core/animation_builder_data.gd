extends Resource

const AnimationData = preload("res://addons/animation_builder/core/animation_data.gd");
const TrackData = preload("res://addons/animation_builder/core/track_data.gd");

@export var frames_per_second: int;
@export var lib_name: String;
# for attacks: active_, recovery_
@export var texture: String;
@export var length: int;
@export var directions: int = 16;
@export var animations: Array[AnimationData];

# optional parameters
## tile height divided by width
@export var iso_scale: float = 1.0;

## rotation start direction, used for correctly scaling values using "to_iso" mod
@export var start_direction: Vector2 = Vector2.RIGHT;
@export var direction_offset: float;

func _to_string() -> String:
	var return_str: String = "{ ";
	return_str += "fps: %s, " % frames_per_second;
	return_str += "lib_name: %s, " % lib_name;
	return_str += "texture: %s, " % texture;
	return_str += "length: %s, " % length;
	return_str += "directions: %s, " % directions;
	return_str += "animations: %s, " % animations;
	return_str += "iso_scale: %s " % iso_scale;
	return_str += "}";
	return return_str
