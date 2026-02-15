# Mouse Position Display Feature

This document describes the mouse position display feature that shows the meta cell grid coordinates under the current mouse pointer.

## Overview

A real-time label displays the grid coordinates of the meta cell currently under the mouse cursor. This is useful for:
- Understanding the dungeon's coordinate system
- Debugging room placement
- Identifying specific cell locations
- Navigating the generated dungeon

## Implementation

### UI Component

**Location**: Bottom-right corner of the screen

**Label Details**:
- Text format: `Cell: (x, y)`
- Shows `-` when no dungeon is generated
- White text with black shadow for readability
- Right-aligned
- Font size: 14px

### Coordinate Conversion

The feature converts mouse position through three coordinate spaces:

1. **Screen Space** → Mouse position on the viewport
2. **World Space** → Position in the 2D game world (accounts for camera zoom/pan)
3. **Grid Space** → Integer grid coordinates of meta cells

```gdscript
# Screen to World (using Camera2D)
var mouse_world_pos = camera.get_global_mouse_position()

# World to Grid
var bounds = generator.get_dungeon_bounds()
var offset = -Vector2(bounds.position) * cell_size + Vector2(50, 50)
var grid_pos = (mouse_world_pos - offset) / cell_size
var grid_pos_int = Vector2i(int(floor(grid_pos.x)), int(floor(grid_pos.y)))
```

### Update Frequency

The position updates every frame via the `_process()` function, providing smooth real-time tracking as the mouse moves.

## Usage

Simply move your mouse over the dungeon visualization. The bottom-right corner will display the grid coordinates under your cursor.

**Example outputs**:
- `Cell: -` - No dungeon generated yet
- `Cell: (0, 0)` - Mouse over the origin cell
- `Cell: (15, -8)` - Mouse over cell at x=15, y=-8

## Technical Details

### Files Modified

1. **scenes/test_dungeon.tscn**
   - Added `MousePositionLabel` node
   - Anchored to bottom-right corner
   - Configured styling and text properties

2. **scripts/dungeon_visualizer.gd**
   - Added `mouse_position_label` reference variable
   - Added `camera` reference variable
   - Added `_process()` function for continuous updates
   - Added `_update_mouse_position_label()` calculation function

### Coordinate System

The dungeon uses a grid-based coordinate system:
- Each meta cell is `cell_size` pixels (default: 32px)
- Origin (0, 0) is relative to the dungeon bounds
- Negative coordinates are possible
- Drawing offset of (50, 50) pixels for margin

### Performance

- **Update Rate**: Every frame (~60 FPS)
- **Overhead**: Minimal - simple arithmetic calculations
- **Optimization**: Uses cached dungeon bounds
- **Impact**: Negligible on performance

### Edge Cases Handled

1. **No Dungeon Generated**: Shows `Cell: -`
2. **Missing Camera**: Gracefully skips update
3. **Missing Label**: Gracefully skips update
4. **Empty Dungeon**: Shows `Cell: -`

## Integration with Existing Features

The mouse position display works seamlessly with:
- Camera zoom (zooming in/out)
- Camera panning (dragging the view)
- Dungeon regeneration
- Step-by-step visualization
- All existing keyboard shortcuts

## Code Structure

```gdscript
# Variables
var mouse_position_label: Label
var camera: Camera2D

# Initialization
func _ready():
    camera = get_node_or_null("../Camera2D")
    mouse_position_label = get_node_or_null("../CanvasLayer/MousePositionLabel")

# Continuous Update
func _process(_delta: float):
    _update_mouse_position_label()

# Calculation
func _update_mouse_position_label():
    # 1. Get mouse in world space
    var mouse_world_pos = camera.get_global_mouse_position()
    
    # 2. Convert to grid coordinates
    var grid_pos = (mouse_world_pos - offset) / cell_size
    
    # 3. Update label
    mouse_position_label.text = "Cell: (%d, %d)" % [grid_pos_int.x, grid_pos_int.y]
```

## Future Enhancements (Optional)

Potential improvements:
- Show additional cell information (room ID, cell type)
- Highlight the cell under the cursor
- Show room boundaries
- Display world coordinates alongside grid coordinates
- Toggle visibility with keyboard shortcut
- Customizable label position

## Testing

Verified functionality:
- ✅ Label displays correct coordinates
- ✅ Updates smoothly as mouse moves
- ✅ Accurate with camera zoom at different levels
- ✅ Accurate with camera pan in different positions
- ✅ Handles dungeon regeneration correctly
- ✅ No performance impact
- ✅ Graceful handling of edge cases

## Related Features

- Camera controls (zoom, pan)
- Dungeon visualization
- Cell drawing system
- Walker visualization

## Conclusion

The mouse position display feature provides an intuitive way to understand the dungeon's coordinate system and navigate the generated content. It's implemented efficiently with minimal overhead and integrates seamlessly with existing features.
