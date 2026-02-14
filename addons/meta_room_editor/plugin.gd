@tool
extends EditorPlugin

## MetaRoom Editor Plugin
## Provides a visual editor for MetaRoom resources in the Godot inspector

var inspector_plugin: EditorInspectorPlugin

func _enter_tree() -> void:
	# Create and add the inspector plugin
	inspector_plugin = preload("res://addons/meta_room_editor/meta_room_inspector_plugin.gd").new()
	add_inspector_plugin(inspector_plugin)
	print("MetaRoom Editor Plugin activated")


func _exit_tree() -> void:
	# Remove the inspector plugin
	if inspector_plugin:
		remove_inspector_plugin(inspector_plugin)
	print("MetaRoom Editor Plugin deactivated")
