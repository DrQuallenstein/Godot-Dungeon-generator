extends Node

func _ready():
print("=== BUG INVESTIGATION ===")

# Load the t_room.tres
var t_room = load("res://resources/rooms/t_room.tres") as MetaRoom

print("\n1. T-Room Template Info:")
print("   Width: ", t_room.width, " Height: ", t_room.height)
print("   Room Name: ", t_room.room_name)
print("   Required Connections: ", t_room.required_connections)
print("   Required Connections Size: ", t_room.required_connections.size())

# Check the connections on the template
var connections = t_room.get_connection_points()
print("\n2. Connections in template:")
for conn in connections:
print("   - Position (", conn.x, ",", conn.y, ") Direction: ", conn.direction)

# Simulate rotation
print("\n3. Testing Rotation:")
var rotated = RoomRotator.rotate_room(t_room, RoomRotator.Rotation.DEG_90)
print("   Rotated room required_connections: ", rotated.required_connections)
print("   Rotated room required_connections size: ", rotated.required_connections.size())

# Check if the rotated room copied required_connections
print("\n4. Problem Check:")
if rotated.required_connections.is_empty():
print("   ❌ BUG FOUND: Rotated room lost required_connections!")
else:
print("   ✓ Rotated room has required_connections")

get_tree().quit()
