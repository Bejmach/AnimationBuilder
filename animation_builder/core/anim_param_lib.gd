extends AnimParam
const AnimParam = preload("res://addons/animation_builder/core/anim_param.gd");

func _init(_modyfiers: Array[String] = []):
	modyfiers = _modyfiers;

func resolve(ctx: AnimParamContext) -> String:
	return ctx.lib_name;

func _to_string() -> String:
	return "LibName {modyfiers: " + str(modyfiers) + " }"
