class_name UnitGroup
extends Node2D


signal turn_completed(group: UnitGroup)
signal defeated

const UNIT = preload("res://rewrite/units/unit/unit.tscn")

var team: Globals.Team
var _units: Array[Unit]
var _current_unit: Unit
var _current_unit_index: int = 0
var _current_mouse_cell: Vector2i


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("click"):
		return

	var cell: Vector2i = Navigation.world_to_cell(get_global_mouse_position())
	for unit in get_children():
		if not unit.cell == cell:
			continue

		get_viewport().set_input_as_handled()
		_disconnect_current_unit_signal()
		_current_unit = unit
		_connect_current_unit_signal()
		return


func init() -> void:
	for child in get_children():
		var unit := child as Unit
		if unit:
			unit.team = team
			unit.unit_defeated.connect(_on_unit_defeated)
			_units.append(unit)


func _connect_current_unit_signal() -> void:
	_current_unit.movement_completed.connect(_on_movement_completed)


func _disconnect_current_unit_signal() -> void:
	_current_unit.movement_completed.disconnect(_on_movement_completed)


func take_turn() -> void:
	var active_units = get_children()
	if _current_unit:
		_disconnect_current_unit_signal()
	EventBus.clear_cell_highlights.emit()
	_current_unit = null
	EventBus.show_selectable_player_units.emit(
			active_units.map(func(unit): return unit.cell)
	)


func _end_turn() -> void:
	_disconnect_current_unit_signal()
	_current_unit = null
	turn_completed.emit(self)


#func get_active_units() -> Array:
	#var units: Array[Unit]
	#return units


func _get_moveable_units() -> Array:
	var units: Array[Unit]
	return units


func _on_unit_defeated() -> void:
	if get_children().size() == 0:
		defeated.emit()


func _on_movement_completed() -> void:
	pass
