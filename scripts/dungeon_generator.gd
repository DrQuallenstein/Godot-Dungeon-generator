class_name DungeonGenerator
extends Node

## DungeonGenerator creates a dungeon by placing rooms using a random walk algorithm.
## It ensures rooms don't overlap and connections match properly.

## Placed room data structure
class PlacedRoom:
	var room: MetaRoom
	var position: Vector2i  # World position (in cells)
	var rotation: RoomRotator.Rotation
	
	func _init(p_room: MetaRoom, p_position: Vector2i, p_rotation: RoomRotator.Rotation):
		room = p_room
		position = p_position
		rotation = p_rotation
	
	## Gets the world position of a cell in this room
	func get_cell_world_pos(local_x: int, local_y: int) -> Vector2i:
		return position + Vector2i(local_x, local_y)


## Available room templates to use for generation
@export var room_templates: Array[MetaRoom] = []

## Target number of rooms to generate
@export var target_room_count: int = 10

## Random seed for generation (0 = random)
@export var generation_seed: int = 0

## Maximum attempts to place a room before giving up
@export var max_placement_attempts: int = 100

## List of all placed rooms in the dungeon
var placed_rooms: Array[PlacedRoom] = []

## Grid of occupied cells (for collision detection)
var occupied_cells: Dictionary = {}  # Vector2i -> PlacedRoom


## Signal emitted when generation completes
signal generation_complete(success: bool, room_count: int)


## Generates the dungeon
func generate() -> bool:
	# Clear previous generation
	clear_dungeon()
	
	# Setup random seed
	if generation_seed != 0:
		seed(generation_seed)
	
	# Validate room templates
	if room_templates.is_empty():
		push_error("DungeonGenerator: No room templates provided")
		return false
	
	# Find a suitable starting room (one with connections)
	var start_room = _get_random_room_with_connections()
	if start_room == null:
		push_error("DungeonGenerator: No rooms with connections found")
		return false
	
	# Place the first room at origin
	var first_placement = PlacedRoom.new(start_room, Vector2i.ZERO, RoomRotator.Rotation.DEG_0)
	_place_room(first_placement)
	
	# Generate remaining rooms using random walk
	var current_room = first_placement
	var attempts = 0
	
	while placed_rooms.size() < target_room_count and attempts < max_placement_attempts:
		var next_placement = _try_place_next_room(current_room)
		
		if next_placement != null:
			_place_room(next_placement)
			current_room = next_placement
			attempts = 0  # Reset attempts on success
		else:
			# Try from a different random placed room
			if placed_rooms.size() > 1:
				current_room = placed_rooms[randi() % placed_rooms.size()]
			attempts += 1
	
	var success = placed_rooms.size() >= target_room_count
	generation_complete.emit(success, placed_rooms.size())
	
	print("DungeonGenerator: Generated ", placed_rooms.size(), " rooms")
	return success


## Attempts to place the next room connected to the current room
func _try_place_next_room(current_placement: PlacedRoom) -> PlacedRoom:
	# Get available connection points from current room
	var connections = current_placement.room.get_connection_points()
	if connections.is_empty():
		return null
	
	# Shuffle connections for randomness
	connections.shuffle()
	
	# Try each connection point
	for conn_point in connections:
		# Try random room templates
		var template_indices = range(room_templates.size())
		template_indices.shuffle()
		
		for template_idx in template_indices:
			var template = room_templates[template_idx]
			
			# Try all rotations
			var rotations = RoomRotator.get_all_rotations()
			rotations.shuffle()
			
			for rotation in rotations:
				var rotated_room = RoomRotator.rotate_room(template, rotation)
				var placement = _try_connect_room(current_placement, conn_point, rotated_room, rotation)
				
				if placement != null:
					return placement
	
	return null


## Tries to connect a room at the specified connection point
func _try_connect_room(
	from_placement: PlacedRoom,
	from_connection: MetaRoom.ConnectionPoint,
	to_room: MetaRoom,
	rotation: RoomRotator.Rotation
) -> PlacedRoom:
	# Find matching connection points in the target room
	var to_connections = to_room.get_connection_points()
	
	for to_conn in to_connections:
		# Check if directions match (opposite)
		var from_world_pos = from_placement.get_cell_world_pos(from_connection.x, from_connection.y)
		var required_direction = MetaCell.opposite_direction(from_connection.direction)
		
		if to_conn.direction != required_direction:
			continue
		
		# Calculate target room position
		var offset = _get_direction_offset(from_connection.direction)
		var target_pos = from_world_pos + offset - Vector2i(to_conn.x, to_conn.y)
		
		# Check if room can be placed without overlap
		if _can_place_room(to_room, target_pos):
			return PlacedRoom.new(to_room, target_pos, rotation)
	
	return null


## Checks if a room can be placed at the given position without overlapping
func _can_place_room(room: MetaRoom, position: Vector2i) -> bool:
	for y in range(room.height):
		for x in range(room.width):
			var cell = room.get_cell(x, y)
			if cell == null or cell.cell_type == MetaCell.CellType.BLOCKED:
				continue
			
			var world_pos = position + Vector2i(x, y)
			if occupied_cells.has(world_pos):
				return false
	
	return true


## Places a room and marks its cells as occupied
func _place_room(placement: PlacedRoom) -> void:
	placed_rooms.append(placement)
	
	# Mark cells as occupied
	for y in range(placement.room.height):
		for x in range(placement.room.width):
			var cell = placement.room.get_cell(x, y)
			if cell == null or cell.cell_type == MetaCell.CellType.BLOCKED:
				continue
			
			var world_pos = placement.get_cell_world_pos(x, y)
			occupied_cells[world_pos] = placement


## Gets the offset vector for a direction
func _get_direction_offset(direction: MetaCell.Direction) -> Vector2i:
	match direction:
		MetaCell.Direction.UP:
			return Vector2i(0, -1)
		MetaCell.Direction.RIGHT:
			return Vector2i(1, 0)
		MetaCell.Direction.BOTTOM:
			return Vector2i(0, 1)
		MetaCell.Direction.LEFT:
			return Vector2i(-1, 0)
	return Vector2i.ZERO


## Gets a random room template that has connections
func _get_random_room_with_connections() -> MetaRoom:
	var valid_rooms: Array[MetaRoom] = []
	
	for template in room_templates:
		if template.has_connections():
			valid_rooms.append(template)
	
	if valid_rooms.is_empty():
		return null
	
	return valid_rooms[randi() % valid_rooms.size()]


## Clears all generated dungeon data
func clear_dungeon() -> void:
	placed_rooms.clear()
	occupied_cells.clear()


## Gets the bounds of the generated dungeon
func get_dungeon_bounds() -> Rect2i:
	if placed_rooms.is_empty():
		return Rect2i(0, 0, 0, 0)
	
	# Initialize with first cell position
	var first_placement = placed_rooms[0]
	var first_pos = first_placement.get_cell_world_pos(0, 0)
	var min_pos = first_pos
	var max_pos = first_pos
	
	for placement in placed_rooms:
		for y in range(placement.room.height):
			for x in range(placement.room.width):
				var world_pos = placement.get_cell_world_pos(x, y)
				min_pos.x = mini(min_pos.x, world_pos.x)
				min_pos.y = mini(min_pos.y, world_pos.y)
				max_pos.x = maxi(max_pos.x, world_pos.x)
				max_pos.y = maxi(max_pos.y, world_pos.y)
	
	return Rect2i(min_pos, max_pos - min_pos + Vector2i.ONE)
