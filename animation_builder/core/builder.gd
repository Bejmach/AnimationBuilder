@tool
extends RefCounted

const AnimationBuilderConfig = preload("res://addons/animation_builder/core/animation_builder_config.gd");
const AnimationData = preload("res://addons/animation_builder/core/animation_data.gd");
const AnimationBuilderData = preload("res://addons/animation_builder/core/animation_builder_data.gd");

const AnimParamContext = preload("res://addons/animation_builder/core/anim_param_context.gd");
const AnimParam = preload("res://addons/animation_builder/core/anim_param.gd");
const AnimParamRotation = preload("res://addons/animation_builder/core/anim_param_rotation.gd");
const AnimParamRotationAngle = preload("res://addons/animation_builder/core/anim_param_rotation_angle.gd");
const AnimParamRotatable = preload("res://addons/animation_builder/core/anim_param_rotatable.gd");
const AnimParamFrameTime = preload("res://addons/animation_builder/core/anim_param_frametime.gd");
const AnimParamVariant = preload("res://addons/animation_builder/core/anim_param_variant.gd");
const AnimParamLib = preload("res://addons/animation_builder/core/anim_param_lib.gd");

const TrackData = preload("res://addons/animation_builder/core/track_data.gd");
const MethodData = preload("res://addons/animation_builder/core/method_data.gd");

var const_dict: Dictionary[String, Variant] = {
	"tween.trans_linear": Tween.TRANS_LINEAR,
	"tween.trans_sine": Tween.TRANS_SINE,
	"tween.trans_quint": Tween.TRANS_QUINT,
	"tween.trans_quart": Tween.TRANS_QUART,
	"tween.trans_quad": Tween.TRANS_QUAD,
	"tween.trans_expo": Tween.TRANS_EXPO,
	"tween.trans_elastic": Tween.TRANS_ELASTIC,
	"tween.trans_cubic": Tween.TRANS_CUBIC,
	"tween.trans_circ": Tween.TRANS_CIRC,
	"tween.trans_bounce": Tween.TRANS_BOUNCE,
	"tween.trans_back": Tween.TRANS_BACK,
	"tween.trans_spring": Tween.TRANS_SPRING,
	"tween.ease_in": Tween.EASE_IN,
	"tween.ease_out": Tween.EASE_OUT,
	"tween.ease_in_out": Tween.EASE_IN_OUT,
	"tween.ease_out_in": Tween.EASE_OUT_IN,
	"animation.interpolation_nearest": Animation.INTERPOLATION_NEAREST,
	"animation.interpolation_cubic": Animation.INTERPOLATION_CUBIC,
	"animation.interpolation_linear": Animation.INTERPOLATION_LINEAR,
	"animation.interpolation_cubic_angle": Animation.INTERPOLATION_CUBIC_ANGLE,
	"animation.interpolation_linear_angle": Animation.INTERPOLATION_LINEAR_ANGLE,
};

func run(animation_player: AnimationPlayer, builder_config: AnimationBuilderConfig) -> void:
	print("Heating oven");
	
	var can_overwrite: bool = false;
	if animation_player.has_animation_library(builder_config.lib_name):
		if builder_config.overwrite:
			can_overwrite = true;
			print("Overwriting library \"", builder_config.lib_name, "\"");
		else:
			push_error("Animation library \"", builder_config.lib_name, "\" already exist");
	
	var animation_lib: AnimationLibrary = AnimationLibrary.new();
	
	var builder_data = parse_animation_builder_data(builder_config);
	
	if !builder_data:
		print("Oven broke :<");
		return;
	
	var horizontal_frames: int = builder_data.length;
	
	for animation in builder_data.animations:
		insert_animations(builder_config, builder_data, animation_lib, animation, horizontal_frames);
	
	if animation_lib.get_animation_list_size() > 0:
		if can_overwrite:
			animation_player.remove_animation_library(builder_config.lib_name);
		animation_player.add_animation_library(builder_data.lib_name, animation_lib);
		print("Animations baked");
	else:
		print("Oven broke :<");

