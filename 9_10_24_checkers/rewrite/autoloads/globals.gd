extends Node


enum Team {
	PLAYER,
	OPPONENT
}

enum Direction {
	UPPER_LEFT,
	UPPER_RIGHT,
	LOWER_LEFT,
	LOWER_RIGHT,
}

const CELL_SIZE = 128
const GRID_SIZE = 8
#const UPPER_LEFT = Vector2i(-1, -1)
#const UPPER_RIGHT = Vector2i(1, -1)
#const LOWER_LEFT = Vector2i(-1, -1)
#const LOWER_RIGHT = Vector2i(1, 1)

var movement_vectors := {}

func _init() -> void:
	movement_vectors[Direction.UPPER_LEFT] = Vector2i(-1, -1)
	movement_vectors[Direction.UPPER_RIGHT] = Vector2i(1, -1)
	movement_vectors[Direction.LOWER_LEFT] = -Vector2i.ONE
	movement_vectors[Direction.LOWER_RIGHT] = Vector2i.ONE
