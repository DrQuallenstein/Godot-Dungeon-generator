# MetaRoom Editor UI Layout

This document shows the visual layout of the MetaRoom editor interface.

## Full Editor Layout

```
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║  MetaRoom Visual Editor                                                   ║
║                                                                           ║
╠═══════════════════════════════════════════════════════════════════════════╣
║                                                                           ║
║  Room Name: [Demo Room___________________________________]                ║
║                                                                           ║
╠───────────────────────────────────────────────────────────────────────────╢
║                                                                           ║
║  Room Dimensions                                                          ║
║  Width: [3▲▼]  Height: [3▲▼]  [Resize Room]                             ║
║                                                                           ║
╠───────────────────────────────────────────────────────────────────────────╢
║                                                                           ║
║  Cell Type Brush                                                          ║
║  [BLOCKED] [◉ FLOOR] [DOOR]                                              ║
║                                                                           ║
║  Connection Brush (toggle on/off)                                        ║
║  [UP] [RIGHT] [BOTTOM] [LEFT]                                            ║
║                                                                           ║
║  [Clear All Connections]                                                  ║
║                                                                           ║
╠───────────────────────────────────────────────────────────────────────────╢
║                                                                           ║
║  Edit Mode                                                                ║
║  [Mode: Inspect Cell (Click to view/edit properties)]                    ║
║                                                                           ║
╠───────────────────────────────────────────────────────────────────────────╢
║                                                                           ║
║  Room Grid                                                                ║
║                                                                           ║
║    ┌──────────┬──────────┬──────────┬──────────┐                        ║
║    │    ■     │    ·     │    ·     │    ·     │                        ║
║    │          │    ⬆     │          │    →     │                        ║
║    └──────────┴──────────┴──────────┴──────────┘                        ║
║    ┌──────────┬──────────┬──────────┬──────────┐                        ║
║    │    ·     │    ·     │    ·     │    ·     │                        ║
║    │    ⬅     │          │          │          │                        ║
║    └──────────┴──────────┴──────────┴──────────┘                        ║
║    ┌──────────┬──────────┬──────────┬──────────┐                        ║
║    │    ·     │    ·     │    D     │    ·     │                        ║
║    │          │          │    ↓     │          │                        ║
║    └──────────┴──────────┴──────────┴──────────┘                        ║
║                                                                           ║
╠═══════════════════════════════════════════════════════════════════════════╣
║                                                                           ║
║  ╔═══════════════════════════════════════════════════════════╗          ║
║  ║ Cell Properties                                           ║          ║
║  ╟───────────────────────────────────────────────────────────╢          ║
║  ║                                                           ║          ║
║  ║ Status: [FLOOR        ▼]                                 ║          ║
║  ║                                                           ║          ║
║  ╟───────────────────────────────────────────────────────────╢          ║
║  ║                                                           ║          ║
║  ║ Connections                                               ║          ║
║  ║                                                           ║          ║
║  ║ ☑ UP                 ☑ Required                         ║          ║
║  ║ ☐ RIGHT              ☐ Required                         ║          ║
║  ║ ☑ BOTTOM             ☑ Required                         ║          ║
║  ║ ☐ LEFT               ☐ Required                         ║          ║
║  ║                                                           ║          ║
║  ╟───────────────────────────────────────────────────────────╢          ║
║  ║                                                           ║          ║
║  ║              [Close Properties]                          ║          ║
║  ║                                                           ║          ║
║  ╚═══════════════════════════════════════════════════════════╝          ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

## Component Details

### 1. Header Section
- **Title**: "MetaRoom Visual Editor" in large font
- **Room Name Field**: Editable text field for room identification

### 2. Room Dimensions Section
- **Width Spinbox**: Numeric input (1-20)
- **Height Spinbox**: Numeric input (1-20)
- **Resize Button**: Applies new dimensions

### 3. Cell Type Brush Section (Paint Mode)
- **BLOCKED Button**: Toggle button for blocked cell brush
- **FLOOR Button**: Toggle button for floor cell brush (default selected)
- **DOOR Button**: Toggle button for door cell brush
- Only one can be selected at a time

### 4. Connection Brush Section (Paint Mode)
- **UP/RIGHT/BOTTOM/LEFT Buttons**: Toggle buttons for connection brushes
- **Clear All Connections Button**: Removes all connections from entire room

### 5. Edit Mode Section
- **Mode Toggle Button**: Switches between Inspect and Paint modes
  - Shows current mode in button text
  - Default: "Mode: Inspect Cell (Click to view/edit properties)"
  - Paint: "Mode: Paint Cell (Click to apply brush)"

### 6. Room Grid Section
- **Visual Grid**: Shows all cells with:
  - Cell type symbols (■ · D)
  - Connection arrows (↑→↓← for optional, ⬆⮕⬇⬅ for required)
  - Color coding (gray/light gray/blue)
  - Clickable buttons (60x60 pixels each)

### 7. Cell Properties Panel (Inspect Mode Only)
- **Appears when**: Clicking a cell in Inspect mode
- **Contains**:
  - Cell type dropdown (BLOCKED/FLOOR/DOOR)
  - Connection checkboxes (4 directions)
  - Required connection checkboxes (4 directions)
  - Close button

## Color Scheme

```
Cell Types:
  BLOCKED:  RGB(0.3, 0.3, 0.3) - Dark Gray
  FLOOR:    RGB(0.8, 0.8, 0.8) - Light Gray
  DOOR:     RGB(0.6, 0.8, 1.0) - Light Blue

