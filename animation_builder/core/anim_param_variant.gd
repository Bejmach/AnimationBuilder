extends AnimParam
const AnimParam = preload("res://addons/animation_builder/core/anim_param.gd");

var value: Variant;

func _init(_value: Variant, _modyfiers: Array[String] = []) -> void:
	value = _value;
	modyfiers = _modyfiers;

func resolve(ctx: AnimParamContext) -> Variant:
	var return_value = value;
	for modyfier: String in modyfiers:
		var parsed_mod: Array[String] = parse_mod(modyfier);
		if parsed_mod[0].begins_with("to_iso"):
			if return_value is Vector2:
				return_value = direction_to_iso(return_value, ctx.iso_scale);
			elif return_value is float:
				return_value = angle_to_iso(return_value, ctx.iso_scale);
		elif parsed_mod[0].begins_with("rotate_angle"):
			if return_value is Vector2:
				return_value = return_value.rotated(deg_to_rad(float(parsed_mod[1])));
		elif parsed_mod[0].begins_with("rotate"):
			if return_value is Vector2:
				return_value = return_value.rotated(float(parsed_mod[1]));
	return return_value;

func _to_string() -> String:
	return "AnimVariant { value: " + str(value) + ", modyfiers: " + str(modyfiers) + " }";


func direction_to_iso(direction: Vector2, iso_scale: float) -> Vector2:
	return Vector2(
			direction.x,
			direction.y * iso_scale
		);

func angle_to_iso(angle: float, iso_scale: float) -> float:
	var real_dir: Vector2 = Vector2.RIGHT.rotated(angle);
	var iso_dir: Vector2 = direction_to_iso(real_dir, iso_scale).normalized();
	return iso_dir.angle();
