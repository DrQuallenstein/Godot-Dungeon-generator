# T-Room Test Template Guide

## Overview
The `t_room_test.tres` template is a 5x5 T-shaped room designed specifically for testing the atomic placement feature of the dungeon generator.

## File Location
```
resources/rooms/t_room_test.tres
```

## Room Specifications

### Dimensions
- **Width:** 5 cells
- **Height:** 5 cells
- **Total cells:** 25

### Room Shape (T-shaped)
```
B B D B B  <- Row 0: Door UP at center (col 2)
B F F F B  <- Row 1: Floor interior
D F F F D  <- Row 2: Door LEFT (col 0) and RIGHT (col 4)
B F F F B  <- Row 3: Floor interior
B B B B B  <- Row 4: Solid wall (no exit)
```

**Legend:**
- `B` = BLOCKED cell (walls, cell_type = 0)
- `F` = FLOOR cell (walkable, cell_type = 1)
- `D` = DOOR cell (connection point, cell_type = 2)

### Connection Points

The room has exactly **3 exit points**:

1. **UP (Direction 0):** Position (2, 0) - center of top edge
2. **LEFT (Direction 3):** Position (0, 2) - left edge middle
3. **RIGHT (Direction 1):** Position (4, 2) - right edge middle

**No BOTTOM exit:** The bottom row is completely blocked.

### Required Connections

```gdscript
required_connections = [0, 3, 1]  # UP, LEFT, RIGHT
```

This means:
- The room **must** connect to other rooms via UP, LEFT, and RIGHT doors
- All three connections are mandatory for valid placement
- The atomic placement system should reject placements that don't satisfy all three connections

## Usage in Testing

### Loading the Template
```gdscript
var t_room = load("res://resources/rooms/t_room_test.tres") as MetaRoom
```

### Test Scenarios

#### 1. Valid Placement
A valid placement occurs when:
- There's an adjacent room to connect at UP (row -1)
- There's an adjacent room to connect at LEFT (column -1)
- There's an adjacent room to connect at RIGHT (column +1)
- All three connections can be satisfied simultaneously

#### 2. Invalid Placement (Should be rejected)
Invalid placements include:
- Only 1 or 2 of the 3 required connections available
- Any placement where BOTTOM connection is expected (room has no bottom door)
- Positions where walls would overlap with existing rooms

### Verification Code Example
```gdscript
# Check if room loaded correctly
assert(t_room.width == 5 and t_room.height == 5)
assert(t_room.required_connections.size() == 3)
assert(0 in t_room.required_connections)  # UP
assert(1 in t_room.required_connections)  # RIGHT
assert(3 in t_room.required_connections)  # LEFT
assert(not 2 in t_room.required_connections)  # No BOTTOM

# Get connection points
var connections = t_room.get_connection_points()
assert(connections.size() == 3)
```

## Why This Template is Ideal for Testing

1. **Clear T-Shape:** Easy to visually verify in the dungeon
2. **3 Required Connections:** Tests the atomic placement constraint logic thoroughly
3. **Asymmetric Design:** The missing bottom exit makes it easy to detect rotation errors
4. **Moderate Size:** 5x5 is large enough to be realistic but small enough to debug easily
5. **Simple Interior:** 9 floor cells in a connected pattern for pathfinding tests

## Integration with Atomic Placement

The atomic placement system should:
1. Check each position in the dungeon grid
2. For each position, verify all 3 required connections (UP, LEFT, RIGHT) can be satisfied
3. Only place the room if ALL required connections are met
4. Update the dungeon grid atomically (all-or-nothing operation)

## Related Files
- `scripts/meta_room.gd` - MetaRoom class definition
- `scripts/meta_cell.gd` - MetaCell and Direction enum
- `test_atomic_placement.gd` - Test script using this template
