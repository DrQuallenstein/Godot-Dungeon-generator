extends Node2D

## Visual Dungeon Viewer with pan and zoom controls
## Displays generated dungeon with visual tiles

@onready var generator: DungeonGenerator = $DungeonGenerator
@onready var camera: Camera2D = $Camera2D
@ontml:parameter>
@onready var tile_container: Node2D = $TileContainer
@onready var info_label: Label = $UI/InfoLabel

## Tile rendering settings
const TILE_SIZE: int = 32  # pixels
const CAMERA_ZOOM_MIN: float = 0.25
const CAMERA_ZOOM_MAX: float = 3.0
const CAMERA_ZOOM_STEP: float = 0.1
const CAMERA_PAN_SPEED: float = 500.0

## Camera state
var is_panning: bool = false
var pan_start_position: Vector2 = Vector2.ZERO
var camera_drag_start: Vector2 = Vector2.ZERO

## Tile colors
var tile_colors := {
	"wall": Color(0.3, 0.3, 0.3),      # Dark gray
	"room": Color(0.9, 0.9, 0.8),      # Light beige
	"corridor": Color(0.7, 0.7, 0.6),  # Gray-beige
	"door": Color(0.6, 0.4, 0.2),      # Brown
	"empty": Color(0.1, 0.1, 0.15)     # Very dark blue-gray
}

func _ready():
	# Setup camera
	camera.zoom = Vector2(1.0, 1.0)
	
	# Create tile types
	var wall_type = MetaTileType.new("wall", "Solid wall")
	var corridor_type = MetaTileType.new("corridor", "Corridor/hallway")
	var room_type = MetaTileType.new("room", "Room floor")
	
	# Create rooms
	var rooms = _create_rooms(wall_type, corridor_type, room_type)
	
	# Configure generator
	generator.available_rooms = rooms
	generator.grid_width = 40
	generator.grid_height = 40
	generator.min_grid_elements = 200
	generator.max_attempts_per_placement = 10
	
	# Connect signals
	generator.generation_complete.connect(_on_generation_complete)
	generator.generation_failed.connect(_on_generation_failed)
	
	# Generate dungeon
	print("Generating dungeon...")
	generator.generate_dungeon()
	
	# Display instructions
	print("\n=== Controls ===")
	print("Mouse Wheel: Zoom in/out")
	print("Middle Mouse / Right Click + Drag: Pan camera")
	print("Arrow Keys: Pan camera")
	print("R: Regenerate dungeon")
	print("===============\n")

func _create_rooms(wall_type: MetaTileType, corridor_type: MetaTileType, room_type: MetaTileType) -> Array[MetaRoom]:
	var rooms: Array[MetaRoom] = []
	
	# Various room sizes
	rooms.append(_create_rectangular_room(3, 3, "TinyRoom", 4.0, wall_type, room_type))
	rooms.append(_create_rectangular_room(5, 5, "SmallRoom", 3.0, wall_type, room_type))
	rooms.append(_create_rectangular_room(7, 5, "MediumRoom", 2.0, wall_type, room_type))
	rooms.append(_create_rectangular_room(9, 7, "LargeRoom", 1.0, wall_type, room_type))
	
	# Corridors
	rooms.append(_create_corridor(3, 1, "ShortCorridorH", 5.0, corridor_type))
	rooms.append(_create_corridor(5, 1, "MediumCorridorH", 3.0, corridor_type))
	rooms.append(_create_corridor(7, 1, "LongCorridorH", 2.0, corridor_type))
	rooms.append(_create_corridor(1, 3, "ShortCorridorV", 5.0, corridor_type))
	rooms.append(_create_corridor(1, 5, "MediumCorridorV", 3.0, corridor_type))
	rooms.append(_create_corridor(1, 7, "LongCorridorV", 2.0, corridor_type))
	
	# Special shapes
	rooms.append(_create_l_corridor(corridor_type))
	rooms.append(_create_t_junction(corridor_type))
	
	return rooms

func _create_rectangular_room(width: int, height: int, name: String, weight: float, 
		wall_type: MetaTileType, room_type: MetaTileType) -> MetaRoom:
	var room = MetaRoom.new(name, width, height)
	room.weight = weight
	
	for y in range(height):
		for x in range(width):
			if x == 0 or x == width - 1 or y == 0 or y == height - 1:
				room.set_tile(x, y, wall_type)
			else:
				room.set_tile(x, y, room_type)
	
	return room

func _create_corridor(width: int, height: int, name: String, weight: float, 
		corridor_type: MetaTileType) -> MetaRoom:
	var corridor = MetaRoom.new(name, width, height)
	corridor.weight = weight
	
	for y in range(height):
		for x in range(width):
			corridor.set_tile(x, y, corridor_type)
	
	return corridor

