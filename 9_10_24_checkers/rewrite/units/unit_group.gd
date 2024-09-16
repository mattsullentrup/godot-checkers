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
	selected_unit.movement_completed.connect(_on_movement_completed)


func _disconnect_selected_unit_signal() -> void:
	selected_unit.movement_completed.disconnect(_on_movement_completed)


func take_turn() -> void:
	if selected_unit:
		_disconnect_selected_unit_signal()
	EventBus.clear_cell_highlights.emit()
	selected_unit = null

	for unit: Unit in moveable_units:
		unit.can_move = false

	_get_moveable_units()
	#var cells: Array = moveable_units.map(func(unit: Unit) -> Vector2i: return unit.cell)
	#var typed_cells: Array[Vector2i]
	#typed_cells.assign(cells)
	#EventBus.show_selectable_player_units.emit(typed_cells)


func _end_turn() -> void:
	_disconnect_selected_unit_signal()
	selected_unit = null
	turn_completed.emit(self)


func _get_moveable_units() -> void:
	for unit: Unit in units:
		unit.available_moves.clear()
		if _can_unit_move(unit, unit.directions):
			moveable_units.append(unit)
			unit.can_move = true


func _can_unit_move(unit: Unit, directions: Array[Globals.Direction]) -> bool:
	#var can_move_either_direction: Array[bool]
	for direction in directions:
		var movement_direction: Vector2i = Globals.movement_vectors.get(direction)
		var target_cell = unit.cell + movement_direction
		if (
				get_parent().all_units.any(func(x: Unit) -> bool: return x.cell == target_cell)
				or not _validate_tile(target_cell)
		):
			#can_move_either_direction.append(false)
			continue

		#can_move_either_direction.append(true)
		unit.available_moves.append(movement_direction + unit.cell)

	return unit.available_moves.size() > 0


func _validate_tile(tile_pos) -> bool:
	if tile_pos.x < 0 or tile_pos.x > (Globals.GRID_SIZE - 1):
		return false

	if tile_pos.y < 0 or tile_pos.y > (Globals.GRID_SIZE - 1):
		return false

	return true


func _on_unit_defeated() -> void:
	if get_children().size() == 0:
		defeated.emit()


func _on_movement_completed() -> void:
	pass
