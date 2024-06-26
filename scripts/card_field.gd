class_name CardField
extends Area2D

@export
var cards_offset = Vector2(25, 0)
var need_reposition = false


func cards() -> Array[Node]:
	return get_children().filter(func(node): return node is Card)


func shuffle():
	var cards = cards()
	for card in cards:
		remove_child(card)
	cards.shuffle()
	for card in cards:
		add_child(card)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if need_reposition:
		_reposition_cards()
		need_reposition = false


func _reposition_cards():
	var cards = get_children().filter(func(node): return node is Card)
	
	for i in range(cards.size()):
		cards[i].fly_to(cards_offset * i)
		cards[i].set_order(i)


func _on_child_entered_tree(node):
	need_reposition = true


func _on_child_exiting_tree(node):
	need_reposition = true
