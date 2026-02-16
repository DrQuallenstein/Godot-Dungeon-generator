# Bug Fix: Regeneration State Persistence Issues

## Problem Statement

User reported two critical issues after regenerating dungeons:

1. **Walkers not showing in walker panel**: After pressing 'R' or 'S' to regenerate, the walker selection panel didn't update to show the new walkers
2. **Normal walks shown as dotted lines**: Some normal walker movements were displayed as dotted lines (teleports) when they shouldn't be
3. **Root cause hypothesis**: "I think because the index of the run before was saved"

## Root Cause Analysis

### Issue 1: Walker Panel Not Updating

**The Bug:**
```gdscript
func _update_walker_selection_ui_if_needed() -> void:
    if walker_checkboxes.is_empty() and not generator.active_walkers.is_empty():
        _update_walker_selection_ui()
    elif walker_checkboxes.size() != generator.active_walkers.size():
        _update_walker_selection_ui()
```

**Why It Failed:**
1. First generation creates walkers (e.g., Walker 0, Walker 1, Walker 2)
2. UI creates 3 checkboxes, stored in `walker_checkboxes`
3. User regenerates dungeon
4. New walkers created (e.g., Walker 3, Walker 4, Walker 5)
5. Walker count is still 3, so condition at line 257 is FALSE
6. UI doesn't update → old checkboxes remain, showing old walker IDs
7. User sees "Walker 0, 1, 2" but actual walkers are 3, 4, 5!

### Issue 2: Incorrect Teleport Visualization

**The Bug:**
```gdscript
func _on_walker_moved(walker, from_pos, to_pos, is_teleport):
    if not walker_teleports.has(walker.walker_id):
        walker_teleports[walker.walker_id] = []
    walker_teleports[walker.walker_id].append(is_teleport)  # ← Keeps appending!
```

**Why It Failed:**
1. First generation: Walker 0 moves [false, false, true, false] (3rd move is teleport)
2. `walker_teleports[0] = [false, false, true, false]`
3. User regenerates
4. New Walker 0 created (different walker, same ID)
5. Walker 0 moves [false, false, false, false] (no teleports this time)
6. But `walker_teleports[0]` already exists! New moves append:
7. `walker_teleports[0] = [false, false, true, false, false, false, false, false]`
8. When drawing paths, index 2 (3rd segment) reads `true` → dotted line!
9. But in THIS generation, that's a normal walk!

**Data Contamination Example:**
```
Generation 1:
- Walker 0: path length 4, teleport at index 2
- walker_teleports[0] = [false, false, true, false]

Regeneration (no clearing):
- Walker 0: path length 4, no teleports
- walker_teleports[0].append(...) continues from old array
- walker_teleports[0] = [false, false, true, false, false, false, false, false]
- Drawing code reads index 2 → true → dotted line on normal walk!
```

### Why _initialize_visible_walker_paths() Was Removed

Looking at the code comment:
```gdscript
# Don't call _initialize_visible_walker_paths() here - it clears walker_teleports!
# The function is already called in _ready() to set up empty data structures.
# Calling it here would erase all teleport data collected during generation.
```

**The History:**
1. Originally, `_initialize_visible_walker_paths()` was called after generation
2. This cleared `walker_teleports` (line 168), which WAS good for cleaning
3. But it also cleared it AFTER generation completed, losing the data
4. It was removed to preserve teleport data after generation
5. Side effect: Now nothing clears old data BEFORE new generation!

## Solution

### Key Insight
We need to clear old data BEFORE generation starts, not after it completes!

### Implementation

**New Function: `_clear_walker_state_for_regeneration()`**
```gdscript
func _clear_walker_state_for_regeneration() -> void:
    # Clear teleport tracking (prevents old teleport data persisting)
    walker_teleports.clear()
    
    # Clear walker positions (old positions no longer valid)
    walker_positions.clear()
    
    # Clear old walker checkboxes from UI
    var checkbox_container = get_node_or_null("../CanvasLayer/WalkerSelectionPanel/MarginContainer/VBoxContainer/WalkerCheckboxContainer")
    if checkbox_container != null:
        for child in checkbox_container.get_children():
            child.queue_free()
    walker_checkboxes.clear()
    
    # Keep visible_walker_paths intact - these are user preferences for which paths to show
    # The user's visibility settings should persist across regenerations
```

**Modified: `_generate_and_visualize()`**
```gdscript
func _generate_and_visualize() -> void:
    print("\n=== Generating Dungeon ===")
    
    # Clear walker state from previous generation BEFORE starting new generation
    _clear_walker_state_for_regeneration()
    
    var success = await generator.generate()
    if success:
        print("Generation successful! Rooms placed: ", generator.placed_rooms.size())
        # Force UI rebuild to show new walkers (don't use conditional update)
        _update_walker_selection_ui()
        queue_redraw()
```

### What Gets Cleared vs Preserved

