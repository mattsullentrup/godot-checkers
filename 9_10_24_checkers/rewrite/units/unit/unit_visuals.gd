extends Node2D


const RADIUS = 48
const WIDTH = 5


func _draw() -> void:
	var color: Color = _get_unit_color()
	draw_circle(global_position, RADIUS, color, true, -1, true)


func _process(_delta: float) -> void:
	queue_redraw()


func _get_unit_color() -> Color:
	if get_parent().team == UnitsContainer.Team.PLAYER:
		return Color.MEDIUM_VIOLET_RED
	elif get_parent().team == UnitsContainer.Team.OPPONENT:
		return Color.MIDNIGHT_BLUE

	return Color.TRANSPARENT