func parse_animation(builder_config: AnimationBuilderConfig, animation: Dictionary) -> AnimationData:
	var anim_name: String;
	var anim_start: int;
	var anim_len: int;
	var anim_loop: bool;
	var anim_values: Dictionary[String, Array] = {};
	var method_values: Dictionary[String, Array] = {};
	if animation.has("name"):
		anim_name = animation.get("name");
	else:
		push_error("animation in lib \"", builder_config.lib_name, "\" does not have \"name\" entry");
		return null;
	if animation.has("start"):
		anim_start = animation.get("start");
	else:
		push_error("animation in lib \"", builder_config.lib_name, "\" does not have \"start\" entry");
		return null;
	if animation.has("length"):
		anim_len = animation.get("length");
	else:
		push_error("animation in lib \"", builder_config.lib_name, "\" does not have \"length\" entry");
		return null;
	anim_loop = animation.get("loop", true);
	
	if animation.has("values"):
		anim_values = parse_animation_values(animation.get("values"));
	
	if animation.has("functions"):
		method_values = parse_animation_methods(animation.get("functions"));
	
	var anim_data: AnimationData = AnimationData.new(anim_name, anim_start, anim_len, anim_loop,
		anim_values, method_values);
	return anim_data;

func parse_animation_methods(values: Dictionary) -> Dictionary[String, Array]:
	var return_values: Dictionary[String, Array] = {};
	for path: String in values:
		var methods: Dictionary = values.get(path);
		for method_name: String in methods:
			var method_calls: Array = methods.get(method_name);
			for method_data: Dictionary in method_calls:
				var method_frame: int = method_data.get("frame", 0);
				var method_params: Array[AnimParam] = [];
				
				var value_array: Array = method_data.get("values", []);
				for value: String in value_array:
					method_params.push_back(parse_param(value));
				
				var anim_method: MethodData = MethodData.new(path, method_frame, method_name, method_params);
				
				if return_values.has(path):
					(return_values.get(path) as Array).push_back(anim_method);
				else:
					return_values.set(path, [anim_method]);
	return return_values;

func parse_vector2(value: String) -> Vector2:
	var x_start = value.find("(") + 1;
	var x_end = value.find(",");
	var y_start = value.find(",") + 1;
	var y_end = value.find(")");
	var x: float = float(value.substr(x_start, x_end - x_start).strip_edges());
	var y: float = float(value.substr(y_start, y_end - y_start).strip_edges());
	var vector: Vector2 = Vector2(x, y);
	return vector;

func parse_animation_values(values: Dictionary) -> Dictionary[String, Array]:
	var return_values: Dictionary[String, Array] = {};
	for path: String in values:
		var track_data: Dictionary = values.get(path);
		
		if !track_data.has("values"):
			push_error("Track %s does not contain any animations" % path);
			continue;
		
		var track_interpolation = const_dict.get(track_data.get("interpolation", Animation.INTERPOLATION_NEAREST), Animation.INTERPOLATION_NEAREST);
		var value_array: Array = track_data.get("values");
		for value: Dictionary in value_array:
			if !(value.has("frame") && value.has("value")):
				push_error("Cant parse animation value that does not contain \"frame\" or \"value\" fields in \"", value, "\"");
			var frame: float = float(value.get("frame"));
			var param: AnimParam = parse_param(value.get("value"));
			
			var anim_value: TrackData = TrackData.new(path, frame, param, track_interpolation);
			
			if return_values.has(path):
				(return_values.get(path) as Array).push_back(anim_value);
			else:
				return_values.set(path, [anim_value]);
	return return_values;