**Cleared (Old Generation Data):**
- ✅ `walker_teleports` - Teleport flags from previous generation
- ✅ `walker_positions` - Walker positions from previous generation
- ✅ `walker_checkboxes` - Dictionary of checkbox references
- ✅ UI checkbox elements - Visual elements in the panel

**Preserved (User Preferences & Configuration):**
- ✅ `visible_walker_paths` - User's visibility settings (which paths to show)
- ✅ Export variables - User configuration (line width, colors, etc.)
- ✅ Camera position/zoom - User's view state

**Why Preserve `visible_walker_paths`?**
```gdscript
# Example: User hides Walker 2's path
visible_walker_paths = {0: true, 1: true, 2: false}

# After regeneration, new Walker 2 is created
# We want to respect user's preference - keep path hidden
visible_walker_paths = {0: true, 1: true, 2: false}  # Preserved!
```

## Before vs After

### Before Fix

**Regeneration Flow:**
```
1. User presses R/S
2. _generate_and_visualize() called
3. generator.generate() creates new dungeon
   - Old walker_teleports data still exists
   - New walker moves APPEND to old arrays
4. _update_walker_selection_ui_if_needed() called
   - Same walker count → no update
5. Result:
   ✗ UI shows old walker IDs
   ✗ Teleport data is mixture of old + new
   ✗ Normal walks shown as dotted lines
```

### After Fix

**Regeneration Flow:**
```
1. User presses R/S
2. _generate_and_visualize() called
3. _clear_walker_state_for_regeneration() called
   - walker_teleports.clear()
   - walker_positions.clear()
   - walker_checkboxes.clear()
   - Old UI elements queue_free()
4. generator.generate() creates new dungeon
   - Clean slate for walker data
   - New walker moves start fresh
5. _update_walker_selection_ui() called (unconditional)
   - Builds new checkboxes for new walkers
6. Result:
   ✓ UI shows correct new walker IDs
   ✓ Teleport data only from current generation
   ✓ Dotted lines only on actual teleports
```

## Testing Scenarios

### Test 1: Basic Regeneration
```
1. Generate dungeon (R or S)
2. Note walker panel shows walkers (e.g., 0, 1, 2)
3. Note which paths have dotted lines
4. Regenerate (R)
5. ✓ Walker panel updates with new walkers
6. ✓ Dotted lines only on teleports in new generation
```

### Test 2: Multiple Regenerations
```
1. Generate (S) - 3 walkers, some teleports
2. Generate (S) - 2 walkers, different teleports
3. Generate (S) - 4 walkers, no teleports
4. Generate (S) - 3 walkers, many teleports
5. ✓ Each generation shows correct walkers in panel
6. ✓ Each generation shows correct teleport visualization
7. ✓ No "ghost" data from previous generations
```

### Test 3: User Preferences Preserved
```
1. Generate dungeon
2. Hide Walker 1's path (press '1')
3. Hide Walker 2's path (press '2')
4. Regenerate (R)
5. ✓ New Walker 1's path is hidden
6. ✓ New Walker 2's path is hidden
7. ✓ User preferences preserved across regenerations
```

### Test 4: Edge Cases
```
1. Generate with 2 walkers
2. Regenerate with 5 walkers
3. ✓ UI updates to show all 5 walkers
4. Regenerate with 1 walker
5. ✓ UI updates to show only 1 walker
6. Regenerate with 2 walkers again
7. ✓ UI updates correctly
```

## Performance Impact

**Clearing Operations:**
- `dictionary.clear()`: O(n) where n = number of entries
- `queue_free()` on children: O(m) where m = number of checkboxes
- Typically n ≤ 10 walkers, m ≤ 10 checkboxes
- Total: < 1ms, negligible impact

**UI Rebuild:**
- Already happens on first generation
- Now also happens on regeneration
- Cost: Create ~10 UI nodes per walker
- Total: < 5ms, acceptable

## Related Issues Fixed

This fix also resolves potential issues with:
1. Walker position cache becoming stale
2. Memory leaks from accumulating old UI elements
3. Confusion when walker IDs don't match displayed IDs
4. Debugging difficulties due to mixed generation data

## Code Comments Added

Added clear documentation in code:
```gdscript
## Clear walker state before regeneration to prevent old data from persisting
func _clear_walker_state_for_regeneration() -> void:
    # Clear teleport tracking (prevents old teleport data from showing on new generation)
    # Clear walker positions (old positions no longer valid)
    # Clear old walker checkboxes from UI
    # Keep visible_walker_paths intact - these are user preferences
```

## Conclusion

This fix ensures clean state between dungeon generations by:
1. Clearing all generation-specific data before new generation
2. Preserving user preferences (visibility settings)
3. Forcing UI rebuild to reflect new walkers
4. Preventing data contamination between generations

The user's hypothesis was correct: "the index of the run before was saved" - specifically, the teleport flags were persisting and mixing with new generation data.
