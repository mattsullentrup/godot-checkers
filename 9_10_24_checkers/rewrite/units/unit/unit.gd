class_name Unit
extends Node2D


signal unit_defeated
signal movement_completed

var team: Globals.Team
var cell: Vector2i
var directions: Array[Globals.Direction]
var color: Color
var can_move := false
