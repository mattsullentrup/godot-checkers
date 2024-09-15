extends Node


enum Team {
	PLAYER,
	OPPONENT
}

const CELL_SIZE = 128
const GRID_SIZE = 8
const UPPER_LEFT = Vector2i(-1, -1)
const UPPER_RIGHT = Vector2i(1, -1)
const LOWER_LEFT = Vector2i(-1, -1)
const LOWER_RIGHT = Vector2i(1, 1)
