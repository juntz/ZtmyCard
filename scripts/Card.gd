class_name Card
extends Area2D

enum CardType {CHARACTER, ENCHANT}

var player : Player
var order = 0
var hover_scale = 1.1
var top_z_index = 100
var selectable = true
var target_image_width = 90.0

var type = CardType.CHARACTER
var card_number: int
var card_name: String
var clock: int = 1
var night_attack_point: int = 130
var day_attack_point: int = 50
var power: int = 0
var power_cost: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	#var texture = load("res://resources/cards/img/1/2.webp")
	#$CardImage.texture = texture
	#var scale = target_image_width / texture.get_width()
	#$CardImage.scale = Vector2(scale, scale)
	var rng = RandomNumberGenerator.new()
	night_attack_point = rng.randi_range(0, 20) * 10
	day_attack_point = rng.randi_range(0, 20) * 10

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
		

func show_card():
	$CardBack.visible = false


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		player.card_clicked(self)


func _on_mouse_entered():
	if selectable:
		player.set_card_hover(self)


func _on_mouse_exited():
	if selectable:
		player.unset_card_hover(self)
