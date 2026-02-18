# Bug Fix #2: Connection Rooms as Starting Room

## Problem Report
User reported: "Mh don't seemed fixed. Still there are L-Rooms that have only on Room. T-Rooms I don't see at all"

Despite the previous fix to validation logic, the issue persisted because connection rooms could still appear with unfulfilled required connections.

## Root Cause Discovery

The previous fix correctly validated connection rooms DURING placement, but there was a critical oversight:

**Connection rooms could be selected as the FIRST room in the dungeon!**

### The Issue:

In `generate()` at line 154-162:
```gdscript
# Find a suitable starting room (one with connections)
var start_room = _get_random_room_with_connections()
if start_room == null:
    push_error("DungeonGenerator: No rooms with connections found")
    return false

# Place the first room at origin (clone it to avoid modifying the template)
var first_room_clone = start_room.clone()
var first_placement = PlacedRoom.new(first_room_clone, Vector2i.ZERO, RoomRotator.Rotation.DEG_0, start_room)
_place_room(first_placement)  # ← NO VALIDATION!
```

The function `_get_random_room_with_connections()` would select ANY room with connections, including:
- L-corridors (2 required connections)
- T-rooms (3 required connections)
- I-corridors (2 required connections)

The first room is placed **without any validation**, so:
- An L-room as the first room → 0 of 2 required connections fulfilled ✗
- A T-room as the first room → 0 of 3 required connections fulfilled ✗
- An I-room as the first room → 0 of 2 required connections fulfilled ✗

This explains why the user still saw L-rooms with only one connection satisfied!

## Why T-Rooms Don't Appear

T-rooms have 3 required connections. For a T-room to be placed after the first room, it would need:
1. To connect to an existing room via one required connection
2. Have TWO other normal rooms already adjacent to its other two required connections

This is extremely rare to happen naturally in dungeon generation, especially early in the generation process. So T-rooms almost never appear because the conditions are too strict.

However, if a T-room was selected as the FIRST room (which could happen), it would be placed with 0 connections fulfilled, which is wrong.

## The Fix

### Modified `_get_random_room_with_connections()`:

**Before (INCORRECT):**
```gdscript
func _get_random_room_with_connections() -> MetaRoom:
    var valid_rooms: Array[MetaRoom] = []
    
    for template in room_templates:
        if template.has_connection_points():
            valid_rooms.append(template)  # ← Includes connection rooms!
    
    if valid_rooms.is_empty():
        return null
    
    return valid_rooms[randi() % valid_rooms.size()]
```

**After (CORRECT):**
```gdscript
func _get_random_room_with_connections() -> MetaRoom:
    var valid_rooms: Array[MetaRoom] = []
    
    for template in room_templates:
        # Only include rooms that have connections AND are not connection rooms
        # Connection rooms should not be used as the first room since their
        # required connections cannot be fulfilled at the start
        if template.has_connection_points() and not template.is_connection_room():
            valid_rooms.append(template)
    
    if valid_rooms.is_empty():
        return null
    
    return valid_rooms[randi() % valid_rooms.size()]
```

### What Changed:
- Added check: `and not template.is_connection_room()`
- Now ONLY normal rooms with connections can be the starting room
- Connection rooms must be placed via the normal placement flow with validation

## Impact

### L-Rooms:
- **Before**: Could appear as first room with 0 connections
- **After**: Only placed when both required connections are fulfilled
- **Result**: All L-rooms properly connected

### T-Rooms:
- **Before**: Could appear as first room with 0 connections, or rarely with validation
- **After**: Only placed when all 3 required connections are fulfilled
- **Result**: T-rooms will be very rare, but when they appear, all 3 connections are valid

### I-Rooms (Straight Corridors):
- **Before**: Could appear as first room with 0 connections
- **After**: Only placed when both required connections are fulfilled
- **Result**: All I-rooms properly connected

### Normal Rooms:
- No change in placement logic
- Always valid as starting room
- Can be placed anywhere as before

## Why This Makes Sense

Connection rooms (L, T, I) represent corridors and connectors. They should:
1. Always connect to existing rooms
2. Never be "dead-ends" with unfulfilled connections
3. Only appear when they can fulfill their purpose of connecting multiple paths

Normal rooms represent actual game spaces (rooms, halls, etc.). They should:
1. Be valid as starting points
2. Can have unused connections (for future expansion)
3. Form the bulk of the dungeon structure

## Expected Behavior After Fix

1. **First room**: Always a normal room with connections
2. **L-rooms**: Appear when connecting two perpendicular paths (both ends fulfilled)
3. **T-rooms**: Very rare, only when three paths meet (all three ends fulfilled)
4. **I-rooms**: Appear when connecting two opposite paths (both ends fulfilled)
5. **No more "floating" connection rooms**: All connection rooms properly connected

## Testing

To verify the fix:
1. Run test_dungeon.tscn multiple times
2. Check the first room - should never be an L, T, or I shape
3. Check any L-rooms - both connections should have rooms
4. Check any T-rooms (if they appear) - all three connections should have rooms
5. Check any I-rooms - both ends should have rooms

## Files Modified

- `scripts/dungeon_generator.gd`: Modified `_get_random_room_with_connections()` to exclude connection rooms
- `BUGFIX_SUMMARY_2.md`: This document explaining the second bug fix
