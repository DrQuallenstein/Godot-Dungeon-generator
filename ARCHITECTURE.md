# System Architecture and Flow

## Component Hierarchy

```
DungeonGenerator (Node)
    ↓ uses
    ├── MetaRoom (Resource) × N templates
    │   ↓ contains
    │   └── MetaCell (Resource) × (width × height)
    │       ↓ has
    │       ├── CellType (BLOCKED, FLOOR, DOOR)
    │       └── Connections (UP, RIGHT, BOTTOM, LEFT)
    │
    └── RoomRotator (Static Class)
        ↓ rotates
        └── MetaRoom → Rotated MetaRoom (0°, 90°, 180°, 270°)
```

## Data Flow

### 1. Room Definition (Editor Time)
```
Designer creates room in Godot Editor
    ↓
MetaRoom Resource (.tres file)
    ├── Width: 3
    ├── Height: 3
    └── Cells: [
        MetaCell { type: FLOOR, connections: UP },
        MetaCell { type: FLOOR, connections: NONE },
        MetaCell { type: BLOCKED, connections: NONE },
        ...
    ]
```

### 2. Generation Process (Runtime)
```
DungeonGenerator.generate()
    ↓
1. Select random starting room with connections
    ↓
2. Place at origin (0, 0)
    ↓
3. LOOP: While rooms < target_count
    │   ↓
    ├─ Get random connection from current room
    │   ↓
    ├─ Select random room template
    │   ↓
    ├─ FOR each rotation (0°, 90°, 180°, 270°):
    │   │   ↓
    │   ├─ Rotate room with RoomRotator
    │   │   ↓
    │   ├─ Find matching connection point
    │   │   ↓
    │   ├─ Calculate target position
    │   │   ↓
    │   ├─ Check collision (no overlap)
    │   │   ↓
    │   └─ IF valid → Place room, break loop
    │       ↓
    └─ Move to new room, repeat
        ↓
4. Return placed_rooms array
```

## Algorithm Details

### Connection Matching
```
Room A (current)                Room B (candidate)
┌─────────┐                    ┌─────────┐
│  FLOOR  │                    │  FLOOR  │
│    ↓    │  ← Must match →   │    ↑    │
│  [DOOR] │                    │ [DOOR]  │
└─────────┘                    └─────────┘
Connection: BOTTOM              Connection: UP
(opposite directions required)
```

### Rotation Process
```
Original Room (0°)      90° Rotation         180° Rotation        270° Rotation
┌───┬───┬───┐          ┌───┬───┬───┐        ┌───┬───┬───┐       ┌───┬───┬───┐
│ ↑ │   │   │          │   │ → │   │        │   │   │ ↓ │       │   │ ← │   │
├───┼───┼───┤    →     ├───┼───┼───┤   →    ├───┼───┼───┤  →    ├───┼───┼───┤
│ ← │ ■ │ → │          │ ↑ │ ■ │ ↓ │        │ → │ ■ │ ← │       │ ↓ │ ■ │ ↑ │
├───┼───┼───┤          ├───┼───┼───┤        ├───┼───┼───┤       ├───┼───┼───┤
│   │ ↓ │   │          │   │ ← │   │        │   │ ↑ │   │       │   │ → │   │
└───┴───┴───┘          └───┴───┴───┘        └───┴───┴───┘       └───┴───┴───┘

Position transforms:
(x,y) → (y, w-1-x) → (w-1-x, h-1-y) → (h-1-y, x)

Connection transforms:
UP → RIGHT → BOTTOM → LEFT → UP
```

### Collision Detection
```
World Space Grid (Dictionary)
┌───┬───┬───┬───┬───┐
│ A │ A │   │   │   │  A = Room A
├───┼───┼───┼───┼───┤
│ A │ A │ B │ B │   │  B = Room B
├───┼───┼───┼───┼───┤
│   │   │ B │ B │   │
└───┴───┴───┴───┴───┘

occupied_cells = {
    Vector2i(0, 0): Room A,
    Vector2i(1, 0): Room A,
    Vector2i(0, 1): Room A,
    Vector2i(1, 1): Room A,
    Vector2i(2, 1): Room B,
    Vector2i(3, 1): Room B,
    Vector2i(2, 2): Room B,
    Vector2i(3, 2): Room B,
}

Check: O(1) lookup per cell
```

## Example Generation Sequence

```
Step 1: Place Starting Room
┌─────────┐
│  CROSS  │
│  (4-way)│
│  ├─┼─┤  │
└─────────┘
Position: (0, 0)

Step 2: Connect Room via RIGHT connection
┌─────────┐   ┌─────────┐
│  CROSS  │───│    L    │
│  (4-way)│   │ CORRIDOR│
│  ├─┼─┤  │   │  (rotated)
└─────────┘   └─────────┘
Position: (0, 0)  Position: (3, 0)

Step 3: Connect Room via BOTTOM connection
┌─────────┐   ┌─────────┐
│  CROSS  │───│    L    │
│  (4-way)│   │ CORRIDOR│
│  ├─┼─┤  │   │         │
└────┬────┘   └─────────┘
     │
┌────┴────┐
│   T     │
│  ROOM   │
│  ├─┼─┤  │
└─────────┘
Position: (3, 3)

Continue until target_room_count reached...
```

## Key Data Structures

### PlacedRoom
```gdscript
class PlacedRoom:
    room: MetaRoom          # The room template
    position: Vector2i      # World position (top-left corner)
    rotation: Rotation      # Applied rotation (0°, 90°, 180°, 270°)
```

### ConnectionPoint
```gdscript
class ConnectionPoint:
    x: int                  # Local cell X coordinate
    y: int                  # Local cell Y coordinate  
    direction: Direction    # Connection direction (UP, RIGHT, BOTTOM, LEFT)
```

### MetaCell
```gdscript
class MetaCell:
    cell_type: CellType               # BLOCKED, FLOOR, DOOR
    connection_up: bool               # Has UP connection
    connection_right: bool            # Has RIGHT connection
    connection_bottom: bool           # Has BOTTOM connection
    connection_left: bool             # Has LEFT connection
```

## Performance Characteristics

- **Room Placement**: O(R × C × 4) where R = room templates, C = connection points
- **Collision Check**: O(W × H) per room, where W = room width, H = room height
- **Cell Lookup**: O(1) using Dictionary
- **Total Generation**: O(N × R × C × 4 × W × H) where N = target room count

For typical values (N=15, R=4, C=3, W=3, H=3):
- ~15 rooms × 4 templates × 3 connections × 4 rotations × 9 cells
- ≈ 6,480 operations
- < 100ms on modern hardware

## Extension Points

1. **Custom Cell Types**: Add new types to `MetaCell.CellType` enum
2. **New Room Templates**: Create `.tres` resources in Godot editor
3. **Generation Constraints**: Modify `_can_place_room()` for custom rules
4. **Connection Logic**: Override `_try_connect_room()` for special connections
5. **Room Selection**: Replace random selection with weighted or rule-based

## Testing

```
test_system.gd runs:
├── test_meta_cell()         - Cell creation, connections, duplication
├── test_meta_room()         - Room creation, cell access, connections
├── test_room_rotator()      - All 4 rotations, position/direction transforms
├── test_room_resources()    - Load and validate .tres files
└── test_dungeon_generator() - Full generation, placement, collision
```

All tests validate:
✓ Correct data structures
✓ Proper rotation logic
✓ Connection matching
✓ Collision detection
✓ Resource loading
✓ Full generation pipeline
