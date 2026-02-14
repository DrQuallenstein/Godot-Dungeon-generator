# API Dokumentation

## MetaTileType

Definiert einen Typ von Meta-Tile (z.B. Wand, Korridor, Raum, Tür).

### Properties

- `type_name: String` - Name des Tile-Typs
- `description: String` - Beschreibung des Tile-Typs

### Constructor

```gdscript
MetaTileType.new(type_name: String = "", description: String = "")
```

### Methods

#### `matches(other: MetaTileType) -> bool`

Prüft ob zwei Tile-Typen übereinstimmen (gleicher `type_name`).

**Parameter:**
- `other`: Der zu vergleichende Tile-Typ

**Rückgabe:** `true` wenn die Typen übereinstimmen, sonst `false`

---

## MetaPrefab

Stellt ein Prefab dar, das auf dem Meta-Grid platziert werden kann.

### Enums

#### Direction

```gdscript
enum Direction {
    NORTH = 0,  # Oben
    EAST = 1,   # Rechts
    SOUTH = 2,  # Unten
    WEST = 3    # Links
}
```

### Properties

- `width: int` - Breite des Prefabs in Grid-Einheiten
- `height: int` - Höhe des Prefabs in Grid-Einheiten
- `prefab_name: String` - Name/ID des Prefabs
- `neighbor_conditions: Dictionary` - Bedingungen für umgebende Tiles (Direction -> MetaTileType)
- `allow_rotation: bool` - Kann das Prefab gedreht werden?
- `tile_type: MetaTileType` - Der Tile-Typ den dieses Prefab repräsentiert

### Constructor

```gdscript
MetaPrefab.new(name: String = "", width: int = 1, height: int = 1)
```

### Methods

#### `set_neighbor_condition(direction: Direction, required_type: MetaTileType) -> void`

Setzt eine Bedingung für eine bestimmte Richtung.

**Parameter:**
- `direction`: Die Richtung (NORTH, EAST, SOUTH, WEST)
- `required_type`: Der erforderliche Tile-Typ in dieser Richtung

**Beispiel:**
```gdscript
var door = MetaPrefab.new("Door", 1, 1)
door.set_neighbor_condition(MetaPrefab.Direction.NORTH, corridor_type)
door.set_neighbor_condition(MetaPrefab.Direction.SOUTH, corridor_type)
```

#### `get_neighbor_condition(direction: Direction) -> MetaTileType`

Gibt die Bedingung für eine bestimmte Richtung zurück (oder null).

**Parameter:**
- `direction`: Die Richtung

**Rückgabe:** MetaTileType oder null

#### `can_place_at(grid: Array, grid_width: int, grid_height: int, x: int, y: int, rotation: int = 0) -> bool`

Prüft ob das Prefab an der gegebenen Position platziert werden kann.

**Parameter:**
- `grid`: Das 2D-Array des Meta-Grids
- `grid_width`: Breite des Grids
- `grid_height`: Höhe des Grids
- `x, y`: Position zum Prüfen
- `rotation`: Rotation in Grad (0, 90, 180, 270)

**Rückgabe:** `true` wenn Platzierung möglich

---

## MetaRoom

Repräsentiert ein Raum-Template, das auf dem Meta-Grid platziert werden kann.

### Properties

- `room_name: String` - Raum-Identifier
- `width: int` - Breite des Raums
- `height: int` - Höhe des Raums
- `layout: Array` - 2D-Array von MetaTileType (Array[Array[MetaTileType]])
- `weight: float` - Gewichtung für zufällige Auswahl (höher = wahrscheinlicher)
- `min_count: int` - Minimale Anzahl dieses Raums im Dungeon
- `max_count: int` - Maximale Anzahl dieses Raums im Dungeon (-1 = unbegrenzt)

### Constructor

```gdscript
MetaRoom.new(name: String = "", width: int = 3, height: int = 3)
```

### Methods

#### `set_tile(x: int, y: int, tile_type: MetaTileType) -> void`

Setzt einen Tile-Typ an einer bestimmten Position im Raum.

**Parameter:**
- `x, y`: Position im Raum
- `tile_type`: Der zu setzende Tile-Typ

#### `get_tile(x: int, y: int) -> MetaTileType`

Gibt den Tile-Typ an einer bestimmten Position zurück.

**Parameter:**
- `x, y`: Position im Raum

**Rückgabe:** MetaTileType oder null

#### `can_place_at(grid: Array, grid_width: int, grid_height: int, x: int, y: int) -> bool`

Prüft ob der Raum an der gegebenen Position platziert werden kann.

**Parameter:**
- `grid`: Das 2D-Array des Meta-Grids
- `grid_width`: Breite des Grids
- `grid_height`: Höhe des Grids
- `x, y`: Position zum Prüfen

**Rückgabe:** `true` wenn Platzierung möglich

#### `place_on_grid(grid: Array, x: int, y: int) -> bool`

Platziert den Raum auf dem Grid.

**Parameter:**
- `grid`: Das 2D-Array des Meta-Grids
- `x, y`: Position zum Platzieren

**Rückgabe:** `true` wenn erfolgreich platziert

---

## DungeonGenerator

