extends Node

## Test script to validate the dungeon generator system
## Run this to ensure all components work correctly

func _ready() -> void:
	print("\n" + "="*60)
	print("DUNGEON GENERATOR SYSTEM TEST")
	print("="*60 + "\n")
	
	var all_tests_passed = true
	
	all_tests_passed = test_meta_cell() and all_tests_passed
	all_tests_passed = test_meta_room() and all_tests_passed
	all_tests_passed = test_room_rotator() and all_tests_passed
	all_tests_passed = test_room_resources() and all_tests_passed
	all_tests_passed = test_dungeon_generator() and all_tests_passed
	
	print("\n" + "="*60)
	if all_tests_passed:
		print("✓ ALL TESTS PASSED")
	else:
		print("✗ SOME TESTS FAILED")
	print("="*60 + "\n")
	
	# Exit after tests
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()


func test_meta_cell() -> bool:
	print("Testing MetaCell...")
	var passed = true
	
	# Test cell creation
	var cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.FLOOR
	cell.connection_up = true
	cell.connection_right = true
	
	if not cell.has_any_connection():
		print("  ✗ Failed: has_any_connection()")
		passed = false
	
	if not cell.has_connection(MetaCell.Direction.UP):
		print("  ✗ Failed: has_connection(UP)")
		passed = false
	
	if cell.has_connection(MetaCell.Direction.BOTTOM):
		print("  ✗ Failed: has_connection(BOTTOM) should be false")
		passed = false
	
	# Test opposite direction
	if MetaCell.opposite_direction(MetaCell.Direction.UP) != MetaCell.Direction.BOTTOM:
		print("  ✗ Failed: opposite_direction(UP)")
		passed = false
	
	# Test duplicate
	var cell_copy = cell.duplicate_deep()
	if cell_copy.connection_up != cell.connection_up or cell_copy.cell_type != cell.cell_type:
		print("  ✗ Failed: duplicate_deep()")
		passed = false
	
	if passed:
		print("  ✓ MetaCell tests passed\n")
	return passed


func test_meta_room() -> bool:
	print("Testing MetaRoom...")
	var passed = true
	
	# Create a simple 2x2 room
	var room = MetaRoom.new()
	room.width = 2
	room.height = 2
	room.room_name = "Test Room"
	room.cells.clear()
	
	# Add cells
	for i in range(4):
		var cell = MetaCell.new()
		cell.cell_type = MetaCell.CellType.FLOOR
		room.cells.append(cell)
	
	# Add a connection to top-left cell
	var top_left = room.get_cell(0, 0)
	top_left.connection_up = true
	
	# Test get_cell
	if room.get_cell(0, 0) != top_left:
		print("  ✗ Failed: get_cell(0, 0)")
		passed = false
	
	if room.get_cell(5, 5) != null:
		print("  ✗ Failed: get_cell out of bounds should return null")
		passed = false
	
	# Test connection points
	var connections = room.get_connection_points()
	if connections.is_empty():
		print("  ✗ Failed: get_connection_points() should not be empty")
		passed = false
	
	if not room.has_connections():
		print("  ✗ Failed: has_connections()")
		passed = false
	
	# Test validation
	if not room.validate():
		print("  ✗ Failed: validate()")
		passed = false
	
	# Test duplicate
	var room_copy = room.duplicate_deep()
	if room_copy.width != room.width or room_copy.height != room.height:
		print("  ✗ Failed: duplicate_deep()")
		passed = false
	
	if passed:
		print("  ✓ MetaRoom tests passed\n")
	return passed


func test_room_rotator() -> bool:
	print("Testing RoomRotator...")
	var passed = true
	
	# Create a simple 2x3 room
	var room = MetaRoom.new()
	room.width = 2
	room.height = 3
	room.cells.clear()
	
	for i in range(6):
		var cell = MetaCell.new()
		cell.cell_type = MetaCell.CellType.FLOOR
		room.cells.append(cell)
	
	# Add connection at top
	room.get_cell(0, 0).connection_up = true
	
	# Test 0° rotation (should be same)
	var rotated_0 = RoomRotator.rotate_room(room, RoomRotator.Rotation.DEG_0)
	if rotated_0.width != room.width or rotated_0.height != room.height:
		print("  ✗ Failed: 0° rotation dimensions")
		passed = false
	
	# Test 90° rotation (dimensions should swap)
	var rotated_90 = RoomRotator.rotate_room(room, RoomRotator.Rotation.DEG_90)
	if rotated_90.width != room.height or rotated_90.height != room.width:
		print("  ✗ Failed: 90° rotation dimensions (expected %dx%d, got %dx%d)" % [room.height, room.width, rotated_90.width, rotated_90.height])
		passed = false
	
	# Test connection rotation
	# Original UP connection should become RIGHT after 90° rotation
	var connections_90 = rotated_90.get_connection_points()
	var has_right_connection = false
	for conn in connections_90:
		if conn.direction == MetaCell.Direction.RIGHT:
			has_right_connection = true
			break
	
	if not has_right_connection:
		print("  ✗ Failed: 90° rotation connection direction")
		passed = false
	
	# Test 180° rotation
	var rotated_180 = RoomRotator.rotate_room(room, RoomRotator.Rotation.DEG_180)
	if rotated_180.width != room.width or rotated_180.height != room.height:
		print("  ✗ Failed: 180° rotation dimensions")
		passed = false
	
	# Test direction rotation
	var dir = MetaCell.Direction.UP
	var rotated_dir = RoomRotator.rotate_direction(dir, RoomRotator.Rotation.DEG_90)
	if rotated_dir != MetaCell.Direction.RIGHT:
		print("  ✗ Failed: rotate_direction(UP, 90°)")
		passed = false
	
	if passed:
		print("  ✓ RoomRotator tests passed\n")
	return passed


