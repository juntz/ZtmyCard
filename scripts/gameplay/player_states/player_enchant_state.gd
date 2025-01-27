class_name PlayerEnchantState
extends PlayerState


func start():
	var set_a_card = _card_fields.get_last_card(CardFields.Field.SET_A)
	if !set_a_card:
		return
	var battle_card = _card_fields.get_last_card(CardFields.Field.BATTLE)
	_card_fields.dump_card(battle_card)
	_card_fields.move_card(set_a_card, CardFields.Field.BATTLE)