Connection Indicators:
  Optional:  ↑→↓← (Standard arrows)
  Required:  ⬆⮕⬇⬅ (Thick/filled arrows)
```

## User Interactions

### Inspect Mode (Default)
1. Click any cell → Properties panel appears
2. Modify properties in panel → Cell updates immediately
3. Click "Close Properties" → Panel hides

### Paint Mode
1. Select cell type brush → Brush activated
2. Select connection brush (optional) → Connection toggle mode
3. Click cells → Brush applies to cell
4. Click again → Toggles connections on/off

### Mode Switching
1. Click mode toggle button → Switches mode
2. Properties panel auto-hides when switching
3. Button text updates to show current mode

## Layout Hierarchy

```
VBoxContainer (Main)
├── Label (Title)
├── HBoxContainer (Room Name)
│   ├── Label
│   └── LineEdit
├── HSeparator
├── Label (Dimensions)
├── HBoxContainer (Dimensions)
│   ├── Label (Width)
│   ├── SpinBox
│   ├── Label (Height)
│   ├── SpinBox
│   └── Button (Resize)
├── HSeparator
├── Label (Cell Type Brush)
├── HBoxContainer (Cell Type Buttons)
│   ├── Button (BLOCKED)
│   ├── Button (FLOOR)
│   └── Button (DOOR)
├── Label (Connection Brush)
├── HBoxContainer (Connection Buttons)
│   ├── Button (UP)
│   ├── Button (RIGHT)
│   ├── Button (BOTTOM)
│   └── Button (LEFT)
├── Button (Clear All Connections)
├── HSeparator
├── Label (Edit Mode)
├── Button (Mode Toggle)
├── HSeparator
├── Label (Room Grid)
├── GridContainer (Grid)
│   └── Button[] (Cell buttons)
├── HSeparator
└── PanelContainer (Properties Panel) [Visible when cell selected]
    └── VBoxContainer
        ├── Label (Title)
        ├── HSeparator
        ├── HBoxContainer (Cell Type)
        │   ├── Label
        │   └── OptionButton
        ├── HSeparator
        ├── Label (Connections)
        ├── HBoxContainer (UP)
        │   ├── CheckBox (Connection)
        │   └── CheckBox (Required)
        ├── HBoxContainer (RIGHT)
        │   ├── CheckBox (Connection)
        │   └── CheckBox (Required)
        ├── HBoxContainer (BOTTOM)
        │   ├── CheckBox (Connection)
        │   └── CheckBox (Required)
        ├── HBoxContainer (LEFT)
        │   ├── CheckBox (Connection)
        │   └── CheckBox (Required)
        ├── HSeparator
        └── Button (Close)
```

## Responsive Design

- Grid container uses `SIZE_SHRINK_BEGIN` for proper sizing
- Buttons use `SIZE_FILL` to expand evenly
- Minimum button size: 60x60 pixels
- All controls have proper spacing with HSeparators
- Properties panel has proper padding via PanelContainer

## Accessibility

- Clear visual feedback for all interactions
- Toggle buttons show pressed state
- Color coding reinforced with symbols
- Keyboard navigation supported (Godot default)
- Clear labels for all controls

---

This layout provides an intuitive and powerful interface for editing MetaRoom resources in the Godot editor.