func test_room_resources() -> bool:
	print("Testing Room Resources...")
	var passed = true
	
	# Try to load all room resources
	var room_paths = [
		"res://resources/rooms/cross_room.tres",
		"res://resources/rooms/l_corridor.tres",
		"res://resources/rooms/straight_corridor.tres",
		"res://resources/rooms/t_room.tres"
	]
	
	for path in room_paths:
		if not ResourceLoader.exists(path):
			print("  ✗ Failed: Resource not found: ", path)
			passed = false
			continue
		
		var room = load(path) as MetaRoom
		if room == null:
			print("  ✗ Failed: Could not load room: ", path)
			passed = false
			continue
		
		if not room.validate():
			print("  ✗ Failed: Room validation failed: ", path)
			passed = false
			continue
		
		if not room.has_connections():
			print("  ✗ Failed: Room has no connections: ", path)
			passed = false
			continue
		
		print("  ✓ Loaded and validated: ", room.room_name)
	
	if passed:
		print("  ✓ All room resources loaded successfully\n")
	return passed


func test_dungeon_generator() -> bool:
	print("Testing DungeonGenerator...")
	var passed = true
	
	# Create generator
	var generator = DungeonGenerator.new()
	add_child(generator)
	
	# Load room templates
	generator.room_templates = [
		load("res://resources/rooms/cross_room.tres"),
		load("res://resources/rooms/l_corridor.tres"),
		load("res://resources/rooms/straight_corridor.tres"),
		load("res://resources/rooms/t_room.tres")
	]
	
	generator.target_room_count = 10
	generator.generation_seed = 12345
	generator.max_placement_attempts = 100
	
	# Test generation
	print("  Generating dungeon...")
	var success = generator.generate()
	
	if not success:
		print("  ⚠ Warning: Generation did not reach target room count")
		print("    Rooms placed: ", generator.placed_rooms.size(), "/", generator.target_room_count)
		# This is not necessarily a failure, depends on room templates
	
	if generator.placed_rooms.is_empty():
		print("  ✗ Failed: No rooms placed")
		passed = false
	else:
		print("  ✓ Placed ", generator.placed_rooms.size(), " rooms")
	
	# Test bounds calculation
	var bounds = generator.get_dungeon_bounds()
	if bounds.size.x <= 0 or bounds.size.y <= 0:
		print("  ✗ Failed: Invalid dungeon bounds")
		passed = false
	else:
		print("  ✓ Dungeon bounds: ", bounds.size)
	
	# Test room placement validity
	var occupied: Dictionary = {}
	for placement in generator.placed_rooms:
		for y in range(placement.room.height):
			for x in range(placement.room.width):
				var cell = placement.room.get_cell(x, y)
				if cell == null or cell.cell_type == MetaCell.CellType.BLOCKED:
					continue
				
				var world_pos = placement.get_cell_world_pos(x, y)
				if occupied.has(world_pos):
					print("  ✗ Failed: Overlapping rooms at ", world_pos)
					passed = false
				occupied[world_pos] = true
	
	if passed:
		print("  ✓ No overlapping rooms detected")
	
	# Test regeneration
	generator.clear_dungeon()
	if not generator.placed_rooms.is_empty():
		print("  ✗ Failed: clear_dungeon() did not clear rooms")
		passed = false
	else:
		print("  ✓ clear_dungeon() works correctly")
	
	# Generate again to test consistency
	generator.generation_seed = 12345  # Same seed
	var success2 = generator.generate()
	var room_count = generator.placed_rooms.size()
	
	generator.clear_dungeon()
	generator.generation_seed = 12345  # Same seed again
	var success3 = generator.generate()
	var room_count2 = generator.placed_rooms.size()
	
	if room_count != room_count2:
		print("  ✗ Failed: Same seed produced different results (", room_count, " vs ", room_count2, ")")
		passed = false
	else:
		print("  ✓ Seed reproducibility works")
	
	generator.queue_free()
	
	if passed:
		print("  ✓ DungeonGenerator tests passed\n")
	return passed
