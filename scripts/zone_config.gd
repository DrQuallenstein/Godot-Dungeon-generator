@tool
class_name ZoneConfig
extends Resource

## ZoneConfig defines a zone (area/biome) that can be assigned to groups of rooms.
## Zones represent thematic regions within a dungeon level, such as landscape,
## castle interior, cave, etc. Each zone forms a contiguous cluster of rooms.

## Display name for this zone (e.g., "CASTLE", "CAVE", "FOREST")
@export var zone_name: String = ""

## Target number of rooms to assign to this zone.
## The actual count may be lower if the dungeon does not have enough rooms.
@export_range(1, 100) var target_room_count: int = 5

## Visualization color used to tint rooms belonging to this zone
@export var color: Color = Color(0.6, 0.4, 0.2)
