class_name PlayerSetState
extends PlayerState

const SET_CARD_LIMIT_WIN = 1
const SET_CARD_LIMIT_LOSE = 2

var _total_attack_point: int:
	get:
		return _game.players.map(
			func(p): return _get_attack_point(p)).reduce(
			func(a, b): return a + b)


func start():
	var damage = _get_damage(_player)
	_player.hp -= damage
	_player.card_set_limit = SET_CARD_LIMIT_LOSE if damage > 0 else SET_CARD_LIMIT_WIN


func _get_damage(player: Player) -> int:
	return _total_attack_point - 2 * _get_attack_point(player)


func _get_attack_point(player: Player) -> int:
	var card = _get_battle_field_card(player)
	if card == null:
		return 0
	if !card is CharacterCard:
		push_error("A non-character card has been set on the battlefield.")
		return 0
	var period = _game.chronos.period
	return card.attack_points[period]
	

func _get_battle_field_card(player: Player):
	return player.card_fields.get_last_card(CardFields.Field.BATTLE)
