extends Area2D

var cards_offset = 95
var need_reposition = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if need_reposition:
		_reposition_cards()
		need_reposition = false


func get_cards():
	return get_children().filter(func(node): return node is Card)


func _reposition_cards():
	var cards = get_cards()
	for i in range(cards.size()):
		cards[i].fly_to(Vector2(cards_offset * (i - 1), 0))
		cards[i].set_order(i)


func is_more_card_available():
	return true


func add_card(card: Card):
	add_child(card)
	_reposition_cards()


func remove_card(card: Card):
	remove_child(card)
	_reposition_cards()


func _on_child_entered_tree(node):
	need_reposition = true


func _on_child_exiting_tree(node):
	need_reposition = true
