class_name UnitsContainer
extends Node2D


signal battle_over(player_won: bool)

var _whose_turn: Globals.Team

@onready var _player_group: UnitGroup = %PlayerGroup
@onready var _opponent_group: UnitGroup = %OpponentGroup


func init() -> void:
	_player_group.team = Globals.Team.PLAYER
	_player_group.init()

	_opponent_group.team = Globals.Team.OPPONENT
	_opponent_group.init()


func start_battle() -> void:
	_whose_turn = Globals.Team.PLAYER


func get_active_units() -> void:
	pass