func _create_l_corridor(corridor_type: MetaTileType) -> MetaRoom:
	var l_corridor = MetaRoom.new("LCorridor", 3, 3)
	l_corridor.weight = 1.5
	l_corridor.set_tile(0, 0, corridor_type)
	l_corridor.set_tile(1, 0, corridor_type)
	l_corridor.set_tile(1, 1, corridor_type)
	l_corridor.set_tile(1, 2, corridor_type)
	return l_corridor

func _create_t_junction(corridor_type: MetaTileType) -> MetaRoom:
	var t_junction = MetaRoom.new("TJunction", 3, 3)
	t_junction.weight = 1.0
	t_junction.set_tile(1, 0, corridor_type)
	t_junction.set_tile(0, 1, corridor_type)
	t_junction.set_tile(1, 1, corridor_type)
	t_junction.set_tile(2, 1, corridor_type)
	t_junction.set_tile(1, 2, corridor_type)
	return t_junction

func _on_generation_complete(grid: Array):
	print("✓ Dungeon generation complete!")
	var stats = generator.get_stats()
	print("Grid Size: %dx%d" % [stats.grid_size.x, stats.grid_size.y])
	print("Filled Tiles: %d (%.1f%%)" % [stats.filled_tiles, 
		stats.filled_tiles * 100.0 / (stats.grid_size.x * stats.grid_size.y)])
	print("Rooms Placed: %d" % stats.rooms_placed)
	
	# Update UI label
	info_label.text = "Controls:
Mouse Wheel: Zoom
Right Click + Drag: Pan
Arrow Keys: Pan
R: Regenerate

Stats:
Grid: %dx%d
Tiles: %d (%.1f%%)
Rooms: %d
Zoom: %.2fx" % [
		stats.grid_size.x, stats.grid_size.y,
		stats.filled_tiles,
		stats.filled_tiles * 100.0 / (stats.grid_size.x * stats.grid_size.y),
		stats.rooms_placed,
		camera.zoom.x
	]
	
	# Render the dungeon
	_render_dungeon(grid)
	
	# Center camera on dungeon
	var dungeon_center = Vector2(
		generator.grid_width * TILE_SIZE / 2.0,
		generator.grid_height * TILE_SIZE / 2.0
	)
	camera.position = dungeon_center

func _on_generation_failed(reason: String):
	print("✗ Generation failed: ", reason)

func _render_dungeon(grid: Array):
	# Clear previous tiles
	for child in tile_container.get_children():
		child.queue_free()
	
	# Render each tile
	for y in range(len(grid)):
		for x in range(len(grid[0])):
			var tile_type = grid[y][x]
			var color: Color
			
			if tile_type == null:
				color = tile_colors["empty"]
			else:
				var type_name = tile_type.type_name
				color = tile_colors.get(type_name, Color.MAGENTA)
			
			# Create tile sprite
			var tile = ColorRect.new()
			tile.size = Vector2(TILE_SIZE - 2, TILE_SIZE - 2)  # -2 for grid lines
			tile.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
			tile.color = color
			tile_container.add_child(tile)

func _input(event: InputEvent):
	# Mouse wheel zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_camera(CAMERA_ZOOM_STEP)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_camera(-CAMERA_ZOOM_STEP)
		
		# Right click or middle mouse for panning
		elif event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				is_panning = true
				pan_start_position = event.position
				camera_drag_start = camera.position
			else:
				is_panning = false
	
	# Mouse motion for panning
	elif event is InputEventMouseMotion and is_panning:
		var delta = (event.position - pan_start_position) / camera.zoom.x
		camera.position = camera_drag_start - delta
	
	# Keyboard regenerate
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			print("\nRegenerating dungeon...")
			generator.generate_dungeon()

func _process(delta: float):
	# Arrow key panning
	var pan_direction = Vector2.ZERO
	
	if Input.is_key_pressed(KEY_LEFT):
		pan_direction.x -= 1
	if Input.is_key_pressed(KEY_RIGHT):
		pan_direction.x += 1
	if Input.is_key_pressed(KEY_UP):
		pan_direction.y -= 1
	if Input.is_key_pressed(KEY_DOWN):
		pan_direction.y += 1
	
	if pan_direction != Vector2.ZERO:
		camera.position += pan_direction.normalized() * CAMERA_PAN_SPEED * delta / camera.zoom.x

func _zoom_camera(zoom_delta: float):
	var new_zoom = camera.zoom.x + zoom_delta
	new_zoom = clamp(new_zoom, CAMERA_ZOOM_MIN, CAMERA_ZOOM_MAX)
	camera.zoom = Vector2(new_zoom, new_zoom)
	
	# Update zoom display in UI
	if info_label:
		var current_text = info_label.text
		var zoom_line_start = current_text.find("Zoom:")
		if zoom_line_start != -1:
			var zoom_line_end = current_text.find("\n", zoom_line_start)
			if zoom_line_end == -1:
				zoom_line_end = len(current_text)
			var new_text = current_text.substr(0, zoom_line_start) + "Zoom: %.2fx" % new_zoom
			if zoom_line_end < len(current_text):
				new_text += current_text.substr(zoom_line_end)
			info_label.text = new_text
