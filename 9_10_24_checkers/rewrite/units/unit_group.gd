class_name UnitGroup
extends Node2D


signal turn_completed(group: UnitGroup)
signal defeated

const UNIT = preload("res://rewrite/units/unit/unit.tscn")

@export var team_color: Color
@export var _directions: Array[Globals.Direction]

var team: Globals.Team
var units: Array[Unit]
var _current_unit: Unit
var _current_unit_index: int = 0
var moveable_units: Array[Unit]


func init() -> void:
	for child in get_children():
		var unit := child as Unit
		if unit:
			unit.team = team
			unit.directions = _directions
			unit.color = team_color
			unit.unit_defeated.connect(_on_unit_defeated)
			units.append(unit)


func set_current_unit(unit: Unit) -> void:
	if _current_unit:
		_disconnect_current_unit_signal()

	_current_unit = unit
	_connect_current_unit_signal()


func _connect_current_unit_signal() -> void:
	_current_unit.movement_completed.connect(_on_movement_completed)


func _disconnect_current_unit_signal() -> void:
	_current_unit.movement_completed.disconnect(_on_movement_completed)


func take_turn() -> void:
	_get_moveable_units()
	if _current_unit:
		_disconnect_current_unit_signal()
	EventBus.clear_cell_highlights.emit()
	_current_unit = null

	var cells: Array = moveable_units.map(func(unit: Unit) -> Vector2i: return unit.cell)
	var typed_cells: Array[Vector2i]
	typed_cells.assign(cells)
	EventBus.show_selectable_player_units.emit(typed_cells)


func _end_turn() -> void:
	_disconnect_current_unit_signal()
	_current_unit = null
	turn_completed.emit(self)


func _get_moveable_units() -> void:
	for unit: Unit in units:
		if _can_unit_move(unit, unit.directions):
			moveable_units.append(unit)


func _can_unit_move(unit: Unit, directions: Array[Globals.Direction]) -> bool:
	var can_move_either_direction: Array[bool]
	for direction in directions:
		var target_cell = unit.cell + Globals.movement_vectors.get(direction)
		if (
				get_parent().all_units.any(func(x: Unit) -> bool: return x.cell == target_cell)
				or not _validate_tile(target_cell)
		):
			can_move_either_direction.append(false)
			continue
		can_move_either_direction.append(true)

	return true in can_move_either_direction


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
