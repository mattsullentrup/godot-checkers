class_name JumpData
extends RefCounted


var jumpable_unit: Unit = null
var target_cell: Vector2i


func _init(p_jumpable_unit = null, p_target_cell = Globals.INVALID_CELL) -> void:
	jumpable_unit = p_jumpable_unit
	target_cell = p_target_cell
