# Visual Bug Explanation

## Bug Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│  TEMPLATE (t_room.tres)                                     │
│  ┌────────────────────────────────────────────┐             │
│  │ room_name = "T-Room"                       │             │
│  │ required_connections = [LEFT, RIGHT, BOTTOM] │         │
│  │ (cells with connections at those edges)    │             │
│  └────────────────────────────────────────────┘             │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ Walker tries to place
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  ROTATION (RoomRotator.rotate_room(template, DEG_90))      │
│  ┌────────────────────────────────────────────┐             │
│  │ Creates NEW MetaRoom instance              │             │
│  │ Copies: width, height, room_name, cells    │             │
│  │ ❌ DOES NOT copy: required_connections     │             │
│  │                                            │             │
│  │ Result: rotated_room.required_connections = [] (empty!) │
│  └────────────────────────────────────────────┘             │
└─────────────────────────────────────────────────────────────┘
                          │
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  PLACEMENT (_walker_try_place_room)                        │
│  ┌────────────────────────────────────────────┐             │
│  │ placement.room = rotated_room              │             │
│  │ placement.room.required_connections = []   │  ← BUG!    │
│  └────────────────────────────────────────────┘             │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ Line 319
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  VALIDATION (_validate_required_connections)               │
│  ┌────────────────────────────────────────────┐             │
│  │ Input: satisfied = [UP, LEFT]             │             │
│  │        required = []  ← Empty array!       │             │
│  │                                            │             │
│  │ Logic: if required.is_empty(): return true │             │
│  │                                            │             │
│  │ Result: ✓ VALIDATION PASSES               │             │
│  └────────────────────────────────────────────┘             │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
                    ❌ ROOM PLACED
              (even without all connections!)
```

---

## What Should Happen

```
┌─────────────────────────────────────────────────────────────┐
│  TEMPLATE (t_room.tres)                                     │
│  required_connections = [LEFT, RIGHT, BOTTOM]               │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ 90° rotation
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  ROTATED ROOM                                               │
│  ┌────────────────────────────────────────────┐             │
│  │ Rotate directions: LEFT→UP, RIGHT→DOWN,    │             │
│  │                    BOTTOM→RIGHT             │             │
│  │                                            │             │
│  │ required_connections = [UP, BOTTOM, RIGHT] │  ← Fixed!  │
│  └────────────────────────────────────────────┘             │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  VALIDATION                                                 │
│  ┌────────────────────────────────────────────┐             │
│  │ satisfied = [UP, RIGHT]                    │             │
│  │ required = [UP, BOTTOM, RIGHT]             │             │
│  │                                            │             │
│  │ Check: Is BOTTOM in satisfied? NO!         │             │
│  │ Result: ❌ VALIDATION FAILS                │             │
│  └────────────────────────────────────────────┘             │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
                  ⏭ TRY NEXT ROTATION
```

---

## Direction Rotation Logic

When rotating a room by 90° clockwise:
```
Original Direction  →  Rotated Direction
──────────────────────────────────────
UP (0)              →  RIGHT (1)
RIGHT (1)           →  BOTTOM (2)  
BOTTOM (2)          →  LEFT (3)
LEFT (3)            →  UP (0)
```

Formula: `new_direction = (old_direction + rotation_steps) % 4`

Where `rotation_steps`:
- DEG_0 = 0 steps
- DEG_90 = 1 step
- DEG_180 = 2 steps
- DEG_270 = 3 steps

---

## Example: T-Room Rotation

### Original T-Room Template
```
     UP (required)
        │
   ┌────┴────┐
LEFT│         │RIGHT (required)
   │    T    │
   └─────────┘
        │
     BOTTOM (required)

required_connections = [UP, LEFT, RIGHT]
```

### After 90° Clockwise Rotation
```
     UP (now required - was LEFT)
        │
   ┌────┴────┐
LEFT│         │RIGHT (now required - was UP)
   │    T    │
   └─────────┘
        │
     BOTTOM (now required - was RIGHT)

required_connections = [UP, RIGHT, BOTTOM]  ← Should rotate!
```

**Current Bug:** After rotation, `required_connections = []` (empty!)

**Fix:** After rotation, `required_connections = [UP, RIGHT, BOTTOM]` (rotated!)

---

## Code Flow Comparison

### Current (Broken) Code

```gdscript
# Line 311-312: Rotate room
var rotated_room = RoomRotator.rotate_room(template, rotation)
var placement = _try_connect_room(...)

# rotated_room.required_connections = []  ← BUG!

# Line 316: Get satisfied connections from rotated room
var satisfied = _get_satisfied_connections(placement.position, placement.room)
# satisfied = [UP, LEFT] (based on rotated room's actual connections)

# Line 319: Validate using placement.room (the rotated room)
if _validate_required_connections(satisfied, placement.room.required_connections):
#                                            ↑
#                                   This is [] (empty!)
    # Validation always passes ❌
```

### Fixed Code

```gdscript
# room_rotator.gd - rotate_room()
var rotated_room = MetaRoom.new()
# ... set dimensions ...

# NEW: Copy and rotate required_connections
rotated_room.required_connections.clear()
for direction in room.required_connections:
    var rotated_dir = rotate_direction(direction, rotation)
    rotated_room.required_connections.append(rotated_dir)

# rotated_room.required_connections = [UP, RIGHT, BOTTOM]  ← Fixed!

# ... rest of rotation ...
```

Now validation works correctly:
```gdscript
# satisfied = [UP, LEFT]
# required = [UP, RIGHT, BOTTOM]
# Check: UP ✓, RIGHT ❌, BOTTOM ❌
# Result: Validation fails, try next rotation ✓
```

---

## Why Both Bugs Are Critical

### Bug #1: Lost required_connections During Rotation
- **Symptom**: Rooms always validate (empty requirements)
- **Impact**: High - affects ALL rotated multi-connection rooms
- **Affected Rooms**: T-rooms, cross rooms, L-corridors with requirements

### Bug #2: Missing required_connections in t_room.tres
- **Symptom**: No validation even after fixing Bug #1
- **Impact**: Medium - only affects this specific room template
- **Affected Rooms**: Only t_room.tres (not t_room_test.tres)

Both must be fixed for proper validation!
