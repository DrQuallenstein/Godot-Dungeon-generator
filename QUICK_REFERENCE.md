# Quick Reference Guide

## File Structure

```
Godot-Dungeon-generator/
├── project.godot              # Godot 4.6 project file
├── icon.svg                   # Project icon
├── README.md                  # User guide and overview
├── DOCUMENTATION.md           # Detailed technical documentation
├── validate_syntax.sh         # Syntax validation script
│
├── scripts/
│   ├── meta_cell.gd          # Cell resource (FLOOR, DOOR, BLOCKED)
│   ├── meta_room.gd          # Room resource (grid of cells)
│   ├── room_rotator.gd       # Room rotation logic (0°, 90°, 180°, 270°)
│   ├── dungeon_generator.gd  # Main generator (random walk algorithm)
│   ├── dungeon_visualizer.gd # Visual debug renderer
│   └── test_system.gd        # Comprehensive test suite
│
├── resources/
│   └── rooms/
│       ├── cross_room.tres         # 4-way connection room (+ shape)
│       ├── l_corridor.tres         # L-shaped corridor (2 connections)
│       ├── straight_corridor.tres  # Straight hallway (2 connections)
│       └── t_room.tres             # T-shaped room (3 connections)
│
└── scenes/
    ├── test_dungeon.tscn     # Visual test scene with generator
    └── test_system.tscn      # Automated test scene
```

## Quick Start

### 1. Open Project in Godot 4.6
```bash
godot project.godot
```

### 2. Run Test Scene
- Press F5 to run `test_dungeon.tscn`
- Press R to regenerate
- Press S to generate with new seed

### 3. Run Automated Tests
- File > Open Scene > `scenes/test_system.tscn`
- Press F5
- Check console for test results

## Core Classes Cheat Sheet

### MetaCell
```gdscript
var cell = MetaCell.new()
cell.cell_type = MetaCell.CellType.FLOOR  # or DOOR, BLOCKED
cell.connection_up = true
cell.connection_right = true
```

### MetaRoom
```gdscript
var room = MetaRoom.new()
room.width = 3
room.height = 3
room.room_name = "My Room"

# Add cells
for i in range(9):
    room.cells.append(MetaCell.new())

# Get cell
var cell = room.get_cell(1, 1)

# Get connections
var connections = room.get_connection_points()
```

### RoomRotator
```gdscript
var rotated = RoomRotator.rotate_room(original_room, RoomRotator.Rotation.DEG_90)

# Try all rotations
for rot in RoomRotator.get_all_rotations():
    var r = RoomRotator.rotate_room(room, rot)
```

### DungeonGenerator
```gdscript
var gen = DungeonGenerator.new()
gen.room_templates = [
    load("res://resources/rooms/cross_room.tres"),
    load("res://resources/rooms/l_corridor.tres"),
]
gen.target_room_count = 15
gen.generation_seed = 12345  # or 0 for random

if gen.generate():
    for placement in gen.placed_rooms:
        print(placement.position)  # Vector2i world position
        print(placement.room)      # MetaRoom instance
        print(placement.rotation)  # Rotation applied
```

## Common Patterns

### Load All Room Resources
```gdscript
func load_room_templates() -> Array[MetaRoom]:
    var rooms: Array[MetaRoom] = []
    var dir = DirAccess.open("res://resources/rooms/")
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".tres"):
                var path = "res://resources/rooms/" + file_name
                rooms.append(load(path))
            file_name = dir.get_next()
    
    return rooms
```

### Spawn TileMap from Dungeon
```gdscript
func spawn_tilemap(generator: DungeonGenerator, tilemap: TileMap):
    for placement in generator.placed_rooms:
        for y in range(placement.room.height):
            for x in range(placement.room.width):
                var cell = placement.room.get_cell(x, y)
                if cell == null or cell.cell_type == MetaCell.CellType.BLOCKED:
                    continue
                
                var world_pos = placement.get_cell_world_pos(x, y)
                var tile_id = 0  # Your floor tile
                tilemap.set_cell(0, world_pos, tile_id, Vector2i.ZERO)
```

### Create Room Programmatically
```gdscript
func create_custom_room() -> MetaRoom:
    var room = MetaRoom.new()
    room.width = 3
    room.height = 3
    room.room_name = "Custom"
    
    # Create 3x3 grid
    for y in range(3):
        for x in range(3):
            var cell = MetaCell.new()
            
            # Edges are blocked
            if x == 0 or x == 2 or y == 0 or y == 2:
                cell.cell_type = MetaCell.CellType.BLOCKED
            else:
                cell.cell_type = MetaCell.CellType.FLOOR
            
            room.cells.append(cell)
    
    # Add top connection
    room.get_cell(1, 0).cell_type = MetaCell.CellType.FLOOR
    room.get_cell(1, 0).connection_up = true
    
    return room
```

