class_name JumpData
extends RefCounted


var jumped_unit: Unit = null
var target_cell: Vector2i


func _init(j = null, t = Globals.INVALID_CELL) -> void:
	jumped_unit = j
	target_cell = t
