class_name PlayerBattleState
extends PlayerState

const SET_CARD_LIMIT_WIN = 1
const SET_CARD_LIMIT_LOSE = 2

var _total_attack_point: int:
	get:
		return _game.players.map(
			func(p): return _get_attack_point(p)).reduce(
			func(a, b): return a + b)


func run_async():
	var damage = _get_damage(_player)
	if damage > 0:
		_player.hp -= damage
		_player.card_set_limit = SET_CARD_LIMIT_LOSE
	else:
		_player.card_set_limit = SET_CARD_LIMIT_WIN
	_card_fields.dump_card(_card_fields.set_b_field_card)
	_card_fields.dump_card(_card_fields.set_a_field_card)


func _get_damage(player: Player) -> int:
	return _total_attack_point - 2 * _get_attack_point(player)


func _get_attack_point(player: Player) -> int:
	var card = player.card_fields.battle_field_card
	if card == null:
		return 0
	var period = _game.chronos.period
	return card.attack_points[period]