### Check Dungeon Connectivity
```gdscript
func is_dungeon_connected(generator: DungeonGenerator) -> bool:
    if generator.placed_rooms.is_empty():
        return false
    
    var visited = {}
    var queue = [generator.placed_rooms[0]]
    
    while not queue.is_empty():
        var current = queue.pop_front()
        if visited.has(current):
            continue
        visited[current] = true
        
        # Find adjacent rooms
        for placement in generator.placed_rooms:
            if placement == current:
                continue
            if are_rooms_adjacent(current, placement):
                queue.append(placement)
    
    return visited.size() == generator.placed_rooms.size()
```

## Debugging Tips

### Visualize Generation Steps
```gdscript
# In dungeon_generator.gd
signal room_placed(placement: PlacedRoom)

# After placing room
room_placed.emit(placement)

# In your scene
generator.room_placed.connect(func(p):
    print("Placed: ", p.room.room_name, " at ", p.position)
    await get_tree().create_timer(0.5).timeout  # Slow down
)
```

### Print Dungeon ASCII
```gdscript
func print_dungeon_ascii(generator: DungeonGenerator):
    var bounds = generator.get_dungeon_bounds()
    
    for y in range(bounds.size.y):
        var line = ""
        for x in range(bounds.size.x):
            var world_pos = bounds.position + Vector2i(x, y)
            if generator.occupied_cells.has(world_pos):
                line += "█"
            else:
                line += " "
        print(line)
```

### Validate Room Resource
```gdscript
func check_room(room: MetaRoom):
    print("Checking: ", room.room_name)
    print("  Size: ", room.width, "x", room.height)
    print("  Cells: ", room.cells.size(), " (expected: ", room.width * room.height, ")")
    print("  Connections: ", room.get_connection_points().size())
    print("  Valid: ", room.validate())
```

## Performance Tips

### Pre-generate Rotations
```gdscript
var rotation_cache: Dictionary = {}  # room -> {rotation -> rotated_room}

func get_rotated_room_cached(room: MetaRoom, rotation: int) -> MetaRoom:
    if not rotation_cache.has(room):
        rotation_cache[room] = {}
    
    if not rotation_cache[room].has(rotation):
        rotation_cache[room][rotation] = RoomRotator.rotate_room(room, rotation)
    
    return rotation_cache[room][rotation]
```

### Generate in Thread
```gdscript
var generation_thread: Thread

func generate_async():
    generation_thread = Thread.new()
    generation_thread.start(
        func():
            var gen = DungeonGenerator.new()
            gen.room_templates = room_templates
            gen.generate()
            return gen.placed_rooms
    )

func check_generation():
    if generation_thread and not generation_thread.is_alive():
        var result = generation_thread.wait_to_finish()
        generation_thread = null
        # Use result
```

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Few rooms generated | Add more room variety, especially 3-4 connection rooms |
| Rooms don't connect | Verify connections are on edge cells only |
| Rooms overlap | Check room.validate() for all templates |
| Generation slow | Reduce target_room_count or max_attempts |
| Seed not reproducible | Ensure same room_templates order |

## Keyboard Shortcuts (Test Scene)

- **R**: Regenerate with same seed
- **S**: Generate with new random seed
- **ESC**: Quit

## Export Variables Quick Reference

### DungeonGenerator
```gdscript
@export var room_templates: Array[MetaRoom] = []
@export var target_room_count: int = 10
@export var generation_seed: int = 0  # 0 = random
@export var max_placement_attempts: int = 100
```

### DungeonVisualizer
```gdscript
@export var cell_size: int = 32
@export var draw_grid: bool = true
@export var draw_connections: bool = true
```

### MetaCell
```gdscript
@export var cell_type: CellType = CellType.FLOOR
@export var connection_up: bool = false
@export var connection_right: bool = false
@export var connection_bottom: bool = false
@export var connection_left: bool = false
```

### MetaRoom
```gdscript
@export var width: int = 3
@export var height: int = 3
@export var cells: Array[MetaCell] = []
@export var room_name: String = "Room"
```

## Next Steps

1. **Customize Rooms**: Create your own room templates in `resources/rooms/`
2. **Integrate TileMap**: Use generator output to spawn actual game tiles
3. **Add Gameplay**: Place enemies, items, and objectives
4. **Extend Generator**: Add room types, critical paths, or special rules
5. **Optimize**: Cache rotations, use spatial partitioning for large dungeons

## Support

See `DOCUMENTATION.md` for detailed technical information.
See `README.md` for user guide and feature overview.

---

**Happy dungeon generating! 🏰**
