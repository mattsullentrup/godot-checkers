extends Node2D


@onready var _parent := get_parent() as Level


func _draw() -> void:
	_draw_tiles()


func _draw_tiles() -> void:
	for y in _parent.GRID_SIZE:
		for x in _parent.GRID_SIZE:
			var color := Color.WHITE if (x + y) % 2 == 0 else Color.DARK_SLATE_BLUE
			draw_rect(
					Rect2i(
							Vector2i(x * _parent.CELL_SIZE, y * _parent.CELL_SIZE),
							Vector2i(_parent.CELL_SIZE, _parent.CELL_SIZE)
					),
					color,
					true
			)
