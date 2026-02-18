# Bug Report: T-Rooms Placed Without Required Connections

## Issue Summary
T-rooms are being placed even when not all required connections are satisfied. Investigation reveals **TWO CRITICAL BUGS**.

---

## Bug #1: `required_connections` Not Copied During Room Rotation ⚠️ CRITICAL

### Location
`scripts/room_rotator.gd` - Lines 17-50 in `rotate_room()` function

### The Problem
When a room is rotated (90°, 180°, 270°), the `required_connections` array is **NOT** copied to the rotated room instance. This means:

1. Template room has: `required_connections = [UP, LEFT, RIGHT]`
2. After rotation: `required_connections = []` (empty!)
3. Validation checks empty array and **always passes**

### Root Cause
```gdscript
# room_rotator.gd - Line 21
var rotated_room = MetaRoom.new()
rotated_room.room_name = room.room_name + "_rot" + str(rotation * 90)

# Only width, height, room_name are set
# required_connections is NEVER copied! ❌
```

Compare with the `clone()` function which also doesn't copy it:
```gdscript
# meta_room.gd - Lines 114-127
func clone() -> MetaRoom:
	var new_room = MetaRoom.new()
	new_room.width = width
	new_room.height = height
	new_room.room_name = room_name
	new_room.cells.clear()
	
	for cell in cells:
		if cell != null:
			new_room.cells.append(cell.clone())
		else:
			new_room.cells.append(null)
	
	return new_room  # ❌ required_connections NOT copied!
```

### How This Breaks Validation

Flow of the bug:
```
1. Template (t_room.tres)
   └─ required_connections = [LEFT, RIGHT, BOTTOM]
   
2. Walker tries to place room
   └─ Calls: RoomRotator.rotate_room(template, DEG_90)
   
3. rotate_room() creates NEW MetaRoom
   └─ rotated_room.required_connections = [] ← BUG! Not copied
   
4. _walker_try_place_room() creates placement with rotated_room
   └─ placement.room.required_connections = [] ← Empty!
   
5. Validation at line 319:
   └─ _validate_required_connections(satisfied, [])
   └─ Returns TRUE because empty array = no requirements!
   
6. Room is placed without checking actual requirements ❌
```

### Evidence in Code

**Line 312**: Room is rotated
```gdscript
var rotated_room = RoomRotator.rotate_room(template, rotation)
```

**Line 312-313**: PlacedRoom stores the rotated room
```gdscript
var placement = _try_connect_room(walker.current_room, conn_point, rotated_room, rotation, template)
```

**Line 319**: Validation uses `placement.room.required_connections`
```gdscript
if _validate_required_connections(satisfied, placement.room.required_connections):
```

But `placement.room` is the **rotated room** which has empty `required_connections`!

### Why Line 319 Should Use `template` Instead

The code SHOULD check the **original template's** required_connections, not the rotated room's:

```gdscript
# WRONG (current code):
if _validate_required_connections(satisfied, placement.room.required_connections):

# CORRECT (should be):
if _validate_required_connections(satisfied, template.required_connections):
```

---

## Bug #2: `required_connections` Not Set in `t_room.tres` ⚠️

### Location
`resources/rooms/t_room.tres` - Missing `required_connections` property

### The Problem
The T-room template file doesn't specify which connections are required:

```gdscript
# t_room.tres - Line 93
room_name = "T-Room"
# ❌ Missing: required_connections = Array[int]([3, 1, 2])
```

Compare with `t_room_test.tres` which correctly has:
```gdscript
# t_room_test.tres - Line 118
required_connections = Array[int]([0, 3, 1])  # UP=0, RIGHT=1, LEFT=3
```

### Impact
Even if Bug #1 is fixed, `t_room.tres` would still be placed incorrectly because it has no requirements.

### Required Connections for T-Room
A T-room has 3 exits and should require 3 connections. Looking at the cell layout:

```
t_room.tres structure (5x4 grid):
- Row 1 (y=1): Cell at x=0 has connection_left + connection_required
- Row 2 (y=2): Cell at x=4 has connection_right + connection_required  
- Row 3 (y=3): Cell at x=2 has connection_bottom + connection_required
```

So it should have:
```gdscript
required_connections = Array[int]([3, 1, 2])  # LEFT=3, RIGHT=1, BOTTOM=2
```

---

## Why the Validation Fails

### Current Flow (Broken)
```
1. template.required_connections = [LEFT, RIGHT, BOTTOM]
2. rotated_room = rotate_room(template, DEG_90)
3. rotated_room.required_connections = []  ← Lost!
4. placement.room = rotated_room
5. _validate_required_connections(satisfied, [])  ← Empty array!
6. Returns TRUE (no requirements to check)
7. Room placed incorrectly ❌
```

### Expected Flow (Fixed)
```
1. template.required_connections = [LEFT, RIGHT, BOTTOM]
2. rotated_room = rotate_room(template, DEG_90)
3. Use template.required_connections directly (not rotated_room's)
4. _validate_required_connections(satisfied, [LEFT, RIGHT, BOTTOM])
5. Check if satisfied array contains all 3 directions
6. Only place if all required connections are satisfied ✓
```

---

## How to Fix

### Fix #1: Use Original Template's `required_connections` (Recommended Quick Fix)

