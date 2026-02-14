@tool
extends EditorInspectorPlugin

## Inspector plugin for MetaRoom resources
## Adds custom property editors for better visualization and editing

func _can_handle(object: Object) -> bool:
	var can_handle = object is MetaRoom
	if can_handle:
		print("MetaRoom Inspector Plugin: _can_handle returned true for ", object)
	return can_handle


func _parse_begin(object: Object) -> void:
	print("MetaRoom Inspector Plugin: _parse_begin called with ", object)
	if object is MetaRoom:
		print("MetaRoom Inspector Plugin: Creating editor for MetaRoom")
		var editor = preload("res://addons/meta_room_editor/meta_room_editor_property.gd").new()
		print("MetaRoom Inspector Plugin: Editor created: ", editor)
		editor.meta_room = object
		print("MetaRoom Inspector Plugin: meta_room assigned, calling initialize()")
		editor.initialize()  # Initialize after setting meta_room
		print("MetaRoom Inspector Plugin: initialize() completed, adding custom control")
		add_custom_control(editor)
		print("MetaRoom Inspector Plugin: Custom control added successfully")
	else:
		print("MetaRoom Inspector Plugin: Object is not a MetaRoom: ", object)
