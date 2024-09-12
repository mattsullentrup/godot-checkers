class_name Level
extends Node2D


const CELL_SIZE = 128
const GRID_SIZE = 8

@onready var _units_container: UnitsContainer = %Units


func _ready() -> void:
	_units_container.battle_over.connect(_on_battle_over)
	_units_container.init()
	_units_container.start_battle()


func _on_battle_over(player_won: bool) -> void:
	pass
