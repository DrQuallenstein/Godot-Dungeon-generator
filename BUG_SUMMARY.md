# Bug Summary: T-Rooms Placed Without Required Connections

## TL;DR

**TWO BUGS FOUND** that cause T-rooms to be placed even when not all required connections are satisfied:

1. **`required_connections` not copied during room rotation** → Rotated rooms have empty requirements
2. **`t_room.tres` missing `required_connections` property** → Template has no requirements

Both must be fixed for proper validation.

---

## Bug #1: Lost `required_connections` During Rotation ⚠️ CRITICAL

### What's Wrong
`RoomRotator.rotate_room()` creates a new `MetaRoom` but doesn't copy the `required_connections` array.

**Result:** All rotated rooms have `required_connections = []` (empty)  
**Impact:** Validation always passes because empty array = no requirements

### Where
- **File**: `scripts/room_rotator.gd`
- **Function**: `rotate_room()` (lines 17-50)
- **Also affects**: `meta_room.gd` - `clone()` function (lines 114-127)

### How to Fix

#### Fix in `room_rotator.gd` (after line 30):
```gdscript
# Copy and rotate required_connections
rotated_room.required_connections.clear()
for direction in room.required_connections:
    var rotated_dir = rotate_direction(direction, rotation)
    rotated_room.required_connections.append(rotated_dir)
```

#### Fix in `meta_room.gd` (before line 127):
```gdscript
# Copy required_connections
new_room.required_connections = required_connections.duplicate()
```

---

## Bug #2: Missing `required_connections` in `t_room.tres` ⚠️

### What's Wrong
The `t_room.tres` file doesn't have the `required_connections` property set.

**Compare:**
- `t_room.tres`: No `required_connections` ❌
- `t_room_test.tres`: Has `required_connections = Array[int]([0, 3, 1])` ✓

### Where
- **File**: `resources/rooms/t_room.tres`
- **Line**: 93 (after `room_name = "T-Room"`)

### How to Fix

Add this line:
```gdscript
required_connections = Array[int]([3, 1, 2])
```

This sets: LEFT=3, RIGHT=1, BOTTOM=2 (matching the cell connections in the template)

---

## Why This Matters

### Current Behavior (Broken)
```
1. Template has required_connections = [LEFT, RIGHT, BOTTOM]
2. rotate_room() creates new room → required_connections = []
3. Validation checks [] → Always passes ❌
4. T-room placed with only 1 or 2 connections (invalid!)
```

### Expected Behavior (Fixed)
```
1. Template has required_connections = [LEFT, RIGHT, BOTTOM]
2. rotate_room() copies and rotates → required_connections = [UP, BOTTOM, RIGHT]
3. Validation checks [UP, BOTTOM, RIGHT] → Only passes if all 3 satisfied
4. T-room only placed when all 3 connections exist ✓
```

---

## Testing After Fix

1. **T-room with 2 connections**: Should be rejected
2. **T-room with 3 connections**: Should be accepted
3. **Regular corridors (no requirements)**: Should work as before

---

## Files to Change

1. `scripts/room_rotator.gd` - Add required_connections rotation
2. `scripts/meta_room.gd` - Fix clone() to copy required_connections
3. `resources/rooms/t_room.tres` - Add required_connections property

---

## Related Files

- **Investigation**: `BUG_REPORT.md` (detailed analysis)
- **Visual Guide**: `BUG_VISUAL.md` (diagrams and examples)
- **This File**: `BUG_SUMMARY.md` (quick reference)
