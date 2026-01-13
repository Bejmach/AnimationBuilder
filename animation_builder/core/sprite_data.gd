extends Resource

@export var texture_path: String;
@export var z_offset: int;

func _init(_texture_path: String, _z_offset: int = 0) -> void:
	texture_path = _texture_path;
	z_offset = _z_offset;

func _to_string() -> String:
	var return_str: String = "{ ";
	return_str += "texture_path: %s, " % texture_path;
	return_str += "z_offset: %s }" % z_offset;
	return return_str;
