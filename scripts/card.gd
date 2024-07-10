class_name Card
extends Area2D

enum CardType {CHARACTER, ENCHANT}

signal card_entered(card: Card)
signal card_exited(card: Card)
signal card_clicked(card: Card)
signal transition_end(card: Card)

var card_scene: PackedScene = preload("res://card.tscn")
var order = 0
var hover_scale = 1.1
var top_z_index = 1000
var selectable = false
var flying = false
var flying_slope = 0.1
var min_speed = 5
var slow_stop = true
var flying_length
var target_pos: Vector2
var flipping = false
var flipping_speed = 0.1
var info: Dictionary
var hover = false
var mouse_is_in = false
var shaking = false
var shake_amount = 2
var orginal_pos: Vector2


func clone() -> Card:
	var card = card_scene.instantiate()
	card.set_info(info)
	card.global_position = global_position
	return card


func set_info(info):
	self.info = info
	_load_card_image("cards/img/zutomayocard_1st_" + str(info["number"]) + ".png")
	

func set_order(i: int):
	order = i
	z_index = i


func set_hover():
	if !hover:
		scale *= hover_scale
		z_index = top_z_index
		hover = true
		card_entered.emit(self)


func unset_hover():
	if hover:
		scale /= hover_scale
		z_index = order
		hover = false
		card_exited.emit(self)


func is_closed():
	return $CardBack.visible


func show_card():
	flipping = true


func shake():
	shaking = true
	$ShakeTimer.start()


func close_card():
	$CardBack.visible = true


func fly_to(pos: Vector2, slow_stop = true):
	flying = true
	target_pos = pos
	self.slow_stop = slow_stop
	flying_length = (target_pos - position).length()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if shaking:
		var rng = RandomNumberGenerator.new()
		var x = rng.randf_range(- shake_amount, shake_amount)
		var y = rng.randf_range(- shake_amount, shake_amount)
		$CardImage.position = Vector2(x, y)
		$CardShadow.position = Vector2(x, y)
	
	if flying:
		var pos_delta = target_pos - position
		var flying_speed = (pos_delta.length() if slow_stop else flying_length - pos_delta.length()) / flying_slope + min_speed
		if pos_delta.length() < flying_speed * delta:
			position = target_pos
			flying = false
			transition_end.emit(self)
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
				transition_end.emit(self)


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
		if event.button_index == MOUSE_BUTTON_LEFT:
			if selectable && hover:
				card_clicked.emit(self)


func _check_hover():
	var all_cards = get_overlapping_areas().filter(
		func (x): return x is Card
	)
	all_cards.append(self)
	var cards = all_cards.filter(
		func (x): return x.mouse_is_in
	)
	if cards.size() > 0:
		cards.sort_custom(
			func (a, b): return a.order > b.order
		)
		var hover_target = cards[0]
		hover_target.set_hover()
		all_cards.erase(hover_target)
	
	for card in all_cards:
		card.unset_hover()


func _on_mouse_entered():
	mouse_is_in = true
	if is_closed():
		return
	
	_check_hover()


func _on_mouse_exited():
	mouse_is_in = false
	if is_closed():
		return
	
	_check_hover()


func _on_shake_timer_timeout():
	shaking = false
	$CardImage.position = Vector2()
	$CardShadow.position = Vector2()
