class_name UnitGroup
extends Node2D


signal turn_completed(group: UnitGroup)
signal defeated

const UNIT = preload("res://rewrite/units/unit/unit.tscn")

@export var team_color: Color
@export var _directions: Array[Globals.Direction]

var team: Globals.Team
var units: Array[Unit]
var moveable_units: Array[Unit]
var jumpable_units: Array[Unit]
var selected_unit: Unit


func init() -> void:
	for child in get_children():
		var unit := child as Unit
		if unit:
			unit.team = team
			unit.directions = _directions
			unit.color = team_color
			unit.unit_defeated.connect(_on_unit_defeated)
			units.append(unit)


func set_selected_unit(unit: Unit) -> void:
	if selected_unit:
		_disconnect_selected_unit_signal()

	selected_unit = unit
	if selected_unit:
		_connect_selected_unit_signal()


func _connect_selected_unit_signal() -> void:
	selected_unit.movement_completed.connect(_on_unit_movement_completed)


func _disconnect_selected_unit_signal() -> void:
	selected_unit.movement_completed.disconnect(_on_unit_movement_completed)


func take_turn() -> void:
	if selected_unit:
		_disconnect_selected_unit_signal()
	EventBus.clear_cell_highlights.emit()
	selected_unit = null

	for unit: Unit in moveable_units:
		unit.can_move = false

	_get_moveable_units()

	if not jumpable_units.is_empty():
		moveable_units.clear
		moveable_units = jumpable_units.duplicate()


func _end_turn() -> void:
	_disconnect_selected_unit_signal()
	selected_unit = null
	for unit: Unit in moveable_units:
		unit.can_move = false
	moveable_units.clear()
	turn_completed.emit(self)


func _get_moveable_units() -> void:
	for unit: Unit in units:
		unit.available_cells.clear()
		for direction in unit.directions:
			var movement_direction: Vector2i = Globals.movement_vectors.get(direction)
			var target_cell = unit.cell + movement_direction
			if _is_cell_available(unit, movement_direction, target_cell):
				moveable_units.append(unit)
				unit.can_move = true
				# TODO: Add logic to check if any units can jump and if so,
				# only allow those that can jump to move this turn
				if unit.can_jump:
					jumpable_units.append(unit)


func _is_cell_available(unit: Unit, direction: Vector2i, target_cell: Vector2i) -> bool:
	if not _validate_tile(target_cell):
		return false

	for unit_on_board: Unit in get_parent().all_units:
		if not unit_on_board.cell == target_cell:
			continue

		if unit_on_board.team == unit.team:
			return false
		else:
			var new_target_cell = target_cell + direction
			if _can_jump_to_cell(new_target_cell):
				unit.available_cells.append(new_target_cell)
				unit.can_jump = true
				# Check for multi jumps
				for new_direction in unit.directions:
					var new_movement_direction = Globals.movement_vectors.get(new_direction)
					var even_newer_target_cell = new_movement_direction * 2 + new_target_cell
					if _can_jump_to_cell(even_newer_target_cell):
						unit.available_cells.append(even_newer_target_cell)

				return true

			return false

	# Can make a normal move
	unit.available_cells.append(target_cell)

	return unit.available_cells.size() > 0


func _can_jump_to_cell(target_cell):
	if not _validate_tile(target_cell):
		return false

	for unit_on_board: Unit in get_parent().all_units:
		if unit_on_board.cell == target_cell:
			return false

	return true


func _validate_tile(tile_pos) -> bool:
	if tile_pos.x < 0 or tile_pos.x > (Globals.GRID_SIZE - 1):
		return false

	if tile_pos.y < 0 or tile_pos.y > (Globals.GRID_SIZE - 1):
		return false

	return true


func _on_unit_defeated() -> void:
	if get_children().size() == 0:
		defeated.emit()


func _on_unit_movement_completed() -> void:
	_end_turn()
