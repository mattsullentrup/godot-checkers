class_name LevelGenerator
extends Node2D


const UNIT = preload("res://rewrite/units/unit/unit.tscn")

@onready var _player_group: UnitGroup = %PlayerGroup
@onready var _opponent_group: UnitGroup = %OpponentGroup


func _draw() -> void:
	_draw_tiles()


func generate_level() -> void:
	_create_units(0, 3, _player_group)
	_create_units(5, Globals.GRID_SIZE, _opponent_group)


func _draw_tiles() -> void:
	for y in Globals.GRID_SIZE:
		for x in Globals.GRID_SIZE:
			var color := Color.WHITE if (x + y) % 2 == 0 else Color.DARK_SLATE_BLUE
			draw_rect(
					Rect2i(
							Vector2i(x * Globals.CELL_SIZE, y * Globals.CELL_SIZE),
							Vector2i(Globals.CELL_SIZE, Globals.CELL_SIZE)
					),
					color,
					true
			)


func _create_units(start_y: int, end_y: int, group: UnitGroup) -> void:
	for y in range(start_y, end_y):
		var start = 1 if y in [1, 5, 7] else 0
		for x in range(start, Globals.GRID_SIZE, 2):
			var unit = UNIT.instantiate()
			unit.global_position = Vector2i(x, y) * Globals.CELL_SIZE
			group.add_child(unit)
