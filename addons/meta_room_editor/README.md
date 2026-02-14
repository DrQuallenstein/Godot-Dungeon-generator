# MetaRoom Editor Plugin

## Overview
The MetaRoom Editor is a visual editor plugin for Godot 4.6 that makes creating and editing MetaRoom resources much easier. Instead of manually editing .tres files, you can now use a visual grid-based interface directly in the Godot inspector.

## Features

### Visual Grid Editor
- Interactive grid display showing all cells in the room
- Click cells to paint them with the selected cell type
- Visual indicators for connections (arrows)
- Color-coded cells based on type:
  - **Gray**: BLOCKED cells
  - **White**: FLOOR cells
  - **Blue**: DOOR cells

### Cell Type Brush
Three types of cells available:
- **BLOCKED**: Impassable cells (walls)
- **FLOOR**: Regular walkable floor
- **DOOR**: Connection points for room exits

### Connection Editor
- Toggle connections in 4 directions: UP, RIGHT, BOTTOM, LEFT
- Click a connection button to select it, then click cells to toggle that connection
- Visual arrows show active connections on each cell
- "Clear All Connections" button to remove all connections at once

### Room Dimensions
- Adjust room width and height (1-20 cells)
- "Resize Room" button to apply new dimensions
- Existing cells are preserved when resizing
- New cells are automatically created as FLOOR type

### Room Name
- Edit the room name directly in the inspector
- Changes are saved to the resource automatically

## Installation

1. The plugin is located in `addons/meta_room_editor/`
2. In Godot, go to **Project > Project Settings > Plugins**
3. Find "MetaRoom Editor" and check the "Enable" checkbox
4. The plugin is now active!

## Usage

### Creating a New MetaRoom

1. In the FileSystem panel, right-click in `resources/rooms/`
2. Select **New Resource...**
3. Choose **MetaRoom** from the list
4. Save the resource with a descriptive name (e.g., `my_room.tres`)
5. Click on the resource to open it in the Inspector
6. The visual editor will appear automatically!

### Editing an Existing MetaRoom

1. Click on any .tres file in `resources/rooms/`
2. The visual editor appears in the Inspector
3. Make your changes using the tools described above
4. Changes are saved automatically to the resource

### Workflow Example

1. **Set room dimensions**: Adjust width/height, click "Resize Room"
2. **Choose cell type**: Click BLOCKED, FLOOR, or DOOR button
3. **Paint cells**: Click grid cells to apply the selected type
4. **Add connections**: 
   - Click a connection button (UP/RIGHT/BOTTOM/LEFT)
   - Click edge cells to toggle connections
   - Connections only work on edge cells!
5. **Test your room**: Save and use it in the dungeon generator

## Tips

- **Edge Connections**: Only cells on the room's edges can have connections to the outside
  - UP: cells on y=0
  - RIGHT: cells on x=width-1
  - BOTTOM: cells on y=height-1
  - LEFT: cells on x=0

- **Multiple Connections**: A cell can have connections in multiple directions

- **Save Often**: While changes are auto-saved to the resource, it's good practice to save your scene/project regularly

- **Test Generation**: After creating a room, test it in the test_dungeon scene to see how it works in the dungeon

## Troubleshooting

**Editor not showing:**
- Make sure the plugin is enabled in Project Settings > Plugins
- Restart Godot if needed
- Check that you're viewing a MetaRoom resource (not MetaCell)

**Grid not displaying or showing only a thin line:**
- This issue has been fixed in the latest version
- Update to the latest plugin version
- The grid should display 60x60 pixel buttons for each cell
- If still having issues, disable and re-enable the plugin in Project Settings

**Changes not saving:**
- Make sure you're editing a saved resource file (.tres)
- Check file permissions
- Try saving the project (Ctrl+S)

**Grid looks wrong:**
- Try resizing the room to refresh the grid
- Close and reopen the resource
- Restart the editor if issues persist

## Technical Details

The plugin consists of:
- `plugin.gd`: Main EditorPlugin registration
- `meta_room_inspector_plugin.gd`: Inspector integration
- `meta_room_editor_property.gd`: Visual editor UI and logic
- `plugin.cfg`: Plugin configuration

The editor integrates with Godot's inspector system, appearing automatically when a MetaRoom resource is selected. All changes are applied directly to the resource and trigger proper change notifications for Godot's save system.
