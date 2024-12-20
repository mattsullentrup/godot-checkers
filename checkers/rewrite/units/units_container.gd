class_name UnitsContainer
extends Node2D


signal battle_over(player_won: bool)

#var all_units: Array[Unit]
var can_click := true
var _active_group: UnitGroup
var _current_mouse_cell: Vector2i
var _board: Array[Array]

@onready var _player_group: UnitGroup = %PlayerGroup
@onready var _opponent_group: UnitGroup = %OpponentGroup


func _unhandled_input(event: InputEvent) -> void:
	if not can_click:
		return

	if event.is_action_pressed("left_click"):
		_current_mouse_cell = Navigation.world_to_cell(get_global_mouse_position())
		if not _unit_can_move_to_click():
			_try_to_select_unit()
			return

		_active_group.selected_unit.move(_current_mouse_cell)
		for unit: Unit in _active_group.moveable_units:
			unit.can_move = false
	elif event.is_action_pressed("right_click"):
		_active_group.set_selected_unit(null)


func init() -> void:
	_player_group.team = Globals.Team.PLAYER
	_opponent_group.team = Globals.Team.OPPONENT
	for group: UnitGroup in [_player_group, _opponent_group]:
		group.board = _board
		group.turn_completed.connect(_on_turn_completed)
		group.defeated.connect(_end_the_battle)
		group.init()


func start_battle() -> void:
	update_board()
	_active_group = _player_group
	_player_group.take_turn()


func update_board() -> void:
	#var board: Array[Array] = []
	_board.clear()
	for y in Globals.GRID_SIZE:
		var row := []
		for x in Globals.GRID_SIZE:
			row.append(null)
		_board.append(row)

	for unit: Unit in get_tree().get_nodes_in_group("unit"):
		var unit_cell = Navigation.world_to_cell(unit.position)
		_board[unit_cell.y][unit_cell.x] = unit

	#return board


func _try_to_select_unit() -> void:
	for unit in _active_group.units:
		if (
				not Navigation.world_to_cell(unit.position) == _current_mouse_cell \
				or unit not in _active_group.moveable_units \
				or unit.can_move == false
		):
			continue

		get_viewport().set_input_as_handled()
		_active_group.set_selected_unit(unit)
		return


func _unit_can_move_to_click() -> bool:
	return (
			_active_group.selected_unit
			and _current_mouse_cell in _active_group.selected_unit.available_cells
			and _active_group.selected_unit.can_move == true
	)


func _on_turn_completed(group: UnitGroup) -> void:
	if group.units.size() > 0:
		_step_turn()
	else:
		_end_the_battle()


func _end_the_battle() -> void:
	battle_over.emit(_player_group.units.size() > 0)


func _step_turn() -> void:
	Globals.turn_number += 1
	if _active_group == _player_group:
		_active_group = _opponent_group
		_opponent_group.take_turn()
	elif _active_group == _opponent_group:
		_active_group = _player_group
		_player_group.take_turn()


#func _update_all_units() -> void:
	#all_units.assign(_player_group.units)
	#all_units.append_array(_opponent_group.units)
