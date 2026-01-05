extends AnimParam
const AnimParam = preload("res://addons/animation_builder/core/anim_param.gd");

func _init(_modyfiers: Array[String] = []):
	modyfiers = _modyfiers;

func resolve(ctx: AnimParamContext) -> int:
	return ctx.facing_dir;

func _to_string() -> String:
	return "Direction { modyfiers: " + str(modyfiers) + " }"
