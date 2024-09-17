class_name Unit
extends Node2D


const MOVEMENT_DURATION = 0.5

signal unit_defeated(unit: Unit)
signal movement_completed

var team: Globals.Team
var cell: Vector2i
var directions: Array[Globals.Direction]

# INFO: This is only used for other nodes to display/check if unit can move to click
var available_cells: Array[Vector2i]
var jump_paths: Array[Array]
var color: Color
var can_move: bool
var can_jump: bool
var tween: Tween

@onready var _unit_visuals: UnitVisuals = %UnitVisuals


func explode() -> void:
	unit_defeated.emit(self)
	_unit_visuals.explode()
	await $GPUParticles2D.finished
	queue_free()


func move(new_cell: Vector2i) -> void:
	z_index += 1

	#available_cells.sort_custom(
			#func(a, b): return cell.distance_squared_to(a) > cell.distance_squared_to(b)
	#)

	if tween:
		tween.kill()
	tween = create_tween()

	if can_jump:
		# TODO: figure out how to find a path to the target cell
		# and loop the tween to get there

		#tween.set_loops(available_cells.size())
		_move_tween(new_cell)
		_unit_visuals.jump_tween(tween)
	else:
		_move_tween(new_cell)

	tween.tween_callback(_finish_moving.bind(new_cell))
	#tween.finished.connect(_finish_moving.bind(new_cell))


func _move_tween(new_cell) -> void:
	var world_pos = Navigation.cell_to_world(new_cell)
	tween.tween_property(self, "global_position", Vector2(world_pos), MOVEMENT_DURATION) \
			.set_trans(Tween.TRANS_QUAD) \
			.set_ease(Tween.EASE_OUT)
			#.as_relative()


func _finish_moving(new_cell: Vector2i) -> void:
	cell = new_cell
	movement_completed.emit(self)
	z_index -= 1
