# Bug Investigation: T-Rooms Placed Without Required Connections

## Bug Found! ⚠️

Investigation revealed **TWO CRITICAL BUGS** in the atomic multi-room placement feature:

### Quick Links
- 📋 **[BUG_SUMMARY.md](BUG_SUMMARY.md)** - Quick reference (start here!)
- 📊 **[BUG_VISUAL.md](BUG_VISUAL.md)** - Visual diagrams and flow charts
- 📝 **[BUG_REPORT.md](BUG_REPORT.md)** - Detailed technical analysis

---

## The Problem

T-rooms are being placed even when not all required connections are satisfied.

**Root Cause:** The `required_connections` property is lost during room rotation.

---

## Bug #1: Lost `required_connections` During Rotation

**Location:** `scripts/room_rotator.gd` - `rotate_room()` function

**Issue:** When rotating a room, the `required_connections` array is not copied to the new rotated room instance.

**Result:** 
```gdscript
template.required_connections = [LEFT, RIGHT, BOTTOM]  // Original
rotated_room.required_connections = []                 // After rotation ❌
```

**Impact:** Validation always passes because empty array = no requirements

---

## Bug #2: Missing `required_connections` in `t_room.tres`

**Location:** `resources/rooms/t_room.tres`

**Issue:** The T-room template file doesn't have the `required_connections` property set.

**Compare:**
- ❌ `t_room.tres` - Missing `required_connections`
- ✅ `t_room_test.tres` - Has `required_connections = Array[int]([0, 3, 1])`

---

## How to Fix

### Fix #1: Copy and Rotate `required_connections`

**File:** `scripts/room_rotator.gd` (after line 30)

```gdscript
# Copy and rotate required_connections
rotated_room.required_connections.clear()
for direction in room.required_connections:
    var rotated_dir = rotate_direction(direction, rotation)
    rotated_room.required_connections.append(rotated_dir)
```

**Also fix:** `scripts/meta_room.gd` - `clone()` function (line 127)

```gdscript
# Copy required_connections
new_room.required_connections = required_connections.duplicate()
```

### Fix #2: Add `required_connections` to `t_room.tres`

**File:** `resources/rooms/t_room.tres` (after line 93)

```gdscript
required_connections = Array[int]([3, 1, 2])
```

---

## Investigation Process

1. ✅ Confirmed `t_room.tres` exists
2. ✅ Found it's missing `required_connections` property
3. ✅ Reviewed validation logic in `dungeon_generator.gd`
4. ✅ Traced through `_get_satisfied_connections()` - Working correctly
5. ✅ Found room rotation loses `required_connections`
6. ✅ Identified both bugs and their interactions

---

## Key Findings

### The Validation Logic is Correct ✓

The `_validate_required_connections()` function works as designed:
- Returns `true` if `required` array is empty (backward compatible)
- Returns `false` if any required direction is missing from `satisfied`

### The Bug is in Data Propagation ✗

The problem is that `required_connections` is not properly copied during:
1. Room rotation (`RoomRotator.rotate_room()`)
2. Room cloning (`MetaRoom.clone()`)

### Direction Checking is Correct ✓

The `_get_satisfied_connections()` function correctly:
- Checks all 4 directions
- Validates connections are on correct edges
- Checks for adjacent walkable cells
- Handles rotated rooms properly

---

## Why the Bug is Subtle

The bug is hard to spot because:

1. The validation function itself is correct
2. The connection detection is working
3. The bug only manifests when rooms are rotated
4. Non-rotated rooms (DEG_0) work fine because `clone()` is called

The issue is a **data copying oversight** in the rotation logic, not a logical error in the validation.

---

## Testing Validation

After fixing both bugs, test with:

```gdscript
# Test Case 1: T-room with only 2 connections
# Expected: Placement rejected, walker tries different rotation/template

# Test Case 2: T-room with all 3 connections satisfied
# Expected: Placement accepted

# Test Case 3: Regular corridor (no required_connections)
# Expected: Works as before (backward compatible)
```

---

## Files Modified (for fix)

1. ✏️ `scripts/room_rotator.gd` - Add `required_connections` rotation
2. ✏️ `scripts/meta_room.gd` - Fix `clone()` to copy `required_connections`
3. ✏️ `resources/rooms/t_room.tres` - Add `required_connections` property

---

## Documentation Files

Created during investigation:
- `BUG_SUMMARY.md` - Quick reference and fix guide
- `BUG_VISUAL.md` - Visual diagrams and examples
- `BUG_REPORT.md` - Detailed technical analysis
- `README_BUG_INVESTIGATION.md` - This file

---

## Next Steps

1. Apply fixes to the 3 files listed above
2. Test T-room placement in dungeon generation
3. Verify rotated rooms have correct `required_connections`
4. Confirm validation rejects invalid placements
5. Ensure backward compatibility (rooms without requirements still work)

---

## Related Documentation

- [ATOMIC_PLACEMENT_IMPLEMENTATION.md](ATOMIC_PLACEMENT_IMPLEMENTATION.md) - Original feature implementation
- [T_ROOM_TEST_GUIDE.md](T_ROOM_TEST_GUIDE.md) - Testing guide for T-rooms
- [VERIFICATION_SUMMARY.md](VERIFICATION_SUMMARY.md) - Feature verification
