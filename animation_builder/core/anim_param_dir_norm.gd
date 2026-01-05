extends AnimParam
const AnimParam = preload("res://addons/animation_builder/core/anim_param.gd");

func _init(_modyfiers: Array[String] = []):
	modyfiers = _modyfiers;

func resolve(ctx: AnimParamContext) -> float:
	var return_value: float = float(ctx.facing_dir) / float(ctx.directions);
	for modyfier in modyfiers:
		var parsed_mod: Array[String] = parse_mod(modyfier);
		if parsed_mod[0].begins_with("clamp"):
			return_value = clamp(return_value, float(parsed_mod[1]), float(parsed_mod[2]));
		elif parsed_mod[0].begins_with("snap"):
			return_value = snapped(return_value, float(parsed_mod[1]));
	return return_value;

func _to_string() -> String:
	return "Direction { modyfiers: " + str(modyfiers) + " }"
