class_name UnitVisuals
extends Node2D


@warning_ignore("integer_division")
const OFFSET = Vector2i(Globals.CELL_SIZE / 2, Globals.CELL_SIZE / 2)
const INITIAL_RADIUS = 48
const BIG_RADIUS = INITIAL_RADIUS + 30
const GROW_DIVISOR = 4.0
const SHRINK_DIVISOR = 1.5
const WIDTH = 5
const AVAILABLE_CELL_COLOR = Color("c8f294")

var _radius: float = INITIAL_RADIUS
var _color: Color

@onready var _parent: Unit = get_parent()
@onready var _particles: GPUParticles2D = $"../GPUParticles2D"


func _ready() -> void:
	var particle_pos: Vector2i = _particles.global_position
	if particle_pos:
		particle_pos += OFFSET
	_particles.global_position = particle_pos


func _draw() -> void:
	_color = _parent.color
	if _particles.emitting:
		return

	draw_circle(OFFSET, _radius, _color, true, -1, true)

	if _parent.get_parent().selected_unit == _parent:
		draw_circle(OFFSET, _radius, Color.YELLOW, false, WIDTH, true)
		if (
				_parent.jump_path_tween and _parent.jump_path_tween.is_running() \
				or _parent.normal_move_tween and _parent.normal_move_tween.is_running()
		):
			return

		for move in _parent.available_cells:
			var world_pos = Navigation.cell_to_world(move)
			var local_pos = Vector2i(to_local(world_pos))
			draw_circle(
					local_pos + OFFSET,
					INITIAL_RADIUS, AVAILABLE_CELL_COLOR, false, WIDTH, true
			)
	elif _parent.can_move:
		draw_circle(OFFSET, _radius, Color.WHITE_SMOKE, false, WIDTH, true)


func _process(_delta: float) -> void:
	queue_redraw()


func explode() -> void:
	_particles.process_material.color = _color
	_particles.emitting = true
	await _particles.finished


func jump_tween(tween: Tween) -> void:
	var grow_time = _parent.MOVEMENT_DURATION / GROW_DIVISOR
	tween.parallel().tween_property(self, "_radius", BIG_RADIUS, grow_time) \
			.set_trans(Tween.TRANS_SINE) \
			.set_ease(Tween.EASE_OUT)

	var shrink_time = _parent.MOVEMENT_DURATION / SHRINK_DIVISOR
	tween.parallel().tween_property(self, "_radius", INITIAL_RADIUS, shrink_time).set_delay(grow_time)\
			.set_trans(Tween.TRANS_SINE) \
			.set_ease(Tween.EASE_IN)
