class_name SwapAtkEffect
extends CardEffect

var _is_target_opponent: bool
var _target: Player:
	get:
		return game.get_opponent(player) if _is_target_opponent else player


func _init(is_target_opponent: bool):
	_is_target_opponent = is_target_opponent


func apply():
	_swap_atk()


func revoke():
	_swap_atk()


func _swap_atk():
	var card = _target.card_fields.battle_field_card
	if card == null:
		return
	card.attack_points = {
		Chronos.Period.DAY: card.attack_points[Chronos.Period.NIGHT],
		Chronos.Period.NIGHT: card.attack_points[Chronos.Period.DAY],
	}
