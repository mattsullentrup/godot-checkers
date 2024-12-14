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
const INVALID_CELL = Vector2i.MIN
const ADJACENT_CELL_SQUARED_DISTANCE = 2

var movement_vectors := {}

# For debug purposes only
var turn_number := 1


func _init() -> void:
	movement_vectors[Direction.UPPER_LEFT] = Vector2i(-1, -1)
	movement_vectors[Direction.UPPER_RIGHT] = Vector2i(1, -1)
	movement_vectors[Direction.LOWER_LEFT] = Vector2i(-1, 1)
	movement_vectors[Direction.LOWER_RIGHT] = Vector2i.ONE


func print_board(board: Array[Array]) -> void:
	var lines = []
	for row in board:
		var line := ""
		for cell in row:
			if not cell:
				line += "_ "
			else:
				var team = "X" if cell.team == Globals.Team.PLAYER else "O"
				line += team + " "
		lines.append(line)

	for line in lines:
		print(line)

	print()
	print()
