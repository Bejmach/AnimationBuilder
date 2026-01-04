extends Resource
const AnimParamContext = preload("res://addons/animation_builder/core/anim_param_context.gd");

@export var modyfiers: Array[String];

func _init() -> void:
	pass;

func resolve(ctx: AnimParamContext) -> Variant:
	return null;

func _to_string() -> String:
	return "NULLPARAM"

func parse_mod(value: String) -> Array[String]:
	value = value.strip_edges();
	var mod_array: Array[String] = [];
	if value.contains("(") && value.contains(")"):
		var mod_name = value.substr(0, value.find("("));
		mod_array.push_back(mod_name);
		var mod_data_start: int = value.find("(") + 1;
		var mod_data_end: int = value.find(")");
		var mod_data: String = value.substr(mod_data_start, mod_data_end - mod_data_start);
		var data_array: PackedStringArray = mod_data.split(",", false);
		for data in data_array:
			mod_array.push_back(data.strip_edges());
	else:
		mod_array.push_back(value);
	return mod_array;
