extends Path2D

var epsilon = 0.001
var progression_speed = 0.5
var moving_scale = 1.1
var hp = 100


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_moving():
		$HpPathFollow/HpIndicator.scale = Vector2(moving_scale, moving_scale)
		$HpPathFollow/DamageLabel.visible = true
	else:
		$HpPathFollow/HpIndicator.scale = Vector2(1, 1)
		$HpPathFollow/DamageLabel.visible = false
		
	var progress_delta = _get_progress_delta()
	var progress_amount = progression_speed * delta
	if abs(progress_delta) < progress_amount:
		$HpPathFollow.progress_ratio += progress_delta
	else:
		$HpPathFollow.progress_ratio += progress_amount if progress_delta > 0 else -progress_amount


func _get_progress_delta() -> float:
	return (hp / 100.0) - $HpPathFollow.progress_ratio

func is_moving():
	return abs(_get_progress_delta()) > epsilon
