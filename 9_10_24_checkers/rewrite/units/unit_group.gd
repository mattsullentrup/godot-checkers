class_name UnitGroup
extends Node2D


signal turn_completed
signal defeated

const UNIT = preload("res://rewrite/units/unit/unit.tscn")

var team: Globals.Team
var _units: Array[Unit]
var _current_unit: Unit
var _current_unit_index: int = 0

# Used for UI to check if click on map is valid and then what attack to do
var _current_actions: Array


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


func _take_turn() -> void:
	_current_unit_index = -1


func _on_unit_defeated() -> void:
	pass


func _on_movement_completed() -> void:
	pass