func parse_param(value: String) -> AnimParam:
	var lower = value.to_lower();
	var param_array: PackedStringArray = lower.split(";");
	var param_name: String = param_array.get(0);
	param_array.remove_at(0);
	if const_dict.has(param_name):
		return AnimParamVariant.new(const_dict.get(param_name), param_array);
	elif param_name.begins_with("$rotatable:"):
		var pushed_value: AnimParamRotatable = AnimParamRotatable.new(parse_vector2(param_name), param_array);
		return pushed_value;
	elif param_name.begins_with("$frametime:"):
		var frames: float = float(param_name.substr(param_name.find(":") + 1).strip_edges());
		var pushed_value: AnimParamFrameTime = AnimParamFrameTime.new(frames, param_array);
		return pushed_value;
	elif param_name.begins_with("$rotation_angle"):
		var pushed_value: AnimParamRotationAngle = AnimParamRotationAngle.new(param_array);
		return pushed_value;
	elif param_name.begins_with("$rotation"):
		var pushed_value: AnimParamRotation = AnimParamRotation.new(param_array);
		return pushed_value;
	elif param_name.begins_with("$lib"):
		var pushed_value: AnimParamLib = AnimParamLib.new(param_array);
		return pushed_value;
	elif param_name.begins_with("$i:"):
		var param_value: int = int(value.substr(value.find(":") + 1).strip_edges());
		return AnimParamVariant.new(param_value, param_array);
	elif param_name.begins_with("$f:"):
		var param_value: float = float(value.substr(value.find(":") + 1).strip_edges());
		return AnimParamVariant.new(param_value, param_array);
	elif param_name.begins_with("$s:"):
		var param_value: String = value.substr(value.find(":") + 1);
		return AnimParamVariant.new(param_value, param_array);
	elif param_name.begins_with("$v2:"):
		var x_start = value.find("(") + 1;
		var x_end = value.find(",");
		var y_start = value.find(",") + 1;
		var y_end = value.find(")");
		var x: float = float(value.substr(x_start, x_end - x_start).strip_edges());
		var y: float = float(value.substr(y_start, y_end - y_start).strip_edges());
		var vector: Vector2 = Vector2(x, y);
		return AnimParamVariant.new(vector, param_array);
	elif param_name.begins_with("$b:"):
		var param_str: String = lower.substr(lower.find(":") + 1).strip_edges();
		match param_str:
			"true", "t":
				return AnimParamVariant.new(true, param_array);
			"false", "f":
				return AnimParamVariant.new(false, param_array);
			_:
				push_error("Cant parse bool value from content: ", param_str);
	else:
		push_error("type not supported for animations");
	return null;

func parse_function_params(values: Array) -> Array[AnimParam]:
	var return_values: Array[AnimParam] = [];
	for value: String in values:
		var param = parse_param(value);
		if param:
			return_values.push_back(param);
	return return_values;

func parse_animation_builder_data(builder_config: AnimationBuilderConfig) -> AnimationBuilderData:
	if !FileAccess.file_exists(builder_config.file_path):
		push_error("file does not exist: ", builder_config.file_path);
		return null;
	
	var json_file = FileAccess.open(builder_config.file_path, FileAccess.READ);
	var data = JSON.parse_string(json_file.get_as_text());
	
	if data == null:
		push_error("Failed to parse JSON: ", builder_config.file_path);
		return null
	
	if data.has(builder_config.lib_name):
		var json_data: Dictionary = data.get(builder_config.lib_name);
		var builder_data: AnimationBuilderData = AnimationBuilderData.new();
		builder_data.lib_name = builder_config.lib_name;
		if json_data.has("fps"):
			builder_data.frames_per_second = json_data.get("fps");
		else:
			push_error("Data in lib ", builder_config.lib_name, "does not have \"fps\" entry");
			return null;
		
		if json_data.has("texture"):
			if !(FileAccess.file_exists(json_data.get("texture")) && (json_data.get("texture") as String).ends_with(".png")):
				push_error("texture file \"", json_data.get("texture"),"\" does not exits, or does not have png format");
				return null;
			builder_data.texture = json_data.get("texture");
		else:
			push_error("Data in lib ", builder_config.lib_name, "does not have \"texture\" entry");
			return null;
			
		if json_data.has("animations"):
			builder_data.animations = [];
			for animation: Dictionary in json_data.get("animations"):
				var animation_data = parse_animation(builder_config, animation);
				builder_data.animations.push_back(animation_data);
		else:
			push_error("Data in lib ", builder_config.lib_name, "does not have \"animations\" entry");
		
		if json_data.has("length"):
			builder_data.length = json_data.get("length");
		else:
			push_error("Data in lib ", builder_config.lib_name, "does not have \"length\" entry");
			return null
			
		builder_data.iso_scale = json_data.get("iso_scale", 1.0);
		builder_data.start_direction = parse_vector2(json_data.get("start_direction", Vector2.RIGHT)).normalized();
		builder_data.direction_offset = builder_data.start_direction.angle();
		
		
		return builder_data;
	else:
		push_error("Data does not contain lib ", builder_config.lib_name);
		return null
	
	return null;

