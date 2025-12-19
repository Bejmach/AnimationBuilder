extends AnimParam
const AnimParam = preload("res://addons/animation_builder/core/anim_param.gd");

var value: Variant;

func _init(_value: Variant) -> void:
	value = _value;

func resolve(ctx: AnimParamContext) -> Variant:
	return value;

func _to_string() -> String:
	return str(value);
