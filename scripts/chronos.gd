class_name Chronos
extends Node2D

const TOTAL_STEP = 18

signal turn_done

var step_left = 0
var rotation_left = 0
var rotation_speed = 5
var rotation_step = 2 * PI / TOTAL_STEP
var pause_left = 0
var pause_delay = 0.3
var time = 5
var prev_time = 5
var turn_started = false


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
		elif turn_started:
			turn_started = false
			turn_done.emit()
	else:
		var ture_rotate_amount = rotate_amount if rotation_left > 0 else -rotate_amount
		rotate(ture_rotate_amount)
		rotation_left -= ture_rotate_amount


@rpc("any_peer", "call_local")
func turn(time_span: int):
	time = (time + time_span) % TOTAL_STEP
	if time_span > 0:
		step_left += time_span
	else:
		rotation_left += time_span * rotation_step
	turn_started = true


@rpc("any_peer", "call_local")
func revert():
	var time_span = prev_time - time
	turn(time_span)


func is_prev_night():
	return prev_time < 9


func is_night():
	return time < 9


func _on_turn_end():
	prev_time = time
