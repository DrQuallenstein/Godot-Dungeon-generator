extends Node

## Standalone script to create room resources without Godot editor

func create_rooms() -> void:
	print("Creating example room resources...")
	
	# Room 1: Cross-shaped room
	var room1 = _create_cross_room()
	_save_room_as_tres(room1, "resources/rooms/cross_room.tres")
	
	# Room 2: L-corridor
	var room2 = _create_l_corridor()
	_save_room_as_tres(room2, "resources/rooms/l_corridor.tres")
	
	# Room 3: Straight corridor
	var room3 = _create_straight_corridor()
	_save_room_as_tres(room3, "resources/rooms/straight_corridor.tres")
	
	# Room 4: T-shaped room
	var room4 = _create_t_room()
	_save_room_as_tres(room4, "resources/rooms/t_room.tres")
	
	print("Room resources created successfully!")


func _create_cross_room() -> MetaRoom:
	var room = MetaRoom.new()
	room.room_name = "Cross Room"
	room.width = 3
	room.height = 3
	room.cells.clear()
	
	# Row 0
	room.cells.append(_create_cell(MetaCell.CellType.BLOCKED))
	room.cells.append(_create_cell(MetaCell.CellType.FLOOR, true, false, false, false))
	room.cells.append(_create_cell(MetaCell.CellType.BLOCKED))
	
	# Row 1
	room.cells.append(_create_cell(MetaCell.CellType.FLOOR, false, false, false, true))
	room.cells.append(_create_cell(MetaCell.CellType.FLOOR))
	room.cells.append(_create_cell(MetaCell.CellType.FLOOR, false, true, false, false))
	
	# Row 2
	room.cells.append(_create_cell(MetaCell.CellType.BLOCKED))
	room.cells.append(_create_cell(MetaCell.CellType.FLOOR, false, false, true, false))
	room.cells.append(_create_cell(MetaCell.CellType.BLOCKED))
	
	return room


func _create_l_corridor() -> MetaRoom:
	var room = MetaRoom.new()
	room.room_name = "L-Corridor"
	room.width = 3
	room.height = 3
	room.cells.clear()
	
	# Row 0
	room.cells.append(_create_cell(MetaCell.CellType.FLOOR, false, false, false, true))
	room.cells.append(_create_cell(MetaCell.CellType.FLOOR))
	room.cells.append(_create_cell(MetaCell.CellType.FLOOR, true, false, false, false))
	
	# Row 1
	room.cells.append(_create_cell(MetaCell.CellType.FLOOR))
	room.cells.append(_create_cell(MetaCell.CellType.BLOCKED))
	room.cells.append(_create_cell(MetaCell.CellType.BLOCKED))
	
	# Row 2
	room.cells.append(_create_cell(MetaCell.CellType.FLOOR, false, false, true, false))
	room.cells.append(_create_cell(MetaCell.CellType.BLOCKED))
	room.cells.append(_create_cell(MetaCell.CellType.BLOCKED))
	
	return room


func _create_straight_corridor() -> MetaRoom:
	var room = MetaRoom.new()
	room.room_name = "Straight Corridor"
	room.width = 3
	room.height = 3
	room.cells.clear()
	
	# Row 0
	room.cells.append(_create_cell(MetaCell.CellType.BLOCKED))
	room.cells.append(_create_cell(MetaCell.CellType.FLOOR, true, false, false, false))
	room.cells.append(_create_cell(MetaCell.CellType.BLOCKED))
	
	# Row 1
	room.cells.append(_create_cell(MetaCell.CellType.BLOCKED))
	room.cells.append(_create_cell(MetaCell.CellType.FLOOR))
	room.cells.append(_create_cell(MetaCell.CellType.BLOCKED))
	
	# Row 2
	room.cells.append(_create_cell(MetaCell.CellType.BLOCKED))
	room.cells.append(_create_cell(MetaCell.CellType.FLOOR, false, false, true, false))
	room.cells.append(_create_cell(MetaCell.CellType.BLOCKED))
	
	return room


func _create_t_room() -> MetaRoom:
	var room = MetaRoom.new()
	room.room_name = "T-Room"
	room.width = 3
	room.height = 3
	room.cells.clear()
	
	# Row 0
	room.cells.append(_create_cell(MetaCell.CellType.FLOOR, false, false, false, true))
	room.cells.append(_create_cell(MetaCell.CellType.FLOOR, true, false, false, false))
	room.cells.append(_create_cell(MetaCell.CellType.FLOOR, false, true, false, false))
	
	# Row 1
	room.cells.append(_create_cell(MetaCell.CellType.BLOCKED))
	room.cells.append(_create_cell(MetaCell.CellType.FLOOR))
	room.cells.append(_create_cell(MetaCell.CellType.BLOCKED))
	
	# Row 2
	room.cells.append(_create_cell(MetaCell.CellType.BLOCKED))
	room.cells.append(_create_cell(MetaCell.CellType.FLOOR, false, false, true, false))
	room.cells.append(_create_cell(MetaCell.CellType.BLOCKED))
	
	return room


func _create_cell(type: MetaCell.CellType, up: bool = false, right: bool = false, bottom: bool = false, left: bool = false) -> MetaCell:
	var cell = MetaCell.new()
	cell.cell_type = type
	cell.connection_up = up
	cell.connection_right = right
	cell.connection_bottom = bottom
	cell.connection_left = left
	return cell


func _save_room_as_tres(room: MetaRoom, filepath: String) -> void:
	# Create .tres file content manually
	var content = '[gd_resource type="Resource" script_class="MetaRoom" load_steps=2 format=3]\n\n'
	content += '[ext_resource type="Script" path="res://scripts/meta_room.gd" id="1"]\n\n'
	content += '[resource]\n'
	content += 'script = ExtResource("1")\n'
	content += 'width = %d\n' % room.width
	content += 'height = %d\n' % room.height
	content += 'room_name = "%s"\n' % room.room_name
	content += 'cells = Array[Resource](['
	
	for i in range(room.cells.size()):
		var cell = room.cells[i]
		if cell != null:
			content += 'SubResource("%d")' % i
		else:
			content += 'null'
		if i < room.cells.size() - 1:
			content += ', '
	
	content += '])\n\n'
	
	# Add cell subresources
	for i in range(room.cells.size()):
		var cell = room.cells[i]
		if cell != null:
			content += '[sub_resource type="Resource" id="%d"]\n' % i
			content += 'script = ExtResource("1_cell")\n'
			content += 'cell_type = %d\n' % cell.cell_type
			content += 'connection_up = %s\n' % str(cell.connection_up).to_lower()
			content += 'connection_right = %s\n' % str(cell.connection_right).to_lower()
			content += 'connection_bottom = %s\n' % str(cell.connection_bottom).to_lower()
			content += 'connection_left = %s\n\n' % str(cell.connection_left).to_lower()
	
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()
		print("✓ Created ", filepath)
	else:
		print("✗ Failed to create ", filepath)
