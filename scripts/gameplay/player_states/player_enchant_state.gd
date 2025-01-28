class_name PlayerEnchantState
extends PlayerState


func run_async():
	var set_a_card = _card_fields.set_a_field_card
	if set_a_card is CharacterCard:
		_card_fields.dump_card(_card_fields.battle_field_card)
		_card_fields.move_card(set_a_card, CardFields.Field.BATTLE)
	elif set_a_card is EnchantCard:
		set_a_card.enchant()
	var set_b_card = _card_fields.set_b_field_card
	if set_b_card is EnchantCard:
		set_b_card.enchant()
