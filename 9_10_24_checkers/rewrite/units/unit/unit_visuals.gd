class_name UnitVisuals
extends Node2D


const INITIAL_RADIUS = 48
const WIDTH = 5
@warning_ignore("integer_division")
const OFFSET = Vector2i(Globals.CELL_SIZE / 2, Globals.CELL_SIZE / 2)

var radius: float = INITIAL_RADIUS

@onready var _parent: Unit = get_parent()


func _draw() -> void:
	var color: Color = get_parent().color
	draw_circle(OFFSET, radius, color, true, -1, true)

	if _parent.get_parent().selected_unit == _parent:
		draw_circle(OFFSET, radius, Color.YELLOW, false, WIDTH, true)
		if _parent.tween and _parent.tween.is_running():
			return

		for move in _parent.available_moves:
			var world_pos = Navigation.cell_to_world(move)
			var local_pos = Vector2i(to_local(world_pos))
			draw_circle(
					local_pos + OFFSET,
					INITIAL_RADIUS, Color.AQUA, false, WIDTH, true
			)
	elif _parent.can_move:
		draw_circle(OFFSET, radius, Color.WHITE_SMOKE, false, WIDTH, true)


func _process(_delta: float) -> void:
	queue_redraw()
