class_name Unit
extends Node2D


signal unit_defeated
signal movement_completed

var team: Globals.Team
var cell: Vector2i
var directions: Array[Globals.Direction]
var available_cells: Array[Vector2i]
var color: Color
var can_move: bool
var can_jump: bool
var tween: Tween

@onready var _unit_visuals: UnitVisuals = %UnitVisuals


func move(new_cell: Vector2i) -> void:
	#available_cells.sort_custom(
			#func(a, b): return cell.distance_squared_to(a) > cell.distance_squared_to(b)
	#)

	if tween:
		tween.kill()
	tween = create_tween()

	var world_pos = Navigation.cell_to_world(new_cell)
	tween.tween_property(self, "global_position", Vector2(world_pos), .5) \
			.set_trans(Tween.TRANS_QUAD) \
			.set_ease(Tween.EASE_OUT)

	tween.tween_interval(0.1)
	#tween.tween_callback(_finish_moving.bind(new_cell))
	await tween.finished
	_finish_moving(new_cell)


func _finish_moving(new_cell: Vector2i) -> void:
	cell = new_cell
	movement_completed.emit()


func _jump_tween() -> void:
	tween.set_parallel(true)
	tween.tween_property(_unit_visuals, "radius", _unit_visuals.INITIAL_RADIUS + 30, 0.5) \
			.set_trans(Tween.TRANS_SINE) \
			.set_ease(Tween.EASE_OUT)
	tween.tween_property(_unit_visuals, "radius", _unit_visuals.INITIAL_RADIUS, 0.5).set_delay(0.75) \
			.set_trans(Tween.TRANS_SINE) \
			.set_ease(Tween.EASE_IN_OUT)
