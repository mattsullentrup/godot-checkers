extends Node2D


const UNIT = preload("res://rewrite/units/unit/unit.tscn")


func _draw() -> void:
	_draw_tiles()


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
