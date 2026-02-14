@tool
extends EditorScript

## Script to create example room resources for the dungeon generator.
## Run this from the Godot editor: File > Run Script

func _run() -> void:
	print("Creating example room resources...")
	
	# Room 1: Simple cross-shaped room with 4 connections
	var room1 = MetaRoom.new()
	room1.room_name = "Cross Room"
	room1.width = 3
	room1.height = 3
	room1.cells.clear()
	
	# Create cross pattern
	# Row 0: blocked, floor, blocked
	var cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.BLOCKED
	room1.cells.append(cell)
	
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.FLOOR
	cell.connection_up = true
	room1.cells.append(cell)
	
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.BLOCKED
	room1.cells.append(cell)
	
	# Row 1: floor, floor, floor (with left and right connections)
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.FLOOR
	cell.connection_left = true
	room1.cells.append(cell)
	
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.FLOOR
	room1.cells.append(cell)
	
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.FLOOR
	cell.connection_right = true
	room1.cells.append(cell)
	
	# Row 2: blocked, floor, blocked
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.BLOCKED
	room1.cells.append(cell)
	
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.FLOOR
	cell.connection_bottom = true
	room1.cells.append(cell)
	
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.BLOCKED
	room1.cells.append(cell)
	
	var result = ResourceSaver.save(room1, "res://resources/rooms/cross_room.tres")
	if result == OK:
		print("✓ Created cross_room.tres")
	else:
		print("✗ Failed to create cross_room.tres: ", result)
	
	
	# Room 2: L-shaped corridor with 2 connections
	var room2 = MetaRoom.new()
	room2.room_name = "L-Corridor"
	room2.width = 3
	room2.height = 3
	room2.cells.clear()
	
	# Row 0: floor, floor, floor
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.FLOOR
	cell.connection_left = true
	room2.cells.append(cell)
	
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.FLOOR
	room2.cells.append(cell)
	
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.FLOOR
	cell.connection_up = true
	room2.cells.append(cell)
	
	# Row 1: floor, blocked, blocked
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.FLOOR
	room2.cells.append(cell)
	
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.BLOCKED
	room2.cells.append(cell)
	
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.BLOCKED
	room2.cells.append(cell)
	
	# Row 2: floor, blocked, blocked
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.FLOOR
	cell.connection_bottom = true
	room2.cells.append(cell)
	
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.BLOCKED
	room2.cells.append(cell)
	
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.BLOCKED
	room2.cells.append(cell)
	
	result = ResourceSaver.save(room2, "res://resources/rooms/l_corridor.tres")
	if result == OK:
		print("✓ Created l_corridor.tres")
	else:
		print("✗ Failed to create l_corridor.tres: ", result)
	
	
	# Room 3: Straight corridor with 2 opposite connections
	var room3 = MetaRoom.new()
	room3.room_name = "Straight Corridor"
	room3.width = 3
	room3.height = 3
	room3.cells.clear()
	
	# Row 0: blocked, floor, blocked
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.BLOCKED
	room3.cells.append(cell)
	
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.FLOOR
	cell.connection_up = true
	room3.cells.append(cell)
	
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.BLOCKED
	room3.cells.append(cell)
	
	# Row 1: blocked, floor, blocked
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.BLOCKED
	room3.cells.append(cell)
	
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.FLOOR
	room3.cells.append(cell)
	
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.BLOCKED
	room3.cells.append(cell)
	
	# Row 2: blocked, floor, blocked
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.BLOCKED
	room3.cells.append(cell)
	
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.FLOOR
	cell.connection_bottom = true
	room3.cells.append(cell)
	
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.BLOCKED
	room3.cells.append(cell)
	
	result = ResourceSaver.save(room3, "res://resources/rooms/straight_corridor.tres")
	if result == OK:
		print("✓ Created straight_corridor.tres")
	else:
		print("✗ Failed to create straight_corridor.tres: ", result)
	
	
	# Room 4: T-shaped room with 3 connections
	var room4 = MetaRoom.new()
	room4.room_name = "T-Room"
	room4.width = 3
	room4.height = 3
	room4.cells.clear()
	
	# Row 0: floor, floor, floor
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.FLOOR
	cell.connection_left = true
	room4.cells.append(cell)
	
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.FLOOR
	cell.connection_up = true
	room4.cells.append(cell)
	
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.FLOOR
	cell.connection_right = true
	room4.cells.append(cell)
	
	# Row 1: blocked, floor, blocked
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.BLOCKED
	room4.cells.append(cell)
	
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.FLOOR
	room4.cells.append(cell)
	
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.BLOCKED
	room4.cells.append(cell)
	
	# Row 2: blocked, floor, blocked
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.BLOCKED
	room4.cells.append(cell)
	
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.FLOOR
	cell.connection_bottom = true
	room4.cells.append(cell)
	
	cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.BLOCKED
	room4.cells.append(cell)
	
	result = ResourceSaver.save(room4, "res://resources/rooms/t_room.tres")
	if result == OK:
		print("✓ Created t_room.tres")
	else:
		print("✗ Failed to create t_room.tres: ", result)
	
	print("\nRoom resource creation complete!")
	print("Resources saved to: res://resources/rooms/")
