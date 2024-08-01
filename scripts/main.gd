class_name Main
extends Node2D


@export var shake_time = 0.3
var shake_amount = 5.0
var shaking = false
var prev_chronos = 5

# true if win
var battle_results = {}
var shake_timer


# Called when the node enters the scene tree for the first time.
func _ready():
	if multiplayer.get_peers().size() <= 0:
		$AiController.acitvate()
	
	shake_timer = Timer.new()
	add_child(shake_timer)
	shake_timer.wait_time = shake_time
	shake_timer.one_shot = true
	shake_timer.connect("timeout", _on_shake_timer_timeout)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if shaking:
		var rng = RandomNumberGenerator.new()
		var x = rng.randf_range(- shake_amount, shake_amount)
		var y = rng.randf_range(- shake_amount, shake_amount)
		position = Vector2(x, y)


func shake(amount: float):
	shake_amount = amount
	shaking = true
	shake_timer.start()


func _on_shake_timer_timeout():
	shaking = false
	position = Vector2()
