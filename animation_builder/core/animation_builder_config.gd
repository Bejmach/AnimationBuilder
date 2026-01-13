extends Resource

@export_file("*.json") var file_path: String;
@export var lib_name: String;
@export var overwrite: bool;

func _init(path: String, lib: String, _overwrite: bool) -> void:
	file_path = path;
	lib_name = lib;
	overwrite = _overwrite;
