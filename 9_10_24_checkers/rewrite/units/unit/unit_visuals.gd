extends Node2D


const RADIUS = 48
const WIDTH = 5
@warning_ignore("integer_division")
const OFFSET = Vector2i(Globals.CELL_SIZE / 2, Globals.CELL_SIZE / 2)


func _draw() -> void:
	var color: Color = _get_unit_color()
	draw_circle(OFFSET, RADIUS, color, true, -1, true)


func _process(_delta: float) -> void:
	queue_redraw()


func _get_unit_color() -> Color:
	if get_parent().team == Globals.Team.PLAYER:
		return Color.MEDIUM_VIOLET_RED
	elif get_parent().team == Globals.Team.OPPONENT:
		return Color.MIDNIGHT_BLUE

	return Color.TRANSPARENT
