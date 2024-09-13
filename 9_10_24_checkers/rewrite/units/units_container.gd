class_name UnitsContainer
extends Node2D


signal battle_over(player_won: bool)

var _active_group: UnitGroup

@onready var _player_group: UnitGroup = %PlayerGroup
@onready var _opponent_group: UnitGroup = %OpponentGroup


func init() -> void:
	_player_group.team = Globals.Team.PLAYER
	_player_group.init()
	_player_group.turn_completed.connect(_on_turn_completed)

	_opponent_group.team = Globals.Team.OPPONENT
	_opponent_group.init()
	_opponent_group.turn_completed.connect(_on_turn_completed)


func start_battle() -> void:
	_active_group = _player_group
	_player_group.take_turn()


func _on_turn_completed(group: UnitGroup) -> void:
	if group.get_active_units().size() > 1:
		_step_turn()
	else:
		battle_over.emit(_player_group.get_active_units().size() > 0)


func _step_turn() -> void:
	if _active_group == _player_group:
		_active_group = _opponent_group
		_opponent_group.take_turn()
	elif _active_group == _opponent_group:
		_active_group = _player_group
		_player_group.take_turn()
