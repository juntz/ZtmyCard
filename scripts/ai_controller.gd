extends Node

@export var main: Main
@export var player: Player
@export var card_delay = 1.0


func _on_timer_timeout():
	if player.hp() <= 0:
		$Timer.stop()
	
	if main.phase != Main.Phase.SET:
		return
		
	if player.ready_status[Main.Phase.BATTLE]:
		return
		
	var hand_card_count = player.hand_cards().size()
	for card in player.hand_cards():
		if player.check_powered(card):
			if player.select_card(card):
				return
	
	for card in player.hand_cards():
		if card.info["sendToPower"] > 0:
			if player.select_card(card):
				return
		
	if hand_card_count == player.hand_cards().size():
		player.battle_ready()