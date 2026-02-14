# MetaRoom Visual Editor - User Guide

## What is the MetaRoom Editor?

The MetaRoom Editor is a visual, grid-based editor for creating and modifying dungeon room templates. Instead of manually editing resource files, you can now use an intuitive interface directly in the Godot Inspector.

## Quick Overview

```
┌──────────────────────────────────────────────────────────────┐
│ MetaRoom Visual Editor                                       │
├──────────────────────────────────────────────────────────────┤
│ Room Name: [My Custom Room__________________________]       │
├──────────────────────────────────────────────────────────────┤
│ Room Dimensions                                              │
│ Width: [3▼] Height: [3▼] [Resize Room]                      │
├──────────────────────────────────────────────────────────────┤
│ Cell Type Brush                                              │
│ [BLOCKED] [FLOOR] [DOOR]                                     │
├──────────────────────────────────────────────────────────────┤
│ Connection Brush (toggle on/off)                             │
│ [UP] [RIGHT] [BOTTOM] [LEFT]                                 │
│ [Clear All Connections]                                      │
├──────────────────────────────────────────────────────────────┤
│ Room Grid (Click to paint cells)                            │
│ ┌────┬────┬────┐                                            │
│ │ ■  │ ·↑ │ ■  │   ■ = BLOCKED                              │
│ ├────┼────┼────┤   · = FLOOR                                │
│ │·←  │ ·  │·→  │   D = DOOR                                 │
│ ├────┼────┼────┤   ↑→↓← = Connections                       │
│ │ ■  │ ·↓ │ ■  │                                            │
│ └────┴────┴────┘                                            │
└──────────────────────────────────────────────────────────────┘
```

## How to Use

### 1. Opening the Editor

1. **Enable the Plugin First!**
   - Project > Project Settings > Plugins
   - Check "Enable" next to "MetaRoom Editor"
   - Close Project Settings

2. **Open a Room Resource**
   - Navigate to `resources/rooms/` in FileSystem
   - Click any `.tres` file (e.g., `cross_room.tres`)
   - The visual editor appears in the Inspector automatically

### 2. Editing Room Properties

**Room Name**
- Type directly in the text field
- Used to identify the room in the generator

**Room Dimensions**
- Adjust Width and Height spinboxes (1-20)
- Click "Resize Room" to apply changes
- Existing cells are preserved
- New cells default to FLOOR type

### 3. Painting Cells

**Step 1: Choose Cell Type**
- Click one of the cell type buttons:
  - **BLOCKED**: Walls, impassable (shown as ■)
  - **FLOOR**: Regular walkable floor (shown as ·)
  - **DOOR**: Special connection cells (shown as D)

**Step 2: Click Grid Cells**
- Click any cell in the grid to paint it
- The cell immediately updates with the selected type
- Colors change based on type:
  - Gray = BLOCKED
  - White = FLOOR
  - Blue = DOOR

### 4. Adding Connections

Connections define where rooms can connect to each other.

**Important Rules:**
- Only edge cells can have connections!
  - UP: only cells on top row (y=0)
  - RIGHT: only cells on right column (x=width-1)
  - BOTTOM: only cells on bottom row (y=height-1)
  - LEFT: only cells on left column (x=0)
- Connections show as arrows: ↑ ↓ ← →
- A cell can have multiple connections

**How to Add:**
1. Click a connection button (UP/RIGHT/BOTTOM/LEFT)
2. Click edge cells to toggle that connection
3. The arrow appears/disappears on the cell
4. Click different edge cells to toggle more

**Clear All:**
- Click "Clear All Connections" to remove all connections at once
- Useful when redesigning room layout

### 5. Example Workflow: Creating an L-Shaped Room

