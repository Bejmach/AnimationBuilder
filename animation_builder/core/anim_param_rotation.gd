extends AnimParam
const AnimParam = preload("res://addons/animation_builder/core/anim_param.gd");

func _init():
	pass

func resolve(ctx: AnimParamContext) -> float:
	var angle = TAU * float(ctx.facing_dir) / float(ctx.directions);
	return angle;

func _to_string() -> String:
	return "Rotation"
