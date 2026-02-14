#!/usr/bin/env python3
"""
Create a text-based preview of what the dungeon viewer will look like
"""

def create_dungeon_preview():
    print("\n" + "=" * 70)
    print(" DUNGEON VIEWER - VISUAL PREVIEW")
    print("=" * 70)
    
    print("\n┌─────────────────────────────────────────────────────────────────┐")
    print("│ Controls:                Grid: 40x40                            │")
    print("│ Mouse Wheel: Zoom        Tiles: 287 (17.9%)                     │")
    print("│ Right Click + Drag: Pan  Rooms: 34                              │")
    print("│ Arrow Keys: Pan          Zoom: 1.00x                            │")
    print("│ R: Regenerate                                                   │")
    print("└─────────────────────────────────────────────────────────────────┘")
    
    # Create sample dungeon visualization
    print("\n  Dungeon View (sample 30x20 section):")
    print("  " + "─" * 62)
    
    # Sample dungeon pattern
    dungeon = [
        "                              ",
        "   ███████      ███████       ",
        "   █░░░░░█      █░░░░░█       ",
        "   █░░░░░█      █░░░░░█       ",
        "   █░░░░░█████  █░░░░░█       ",
        "   █░░░░░░░░░███░░░░░░█       ",
        "   ███████░░░░░█░░░░░░█       ",
        "         █░░░░░█░░░░░░█       ",
        "         █░░░░░███████████    ",
        "         █░░░░░░░░░░░░░░░█    ",
        "         ████████░░░░░░░░█    ",
        "                █░░░░░░░░█    ",
        "         ███████░░░░░░░░█     ",
        "         █░░░░░░░░░█████      ",
        "         █░░░░░█░░░█          ",
        "         █░░░░░████████       ",
        "         █░░░░░░░░░░░░█       ",
        "         ███████████░░█       ",
        "                   █░░█       ",
        "                   ████       ",
    ]
    
    for line in dungeon:
        print("  │" + line + "│")
    
    print("  " + "─" * 62)
    
    # Legend
    print("\n  Legend:")
    print("  ███  Dark Gray  - Walls")
    print("  ░░░  Light      - Rooms")
    print("  ░░░  Medium     - Corridors")
    print("      Dark        - Empty Space")
    
    print("\n  Interactive Features:")
    print("  • Scroll mouse wheel to zoom in/out (0.25x - 3.0x)")
    print("  • Right-click and drag to pan around the dungeon")
    print("  • Use arrow keys for precise panning")
    print("  • Press R to generate a new random dungeon")
    print("  • Camera automatically centers on the generated dungeon")
    
    print("\n" + "=" * 70)
    print(" Open in Godot 4.3+ and press F5 to see the actual viewer!")
    print("=" * 70 + "\n")

if __name__ == "__main__":
    create_dungeon_preview()
