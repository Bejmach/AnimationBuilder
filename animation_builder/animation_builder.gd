@tool
extends EditorPlugin

var dock;

func _enter_tree() -> void:
	dock = preload("res://addons/animation_builder/ui/animation_builder_dock.tscn").instantiate();
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, dock);


func _exit_tree() -> void:
	remove_control_from_docks(dock);
	dock.free();
