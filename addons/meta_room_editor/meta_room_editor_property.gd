@tool
extends VBoxContainer

## Visual editor for MetaRoom resources
## Provides a grid-based interface for editing room layouts

var meta_room: MetaRoom
var grid_container: GridContainer
var cell_buttons: Array[Button] = []
var selected_cell_type: MetaCell.CellType = MetaCell.CellType.FLOOR
var selected_connection_direction: int = -1  # -1 = none, 0-3 = UP/RIGHT/BOTTOM/LEFT

# UI Elements
var info_label: Label
var width_spinbox: SpinBox
var height_spinbox: SpinBox
var resize_button: Button
var cell_type_buttons: Dictionary = {}
var connection_buttons: Dictionary = {}

var _initialized: bool = false


## Initialize the editor with the MetaRoom resource
## This must be called after meta_room is set
func initialize() -> void:
	if _initialized:
		return
	
	if not meta_room:
		push_error("MetaRoom editor: Cannot initialize without meta_room")
		return
	
	_initialized = true
	_setup_ui()
	_refresh_grid()


func _setup_ui() -> void:
	# Info section
	info_label = Label.new()
	info_label.text = "MetaRoom Visual Editor"
	info_label.add_theme_font_size_override("font_size", 16)
	add_child(info_label)
	
	# Room name
	var name_container = HBoxContainer.new()
	var name_label = Label.new()
	name_label.text = "Room Name: "
	name_label.custom_minimum_size.x = 100
	name_container.add_child(name_label)
	
	var name_edit = LineEdit.new()
	name_edit.text = meta_room.room_name
	name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_edit.text_changed.connect(_on_name_changed)
	name_container.add_child(name_edit)
	add_child(name_container)
	
	# Separator
	var sep1 = HSeparator.new()
	add_child(sep1)
	
	# Dimensions section
	var dim_label = Label.new()
	dim_label.text = "Room Dimensions"
	dim_label.add_theme_font_size_override("font_size", 14)
	add_child(dim_label)
	
	var dim_container = HBoxContainer.new()
	
	var width_label = Label.new()
	width_label.text = "Width: "
	dim_container.add_child(width_label)
	
	width_spinbox = SpinBox.new()
	width_spinbox.min_value = 1
	width_spinbox.max_value = 20
	width_spinbox.value = meta_room.width
	width_spinbox.step = 1
	dim_container.add_child(width_spinbox)
	
	var height_label = Label.new()
	height_label.text = "  Height: "
	dim_container.add_child(height_label)
	
	height_spinbox = SpinBox.new()
	height_spinbox.min_value = 1
	height_spinbox.max_value = 20
	height_spinbox.value = meta_room.height
	height_spinbox.step = 1
	dim_container.add_child(height_spinbox)
	
	resize_button = Button.new()
	resize_button.text = "Resize Room"
	resize_button.pressed.connect(_on_resize_pressed)
	dim_container.add_child(resize_button)
	
	add_child(dim_container)
	
	# Separator
	var sep2 = HSeparator.new()
	add_child(sep2)
	
	# Cell type selector
	var type_label = Label.new()
	type_label.text = "Cell Type Brush"
	type_label.add_theme_font_size_override("font_size", 14)
	add_child(type_label)
	
	var type_container = HBoxContainer.new()
	
	for cell_type in MetaCell.CellType.values():
		var btn = Button.new()
		var type_name = MetaCell.CellType.keys()[cell_type]
		btn.text = type_name
		btn.toggle_mode = true
		btn.pressed.connect(_on_cell_type_selected.bind(cell_type))
		type_container.add_child(btn)
		cell_type_buttons[cell_type] = btn
		
		if cell_type == selected_cell_type:
			btn.button_pressed = true
	
	add_child(type_container)
	
	# Connection selector
	var conn_label = Label.new()
	conn_label.text = "Connection Brush (toggle on/off)"
	conn_label.add_theme_font_size_override("font_size", 14)
	add_child(conn_label)
	
	var conn_container = HBoxContainer.new()
	
	var directions = ["UP", "RIGHT", "BOTTOM", "LEFT"]
	for i in range(4):
		var btn = Button.new()
		btn.text = directions[i]
		btn.toggle_mode = true
		btn.pressed.connect(_on_connection_selected.bind(i))
		conn_container.add_child(btn)
		connection_buttons[i] = btn
	
	add_child(conn_container)
	
	# Clear connections button
	var clear_conn_btn = Button.new()
	clear_conn_btn.text = "Clear All Connections"
	clear_conn_btn.pressed.connect(_on_clear_all_connections)
	add_child(clear_conn_btn)
	
	# Separator
	var sep3 = HSeparator.new()
	add_child(sep3)
	
	# Grid label
	var grid_label = Label.new()
	grid_label.text = "Room Grid (Click to paint cells)"
	grid_label.add_theme_font_size_override("font_size", 14)
	add_child(grid_label)
	
	# Grid container
	grid_container = GridContainer.new()
	grid_container.columns = meta_room.width
	# Ensure grid container has proper sizing
	grid_container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	grid_container.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	add_child(grid_container)


