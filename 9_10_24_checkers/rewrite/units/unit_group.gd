class_name UnitGroup
extends Node2D


const UNIT = preload("res://rewrite/units/unit/unit.tscn")

var _units: Array[Unit]


func _ready() -> void:
	_create_unit()


func _create_unit() -> void:
	var unit = UNIT.instantiate()
	add_child(unit)
