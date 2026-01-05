extends AnimParam
const AnimParam = preload("res://addons/animation_builder/core/anim_param.gd");

func _init(_modyfiers: Array[String] = []):
	modyfiers = _modyfiers;

func resolve(ctx: AnimParamContext) -> float:
	var angle = TAU * float(ctx.facing_dir) / float(ctx.directions);
	for modyfier in modyfiers:
		var parsed_mod: Array[String] = parse_mod(modyfier);
		if parsed_mod[0].begins_with("to_iso"):
			angle = angle_to_iso(angle, ctx);
	return angle;

func _to_string() -> String:
	return "Rotation { modyfiers: " + str(modyfiers) + " }"

func direction_to_iso(direction: Vector2, iso_scale: float) -> Vector2:
	return Vector2(
			direction.x,
			direction.y * iso_scale
		);

func angle_to_iso(angle: float, ctx: AnimParamContext) -> float:
	var real_dir: Vector2 = ctx.start_direction.rotated(angle);
	var iso_dir: Vector2 = direction_to_iso(real_dir, ctx.iso_scale).normalized();
	return iso_dir.angle() - ctx.direction_offset;
