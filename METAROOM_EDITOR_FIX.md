# MetaRoom Editor Grid Visualization Fix

## Issue Report
**Date:** 2026-02-14
**Problem:** Grid visualization not working - only showing "a little line" with no clickable buttons

## Technical Details

### Root Cause
The custom inspector property editor was not initializing properly because:
1. UI setup was done in `_ready()` method
2. When used as custom inspector control, `_ready()` fires before `meta_room` is assigned
3. Early return prevented UI creation
4. Result: Empty/minimal display with no interactive grid

### The Fix

#### Before (Broken)
```gdscript
# meta_room_editor_property.gd
func _ready() -> void:
    if not meta_room:
        return  # This always triggered!
    
    _setup_ui()
    _refresh_grid()
```

#### After (Fixed)
```gdscript
# meta_room_editor_property.gd
var _initialized: bool = false

func initialize() -> void:
    if _initialized:
        return
    
    if not meta_room:
        push_error("MetaRoom editor: Cannot initialize without meta_room")
        return
    
    _initialized = true
    _setup_ui()
    _refresh_grid()

# meta_room_inspector_plugin.gd
func _parse_begin(object: Object) -> void:
    if object is MetaRoom:
        var editor = preload("res://addons/meta_room_editor/meta_room_editor_property.gd").new()
        editor.meta_room = object
        editor.initialize()  # ← Call after assignment!
        add_custom_control(editor)
```

### Additional Improvements

1. **Grid Container Sizing:**
   ```gdscript
   grid_container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
   grid_container.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
   ```

2. **Button Sizing:**
   ```gdscript
   btn.custom_minimum_size = Vector2(60, 60)
   btn.size_flags_horizontal = Control.SIZE_FILL
   btn.size_flags_vertical = Control.SIZE_FILL
   ```

## Testing Checklist

When testing this fix in Godot:

- [ ] Enable MetaRoom Editor plugin
- [ ] Open any .tres file in resources/rooms/
- [ ] Verify grid displays with visible buttons (60x60 pixels each)
- [ ] Check that buttons show cell type symbols (■, ·, D)
- [ ] Test clicking buttons changes cell type
- [ ] Test toggling connections shows arrows
- [ ] Test resizing room refreshes grid correctly
- [ ] Verify all UI controls are visible and functional

## Expected Result

Users should now see:
- Full editor interface with all controls
- Grid with properly sized, clickable buttons
- Visual feedback (colors, symbols, arrows)
- Ability to paint cells and toggle connections
- Proper layout that doesn't collapse to a line

## Files Changed

1. `addons/meta_room_editor/meta_room_editor_property.gd`
   - Replaced `_ready()` with `initialize()` method
   - Added initialization guard
   - Added size flags for proper layout

2. `addons/meta_room_editor/meta_room_inspector_plugin.gd`
   - Added `initialize()` call after setting meta_room

3. Documentation updates:
   - `METAROOM_EDITOR_GUIDE.md`
   - `addons/meta_room_editor/README.md`

## Related Godot Concepts

### Custom Inspector Controls
When creating custom editor controls for the inspector:
1. Don't rely on `_ready()` for initialization
2. Properties are set AFTER node is added to tree
3. Use explicit initialization methods
4. Call initialization after all properties are set

### Size Flags
- `SIZE_SHRINK_BEGIN`: Don't expand, stay at minimum size
- `SIZE_FILL`: Expand to fill available space
- Important for proper layout in containers

## Prevention

To avoid similar issues in future custom editor controls:
1. Always use explicit initialization methods
2. Never assume properties are set before `_ready()`
3. Add initialization guards
4. Test in actual Godot editor, not just running scenes
5. Check that UI elements have proper size constraints

## References

- Godot EditorInspectorPlugin: https://docs.godotengine.org/en/stable/classes/class_editorinspectorplugin.html
- Custom Inspector Plugins: https://docs.godotengine.org/en/stable/tutorials/plugins/editor/inspector_plugins.html
- Container Size Flags: https://docs.godotengine.org/en/stable/classes/class_control.html#class-control-property-size-flags-horizontal
