class_name PlayerMulliganState
extends PlayerState

const MULLIGAN_CARD_COUNT:int = 5

var _selected_cards: Array[Card] = []


func run_async():
	_card_fields.draw_cards(MULLIGAN_CARD_COUNT)
	await player_ready
	for card in _selected_cards:
		_card_fields.move_card(card, CardFields.Field.DECK)
	_card_fields.draw_cards(len(_selected_cards))
	_selected_cards.clear()


func select_card(card: Card):
	if card in _selected_cards:
		_selected_cards.erase(card)
	elif card in _card_fields.get_cards(CardFields.Field.HAND):
		_selected_cards.append(card)
