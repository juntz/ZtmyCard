class_name Card
extends Area2D

enum CardType {CHRACTOR, ENCHANT}

var player : Player
var order = 0
var hover_scale = 1.1
var top_z_index = 100
var selectable = true

var type = CardType.CHRACTOR
var card_number: int
var card_name: String
var clock: int = 1
var night_attack_point: int = 130
var day_attack_point: int = 50
var power: int = 0
var power_cost: int = 0


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
