# Godot Dungeon Generator

A flexible dungeon generator for Roguelike games in Godot 4.x with GDScript. Uses Meta-Prefabs and a Random Room Walker algorithm.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Godot](https://img.shields.io/badge/godot-4.3+-blue.svg)

## 🎮 Quick Start

1. Open the project in Godot 4.3 or later
2. Press **F5** to run the main scene
3. Use **Mouse Wheel** to zoom, **Right Click + Drag** to pan
4. Press **R** to regenerate the dungeon

## 📁 Project Structure

```
Godot-Dungeon-generator/
├── scripts/              # Core GDScript files
│   ├── meta_tile_type.gd    # Tile type definitions
│   ├── meta_prefab.gd       # Prefab with conditions
│   ├── meta_room.gd         # Room templates
│   └── dungeon_generator.gd # Main generator
├── scenes/               # Main scenes
│   ├── dungeon_viewer.tscn  # Main visual viewer (with pan/zoom)
│   └── dungeon_viewer.gd    # Viewer script
├── examples/             # Example scenes
│   ├── example_usage.*      # Basic usage
│   ├── advanced_example.*   # Advanced features
│   └── visual_example.*     # Visual demo
├── resources/            # Resource files
├── docs/                 # Documentation
│   ├── README.md            # Detailed guide (German)
│   ├── USAGE.md             # Usage examples
│   ├── API.md               # API reference
│   └── IMPLEMENTATION_COMPLETE.md
├── project.godot         # Godot project file
├── icon.svg              # Project icon
└── LICENSE               # MIT License
```

## ✨ Features

- **Meta-Prefab System**: Define reusable room templates with placement conditions
- **Rotation Support**: Automatic rotation of prefabs (90°, 180°, 270°)
- **Flexible Conditions**: Define which tile types must surround a prefab
- **Random Room Walker**: Intelligent algorithm for room placement
- **Visual Display**: See your dungeon with pan and zoom controls
- **Configurable**: Control grid size, minimum tile count, etc.

## 🎯 Controls

| Action | Input |
|--------|-------|
| **Zoom In/Out** | Mouse Wheel |
| **Pan Camera** | Right Click + Drag or Arrow Keys |
| **Regenerate** | R Key |

## 📚 Documentation

- **[Full Documentation](docs/README.md)** - Complete guide in German
- **[Usage Guide](docs/USAGE.md)** - Detailed usage examples
- **[API Reference](docs/API.md)** - API documentation

## 🏗️ Core Components

### 1. MetaTileType
Defines a type of meta tile (wall, corridor, room, door).

### 2. MetaPrefab
Represents a prefab that can be placed on the meta grid with:
- Variable size (1x1, 2x2, etc.)
- Neighbor type conditions
- Rotation support (90°, 180°, 270°)

### 3. MetaRoom
Room template with:
- Grid layout of MetaTileTypes
- Weighted random selection
- Placement validation

### 4. DungeonGenerator
Main generator using Random Room Walker algorithm:
- Configurable grid size
- Minimum grid element requirement
- Retry logic: 10 attempts, then pick random existing room
- Signals for generation events

## 🚀 Usage Example

```gdscript
extends Node2D

@onready var generator: DungeonGenerator = $DungeonGenerator

func _ready():
    # Create tile types
    var wall = MetaTileType.new("wall", "Solid wall")
    var room = MetaTileType.new("room", "Room floor")
    
    # Create a room
    var small_room = MetaRoom.new("SmallRoom", 3, 3)
    # ... configure room layout
    
    # Setup generator
    generator.available_rooms = [small_room]
    generator.grid_width = 30
    generator.grid_height = 30
    generator.min_grid_elements = 100
    
    # Generate
    generator.generation_complete.connect(_on_complete)
    generator.generate_dungeon()

func _on_complete(grid: Array):
    print("Dungeon generated!")
    # Use the grid...
```

## 🔧 Configuration

Key properties in DungeonGenerator:

```gdscript
@export var grid_width: int = 20              # Grid width
@export var grid_height: int = 20             # Grid height
@export var min_grid_elements: int = 50       # Minimum filled tiles
@export var max_attempts_per_placement: int = 10  # Retry attempts
@export var available_rooms: Array[MetaRoom] = []  # Room templates
```

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Support

For issues and questions, please use the GitHub issue tracker.

---

**Made with ❤️ for the Godot community**
