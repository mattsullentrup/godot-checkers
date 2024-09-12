class_name UnitsContainer
extends Node2D


signal battle_over(player_won: bool)

var _whose_turn: Globals.Team

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
	_whose_turn = Globals.Team.PLAYER


func get_active_units() -> void:
	pass


func _on_turn_completed(group: UnitGroup) -> void:
	if group.get_active_units().size() > 1:
		_step_turn()
	else:
		battle_over.emit(_player_group.get_active_units().size() > 0)


func _step_turn() -> void:
	if _whose_turn == Globals.Team.PLAYER:
		_whose_turn = Globals.Team.OPPONENT
		_opponent_group.take_turn()
	elif _whose_turn == Globals.Team.OPPONENT:
		_whose_turn = Globals.Team.PLAYER
		_player_group.take_turn()
