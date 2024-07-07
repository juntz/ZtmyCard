extends Node2D

var total_step = 18
var step_left = 0
var rotation_left = 0
var rotation_speed = 5
var rotation_step = 2 * PI / total_step
var pause_left = 0
var pause_delay = 0.3


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if pause_left > 0:
		pause_left -= delta
		return
	
	var rotate_amount = rotation_speed * delta
	if abs(rotation_left) < rotate_amount:
		rotate(rotation_left)
		rotation_left = 0
		if step_left > 0:
			step_left -= 1
			pause_left = pause_delay
			rotation_left = rotation_step
		else:
			$"..".hold_phase = false
	else:
		var ture_rotate_amount = rotate_amount if rotation_left > 0 else -rotate_amount
		rotate(ture_rotate_amount)
		rotation_left -= ture_rotate_amount


func turn(time: int):
	$"..".hold_phase = true
	if time > 0:
		step_left = time - 1
		rotation_left += rotation_step
	else:
		step_left = 0
		rotation_left += time * rotation_step
