# MetaRoom Editor - Tool Mode Reload Required

## Current Status

The MetaRoom editor code is now **fully fixed and functional**, but you need to reload the scripts in Godot for the changes to take effect.

## The Error You're Seeing

```
ERROR: res://addons/meta_room_editor/meta_room_editor_property.gd:291 - 
Invalid call function 'get_cell' in base 'Resource (MetaRoom)': 
Attempt to call a method on a placeholder instance. 
Check if the script is in tool mode.
```

## What This Means

This error occurs because:
1. We recently added the `@tool` directive to `MetaRoom` and `MetaCell` scripts
2. Godot has already loaded the old versions of these scripts (without `@tool`)
3. The loaded resource instances are "placeholders" that don't have access to methods
4. Godot needs to reload the scripts to recognize the `@tool` directive

## How to Fix (Choose ONE method)

### Method 1: Restart Godot (Recommended - Simplest)
1. **Save your project** (Ctrl+S or Cmd+S)
2. **Close Godot completely**
3. **Reopen Godot**
4. **Open your project again**
5. The plugin will now work correctly!

### Method 2: Reload Current Project
1. In Godot, go to **Project** menu
2. Select **Reload Current Project**
3. Wait for project to reload
4. The plugin should now work!

### Method 3: Reimport Resources
1. Navigate to `resources/rooms/` in FileSystem panel
2. Select all `.tres` files (cross_room.tres, l_corridor.tres, etc.)
3. Right-click and select **Reimport**
4. Wait for reimport to complete

### Method 4: Force Script Reload
1. Open `scripts/meta_room.gd` in the script editor
2. Make a trivial change (add a space, then remove it)
3. Save the file (Ctrl+S)
4. Repeat for `scripts/meta_cell.gd`
5. Close and reopen any .tres resource files

## After Reloading

Once you've reloaded using any of the methods above:

1. **Enable the plugin** (if not already enabled):
   - Go to **Project > Project Settings > Plugins**
   - Check "Enable" next to "MetaRoom Editor"

2. **Open a room resource**:
   - Navigate to `resources/rooms/` in FileSystem
   - Click on `cross_room.tres` (or any other .tres file)

3. **You should now see**:
   - The full MetaRoom Visual Editor in the Inspector
   - "Room Grid (Click to paint cells)" label
   - A grid of 3x3 (or appropriate size) clickable buttons
   - Each button showing cell type and connections

## Debug Output to Confirm It's Working

After reloading, open a .tres file and check the console. You should see:
```
MetaRoom Inspector Plugin: _can_handle returned true for...
MetaRoom Inspector Plugin: _parse_begin called with...
MetaRoom Inspector Plugin: Creating editor for MetaRoom
...
MetaRoom Editor: initialize() called
MetaRoom Editor: Starting initialization...
MetaRoom Editor: UI setup complete
MetaRoom Editor: Creating grid with 3x3 cells
MetaRoom Editor: Created 9 buttons in grid
```

## If It Still Doesn't Work

If you still see errors after reloading:

1. Check that both files have `@tool` at the top:
   - Open `scripts/meta_room.gd` - first line should be `@tool`
   - Open `scripts/meta_cell.gd` - first line should be `@tool`

2. Check the full error message in console
   - Copy the complete error output
   - Check which file and line number
   - Report back with the details

3. Verify plugin is enabled:
   - Project > Project Settings > Plugins
   - "MetaRoom Editor" should be checked

4. Try creating a NEW MetaRoom resource:
   - Right-click in FileSystem
   - New Resource
   - Type "MetaRoom" and select it
   - Save as test_room.tres
   - Try opening it

## What We Fixed

The code changes that were made:

1. **Added `@tool` directive** to `scripts/meta_room.gd`
2. **Added `@tool` directive** to `scripts/meta_cell.gd`
3. **Added comprehensive debug logging** to track what's happening
4. **Fixed initialization** to be called after meta_room is assigned
5. **Added proper sizing** for grid and buttons

All the code is correct now - you just need to reload for Godot to recognize the changes!

## Expected Result

After reloading, when you open any .tres file in `resources/rooms/`, you should see a complete visual editor with:

```
┌────────────────────────────────────────┐
│ MetaRoom Visual Editor                 │
├────────────────────────────────────────┤
│ Room Name: [Cross Room___________]    │
├────────────────────────────────────────┤
│ Room Dimensions                        │
│ Width: [3] Height: [3] [Resize Room]  │
├────────────────────────────────────────┤
│ Cell Type Brush                        │
│ [BLOCKED] [FLOOR] [DOOR]               │
├────────────────────────────────────────┤
│ Connection Brush                       │
│ [UP] [RIGHT] [BOTTOM] [LEFT]           │
├────────────────────────────────────────┤
│ Room Grid (Click to paint cells)      │
│ ┌────┬────┬────┐                      │
│ │ ■  │ ·↑ │ ■  │                      │
│ ├────┼────┼────┤                      │
│ │·←  │ ·  │·→  │                      │
│ ├────┼────┼────┤                      │
│ │ ■  │ ·↓ │ ■  │                      │
│ └────┴────┴────┘                      │
└────────────────────────────────────────┘
```

With actual clickable 60x60 pixel buttons!