Hauptgenerator mit Random Room Walker Algorithmus.

### Signals

#### `generation_complete(grid: Array)`

Wird ausgelöst wenn die Generierung erfolgreich abgeschlossen wurde.

**Parameter:**
- `grid`: Das generierte Meta-Grid (2D-Array)

#### `generation_failed(reason: String)`

Wird ausgelöst wenn die Generierung fehlgeschlagen ist.

**Parameter:**
- `reason`: Grund des Fehlers

### Properties

- `grid_width: int` - Breite des Meta-Grids (default: 20)
- `grid_height: int` - Höhe des Meta-Grids (default: 20)
- `min_grid_elements: int` - Minimale Anzahl gefüllter Tiles (default: 50)
- `max_attempts_per_placement: int` - Maximale Versuche pro Raum-Platzierung (default: 10)
- `available_rooms: Array[MetaRoom]` - Verfügbare Räume für die Generierung

### Methods

#### `generate_dungeon() -> void`

Startet die Dungeon-Generierung.

**Beispiel:**
```gdscript
var generator = DungeonGenerator.new()
generator.grid_width = 30
generator.grid_height = 30
generator.min_grid_elements = 100
generator.available_rooms = [room1, room2, corridor1]
generator.generation_complete.connect(_on_complete)
generator.generate_dungeon()
```

#### `get_grid() -> Array`

Gibt das generierte Grid zurück.

**Rückgabe:** 2D-Array von MetaTileType

#### `get_stats() -> Dictionary`

Gibt Statistiken über die Generierung zurück.

**Rückgabe:** Dictionary mit:
- `filled_tiles: int` - Anzahl gefüllter Tiles
- `rooms_placed: int` - Anzahl platzierter Räume
- `grid_size: Vector2i` - Größe des Grids

#### `print_grid() -> void`

Gibt das Grid in der Konsole aus (Debug-Funktion).

---

## Algorithmus Details

### Random Room Walker

Der Generator verwendet einen Walker-basierten Ansatz:

1. **Initialisierung**
   - Erstelle leeres Grid mit Größe `grid_width × grid_height`
   - Platziere Walker in der Mitte

2. **Raum-Platzierung**
   - Wähle zufälligen Raum basierend auf Gewichtung
   - Versuche Platzierung in der Nähe des Walkers (mit Offset-Variation)
   - Bis zu `max_attempts_per_placement` Versuche

3. **Bei Fehler**
   - Nach `max_attempts_per_placement` erfolglosen Versuchen:
     - Wähle zufälligen bereits platzierten Raum
     - Bewege Walker dorthin
   - Wenn keine Räume platziert: Wähle zufällige Position

4. **Abschluss**
   - Generierung läuft bis `min_grid_elements` erreicht ist
   - Oder maximale Iterationen (1000) überschritten werden

### Gewichtete Raum-Auswahl

Räume werden basierend auf ihrem `weight`-Wert ausgewählt:
- Höheres Gewicht = höhere Wahrscheinlichkeit
- Gewicht 2.0 ist doppelt so wahrscheinlich wie 1.0
- Gewicht 0.5 ist halb so wahrscheinlich wie 1.0

---

## Beispiele

### Einfacher Dungeon

```gdscript
extends Node

func _ready():
    # Tile-Typen
    var wall = MetaTileType.new("wall", "Wand")
    var floor = MetaTileType.new("floor", "Boden")
    
    # Raum erstellen
    var room = MetaRoom.new("SimpleRoom", 5, 5)
    for y in range(5):
        for x in range(5):
            if x == 0 or x == 4 or y == 0 or y == 4:
                room.set_tile(x, y, wall)
            else:
                room.set_tile(x, y, floor)
    
    # Generator
    var gen = DungeonGenerator.new()
    gen.available_rooms = [room]
    gen.grid_width = 20
    gen.grid_height = 20
    gen.min_grid_elements = 50
    gen.generation_complete.connect(func(grid): print("Fertig!"))
    gen.generate_dungeon()
```

### Prefab mit Bedingungen

```gdscript
# Tür die nur zwischen zwei Korridoren platziert werden kann
var door = MetaPrefab.new("Door", 1, 1)
door.tile_type = door_type
door.set_neighbor_condition(MetaPrefab.Direction.NORTH, corridor_type)
door.set_neighbor_condition(MetaPrefab.Direction.SOUTH, corridor_type)

# Prüfen ob platzierbar
if door.can_place_at(grid, width, height, x, y, 0):
    print("Kann platziert werden!")

# Mit Rotation testen
for rotation in [0, 90, 180, 270]:
    if door.can_place_at(grid, width, height, x, y, rotation):
        print("Kann mit %d° Rotation platziert werden" % rotation)
```

### Verschiedene Raum-Typen

```gdscript
# Häufiger kleiner Raum
var small = MetaRoom.new("Small", 3, 3)
small.weight = 5.0

# Seltener großer Raum
var large = MetaRoom.new("Large", 9, 9)
large.weight = 0.5
large.max_count = 2  # Maximal 2 große Räume

# Korridor
var corridor = MetaRoom.new("Corridor", 5, 1)
corridor.weight = 3.0

var rooms = [small, large, corridor]
```
