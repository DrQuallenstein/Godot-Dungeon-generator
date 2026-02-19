# Fix: T-Rooms Always Trigger Atomic Placement

## Problem 1: T-Rooms with Unfilled Required Connections

User report: "Die T-Räume haben immer noch erforderliche Verbindungen die keinen Raum haben"

### Root Cause

**OLD Logic:**
```gdscript
func _should_use_atomic_placement(room, conn_point):
    return room.is_connector_piece() and not conn_point.is_required
```

**Problem Scenario:**
1. Another connector (e.g., I-room) is being placed
2. Tries to fill its required connections atomically
3. Chooses T-room as filler for required connection
4. `conn_point.is_required = true` (part of parent atomic op)
5. `_should_use_atomic_placement` returns FALSE
6. T-room placed WITHOUT atomic filling
7. **Result:** T-room with unfilled exits ❌

### Solution

**NEW Logic:**
```gdscript
func _should_use_atomic_placement(room, conn_point):
    if not room.is_connector_piece():
        return false  # Not a connector
    
    var required_count = room.get_required_connection_points().size()
    
    # T-rooms (3+ required) ALWAYS need atomic placement
    if required_count >= 3:
        return true  # Regardless of conn_point.is_required!
    
    # I/L-rooms (2 required) only need atomic at normal connections
    return not conn_point.is_required
```

### Key Change

| Room Type | Required | At Normal Conn | At Required Conn |
|-----------|----------|---------------|------------------|
| **T-Room** | 3 | Atomic ✓ | Atomic ✓ (NEW!) |
| **I-Room** | 2 | Atomic ✓ | No atomic (same) |
| **L-Room** | 2 | Atomic ✓ | No atomic (same) |

**T-rooms now trigger atomic placement EVERYWHERE!**

## Scenarios

### Scenario 1: T-Room at Normal Connection

```
Walker places T-room at normal connection:

Check:
  - is_connector_piece() = TRUE
  - required_count = 3
  - Check: 3 >= 3 → TRUE

Result:
  - Atomic placement triggered
  - Fills all 3 required connections
  - Success only if ALL 3 filled
  → T-room complete or not placed ✓
```

### Scenario 2: T-Room as Filler (NEW BEHAVIOR!)

```
I-room filling required connection, chooses T-room:

OLD:
  - conn_point.is_required = TRUE
  - _should_use_atomic_placement → FALSE
  - T-room placed WITHOUT atomic
  - Result: T-room with unfilled exits ❌

NEW:
  - is_connector_piece() = TRUE
  - required_count = 3
  - Check: 3 >= 3 → TRUE (ignores conn_point!)
  - Atomic placement triggered
  - Tries to fill all 3 T-room exits
  
  If successful:
    - T-room complete with 3 doors ✓
  
  If fails:
    - T-room not placed
    - Try next template
    - Prevents incomplete T-rooms ✓
```

### Scenario 3: I-Room as Filler (UNCHANGED)

```
Another connector filling required connection, chooses I-room:

Check:
  - is_connector_piece() = TRUE
  - required_count = 2
  - Check: 2 < 3 → Go to next condition
  - conn_point.is_required = TRUE
  - return not TRUE → FALSE

Result:
  - No atomic placement
  - I-room placed as filler
  - Can have 1 or 2 doors (flexible)
  - Same behavior as before ✓
```

## Benefits

### ✅ T-Rooms Always Complete

- Trigger atomic placement everywhere
- All 3 exits filled or placement fails
- No partial T-rooms
- "Jeder Ausgang des T ist connected" ✓

### ✅ I/L-Rooms Remain Flexible

- Still flexible when used as fillers
- Can work with 1 or 2 connections
- No change to existing behavior

### ✅ Prevents Incomplete Connectors

- T-rooms (≥3 req) must be complete
- Quality over quantity
- Better user experience

## Trade-offs

### ⚠️ T-Rooms as Fillers May Fail More Often

**Reason:**
- T-rooms need all 3 exits fillable
- In tight spaces, may not find space for all 3
- Will reject T-room and try next template

**Impact:**
- Fewer T-rooms placed overall (possible)
- But ALL placed T-rooms are complete
- Better than many incomplete T-rooms

**Mitigation:**
- Template prioritization: Non-connectors first
- Gives preference to simpler rooms as fillers
- T-rooms mainly placed by walkers at normal connections

### ✅ Acceptable Trade-off

**Before:**
- More T-rooms placed
- Many incomplete (1 or 2 of 3 doors)
- User complaint: "haben immer noch erforderliche Verbindungen die keinen Raum haben"

**After:**
- Fewer T-rooms (possible)
- All complete (all 3 doors)
- User satisfaction: T-rooms properly connected

## Problem 2: Isolated Rooms

User report: "Außerdem werden einfach Räume in die Wildnis gesetzt ohne Verbindung zu irgendwas"

### Partial Solution

This fix helps by ensuring T-rooms are properly connected through atomic placement.

### Remaining Investigation

Possible causes of isolation:
1. Rooms placed without proper door verification
2. `_try_connect_room` succeeds but no door created
3. Connection matching issues

**Note:** Current `_try_connect_room` logic:
- Finds matching connection directions
- Aligns cells to overlap
- `_merge_overlapping_cells` creates doors between BLOCKED cells
- Should prevent isolation in most cases

**Further testing needed** to determine if additional fixes required.

## Implementation

### Code Location
- File: `scripts/dungeon_generator.gd`
- Function: `_should_use_atomic_placement()`
- Lines: ~731-747

### Key Code
```gdscript
# Get number of required connections
var required_count = room.get_required_connection_points().size()

# T-rooms and multi-connection rooms (3+) ALWAYS need atomic placement
# This ensures all exits are filled regardless of where the room is placed
if required_count >= 3:
    return true
```

## Testing

### Test File
- `test_t_room_always_atomic.gd` - Scenarios and validation

### Validation
- Python validation confirms correct logic
- T-rooms (≥3 required) always return true
- I/L-rooms (2 required) conditional on connection type
- Comments updated to reflect new behavior

## Expected Results

### User Experience

**Before:**
- T-rooms with unfilled exits
- Complaint: "haben immer noch erforderliche Verbindungen die keinen Raum haben"

**After:**
- T-rooms always complete (all exits connected)
- May be fewer T-rooms, but all proper
- User satisfaction ✓

### Dungeon Generation

- T-rooms: Guaranteed complete when placed
- I/L-rooms: Unchanged behavior (flexible)
- Overall: More coherent, proper-looking dungeons

## Status

**✅ IMPLEMENTED**

T-rooms now always trigger atomic placement, ensuring all exits are connected regardless of placement context.