```
Goal: Create a 3x3 L-shaped corridor with connections

Step 1: Set dimensions to 3x3
Step 2: Paint BLOCKED cells in corners
  ┌─────┬─────┬─────┐
  │  ■  │  ·  │  ■  │
  ├─────┼─────┼─────┤
  │  ·  │  ·  │  ■  │
  ├─────┼─────┼─────┤
  │  ·  │  ·  │  ■  │
  └─────┴─────┴─────┘

Step 3: Add connections
  - Select LEFT, click cell(0,0) for left entrance
  - Select BOTTOM, click cell(1,2) for bottom exit
  ┌─────┬─────┬─────┐
  │·← ■ │  ·  │  ■  │
  ├─────┼─────┼─────┤
  │  ·  │  ·  │  ■  │
  ├─────┼─────┼─────┤
  │  ·  │ ·↓  │  ■  │
  └─────┴─────┴─────┘

Done! Room saved automatically.
```

## Tips & Tricks

### Design Tips
1. **Start Simple**: Begin with small rooms (3x3) to understand the system
2. **Test Often**: Run test_dungeon.tscn to see how your rooms work
3. **Multiple Connections**: Rooms with more connections are more versatile
4. **Edge Planning**: Plan your connections carefully - they determine room flow

### Editing Tips
1. **Undo**: Godot's Ctrl+Z works for resource changes
2. **Quick Toggle**: Click a connection button and paint multiple cells quickly
3. **Symmetry**: Use BLOCKED cells to create interesting shapes
4. **Preview**: The grid updates instantly as you work

### Common Patterns

**Hallway (2-way)**
```
┌─────┬─────┬─────┐
│·← ■ │  ·  │ ■·→ │
└─────┴─────┴─────┘
```

**T-Junction (3-way)**
```
┌─────┬─────┬─────┐
│  ■  │ ·↑  │  ■  │
├─────┼─────┼─────┤
│·←   │  ·  │ ·→  │
└─────┴─────┴─────┘
```

**Cross (4-way)**
```
┌─────┬─────┬─────┐
│  ■  │ ·↑  │  ■  │
├─────┼─────┼─────┤
│·←   │  ·  │ ·→  │
├─────┼─────┼─────┤
│  ■  │ ·↓  │  ■  │
└─────┴─────┴─────┘
```

**Dead End (1-way)**
```
┌─────┬─────┬─────┐
│ ■   │ ·↑  │  ■  │
├─────┼─────┼─────┤
│ ■   │  ·  │  ■  │
├─────┼─────┼─────┤
│ ■   │  ·  │  ■  │
└─────┴─────┴─────┘
```

## Troubleshooting

**Q: Editor not showing up?**
- Make sure the plugin is enabled in Project Settings > Plugins
- Restart Godot if needed
- Confirm you're viewing a MetaRoom resource (not MetaCell)

**Q: Grid not displaying or showing only a line?**
- This was fixed in the latest version
- Make sure you have the updated plugin files
- The grid should show 60x60 pixel buttons for each cell
- If still having issues, try disabling and re-enabling the plugin

**Q: Can't add connections to middle cells?**
- This is correct! Only edge cells can have connections to other rooms
- Middle cells are internal to the room

**Q: Changes not saving?**
- Changes auto-save to the resource
- Make sure you have a saved .tres file (not just "New Resource")
- Check file permissions

**Q: Grid looks wrong after resizing?**
- Try closing and reopening the resource
- The grid should match the width x height dimensions

**Q: Colors hard to see?**
- Adjust your Godot editor theme
- The colors adapt to your theme automatically

## Advanced Usage

### Creating Large Rooms
- Increase dimensions up to 20x20
- Useful for large chambers, boss rooms
- More cells = more design possibilities

### Asymmetric Rooms
- Use BLOCKED cells creatively
- Create L-shapes, T-shapes, S-shapes
- Non-rectangular rooms add variety

### Door Cells
- DOOR cells are optional
- Use them to mark special connection points
- Generator treats them like FLOOR currently
- Future feature: special door handling

### Multi-Room Design
- Create a set of themed rooms
- Ensure connections match across rooms
- Test different room combinations

## See Also

- `addons/meta_room_editor/README.md` - Technical plugin documentation
- `README.md` - Project overview
- `GETTING_STARTED.md` - Setup guide
- `DOCUMENTATION.md` - API reference

## Support

If you encounter issues or have suggestions:
1. Check the existing room templates for examples
2. Review the troubleshooting section
3. Test in the test_dungeon.tscn scene
4. Check the console for error messages
