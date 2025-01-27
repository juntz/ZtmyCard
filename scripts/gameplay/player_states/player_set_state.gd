class_name PlayerBattleState
extends PlayerState


func start():
	
	_clear_set_field()


func select_card(card: Card) -> void:
	pass


func _clear_set_field():
	_dump_last_card(CardFields.Field.SET_A)
	_dump_last_card(CardFields.Field.SET_B)


func _dump_last_card(field: CardFields.Field):
	_card_fields.dump_card(
			_card_fields.get_last_card(field))
