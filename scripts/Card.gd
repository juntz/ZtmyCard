class_name Card
extends Area2D

enum CardType {CHARACTER, ENCHANT}

var player : Player
var order = 0
var hover_scale = 1.1
var top_z_index = 100
var selectable = false
var flying = false
var flying_time = 0.1
var target_pos: Vector2
var flipping = false
var flipping_speed = 0.1
var info: Dictionary


func set_info(info):
	self.info = info
	_load_card_image("cards/img/zutomayocard_1st_" + str(info["number"]) + ".png")
	

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
		
		
func is_closed():
	return $CardBack.visible


func show_card():
	flipping = true


func close_card():
	$CardBack.visible = true


func fly_to(pos: Vector2):
	flying = true
	target_pos = pos


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if flying:
		var pos_delta = target_pos - position
		var flying_speed = pos_delta.length() / flying_time
		if pos_delta.length() < 1:
			position = target_pos
			flying = false
		else:
			position += pos_delta.normalized() * flying_speed * delta
			
	if flipping:
		if $CardBack.visible:
			scale.x -= flipping_speed
			if scale.x <= 0:
				$CardBack.visible = false
		else:
			scale.x += flipping_speed
			if scale.x >= 1:
				scale.x = 1
				flipping = false


func _load_card_image(path):
	if !FileAccess.file_exists(path):
		printerr("Cannot find the card image: " + path)
		return
	
	var image = Image.load_from_file(path)
	var texture = ImageTexture.create_from_image(image)
	texture.set_size_override(Vector2(700, 978))
	$CardImage.texture = texture


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if selectable:
			player.card_clicked(self)


func _on_mouse_entered():
	if !is_closed():
		player.set_card_hover(self)


func _on_mouse_exited():
	if !is_closed():
		player.unset_card_hover(self)
