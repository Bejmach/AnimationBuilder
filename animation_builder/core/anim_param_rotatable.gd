extends AnimParam
const AnimParam = preload("res://addons/animation_builder/core/anim_param.gd");

@export var vector: Vector2;

func _init(_vector: Vector2, _modyfiers: Array[String] = []):
	vector = _vector;
	modyfiers = _modyfiers;

func resolve(ctx: AnimParamContext) -> Vector2:
	var angle = TAU * float(ctx.facing_dir) / float(ctx.directions);
	var return_vector = vector.rotated(angle);
	for modyfier: String in modyfiers:
		var parsed_mod: Array[String] = parse_mod(modyfier);
		if parsed_mod[0].begins_with("scale"):
			return_vector *= float(parsed_mod[1]);
		elif parsed_mod[0].begins_with("invert_x"):
			return_vector = Vector2(-return_vector.x, return_vector.y);
		elif parsed_mod[0].begins_with("invert_y"):
			return_vector = Vector2(return_vector.x, -return_vector.y);
		elif parsed_mod[0].begins_with("to_iso"):
			return_vector = direction_to_iso(return_vector, ctx.iso_scale);
		elif parsed_mod[0].begins_with("rotate"):
			return_vector = return_vector.rotated(float(parsed_mod[1]));
		elif parsed_mod[0].begins_with("rotate_angle"):
			return_vector = return_vector.rotated(deg_to_rad(float(parsed_mod[1])));
	return return_vector;

func _to_string() -> String:
	return "Rotatable { vector: " + str(vector) + ", modyfiers: " + str(modyfiers) + " }"

func direction_to_iso(direction: Vector2, iso_scale: float) -> Vector2:
	return Vector2(
			direction.x,
			direction.y * iso_scale
		);
