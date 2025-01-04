class_name GamePlayer
extends Player

var battle_ready: bool = false
var hp: int = MAX_HP
var power: int:
	get:
		return _cards[Field.POWER_CHARGER].reduce(
			func(a: Card, b: Card):
				return a.send_to_power + b.send_to_power,
			0)

var _deck: Array[Card]
var _cards: Dictionary = {}
var _card_count_limits: Dictionary = {
	Field.BATTLE: 1,
	Field.SET_A: 1,
	Field.SET_B: 1,
	Field.SET_C: 1,
}

func _init(deck: Array[Card]):
	_deck = deck.duplicate()
	for field in Field.values():
		_cards[field] = []
	_cards[Field.DECK].append_array(deck)


func get_cards(field: Field) -> Array[Card]:
	var cards: Array[Card]
	cards.assign(_cards[field])
	cards.make_read_only()
	return cards


func get_cards_idx(field: Field) -> Array[int]:
	var cards = get_cards(field)
	var result: Array[int]
	result.assign(cards.map(_get_card_idx))
	return result


func move_card(idx: int, from: Field, to: Field) -> void:
	if _is_limit_reached(to):
		card_action_failed.emit(idx, from, to)
		return
	var card = _deck[idx]
	if card not in _cards[from]:
		card_action_failed.emit(idx, from, to)
		return
	_cards[from].remove(card)
	_cards[to].append(card)
	card_moved.emit(idx, from, to)


func draw_card():
	var deck_cards = _cards[Field.DECK]
	if len(deck_cards) <= 0:
		return
	var card = deck_cards[-1]
	var card_idx = _get_card_idx(card)
	move_card(card_idx, Field.DECK, Field.HAND)


func shuffle_deck():
	_cards[Field.DECK].shuffle()


func _is_limit_reached(field: Field) -> bool:
	if !_card_count_limits.has(field):
		return false
	var limit = _card_count_limits[field]
	return len(_cards[field]) >= limit


func _get_card_idx(card: Card) -> int:
	return _deck.find(card)
