@tool
extends VBoxContainer

const AnimationBuilderConfig = preload("res://addons/animation_builder/core/animation_builder_config.gd");
const AnimationBuilder = preload("res://addons/animation_builder/core/builder.gd");

@onready var file_path: LineEdit = $FilePath;
@onready var lib_name: LineEdit = $LibName;
@onready var sprite_path: LineEdit = $SpritePath;
@onready var overwrite: CheckBox = $Overwrite;


func _on_button_pressed() -> void:
	var scene_root = EditorInterface.get_edited_scene_root()
	if !scene_root:
		push_error("No active scene");
		return;
	
	var selection = EditorInterface.get_selection();
	var nodes = selection.get_selected_nodes();
	
	if nodes.is_empty():
		push_error("Select an AnimationPlayer.");
		return;
	
	var animation_player = nodes[0] as AnimationPlayer;
	if !animation_player:
		push_error("First selected node is not AnimationPlayer");
		return;
	
	var config: AnimationBuilderConfig = AnimationBuilderConfig.new(file_path.text, lib_name.text, sprite_path.text, overwrite.button_pressed);
	var builder = AnimationBuilder.new();
	
	builder.run(animation_player, config);
