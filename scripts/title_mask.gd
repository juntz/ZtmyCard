extends Sprite2D


@export var alpha_change_speed = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	modulate.a -= alpha_change_speed * delta
