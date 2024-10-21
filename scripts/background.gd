extends Sprite2D

var rotate_speed = 0.01


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate(delta * rotate_speed)
