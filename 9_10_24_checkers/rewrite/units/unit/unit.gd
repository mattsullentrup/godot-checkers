class_name Unit
extends Node2D


signal unit_defeated
signal movement_completed

var team: Globals.Team
var cell: Vector2i
var directions: Array[Globals.Direction]
var available_moves: Array[Vector2i]
var color: Color
var can_move := false


func move(new_cell: Vector2i) -> void:
	var world_pos = Navigation.cell_to_world(new_cell)
	var tween := create_tween()
	tween.tween_property(self, "global_position", Vector2(world_pos), 1)
	tween.tween_callback(_finish_moving.bind(new_cell))


func _finish_moving(new_cell: Vector2i) -> void:
	movement_completed.emit()
	cell = new_cell
