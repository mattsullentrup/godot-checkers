extends Sprite2D


const GROW_DURATION = 0.15
const SHRINK_DURATION = 0.2


func _ready() -> void:
	position += Vector2(Globals.CELL_SIZE / 2.0, Globals.CELL_SIZE / 2.0)
	scale = Vector2.ZERO


func explode() -> void:
	var grow_tween := create_tween().set_parallel(true)
	grow_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	grow_tween.tween_property(self, "self_modulate", Color.WHITE, GROW_DURATION).from(Color.TRANSPARENT)
	grow_tween.tween_property(self, "scale", Vector2.ONE, GROW_DURATION).from(Vector2.ZERO)

	await grow_tween.finished

	var shrink_tween := create_tween().set_parallel(true)
	shrink_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	shrink_tween.tween_property(self, "scale", Vector2.ZERO, SHRINK_DURATION)
	shrink_tween.tween_property(self, "self_modulate", Color.TRANSPARENT, SHRINK_DURATION)
