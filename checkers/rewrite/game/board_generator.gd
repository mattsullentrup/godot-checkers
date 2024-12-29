class_name BoardGenerator
extends Node2D


const OPPONENT_UNIT = preload("res://rewrite/units/unit/opponent_unit/opponent_unit.tscn")
const PLAYER_UNIT = preload("res://rewrite/units/unit/player_unit/player_unit.tscn")

@onready var _player_group: UnitGroup = %PlayerGroup
@onready var _opponent_group: UnitGroup = %OpponentGroup


func _draw() -> void:
	_draw_tiles()


func generate_level() -> void:
	_create_units(0, 3, _opponent_group)
	_create_units(5, Globals.GRID_SIZE, _player_group)

	#_create_test_scene()


func _create_test_scene():
	_make_new_unit(_player_group, Vector2i(3, 6))

	for y in [1, 3, 5]:
		for x in [2, 4, 6]:
			_make_new_unit(_opponent_group, Vector2i(x, y))


func _make_new_unit(group: UnitGroup, pos: Vector2i) -> void:
	var unit = PLAYER_UNIT.instantiate() if group.team == Globals.Team.PLAYER else OPPONENT_UNIT.instantiate()
	#unit.cell = pos
	unit.global_position = Navigation.cell_to_world(pos)
	group.add_child(unit)


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

			var default_font = ThemeDB.fallback_font
			#var default_font_size = ThemeDB.fallback_font_size
			var pos = Vector2i(x * Globals.CELL_SIZE, y * Globals.CELL_SIZE)
			var cell = Vector2i(x, y)
			var font_size = 14
			var text = "  {0}   {1}".format([pos, cell])
			draw_string_outline(default_font, Vector2(pos.x, pos.y + 15), text, \
					HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 4, Color.BLACK)

			draw_string(default_font, Vector2(pos.x, pos.y + 15), text, \
					HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.YELLOW)



func _create_units(start_y: int, end_y: int, group: UnitGroup) -> void:
	for y in range(start_y, end_y):
		var start = 0 if y in [1, 5, 7] else 1
		for x in range(start, Globals.GRID_SIZE, 2):
			_make_new_unit(group, Vector2i(x, y))
