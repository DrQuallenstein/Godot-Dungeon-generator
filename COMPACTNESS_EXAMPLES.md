# Compactness Comparison Examples

This document shows examples of how the `compactness_bias` parameter affects dungeon layout.

## Test Configuration

All examples use the same seed and parameters:
- Seed: 978639432
- Target cells: 150
- Walkers: 3
- Room templates: 6 (t_room, cross_room_medium, l_corridor, straight_corridor, cross_room_small, cross_room_big)

## Compactness Bias = 0.0 (No Bias - Original Behavior)

**Characteristics:**
- Fully random room placement
- May create long corridors
- Walkers spread out naturally
- Can result in sprawling layouts
- More dead ends far from center

**Expected Pattern:**
```
    ╔═══╗
    ║ 3 ║
    ╚═╤═╝
      │
╔═══╗ │ ╔═══╗
║ 1 ╞═╪═╡ 5 ║
╚═══╝ │ ╚═══╝
      │
    ╔═╧═╗
    ║ 2 ║    ╔═══╗
    ╚═╤═╝    ║ 7 ║
      │      ╚═╤═╝
    ╔═╧═╗      │
    ║ 4 ╞══════╧═══╗
    ╚═══╝      ║ 6 ║
              ╚═══╝
```
*Note: Long corridor from room 4 to room 6*

## Compactness Bias = 0.3 (Default - Balanced)

**Characteristics:**
- Moderate preference for center placement
- Good balance of variety and compactness
- Occasional long corridors but less frequent
- Natural-looking dungeon flow
- Recommended for most games

**Expected Pattern:**
```
    ╔═══╗
╔═══╡ 3 ╞═══╗
║ 1 ╞═╤═╡ 5 ║
╚═══╝ │ ╚═══╝
    ╔═╧═╗
    ║ 2 ║
    ╚═╤═╝
    ╔═╧═╗
    ║ 4 ╞═══╗
    ╚═══╝ 6 ║
          ╚═╤═╝
          7 ║
          ╚═╝
```
*Note: More centralized, shorter connections*

## Compactness Bias = 0.6 (High - Tight Layout)

**Characteristics:**
- Strong preference for center placement
- Very compact dungeons
- Minimal long corridors
- More interconnected rooms
- May feel cramped

**Expected Pattern:**
```
  ╔═══╗
╔═╡ 3 ╞═╗
║1╞═╤═╡5║
╚═╝ │ ╚═╝
  ╔═╧═╗
╔═╡ 2 ╞═╗
║4╞═╤═╡6║
╚═╝ │ ╚═╝
    7
```
*Note: Very tight clustering around center*

## Compactness Bias = 1.0 (Maximum - Very Compact)

**Characteristics:**
- Always prefers center placement
- Extremely compact
- No long corridors
- Maximum room density
- May reduce variety/exploration

**Expected Pattern:**
```
╔═╤═╤═╗
║1│2│3║
╠═╪═╪═╣
║4│5│6║
╠═╧═╧═╣
║  7  ║
╚═════╝
```
*Note: Very dense, grid-like structure*

## Usage Recommendations

### For Exploration Games (Metroidvania, Roguelikes)
- **compactness_bias: 0.2 - 0.4**
- Allows for some sprawl
- Creates interesting exploration paths
- Natural-feeling dead ends

### For Action Games (Twin-stick shooters, Brawlers)
- **compactness_bias: 0.4 - 0.6**
- Tighter combat arenas
- Shorter travel distances
- More enemy encounter density

### For Puzzle Games
- **compactness_bias: 0.6 - 0.8**
- Compact, interconnected layouts
- Easy to understand overall structure
- Minimizes backtracking

### For Tight Combat Dungeons
- **compactness_bias: 0.7 - 1.0**
- Dense room placement
- Minimal corridors
- Intense, claustrophobic feel

## Adjusting in Real-Time

Use the keyboard controls during play:
1. Press `S` to generate a new dungeon
2. Note the layout and feel
3. Press `C` to increase compactness
4. Press `S` again to see the difference
5. Repeat until you find the right value

## Technical Details

The compactness bias affects:
1. **Connection Selection**: Prefers connections closer to dungeon center
2. **Walker Teleportation**: Spawns walkers at rooms closer to center
3. **Path Building**: Encourages filling in gaps near existing rooms

The algorithm uses the dungeon's center of mass (average position of all rooms) as the target point for bias calculations.

## Performance Impact

- Minimal (< 5% overhead)
- Center calculation: O(n) where n = number of placed rooms
- Distance calculations: O(1) per connection
- Worth the improved quality

## Future Enhancements

Potential improvements:
- Multiple center points for multi-hub dungeons
- Dynamic bias that changes during generation
- Zone-based compactness (tight center, loose edges)
- Pathfinding-based compactness metrics
