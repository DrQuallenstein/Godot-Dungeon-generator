@tool
class_name MetaCell
extends Resource

## MetaCell represents a single cell in a dungeon room.
## It defines the cell type and its connections to adjacent cells.

## Direction enum for cell connections
enum Direction {
	UP = 0,
	RIGHT = 1,
	BOTTOM = 2,
	LEFT = 3
}

## Cell type enum defining what kind of cell this is
enum CellType {
	BLOCKED = 0,           ## Cannot be walked through
	FLOOR = 1,             ## Regular walkable floor
	POTENTIAL_PASSAGE = 2, ## Overlap point; post-processing decides if it becomes PASSAGE or BLOCKED
	PASSAGE = 3            ## Definitive passage created by walker traversal
}

## The type of this cell
@export var cell_type: CellType = CellType.FLOOR

## Whether this cell has a connection upward
@export var connection_up: bool = false

## Whether this cell has a connection to the right
@export var connection_right: bool = false

## Whether this cell has a connection downward
@export var connection_bottom: bool = false

## Whether this cell has a connection to the left
@export var connection_left: bool = false

## Whether the connection is required (must be connected)
@export var connection_required: bool = false



## Returns true if this cell has any connections
func has_any_connection() -> bool:
	return connection_up or connection_right or connection_bottom or connection_left


## Returns true if this cell has a connection in the specified direction
func has_connection(direction: Direction) -> bool:
	match direction:
		Direction.UP:
			return connection_up
		Direction.RIGHT:
			return connection_right
		Direction.BOTTOM:
			return connection_bottom
		Direction.LEFT:
			return connection_left
	return false


## Sets the connection state for a specific direction
func set_connection(direction: Direction, value: bool) -> void:
	match direction:
		Direction.UP:
			connection_up = value
		Direction.RIGHT:
			connection_right = value
		Direction.BOTTOM:
			connection_bottom = value
		Direction.LEFT:
			connection_left = value


## Sets the required state for a connection in a specific direction
func set_connection_required(direction: Direction, value: bool) -> void:
	connection_required = value


## Returns the opposite direction
static func opposite_direction(direction: Direction) -> Direction:
	match direction:
		Direction.UP:
			return Direction.BOTTOM
		Direction.RIGHT:
			return Direction.LEFT
		Direction.BOTTOM:
			return Direction.UP
		Direction.LEFT:
			return Direction.RIGHT
	return Direction.UP


## Creates a deep copy of this cell
func clone() -> MetaCell:
	var new_cell = MetaCell.new()
	new_cell.cell_type = cell_type
	new_cell.connection_up = connection_up
	new_cell.connection_right = connection_right
	new_cell.connection_bottom = connection_bottom
	new_cell.connection_left = connection_left
	new_cell.connection_required = connection_required
	return new_cell
