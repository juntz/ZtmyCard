extends Node2D

signal animation_finished

@onready var tween = get_tree().create_tween()


# Called when the node enters the scene tree for the first time.
func _ready():
	tween.stop()
	tween.set_loops()
	tween.set_parallel()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.tween_property($'Path2D/PathFollow2D', "modulate", Color(1, 1, 1, 1), 1)
	tween.tween_property($'Path2D/PathFollow2D', "modulate", Color(1, 1, 1, 0), 1).set_delay(1)
	tween.tween_property($'Path2D/PathFollow2D', "progress_ratio", 1, 2).set_trans(Tween.TRANS_CUBIC)
	tween.chain()
	tween.tween_callback(animation_finished.emit)
	tween.tween_callback(tween.stop)


func start_animation(text: String):
	tween.stop()
	$Path2D/PathFollow2D/Label.text = text
	$Path2D/PathFollow2D.progress_ratio = 0
	$Path2D/PathFollow2D.modulate.a = 0
	tween.play()
