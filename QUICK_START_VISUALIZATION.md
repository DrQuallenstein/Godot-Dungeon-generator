# Quick Start Guide - Walker Visualization

This is a quick reference for using the new walker visualization and compactness features.

## TL;DR - Just Want to See It Work?

1. Open the project in Godot 4.6
2. Press **F5** to run
3. **Watch the colored circles** - those are walkers placing rooms!
4. Press **P** to see their paths
5. Press **C** a few times, then **S** to see tighter dungeons

## Visual Legend

### What You'll See

```
🔵 Walker 0 (Blue circle with "0" inside)
🟢 Walker 1 (Green circle with "1" inside)  
🟣 Walker 2 (Purple circle with "2" inside)

--- Walker path trail (faded lines showing where it's been)

█ Dark gray = Wall (BLOCKED cell)
█ Medium gray = Floor (FLOOR cell)
█ Brown = Door (DOOR cell)
```

### What's Happening

The colored circles are "walkers" - they move around the dungeon placing rooms:

1. **Walker spawns** at the first room
2. **Moves** to adjacent open connections
3. **Places a room** from available templates
4. **Leaves a trail** showing its path
5. **Dies** after placing max rooms
6. **Respawns** at a new location
7. **Repeat** until target cell count reached

## Keyboard Reference Card

```
┌─────────────────────────────────────┐
│      GENERATION CONTROLS            │
├─────────────────────────────────────┤
│  R  │ Regenerate (same seed)        │
│  S  │ Generate new (random seed)    │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│     VISUALIZATION CONTROLS          │
├─────────────────────────────────────┤
│  W  │ Toggle walker markers         │
│  P  │ Toggle path trails            │
│  V  │ Toggle step-by-step mode      │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│     COMPACTNESS CONTROLS            │
├─────────────────────────────────────┤
│  C  │ More compact (+0.1)           │
│  X  │ Less compact (-0.1)           │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│        CAMERA CONTROLS              │
├─────────────────────────────────────┤
│  🖱  │ Mouse wheel = Zoom           │
│  🖱  │ Middle/Right drag = Pan      │
│  +/- │ Zoom in/out                  │
│  0   │ Reset camera                 │
└─────────────────────────────────────┘
```

## Try This Tutorial

### Step 1: Basic Generation
1. Press **S** to generate a dungeon
2. Look for the colored circles (walkers)
3. See how rooms are connected

### Step 2: Enable Paths
1. Press **P** to show walker paths
2. See the colored lines showing where walkers traveled
3. Notice how paths connect all rooms

### Step 3: Watch It Happen
1. Press **V** to enable step-by-step mode
2. Press **S** to generate a new dungeon
3. Watch walkers place rooms one by one!
4. Press **V** again to turn off when done

### Step 4: Experiment with Compactness
1. Press **C** five times (compactness = 0.8)
2. Press **S** to generate
3. Notice the dungeon is tighter, less sprawling
4. Press **X** five times (compactness = 0.3)
5. Press **S** again
6. Compare the two layouts

### Step 5: Compare Extremes
1. **Maximum Spread** (compactness = 0.0):
   - Press **X** until "Compactness Bias: 0.0"
   - Press **S**
   - Notice long corridors, spread out layout

2. **Maximum Compact** (compactness = 1.0):
   - Press **C** until "Compactness Bias: 1.0"
   - Press **S**
   - Notice tight clustering, no long corridors

3. **Recommended** (compactness = 0.3-0.5):
   - Press **C** or **X** to set to ~0.4
   - Press **S**
   - Notice good balance

## Statistics Panel

Top-left corner shows:
```
Rooms: 6              ← Total rooms placed
Cells: 150 / 150      ← Cells placed / target
Bounds: 23 x 18       ← Dungeon size (cells)
Active Walkers: 3 / 3 ← Live walkers / total
Compactness Bias: 0.3 ← Current compactness
Seed: 978639432       ← Generation seed
```

## Tips & Tricks

### Understanding Walker Behavior

**Walker Colors**: Each walker has a unique color so you can track them individually.

**Path Trails**: 
- Older segments are more transparent
- Newer segments are more opaque
- Shows complete walker history

**Walker Death/Respawn**:
- When a walker places max rooms, it dies
- A new walker immediately spawns
- Spawn location chosen to fill gaps

### Optimal Compactness Settings

**Exploration Games** (0.2-0.4):
- More sprawl = more exploration
- Longer corridors = discovery feeling
- Natural dead ends

**Action Games** (0.4-0.6):
- Balanced layout
- Moderate travel time
- Good enemy density

**Puzzle Games** (0.6-0.8):
- Compact = easy to understand
- Short distances
- Interconnected rooms

**Arena Games** (0.8-1.0):
- Very tight
- Minimal corridors
- Maximum room density

### Debug Techniques

**Finding Stuck Walkers**:
1. Enable paths with **P**
2. Look for short, looping paths
3. That walker is stuck!

**Analyzing Coverage**:
1. Look at path density
2. Areas without paths = unexplored
3. Adjust walker count if needed

**Testing Repeatability**:
1. Note the seed number
2. Press **R** multiple times
3. Should get identical dungeons

## Common Questions

**Q: Why do walkers sometimes teleport?**
A: When a walker can't place a room (no open connections or no valid templates), it teleports to another room with open connections.

**Q: What's the difference between R and S?**
A: **R** uses the same seed (identical dungeon), **S** uses a random seed (different dungeon each time).

**Q: Why are some paths broken/disconnected?**
A: That shows a teleport event - the walker jumped to a different room.

**Q: Can I have more/fewer walkers?**
A: Yes! Edit the `num_walkers` property in the inspector (DungeonGenerator node).

**Q: How fast is step-by-step mode?**
A: Default is 0.1 seconds per step. Edit `visualization_step_delay` to adjust.

**Q: The dungeon seems too spread out/compact?**
A: Adjust `compactness_bias` with C/X keys until it feels right for your game.

## Performance Notes

- Visualization adds ~5% overhead when enabled
- Step-by-step mode is intentionally slow for viewing
- Disable visualization in production builds
- Path history uses minimal memory (few KB per walker)

## Next Steps

1. **Experiment**: Try different compactness values
2. **Customize**: Adjust walker count in inspector
3. **Iterate**: Find settings that match your game's needs
4. **Integrate**: Use the generated data in your game

## Need More Help?

- See `WALKER_VISUALIZATION.md` for detailed documentation
- See `COMPACTNESS_EXAMPLES.md` for visual examples
- See `README.md` for full project documentation

Happy dungeon generating! 🏰