func insert_animations(builder_config: AnimationBuilderConfig, builder_data: AnimationBuilderData, animation_lib: AnimationLibrary, animation: AnimationData, horizontal_frames: int):
	var frame_time = 1.0 / float(builder_data.frames_per_second);	
	var texture: Texture2D = load(builder_data.texture);
	
	for i in range(0, builder_data.directions, 1):
		var anim_param_context = AnimParamContext.new(
			builder_config.lib_name,
			i,
			builder_data.directions,
			frame_time,
			builder_data.iso_scale,
			builder_data.start_direction,
			builder_data.direction_offset
		);
		
		var anim_name = animation.anim_name + str(i);
		var anim = Animation.new();
		
		anim.length = frame_time * animation.length;
		if animation.looping:
			anim.loop_mode = Animation.LOOP_LINEAR;
		else:
			anim.loop_mode = Animation.LOOP_NONE;
		
		var frame_track = anim.add_track(Animation.TYPE_VALUE);
		anim.track_set_interpolation_loop_wrap(frame_track, false);
		anim.track_set_interpolation_type(frame_track, Animation.INTERPOLATION_NEAREST);
		anim.track_set_path(frame_track, builder_config.sprite_path + ":frame");
		
		var texture_track = anim.add_track(Animation.TYPE_VALUE);
		anim.track_set_interpolation_loop_wrap(texture_track, false);
		anim.track_set_interpolation_type(texture_track, Animation.INTERPOLATION_NEAREST);
		anim.value_track_set_update_mode(texture_track, Animation.UPDATE_DISCRETE);
		anim.track_set_path(texture_track, builder_config.sprite_path + ":texture");
		
		anim.track_insert_key(texture_track, 0, texture);
		
		var HFrames_track = anim.add_track(Animation.TYPE_VALUE);
		anim.track_set_interpolation_loop_wrap(HFrames_track, false);
		anim.track_set_interpolation_type(HFrames_track, Animation.INTERPOLATION_NEAREST);
		anim.value_track_set_update_mode(HFrames_track, Animation.UPDATE_DISCRETE);
		anim.track_set_path(HFrames_track, builder_config.sprite_path + ":hframes");
		
		anim.track_insert_key(HFrames_track, 0, horizontal_frames);
		
		var VFrames_track = anim.add_track(Animation.TYPE_VALUE);
		anim.track_set_interpolation_loop_wrap(VFrames_track, false);
		anim.track_set_interpolation_type(VFrames_track, Animation.INTERPOLATION_NEAREST);
		anim.value_track_set_update_mode(VFrames_track, Animation.UPDATE_DISCRETE);
		anim.track_set_path(VFrames_track, builder_config.sprite_path + ":vframes");
		
		anim.track_insert_key(VFrames_track, 0, builder_data.directions);
		
		#print("Animation: ", animation);
		
		if animation.values.size() > 0:
			for path in animation.values:
				var values: Array = animation.values.get(path);
				var value_track = anim.add_track(Animation.TYPE_VALUE);
				anim.track_set_interpolation_loop_wrap(value_track, false);
				anim.value_track_set_update_mode(value_track, Animation.UPDATE_DISCRETE);
				anim.track_set_path(value_track, path);
				
				for value: TrackData in values:
					anim.track_set_interpolation_type(value_track, value.interpolation);
					anim.track_insert_key(value_track, frame_time * value.frame, value.value.resolve(anim_param_context));
		
		if animation.methods.size() > 0:
			for path in animation.methods:
				var method_calls: Array = animation.methods.get(path);
				var method_track = anim.add_track(Animation.TYPE_METHOD);
				anim.track_set_interpolation_loop_wrap(method_track, false);
				anim.track_set_interpolation_type(method_track, Animation.INTERPOLATION_NEAREST);
				anim.track_set_path(method_track, path);
				
				for method: MethodData in method_calls:
					var params: Array = [];
					for param: AnimParam in method.values:
						params.push_back(param.resolve(anim_param_context));
					anim.track_insert_key(method_track, frame_time * method.frame, {"method": method.method_name, "args": params});
		
		for frame in range(0, animation.length, 1):
			anim.track_insert_key(frame_track, frame*frame_time, i*horizontal_frames + frame + animation.start);
		
		animation_lib.add_animation(anim_name, anim);
