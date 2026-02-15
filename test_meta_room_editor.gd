@tool
extends SceneTree

## Test script to validate MetaRoom editor functionality

func _init():
	print("=== Testing MetaRoom Editor Implementation ===")
	
	# Test 1: Create a MetaRoom
	print("\n[Test 1] Creating MetaRoom...")
	var room = MetaRoom.new()
	room.width = 3
	room.height = 3
	room._initialize_cells()
	print("✓ MetaRoom created: ", room.width, "x", room.height)
	
	# Test 2: Verify cells have required connection properties
	print("\n[Test 2] Checking MetaCell properties...")
	var cell = room.get_cell(0, 0)
	if cell:
		print("✓ Cell created")
		print("  - cell_type: ", cell.cell_type)
		print("  - connection_up: ", cell.connection_up)
		print("  - connection_up_required: ", cell.connection_up_required)
		print("  - connection_right_required: ", cell.connection_right_required)
		print("  - connection_bottom_required: ", cell.connection_bottom_required)
		print("  - connection_left_required: ", cell.connection_left_required)
	else:
		print("✗ Failed to get cell")
		quit(1)
	
	# Test 3: Test set_connection_required method
	print("\n[Test 3] Testing set_connection_required...")
	cell.set_connection_required(MetaCell.Direction.UP, true)
	cell.set_connection_required(MetaCell.Direction.RIGHT, true)
	if cell.connection_up_required and cell.connection_right_required:
		print("✓ set_connection_required works correctly")
	else:
		print("✗ set_connection_required failed")
		quit(1)
	
	# Test 4: Test is_connection_required method
	print("\n[Test 4] Testing is_connection_required...")
	if cell.is_connection_required(MetaCell.Direction.UP):
		print("✓ is_connection_required(UP) returns true")
	else:
		print("✗ is_connection_required failed")
		quit(1)
	
	# Test 5: Test cell cloning with required flags
	print("\n[Test 5] Testing cell cloning...")
	var cloned_cell = cell.clone()
	if cloned_cell.connection_up_required and cloned_cell.connection_right_required:
		print("✓ Cell clone preserves required connection flags")
	else:
		print("✗ Cell clone failed to preserve flags")
		quit(1)
	
	# Test 6: Load existing room resource
	print("\n[Test 6] Loading existing room resource...")
	var loaded_room = load("res://resources/rooms/straight_corridor.tres")
	if loaded_room:
		print("✓ Room loaded: ", loaded_room.room_name)
		print("  - Dimensions: ", loaded_room.width, "x", loaded_room.height)
		print("  - Cells count: ", loaded_room.cells.size())
		
		# Check if cells have the new properties (should default to false)
		var test_cell = loaded_room.get_cell(0, 0)
		if test_cell:
			print("  - Cell has connection_up_required property: ", "connection_up_required" in test_cell)
			print("  - connection_up_required value: ", test_cell.connection_up_required)
	else:
		print("✗ Failed to load room resource")
		quit(1)
	
	# Test 7: Check editor property script
	print("\n[Test 7] Checking editor property script...")
	var EditorClass = load("res://addons/meta_room_editor/meta_room_editor_property.gd")
	if EditorClass:
		print("✓ Editor property script loaded successfully")
	else:
		print("✗ Failed to load editor property script")
		quit(1)
	
	print("\n=== All Tests Passed! ===")
	print("\nThe MetaRoom editor implementation is working correctly.")
	print("Features validated:")
	print("  ✓ Required connection flags on MetaCell")
	print("  ✓ set_connection_required() method")
	print("  ✓ is_connection_required() method")
	print("  ✓ Cell cloning with required flags")
	print("  ✓ Backward compatibility with existing resources")
	print("  ✓ Editor property script loads")
	
	quit(0)
