class_name UnitsContainer
extends Node2D


signal battle_over(player_won: bool)

enum Team {
	PLAYER,
	OPPONENT
}

var _whose_turn: Team


func init() -> void:
	pass


func start_battle() -> void:
	pass


func get_active_units() -> void:
	pass
