class_name Card
extends Area2D

var player : Player
var order = 0
var hover_scale = 1.1
var top_z_index = 100
var selectable = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_order(i: int):
	order = i
	z_index = i


func set_hover(hover: bool):
	if hover:
		scale *= hover_scale
		z_index = top_z_index
	else:
		scale /= hover_scale
		z_index = order


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		player.card_clicked(self)


func _on_mouse_entered():
	if selectable:
		player.set_card_hover(self)


func _on_mouse_exited():
	if selectable:
		player.unset_card_hover(self)
