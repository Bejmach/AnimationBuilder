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

const TrackData = preload("res://addons/animation_builder/core/track_data.gd");

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
	
	var horizontal_frames: int = 0;
	for animation in builder_data.animations:
		horizontal_frames += animation.length;
	
	var animation_range: Array[int] = [];
	# check if animations overlaping
	for animation in builder_data.animations:
		animation_range.append_array(range(animation.start, animation.start + animation.length, 1));
	
	animation_range.sort();
	
	for i in range(0, horizontal_frames, 1):
		if i != animation_range[i]:
			push_error("Cant bake animations. Check if animations are overlaping, and/or missing frames");
			push_error("expected output: ", range(0, horizontal_frames, 1));
			push_error("actual output: ", animation_range);
			return;
	
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
	var anim_method_locations: Dictionary[String, int] = {};
	var anim_method_params: Dictionary[String, Array] = {};
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
		var parsed_functions: Array[Dictionary] = parse_functions(animation.get("functions"));
		anim_method_locations = parsed_functions[0];
		anim_method_params = parsed_functions[1];
	
	var anim_data: AnimationData = AnimationData.new(anim_name, anim_start, anim_len, anim_loop,
		anim_values, anim_method_locations, anim_method_params);
	return anim_data;

func parse_functions(values: Array) -> Array[Dictionary]:
	var method_locations: Dictionary[String, int] = {};
	var method_params: Dictionary[String, Array] = {};
	
	for function: Dictionary in values:
		var function_name: String;
		var function_start: int;
		var function_params: Array;
		
		if function.has("name"):
			function_name = function.get("name");
		else:
			push_error("function does not have \"name\" entry");
			push_error(function);
		if function.has("start"):
			function_start = function.get("start");
		else:
			push_error("function \"", function_name ,"\" does not have \"start\" entry");
		if function.has("params"):
			function_params = parse_function_params(function.get("params"));
		method_locations.set(function_name, function_start);
		method_params.set(function_name, function_params);
	return [method_locations, method_params];

func parse_vector2(value: String) -> Vector2:
	var x_start = value.find("(") + 1;
	var x_end = value.find(",");
	var y_start = value.find(",") + 1;
	var y_end = value.find(")");
	var x: float = float(value.substr(x_start, x_end - x_start).strip_edges());
	var y: float = float(value.substr(y_start, y_end - y_start).strip_edges());
	var vector: Vector2 = Vector2(x, y);
	return vector;

func parse_param(value: String) -> AnimParam:
	var lower = value.to_lower();
	if const_dict.has(lower):
		return AnimParamVariant.new(const_dict.get(lower));
	elif lower.begins_with("$rotatable:"):
		var pushed_value: AnimParamRotatable = AnimParamRotatable.new(parse_vector2(value));
		return pushed_value;
	elif lower.begins_with("$frametime:"):
		var frames: float = float(value.substr(value.find(":") + 1).strip_edges());
		var pushed_value: AnimParamFrameTime = AnimParamFrameTime.new(frames);
		return pushed_value;
	elif lower.begins_with("$rotation_angle"):
		var pushed_value: AnimParamRotationAngle = AnimParamRotationAngle.new();
		return pushed_value;
	elif lower.begins_with("$rotation"):
		var pushed_value: AnimParamRotation = AnimParamRotation.new();
		return pushed_value;
	elif lower.begins_with("$i:"):
		var param_value: int = int(value.substr(value.find(":") + 1).strip_edges());
		return AnimParamVariant.new(param_value);
	elif lower.begins_with("$f:"):
		var param_value: float = float(value.substr(value.find(":") + 1).strip_edges());
		return AnimParamVariant.new(param_value);
	elif lower.begins_with("$s:"):
		var param_value: String = value.substr(value.find(":") + 1);
		return AnimParamVariant.new(param_value);
	elif lower.begins_with("$v2:"):
		var x_start = value.find("(") + 1;
		var x_end = value.find(",");
		var y_start = value.find(",") + 1;
		var y_end = value.find(")");
		var x: float = float(value.substr(x_start, x_end - x_start).strip_edges());
		var y: float = float(value.substr(y_start, y_end - y_start).strip_edges());
		var vector: Vector2 = Vector2(x, y);
		return AnimParamVariant.new(vector);
	elif lower.begins_with("$b:"):
		var param_str: String = lower.substr(lower.find(":") + 1).strip_edges();
		match param_str:
			"true", "t":
				return AnimParamVariant.new(true);
			"false", "f":
				return AnimParamVariant.new(false);
			_:
				push_error("Cant parse bool value from content: ", param_str);
	else:
		push_error("type not supported for animations");
	return null;

func parse_animation_values(values: Dictionary) -> Dictionary[String, Array]:
	var return_values: Dictionary[String, Array] = {};
	for path: String in values:
		var track_data: Dictionary = values.get(path);
		
		if !track_data.has("values"):
			push_error("Track %s does not contain any animations" % path);
			continue;
		
		var track_interpolation = const_dict.get(track_data.get("interpolation", "animation.interpolation_nearest"), Animation.INTERPOLATION_NEAREST);
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
			
		return builder_data;
	else:
		push_error("Data does not contain lib ", builder_config.lib_name);
		return null
	
	return null;

func insert_animations(builder_config: AnimationBuilderConfig, builder_data: AnimationBuilderData, animation_lib: AnimationLibrary, animation: AnimationData, horizontal_frames: int):
	var frame_time = 1.0 / float(builder_data.frames_per_second);	
	var texture: Texture2D = load(builder_data.texture);
	
	for i in range(0, builder_data.directions, 1):
		var anim_param_context = AnimParamContext.new(i, builder_data.directions, frame_time);
		
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
		
		if animation.values.size() > 0:
			for path in animation.values:
				var values: Array = animation.values.get(path)
				var value_track = anim.add_track(Animation.TYPE_VALUE);
				anim.track_set_interpolation_loop_wrap(value_track, false);
				anim.value_track_set_update_mode(value_track, Animation.UPDATE_DISCRETE);
				anim.track_set_path(value_track, path);
				
				for value: TrackData in values:
					anim.track_set_interpolation_type(value_track, value.interpolation);
					anim.track_insert_key(value_track, frame_time * value.frame, value.value.resolve(anim_param_context));
		
		if animation.method_locations.size() > 0:
			var method_track = anim.add_track(Animation.TYPE_METHOD);
			anim.track_set_interpolation_loop_wrap(method_track, false);
			anim.track_set_interpolation_type(method_track, Animation.INTERPOLATION_NEAREST);
			anim.track_set_path(method_track, ".");
			
			for method in animation.method_locations:
				var params: Array = [];
				if animation.method_params.has(method):
					for value in animation.method_params.get(method):
						if value is AnimParam:
							params.push_back(value.resolve(anim_param_context));
						else:
							push_error("Cant resolve non AnimParam in animation");
				var time = animation.method_locations.get(method) * frame_time;
				anim.track_insert_key(method_track, time, {"method": method, "args": params});
		
		for frame in range(0, animation.length, 1):
			anim.track_insert_key(frame_track, frame*frame_time, i*horizontal_frames + frame + animation.start);
		
		animation_lib.add_animation(anim_name, anim);
