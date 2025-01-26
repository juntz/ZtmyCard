class_name PlayerMulliganState
extends PlayerState

const MULLIGAN_CARD_COUNT:int = 5

var _selected_cards: Array[Card] = []


func start():
	_player.shuffle_deck()
	_player.draw_cards(MULLIGAN_CARD_COUNT)


func select_card(card: Card):
	if card in _selected_cards:
		_selected_cards.erase(card)
	elif card in _player.get_cards(Player.Field.HAND):
		_selected_cards.append(card)


func player_ready():
	for card in _selected_cards:
		_player.move_card(card, Player.Field.DECK)
	_player.shuffle_deck()
	_player.draw_cards(len(_selected_cards))
	_selected_cards.clear()
	next_phase_ready.emit()
