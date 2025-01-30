class_name ChronosNode
extends Node2D

var time: int:
	get:
		return _time
	set(value):
		_time = value
		var tween = get_tree().create_tween()
		tween.tween_property($Chronos, "rotation", _rotation_amount, 1).set_trans(Tween.TRANS_BACK)
var _time: int
var _rotation_amount: float:
	get:
		return -(_time * TAU / Chronos.MAX_TIME)

func _ready():
	time = Chronos.INITIAL_TIME
