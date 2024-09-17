class_name JumpData
extends RefCounted


var jumped_unit: Unit = null
var target_cell: Vector2i


func _init(p_jump_data = null, p_target_cell = Globals.INVALID_CELL) -> void:
	jumped_unit = p_jump_data
	target_cell = p_target_cell
