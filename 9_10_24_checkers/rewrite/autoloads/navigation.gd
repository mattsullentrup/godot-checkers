extends Node


func world_to_cell(pos: Vector2) -> Vector2i:
	@warning_ignore("integer_division")
	return Vector2i(
			_round_down(pos.x) / Globals.CELL_SIZE,
			_round_down(pos.y) / Globals.CELL_SIZE
	)


func cell_to_world(cell: Vector2) -> Vector2:
	var pos: Vector2
	return pos * Globals.CELL_SIZE


func _round_down(num: float) -> int:
	@warning_ignore("narrowing_conversion")
	return num - (int(num) % Globals.CELL_SIZE)
