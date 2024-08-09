extends Area2D


var scroll_speed = Vector2(0, 50)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				$CardField.scroll_move_up( scroll_speed.y )
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				$CardField.scroll_move_down( scroll_speed.y )
