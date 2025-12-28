extends AnimParam
const AnimParam = preload("res://addons/animation_builder/core/anim_param.gd");

func _init():
	pass

func resolve(ctx: AnimParamContext) -> String:
	return ctx.lib_name;

func _to_string() -> String:
	return "LibName"
