class_name PlayerEnchantState
extends PlayerState


func _init(player: PlayerContext, chronos: Chronos):
	super._init(player)


func start():
	var set_a_card = _player.get_last_card(Player.Field.SET_A)
	if !set_a_card:
		return
	var battle_card = _player.get_last_card(Player.Field.BATTLE)
	_player.dump_card(battle_card)
	_player.move_card(set_a_card, Player.Field.BATTLE)
	
