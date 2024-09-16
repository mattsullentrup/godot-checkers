class_name UnitsContainer
extends Node2D


signal battle_over(player_won: bool)

var all_units: Array[Unit]
var _active_group: UnitGroup
var _current_mouse_cell: Vector2i

@onready var _player_group: UnitGroup = %PlayerGroup
@onready var _opponent_group: UnitGroup = %OpponentGroup


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		_current_mouse_cell = Navigation.world_to_cell(get_global_mouse_position())
		if (
				_active_group.selected_unit \
				and _current_mouse_cell in _active_group.selected_unit.available_cells
				and _active_group.selected_unit.can_move == true
		):
			_active_group.selected_unit.move(_current_mouse_cell)
			for unit: Unit in _active_group.moveable_units:
				unit.can_move = false
			return
		for unit in _active_group.units:
			if (
						not unit.cell == _current_mouse_cell \
						or unit not in _active_group.moveable_units \
						or unit.can_move == false
			):
				continue

			get_viewport().set_input_as_handled()
			_active_group.set_selected_unit(unit)
			return
	elif event.is_action_pressed("right_click"):
		_active_group.set_selected_unit(null)


func init() -> void:
	_player_group.team = Globals.Team.PLAYER
	_player_group.init()
	_player_group.turn_completed.connect(_on_turn_completed)

	_opponent_group.team = Globals.Team.OPPONENT
	_opponent_group.init()
	_opponent_group.turn_completed.connect(_on_turn_completed)


func start_battle() -> void:
	_get_all_units()
	_active_group = _player_group
	_player_group.take_turn()


func _on_turn_completed(group: UnitGroup) -> void:
	if group.units.size() > 1:
		_step_turn()
	else:
		battle_over.emit(_player_group.units.size() > 0)


func _step_turn() -> void:
	_get_all_units()

	if _active_group == _player_group:
		_active_group = _opponent_group
		_opponent_group.take_turn()
	elif _active_group == _opponent_group:
		_active_group = _player_group
		_player_group.take_turn()


func _get_all_units() -> void:
	all_units.clear()
	all_units = _player_group.units.duplicate()
	all_units.append_array(_opponent_group.units.duplicate())
