class_name UnitVisuals
extends Node2D


const RADIUS = 48
const WIDTH = 5
@warning_ignore("integer_division")
const OFFSET = Vector2i(Globals.CELL_SIZE / 2, Globals.CELL_SIZE / 2)

@onready var _parent: Unit = get_parent()


func _draw() -> void:
	var color: Color = get_parent().color
	draw_circle(OFFSET, RADIUS, color, true, -1, true)

	if _parent.get_parent().selected_unit == _parent:
		draw_circle(OFFSET, RADIUS, Color.YELLOW, false, WIDTH, true)
		for move in _parent.available_moves:
			draw_circle(
					Globals.movement_vectors.get(move) * Globals.CELL_SIZE + OFFSET,
					RADIUS, Color.AQUA, false, WIDTH, true
			)
	elif _parent.can_move:
		draw_circle(OFFSET, RADIUS, Color.WHITE_SMOKE, false, WIDTH, true)


func _process(_delta: float) -> void:
	queue_redraw()