func _refresh_grid() -> void:
	if not grid_container:
		return
	
	# Clear existing buttons
	for child in grid_container.get_children():
		child.queue_free()
	cell_buttons.clear()
	
	# Set grid columns
	grid_container.columns = meta_room.width
	
	# Create buttons for each cell
	for y in range(meta_room.height):
		for x in range(meta_room.width):
			var btn = Button.new()
			btn.custom_minimum_size = Vector2(60, 60)
			# Ensure buttons expand to fill space
			btn.size_flags_horizontal = Control.SIZE_FILL
			btn.size_flags_vertical = Control.SIZE_FILL
			btn.pressed.connect(_on_cell_clicked.bind(x, y))
			
			var cell = meta_room.get_cell(x, y)
			if cell:
				_update_cell_button(btn, cell, x, y)
			
			grid_container.add_child(btn)
			cell_buttons.append(btn)


func _update_cell_button(btn: Button, cell: MetaCell, x: int, y: int) -> void:
	# Set text based on cell type
	var type_symbols = {
		MetaCell.CellType.BLOCKED: "■",
		MetaCell.CellType.FLOOR: "·",
		MetaCell.CellType.DOOR: "D"
	}
	
	var text = type_symbols.get(cell.cell_type, "?")
	
	# Add connection indicators
	var conn_text = ""
	if cell.connection_up:
		conn_text += "↑"
	if cell.connection_right:
		conn_text += "→"
	if cell.connection_bottom:
		conn_text += "↓"
	if cell.connection_left:
		conn_text += "←"
	
	if conn_text:
		text += "\n" + conn_text
	
	btn.text = text
	
	# Color based on cell type
	var colors = {
		MetaCell.CellType.BLOCKED: Color(0.3, 0.3, 0.3),
		MetaCell.CellType.FLOOR: Color(0.8, 0.8, 0.8),
		MetaCell.CellType.DOOR: Color(0.6, 0.8, 1.0)
	}
	
	var modulate_color = colors.get(cell.cell_type, Color.WHITE)
	btn.modulate = modulate_color


func _on_cell_clicked(x: int, y: int) -> void:
	var cell = meta_room.get_cell(x, y)
	if not cell:
		return
	
	# Apply cell type
	cell.cell_type = selected_cell_type
	
	# Apply connection if one is selected
	if selected_connection_direction >= 0:
		var direction = selected_connection_direction as MetaCell.Direction
		var current = cell.has_connection(direction)
		cell.set_connection(direction, not current)
	
	# Update button appearance
	var btn_index = y * meta_room.width + x
	if btn_index < cell_buttons.size():
		_update_cell_button(cell_buttons[btn_index], cell, x, y)
	
	# Notify that the resource changed
	meta_room.emit_changed()


func _on_cell_type_selected(cell_type: MetaCell.CellType) -> void:
	selected_cell_type = cell_type
	
	# Update button states
	for type in cell_type_buttons:
		cell_type_buttons[type].button_pressed = (type == cell_type)


func _on_connection_selected(direction: int) -> void:
	selected_connection_direction = direction
	
	# Update button states
	for dir in connection_buttons:
		connection_buttons[dir].button_pressed = (dir == direction)


func _on_resize_pressed() -> void:
	var new_width = int(width_spinbox.value)
	var new_height = int(height_spinbox.value)
	
	if new_width == meta_room.width and new_height == meta_room.height:
		return
	
	# Create new cells array
	var new_cells: Array[MetaCell] = []
	
	for y in range(new_height):
		for x in range(new_width):
			if x < meta_room.width and y < meta_room.height:
				# Copy existing cell
				var old_cell = meta_room.get_cell(x, y)
				if old_cell:
					new_cells.append(old_cell.clone())
				else:
					new_cells.append(_create_default_cell())
			else:
				# Create new cell
				new_cells.append(_create_default_cell())
	
	# Update room dimensions and cells
	meta_room.width = new_width
	meta_room.height = new_height
	meta_room.cells = new_cells
	
	# Refresh the grid display
	_refresh_grid()
	
	# Notify that the resource changed
	meta_room.emit_changed()


func _create_default_cell() -> MetaCell:
	var cell = MetaCell.new()
	cell.cell_type = MetaCell.CellType.FLOOR
	return cell


func _on_name_changed(new_name: String) -> void:
	meta_room.room_name = new_name
	meta_room.emit_changed()


func _on_clear_all_connections() -> void:
	for y in range(meta_room.height):
		for x in range(meta_room.width):
			var cell = meta_room.get_cell(x, y)
			if cell:
				cell.connection_up = false
				cell.connection_right = false
				cell.connection_bottom = false
				cell.connection_left = false
	
	_refresh_grid()
	meta_room.emit_changed()