**File**: `scripts/dungeon_generator.gd`  
**Line**: 319

Change from:
```gdscript
if _validate_required_connections(satisfied, placement.room.required_connections):
```

To:
```gdscript
if _validate_required_connections(satisfied, template.required_connections):
```

**Why This Works:**
- `template` is the original unrotated room with correct `required_connections`
- `placement.room` is the rotated room which has lost this data
- The validation logic already handles direction comparison correctly
- The `satisfied` array is calculated from the rotated room's actual connections, so it will match the original template's requirements

**Note:** The directions don't need to be rotated because `_get_satisfied_connections()` checks the rotated room's actual connection layout. If a T-room template has [LEFT, RIGHT, BOTTOM] and is rotated 90°, those connections physically become [UP, LEFT, BOTTOM] in the rotated room, and `_get_satisfied_connections()` will return the directions based on where the connections actually are in the rotated room.

Wait, that's not right. Let me reconsider...

Actually, there's a subtlety here. The `required_connections` array specifies directions in the **original template's coordinate system**. When we rotate the room, those directions should also rotate. For example:
- Template has `required_connections = [LEFT, RIGHT, BOTTOM]`
- After 90° rotation, the physical connections are at [UP, LEFT, BOTTOM]
- But we're checking if `satisfied` (which contains the actual rotated directions) matches `required_connections` (original directions)

This is the real bug! We need to either:

**Option A:** Copy AND rotate the `required_connections` during rotation
**Option B:** Use the original template's `required_connections` but rotate them before validation

Let me check the actual logic more carefully...

Actually, looking at line 316:
```gdscript
var satisfied = _get_satisfied_connections(placement.position, placement.room)
```

The `satisfied` array is calculated from `placement.room` which is the **rotated room**. So `satisfied` contains directions in the rotated coordinate system.

But `required_connections` should also be in the rotated coordinate system to match!

### Fix #1 (Revised): Copy AND Rotate `required_connections` During Room Rotation

**File**: `scripts/room_rotator.gd`  
**Location**: After line 30

Add this code:
```gdscript
# Copy and rotate required_connections
rotated_room.required_connections.clear()
for direction in room.required_connections:
	var rotated_dir = rotate_direction(direction, rotation)
	rotated_room.required_connections.append(rotated_dir)
```

Full function should look like:
```gdscript
static func rotate_room(room: MetaRoom, rotation: Rotation) -> MetaRoom:
	if rotation == Rotation.DEG_0:
		return room.clone()
	
	var rotated_room = MetaRoom.new()
	rotated_room.room_name = room.room_name + "_rot" + str(rotation * 90)
	
	# Calculate new dimensions based on rotation
	if rotation == Rotation.DEG_90 or rotation == Rotation.DEG_270:
		rotated_room.width = room.height
		rotated_room.height = room.width
	else:
		rotated_room.width = room.width
		rotated_room.height = room.height
	
	# Copy and rotate required_connections  ← NEW!
	rotated_room.required_connections.clear()
	for direction in room.required_connections:
		var rotated_dir = rotate_direction(direction, rotation)
		rotated_room.required_connections.append(rotated_dir)
	
	# Initialize the rotated cells array
	rotated_room.cells.clear()
	for i in range(rotated_room.width * rotated_room.height):
		rotated_room.cells.append(null)
	
	# ... rest of function ...
```

**Also fix `clone()` to copy `required_connections`:**

**File**: `scripts/meta_room.gd`  
**Location**: Line 127 (before `return new_room`)

Add:
```gdscript
# Copy required_connections
new_room.required_connections = required_connections.duplicate()
```

### Fix #2: Add `required_connections` to `t_room.tres`

**File**: `resources/rooms/t_room.tres`  
**Location**: After line 93 (after `room_name = "T-Room"`)

Add:
```gdscript
required_connections = Array[int]([3, 1, 2])
```

This sets required connections to [LEFT=3, RIGHT=1, BOTTOM=2].

---

## Testing the Fix

After applying both fixes:

1. T-rooms should only be placed when all 3 required connections are satisfied
2. Rotated T-rooms should also respect their rotated required connections
3. Rooms without `required_connections` should continue working as before (backward compatible)

### Test Case 1: T-room with only 2 connections
- Should be **rejected** during placement
- Walker should try different template/rotation

### Test Case 2: T-room with all 3 connections  
- Should be **accepted** and placed

### Test Case 3: Regular corridor (no required_connections)
- Should work as before (no change)

---

## Summary

**Two bugs found:**

1. ⚠️ **CRITICAL**: `rotate_room()` doesn't copy or rotate `required_connections`
   - Rotated rooms have empty `required_connections = []`
   - Validation always passes (no requirements = always valid)
   - **Fix**: Copy and rotate `required_connections` in `rotate_room()`

2. ⚠️ **CONFIG**: `t_room.tres` missing `required_connections` property
   - Template doesn't specify which connections are required
   - Even with fix #1, this room wouldn't validate properly
   - **Fix**: Add `required_connections = Array[int]([3, 1, 2])`

**Root Cause**: The `required_connections` feature was added to the data model but the room rotation and cloning logic was never updated to handle it.

**Impact**: High - T-rooms and other multi-connection rooms can be placed incorrectly, creating invalid dungeon layouts.

**Difficulty**: Easy - Both fixes are simple additions to existing code.
