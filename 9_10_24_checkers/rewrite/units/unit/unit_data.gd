class_name UnitData
extends Resource


@export var normal_color: Color
@export var king_color: Color
@export var directions: Array[Globals.Direction]
@export var team: Globals.Team


func _set_is_king(_value) -> void:
	for vector in Globals.movement_vectors:
		var movement_direction = Globals.movement_vectors.get(vector)
		if not directions.has(movement_direction):
			directions.append(movement_direction)
