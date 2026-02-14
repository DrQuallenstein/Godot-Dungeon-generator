# Camera Controls Documentation

## Overview

The dungeon map now includes full pan and zoom functionality, allowing you to easily navigate and inspect generated dungeons at any scale.

## Camera Controls

### Zooming

**Mouse Wheel**
- Scroll up: Zoom in
- Scroll down: Zoom out
- **Zoom behavior**: The point under your mouse cursor stays fixed as you zoom, making it easy to zoom into specific areas

**Keyboard**
- `+` or `=` key: Zoom in (centered on screen)
- `-` key: Zoom out (centered on screen)
- `0` key: Reset camera to default position and zoom level

**Zoom Limits**
- Minimum zoom: 0.1x (very far out)
- Maximum zoom: 5.0x (very close)
- Default zoom: 1.0x

### Panning

**Middle Mouse Button**
- Click and hold middle mouse button
- Drag to move the camera
- Release to stop panning

**Right Mouse Button** (Alternative)
- Click and hold right mouse button
- Drag to move the camera
- Release to stop panning
- *Note: This can be disabled in the camera controller if needed*

**Pan Behavior**
- Pan movement is smooth and follows your mouse
- Pan speed automatically accounts for zoom level
- Works intuitively at any zoom level

### Reset

**Keyboard**
- `0` key: Instantly reset camera to center position (640, 360) with 1.0x zoom

## Usage Examples

### Inspecting a Large Dungeon
1. Use mouse wheel to zoom out and see the entire dungeon
2. Click and drag with middle mouse to pan around
3. Zoom back in to specific areas of interest

### Examining Room Details
1. Zoom in using mouse wheel over the area you want to inspect
2. Pan around with middle mouse button to view different parts
3. Use `0` key to reset when done

### Quick Navigation
1. Zoom out to see overall structure
2. Click and drag to move to area of interest
3. Zoom in for details
4. Press `0` to reset for next generation

## Technical Details

### Implementation

The camera controller is implemented in `scripts/camera_controller.gd` and extends Godot's `Camera2D` node.

**Key Features:**
- Uses `_unhandled_input()` to process mouse and keyboard events
- Properly marks events as handled to prevent conflicts
- Zoom calculation maintains mouse cursor position
- Pan movement converts screen space to world space based on zoom

**Configurable Properties:**
```gdscript
@export var min_zoom: float = 0.1           # Minimum zoom level
@export var max_zoom: float = 5.0           # Maximum zoom level
@export var zoom_speed: float = 0.1         # Zoom increment per scroll
@export var pan_speed: float = 1.0          # Pan speed multiplier
@export var enable_right_button_pan: bool = true  # Enable right-click panning
```

### Integration

The camera controller is attached to the Camera2D node in `test_dungeon.tscn`:

```gdscript
[node name="Camera2D" type="Camera2D" parent="."]
position = Vector2(640, 360)
script = ExtResource("camera_controller.gd")
```

### Event Handling

The controller handles the following input events:
- `InputEventMouseButton`: Mouse wheel and button presses
- `InputEventMouseMotion`: Mouse movement during panning
- `InputEventKey`: Keyboard shortcuts

All handled events call `get_viewport().set_input_as_handled()` to prevent event propagation.

## Customization

### Adjusting Zoom Limits

Edit the camera controller properties in the scene or script:

```gdscript
# Allow more extreme zoom levels
min_zoom = 0.05  # Zoom out further
max_zoom = 10.0  # Zoom in closer
```

### Changing Zoom Speed

```gdscript
# Make zoom more sensitive
zoom_speed = 0.2  # Larger steps per scroll

# Make zoom less sensitive  
zoom_speed = 0.05  # Smaller steps per scroll
```

### Disabling Right-Click Panning

```gdscript
# Only use middle mouse button
enable_right_button_pan = false
```

### Changing Default Camera Position

Edit the reset position in `_reset_camera()`:

```gdscript
func _reset_camera() -> void:
    position = Vector2(800, 600)  # Custom center
    zoom = Vector2(1.0, 1.0)
```

## Tips and Tricks

### Smooth Navigation
- Use mouse wheel for quick zoom adjustments
- Combine zoom and pan for smooth navigation
- Use `0` key as a quick "home" button

### Precision Work
- Zoom in close for detailed cell inspection
- Use keyboard zoom for gradual, centered adjustments
- Pan with middle mouse for fine positioning

### Large Dungeons
- Start zoomed out to see the whole structure
- Use pan to survey different areas
- Zoom in to specific rooms for details

## Troubleshooting

### Camera Not Responding
- Ensure the Camera2D node has the camera_controller.gd script attached
- Check that the Camera2D is enabled (enabled property is true)
- Verify no other scripts are consuming input events

### Zoom Not Working
- Check zoom limits haven't been set too narrow
- Ensure min_zoom < max_zoom
- Verify camera is not at min/max zoom limit

### Pan Feels Wrong
- Adjust pan_speed property
- Check that zoom level is reasonable (not too extreme)
- Ensure camera position hasn't moved out of bounds

### Reset Not Working
- Verify `0` key binding (not numpad 0 unless using KEY_KP_0)
- Check _reset_camera() function has correct default values

## Future Enhancements

Potential improvements:
- **Smooth zoom animation**: Tween zoom changes for smoother feel
- **Pan boundaries**: Limit camera movement to dungeon bounds
- **Follow room**: Auto-center on newly placed rooms
- **Mini-map**: Small overview map in corner
- **Zoom indicator**: Visual display of current zoom level
- **Touch support**: Pinch-to-zoom and drag gestures for mobile
- **Camera presets**: Save and recall favorite camera positions
- **Auto-frame**: Automatically frame the entire dungeon

## Related Files

- `scripts/camera_controller.gd` - Camera control implementation
- `scenes/test_dungeon.tscn` - Test scene with camera
- `scripts/dungeon_visualizer.gd` - Dungeon rendering
