extends AnimParam
const AnimParam = preload("res://addons/animation_builder/core/anim_param.gd");

@export var vector: Vector2;

func _init(_vector: Vector2):
	vector = _vector;

func resolve(ctx: AnimParamContext) -> Vector2:
	var angle = TAU * float(ctx.facing_dir) / float(ctx.directions);
	return vector.rotated(angle);

func _to_string() -> String:
	return "Rotatable { vector: " + str(vector) + " }"
