class_name CardField
extends Area2D

enum Field{NONE, BATTLE, SET, ABYSS, POWER_CHARGER, DECK, HAND, ENCHANT, SELECTION}

@export var cards_offset = Vector2(25, 0)
@export var card_line_offset = Vector2(0, 150)
@export var fly_ease_out = true
@export var base_z_index = 0
@export var card_count_per_line = 20
@export var scrollable = false
var need_reposition = false
var row_offset = 0
var col_offset = 0


func cards() -> Array[Node]:
	return get_children().filter(func(node): return node is Card)


func shuffle():
	var cards = cards()
	for card in cards:
		remove_child(card)
	cards.shuffle()
	for card in cards:
		add_child(card)

func scroll_move_up(scroll : float): 
	if not scrollable:
		printerr("scrollable is false, but try scroll up.")

	var cur_y = position.y 
	var new_y = cur_y + scroll
	var min_y = (card_line_offset.y / 2)
	if new_y > min_y:
		new_y = min_y

	position.y = new_y
	

func scroll_move_down(scroll : float): 
	if not scrollable:
		printerr("scrollable is false, but try scroll down.")

	var cur_y = position.y
	var new_y = cur_y - scroll

	# 매직넘버. (0은 카드의 머리부분만 잘려서 보이고. -1.5가 이쁘게 보인다.)
	var hide_line_count = -1.5
	var max_y = (-(card_line_offset.y+cards_offset.y) * (floor(float(cards().size())/float(card_count_per_line))+hide_line_count)) * scale.y
	if new_y < max_y:
		new_y = max_y

	position.y = new_y

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if scrollable:
		if Input.is_action_just_pressed("scroll_up"):
			if col_offset > 0:
				col_offset -= 1
				need_reposition = true
		if Input.is_action_just_pressed("scroll_down"):
			if col_offset < (cards().size() / card_count_per_line):
				col_offset += 1
				need_reposition = true
	if need_reposition:
		_reposition_cards()
		need_reposition = false


func _reposition_cards():
	var cards = cards()
	
	for i in range(cards.size()):
		var col = i / card_count_per_line
		var row = i % card_count_per_line
		cards[i].fly_to(card_line_offset * (col - col_offset) + cards_offset * (row + row_offset), fly_ease_out)
		cards[i].set_order(base_z_index + i)


func _on_child_entered_tree(_node):
	need_reposition = true


func _on_child_exiting_tree(_node):
	need_reposition = true


func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventKey:
		event.is_pressed()
