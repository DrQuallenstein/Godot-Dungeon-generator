@tool
extends EditorInspectorPlugin

## Inspector plugin for MetaRoom resources
## Adds custom property editors for better visualization and editing

func _can_handle(object: Object) -> bool:
	return object is MetaRoom


func _parse_begin(object: Object) -> void:
	if object is MetaRoom:
		var editor = preload("res://addons/meta_room_editor/meta_room_editor_property.gd").new()
		editor.meta_room = object
		editor.initialize()  # Initialize after setting meta_room
		add_custom_control(editor)
