extends Node

## Demo script to show the MetaRoom editor UI functionality

@onready var ui_container = $UIContainer

var editor_instance

func _ready():
	print("=== MetaRoom Editor UI Demo ===")
	
	# Create a test MetaRoom
	var test_room = MetaRoom.new()
	test_room.width = 4
	test_room.height = 3
	test_room.room_name = "Demo Room"
	test_room._initialize_cells()
	
	# Set up some interesting properties
	var cell = test_room.get_cell(1, 0)
	if cell:
		cell.connection_up = true
		cell.connection_up_required = true
	
	cell = test_room.get_cell(2, 2)
	if cell:
		cell.connection_bottom = true
		cell.cell_type = MetaCell.CellType.DOOR
	
	cell = test_room.get_cell(0, 1)
	if cell:
		cell.connection_left = true
		cell.connection_left_required = true
	
	cell = test_room.get_cell(3, 1)
	if cell:
		cell.connection_right = true
	
	# Load the editor
	var EditorClass = load("res://addons/meta_room_editor/meta_room_editor_property.gd")
	editor_instance = EditorClass.new()
	editor_instance.meta_room = test_room
	ui_container.add_child(editor_instance)
	editor_instance.initialize()
	
	print("Editor UI loaded successfully!")
	print("Features available:")
	print("  - Mode toggle between Inspect and Paint")
	print("  - Cell properties panel")
	print("  - Required connection flags")
	print("  - Grid visualization")
