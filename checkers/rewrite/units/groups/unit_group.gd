class_name UnitGroup
extends Node2D


signal turn_completed(group: UnitGroup)
signal defeated

@export var team: Globals.Team
@export var team_color: Color = Color.MIDNIGHT_BLUE
@export var _other_side_of_board_y: int

var units: Array[Unit]
var moveable_units: Array[Unit]
var jumpable_units: Array[Unit]
var all_units: Array[Unit]
var selected_unit: Unit

@onready var _unit_movement: UnitMovement = %UnitMovement


func init() -> void:
	for child in get_children():
		var unit := child as Unit
		if not unit:
			continue

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

	selected_unit = null
	for unit: Unit in moveable_units:
		unit.can_move = false

	#await get_tree().create_timer(0.1).timeout
	_unit_movement.get_moveable_units()

	if jumpable_units.is_empty():
		return

	for unit in moveable_units:
		if not unit.can_jump:
			unit.can_move = false

	moveable_units.clear()
	moveable_units = jumpable_units.duplicate()


func _end_turn() -> void:
	_disconnect_selected_unit_signal()
	selected_unit = null
	for unit: Unit in moveable_units:
		unit.can_move = false
		unit.can_jump = false
		unit.jump_paths.clear()
		unit.available_cells.clear()

	moveable_units.clear()
	jumpable_units.clear()
	turn_completed.emit(self)


func _on_unit_defeated(unit: Unit) -> void:
	units.erase(unit)
	all_units.erase(unit)
	if units.is_empty():
		defeated.emit()


func _on_unit_movement_completed(unit: Unit) -> void:
	if unit.cell.y == _other_side_of_board_y:
		unit.is_king = true

	if unit.jump_paths.all(func(x: Array) -> bool: return x.is_empty()):
		_end_turn()
	else:
		unit.can_move = true
