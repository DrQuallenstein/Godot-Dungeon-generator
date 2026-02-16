# Castle Dungeon Tileset

This directory contains the pixel art tileset for rendering inner castle dungeons.

## Files

### castle_dungeon_tileset.png
- **Size**: 512x256 pixels (16x8 tiles)
- **Tile Size**: 32x32 pixels
- **Format**: PNG with transparency
- **Total Tiles**: 128

## Tile Layout

The tileset is organized as follows:

### Row 0 (Basic Tiles)
- **(0,0)**: Floor tile (light)
- **(1,0)**: Floor tile (dark variant)
- **(2,0)**: Full wall (solid stone)
- **(3,0)**: Wall top (lighter top edge)
- **(4,0)**: Wall bottom (with floor transition)
- **(5,0)**: Door tile

### Row 1 (Corner Tiles)
**Inner Corners** (wall with floor cutout):
- **(0,1)**: Top-left inner corner
- **(1,1)**: Top-right inner corner
- **(2,1)**: Bottom-left inner corner
- **(3,1)**: Bottom-right inner corner

**Outer Corners** (floor with wall corner):
- **(4,1)**: Top-left outer corner
- **(5,1)**: Top-right outer corner
- **(6,1)**: Bottom-left outer corner
- **(7,1)**: Bottom-right outer corner

### Row 2 (Side Walls)
- **(0,2)**: Wall on left side (floor on right)
- **(1,2)**: Wall on right side (floor on left)

## Color Palette

The tileset uses a dark medieval castle interior palette:

- **Wall Dark**: RGB(60, 55, 50) - Dark stone
- **Wall Mid**: RGB(85, 80, 75) - Mid stone
- **Wall Light**: RGB(110, 105, 100) - Light stone highlights
- **Floor Dark**: RGB(70, 65, 60) - Dark floor
- **Floor Mid**: RGB(90, 85, 80) - Mid floor
- **Floor Light**: RGB(100, 95, 90) - Light floor
- **Door Wood**: RGB(80, 50, 30) - Dark wood
- **Door Metal**: RGB(100, 100, 110) - Metal trim
- **Black**: RGB(0, 0, 0) - Outlines

## Usage

The tileset is used by:
1. **TileSet Resource**: `resources/castle_dungeon_tileset.tres`
2. **TileMapLayer**: In `scenes/test_dungeon.tscn`
3. **Mapper Script**: `scripts/dungeon_tile_mapper.gd`

The mapper script automatically selects the appropriate tile based on:
- Cell type (floor, wall, door)
- Adjacent cell configuration
- Wall transitions and corners

## Regenerating the Tileset

If you need to regenerate or modify the tileset, the Python script used to create it is at:
`/tmp/create_castle_tileset.py` (during development)

To create a custom tileset:
1. Modify the colors and patterns in the Python script
2. Run the script to generate a new PNG
3. Replace `castle_dungeon_tileset.png` with your new image
4. The TileSet resource should automatically pick up the changes

## Design Philosophy

The tileset follows these design principles:
- **Low color count**: Simple palette for authentic pixel art look
- **Clear readability**: High contrast between floors and walls
- **Modular design**: Tiles work together seamlessly
- **Medieval aesthetic**: Stone texture with brick patterns
- **Size efficiency**: Only essential tiles included to minimize memory
