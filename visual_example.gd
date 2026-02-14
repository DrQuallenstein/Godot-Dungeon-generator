extends Node2D

## Visual example that displays generated dungeon on screen
## This demonstrates how to visualize the meta grid

@onready var generator: DungeonGenerator = $DungeonGenerator

const TILE_SIZE = 16  # Size of each tile in pixels

# Colors for different tile types
const COLORS = {
	"wall": Color(0.3, 0.3, 0.3),
	"room": Color(0.8, 0.8, 0.8),
	"corridor": Color(0.6, 0.6, 0.6),
	"door": Color(0.4, 0.2, 0.0),
}

var grid: Array = []

func _ready():
	# Create tile types
	var wall_type = MetaTileType.new("wall", "Solid wall")
	var corridor_type = MetaTileType.new("corridor", "Corridor/hallway")
	var room_type = MetaTileType.new("room", "Room floor")
	
	# Create rooms
	var rooms = _create_rooms(wall_type, corridor_type, room_type)
	
	# Configure generator
	generator.available_rooms = rooms
	generator.grid_width = 50
	generator.grid_height = 40
	generator.min_grid_elements = 200
	generator.max_attempts_per_placement = 10
	
	# Connect signals
	generator.generation_complete.connect(_on_generation_complete)
	generator.generation_failed.connect(_on_generation_failed)
	
	print("Starting visual dungeon generation...")
	generator.generate_dungeon()

func _create_rooms(wall_type: MetaTileType, corridor_type: MetaTileType, room_type: MetaTileType) -> Array[MetaRoom]:
	var rooms: Array[MetaRoom] = []
	
	# Various sized rooms
	rooms.append(_create_rect_room(3, 3, "Tiny", 5.0, wall_type, room_type))
	rooms.append(_create_rect_room(5, 5, "Small", 3.0, wall_type, room_type))
	rooms.append(_create_rect_room(7, 5, "Medium", 2.0, wall_type, room_type))
	rooms.append(_create_rect_room(9, 7, "Large", 1.0, wall_type, room_type))
	
	# Corridors
	rooms.append(_create_corridor(3, 1, "ShortH", 6.0, corridor_type))
	rooms.append(_create_corridor(5, 1, "MediumH", 4.0, corridor_type))
	rooms.append(_create_corridor(1, 3, "ShortV", 6.0, corridor_type))
	rooms.append(_create_corridor(1, 5, "MediumV", 4.0, corridor_type))
	
	return rooms

func _create_rect_room(w: int, h: int, name: String, weight: float, wall: MetaTileType, floor: MetaTileType) -> MetaRoom:
	var room = MetaRoom.new(name, w, h)
	room.weight = weight
	for y in range(h):
		for x in range(w):
			if x == 0 or x == w - 1 or y == 0 or y == h - 1:
				room.set_tile(x, y, wall)
			else:
				room.set_tile(x, y, floor)
	return room

func _create_corridor(w: int, h: int, name: String, weight: float, corridor: MetaTileType) -> MetaRoom:
	var room = MetaRoom.new(name, w, h)
	room.weight = weight
	for y in range(h):
		for x in range(w):
			room.set_tile(x, y, corridor)
	return room

func _on_generation_complete(generated_grid: Array):
	grid = generated_grid
	var stats = generator.get_stats()
	print("Generation complete!")
	print("Stats: ", stats)
	
	# Trigger redraw
	queue_redraw()

func _on_generation_failed(reason: String):
	print("Generation failed: ", reason)

func _draw():
	if grid.is_empty():
		return
	
	# Calculate offset to center the dungeon
	var total_width = len(grid[0]) * TILE_SIZE
	var total_height = len(grid) * TILE_SIZE
	var offset_x = (get_viewport_rect().size.x - total_width) / 2
	var offset_y = (get_viewport_rect().size.y - total_height) / 2
	
	# Draw grid
	for y in range(len(grid)):
		for x in range(len(grid[0])):
			var tile = grid[y][x]
			if tile != null:
				var color = COLORS.get(tile.type_name, Color.MAGENTA)
				var rect = Rect2(
					offset_x + x * TILE_SIZE,
					offset_y + y * TILE_SIZE,
					TILE_SIZE,
					TILE_SIZE
				)
				draw_rect(rect, color)
				
				# Draw border
				draw_rect(rect, Color.BLACK, false, 1.0)
	
	# Draw legend
	_draw_legend()

func _draw_legend():
	var legend_x = 10
	var legend_y = 10
	var legend_spacing = 20
	
	var items = [
		["wall", "Wall"],
		["room", "Room"],
		["corridor", "Corridor"],
		["door", "Door"],
	]
	
	for item in items:
		var type_name = item[0]
		var label = item[1]
		var color = COLORS.get(type_name, Color.MAGENTA)
		
		# Draw color box
		draw_rect(Rect2(legend_x, legend_y, 15, 15), color)
		draw_rect(Rect2(legend_x, legend_y, 15, 15), Color.BLACK, false, 1.0)
		
		# Draw text (simplified - in real Godot you'd use Label nodes)
		legend_y += legend_spacing

func _input(event):
	# Press Space to regenerate
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		print("\nRegenerating dungeon...")
		generator.generate_dungeon()
