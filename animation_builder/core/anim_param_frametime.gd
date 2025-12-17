extends AnimParam
const AnimParam = preload("res://addons/animation_builder/core/anim_param.gd");

@export var frames: float;

func _init(_frames: float):
	frames = _frames;

func resolve(ctx: AnimParamContext) -> float:
	return ctx.frame_time * frames;

func _to_string() -> String:
	return "FrameTime { frames: " + str(frames) + " }"
