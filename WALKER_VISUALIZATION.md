# Walker Visualization and Compactness Features

This document describes the new walker visualization and dungeon compactness features added to the dungeon generator.

## Overview

The dungeon generator now includes real-time visualization of the multi-walker algorithm in action, along with improvements to generate more compact dungeons with less straight, boring corridors.

## Walker Visualization Features

### Visual Components

1. **Walker Markers**
   - Each walker is displayed as a colored circle at its current position
   - Walker ID is shown inside the circle
   - Each walker has a unique color based on its ID (using golden ratio for color distribution)
   - Active walkers pulse and move in real-time

2. **Walker Paths**
   - Shows the complete path history of each walker
   - Path segments fade from older (transparent) to newer (more opaque)
   - Helps visualize the exploration pattern and identify coverage gaps
   - Different colored paths for each walker

3. **Live Statistics**
   - Displays active walker count vs total walkers
   - Shows current compactness bias setting
   - Updates in real-time during generation

### Keyboard Controls

**Generation Controls:**
- `R` - Regenerate dungeon with the same seed
- `S` - Generate with a new random seed

**Visualization Controls:**
- `W` - Toggle walker visualization on/off
- `P` - Toggle path visualization on/off
- `V` - Toggle step-by-step visualization mode (watch generation happen)
- `C` - Increase compactness bias by 0.1
- `X` - Decrease compactness bias by 0.1

## Compactness Algorithm

### Problem

The original algorithm could generate dungeons that were:
- Too spread out with long empty corridors
- Very linear (10+ rooms in a straight line before a turn)
- Dead ends far from the main dungeon

### Solution

The new compactness system includes:

1. **Directional Biasing**
   - Connections are sorted by distance to the dungeon's center of mass
   - Walkers prefer placing rooms closer to the center
   - Controlled by `compactness_bias` parameter (0.0 to 1.0)

2. **Smart Walker Teleportation**
   - When a walker gets stuck, it teleports to a room with open connections
   - With compactness bias, prefers rooms closer to the dungeon center
   - Reduces long-distance jumps that create sprawling layouts

3. **Center of Mass Tracking**
   - Dungeon center is dynamically calculated as the average position of all placed rooms
   - Used to guide both room placement and walker teleportation

### Configuration

The compactness feature is controlled by the `compactness_bias` export variable in `DungeonGenerator`:

```gdscript
@export_range(0.0, 1.0) var compactness_bias: float = 0.3
```

- `0.0` - No bias, fully random (original behavior)
- `0.3` - Moderate bias (default, good balance)
- `0.5` - Strong bias (tighter dungeons)
- `1.0` - Maximum bias (very compact, may reduce variety)

### How It Works

1. **Connection Sorting**
   - When placing a room, available connections are evaluated
   - Each connection's distance to dungeon center is calculated
   - Connections are sorted: closer to center = higher priority
   - Random override: `(1 - compactness_bias)` chance to ignore sorting

2. **Walker Respawn Location**
   - When walkers die or teleport, they choose a spawn location
   - With compactness bias, they prefer rooms closer to center
   - Still prioritizes rooms with unsatisfied required connections

## Visualization Signals

The generator now emits three new signals for visualization:

```gdscript
## Emitted when a room is placed
signal room_placed(placement: PlacedRoom, walker: Walker)

## Emitted when a walker moves or spawns
signal walker_moved(walker: Walker, from_pos: Vector2i, to_pos: Vector2i)

## Emitted at each generation step
signal generation_step(iteration: int, total_cells: int)
```

These signals allow the visualizer (or any other system) to:
- Track walker movements in real-time
- Update the display incrementally
- Implement step-by-step debugging
- Create animations of the generation process

## Step-by-Step Mode

When `enable_visualization` is true and `visualization_step_delay > 0`, the generator pauses between each room placement:

```gdscript
@export var enable_visualization: bool = false
@export var visualization_step_delay: float = 0.1
```

This allows you to:
- Watch the algorithm work in slow motion
- Debug placement issues
- Understand the multi-walker behavior
- Create video demonstrations

## Usage Example

```gdscript
# Configure for compact dungeons with visualization
var generator = DungeonGenerator.new()
generator.compactness_bias = 0.5  # Strong compactness
generator.enable_visualization = true  # Watch it happen
generator.visualization_step_delay = 0.05  # 50ms per step

# Connect to signals
generator.room_placed.connect(func(placement, walker):
    print("Walker %d placed room at %v" % [walker.walker_id, placement.position])
)

generator.walker_moved.connect(func(walker, from_pos, to_pos):
    print("Walker %d moved from %v to %v" % [walker.walker_id, from_pos, to_pos])
)

# Generate
generator.generate()
```

## Benefits

### Debugging
- **Visual Feedback**: See exactly what the algorithm is doing
- **Path Analysis**: Identify why certain patterns emerge
- **Problem Detection**: Spot stuck walkers or inefficient exploration

### Algorithm Refinement
- **Compactness Control**: Adjust the bias to match your game's needs
- **Pattern Understanding**: Learn how walkers interact and create dungeons
- **Parameter Tuning**: See the effect of different settings in real-time

### Player Experience
- **Less Backtracking**: Compact dungeons reduce empty walking
- **More Variety**: Shorter corridors mean more interesting intersections
- **Better Pacing**: Dead ends are closer to main paths

## Performance Notes

- Walker visualization adds minimal overhead when disabled
- Path tracking uses arrays, so very long paths (1000+ rooms) may impact memory
- Step-by-step mode significantly slows generation (by design)
- Compactness calculations add ~5-10% overhead but are worth it for quality

## Future Enhancements

Possible improvements:
1. **Heat Maps**: Show areas of high walker density
2. **Connection Analysis**: Highlight bottlenecks and loops
3. **Replay Mode**: Save and replay generation sequences
4. **Walker Strategies**: Different behaviors (aggressive, cautious, explorer)
5. **Adaptive Compactness**: Dynamically adjust bias based on dungeon shape

## Related Files

- `scripts/dungeon_generator.gd` - Core generator with compactness logic
- `scripts/dungeon_visualizer.gd` - Visualization implementation
- `scenes/test_dungeon.tscn` - Test scene with all controls
- `README.md` - Main project documentation
