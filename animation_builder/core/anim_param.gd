extends Resource
const AnimParamContext = preload("res://addons/animation_builder/core/anim_param_context.gd");

@export var modyfiers: Array[String];

func _init() -> void:
	pass;

func resolve(ctx: AnimParamContext) -> Variant:
	return null;

func _to_string() -> String:
	return "NULLPARAM"
