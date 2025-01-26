class_name PlayerBattleState
extends PlayerState


func start():
	
	_clear_set_field()
	
	
func _clear_set_field():
	_player.dump_card(_player.get_last_card(Player.Field.SET_A))
	_player.dump_card(_player.get_last_card(Player.Field.SET_B))
