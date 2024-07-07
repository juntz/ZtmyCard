extends Node

@export var player: Player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


@rpc("any_peer")
func select_hand_card(index: int, card_info: Dictionary):
	var card: Card = player.hand_cards()[index]
	card.set_info(card_info)
	player.select_card(card)


@rpc("any_peer")
func select_battle_field_card():
	var card: Card = player.battle_field_card()
	player.select_card(card)


@rpc("any_peer")
func select_set_field_card(index: int):
	var card: Card = player.set_field_cards()[index]
	player.select_card(card)


@rpc("any_peer")
func battle_ready():
	player.battle_ready()
