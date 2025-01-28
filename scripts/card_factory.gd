class_name CardFactory

var _game: Game


func _init(game: Game):
	_game = game


func from_document(document: Dictionary) -> Card:
	var card: Card
	match document['type']:
		'character':
			card = _get_character_card(document)
		'enchant':
			card = _get_enchant_card(document)
		_:
			push_error('Cannot get a card information from given document.')
			return null
	_set_common_fields(card, document)
	return card


func _set_common_fields(card: Card, document: Dictionary) -> void:
	var attribute_key = document['attribute'].to_upper()
	card.attribute = Card.Attribute[attribute_key]
	card.clock = int(document['clock'])
	card.power_cost = int(document['powerCost'])
	card.send_to_power = int(document['sendToPower'])


func _get_character_card(document: Dictionary) -> CharacterCard:
	var card = CharacterCard.new()
	var attack_points = document['attackPoint']
	card.attack_points[Chronos.Period.NIGHT] = attack_points['night']
	card.attack_points[Chronos.Period.DAY] = attack_points['day']
	return card


func _get_enchant_card(document: Dictionary) -> EnchantCard:
	var card = EnchantCard.new()
	var effect = document['effect']
	match effect['type']:
		'swapDayAndNightAttackPoint':
			card.effect = SwapAtkEffect.new(
					_is_target_opponent(effect))
		var type:
			push_error('Undefined effect type: %s', type)
			card.effect = CardEffect.new()
	return card


func _is_target_opponent(effect: Dictionary) -> bool:
	return effect['fields']['target'] == 'opponent'
