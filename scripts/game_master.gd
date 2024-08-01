class_name GameMaster
extends Node

enum Phase{SET, CLOCK, ENCHANT, BATTLE}

var players = {}
var phase = Phase.SET
var ready_status = {}
@onready var chronos: Chronos = $"../Chronos"


# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	var id = multiplayer.get_unique_id()
	players[id] = $"../Player"
	ready_status[id] = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !multiplayer.is_server():
		return
	
	if _is_ready_for_next_phase():
		_process_phase_transition()
		_reset_ready_status()


@rpc("any_peer", "call_local")
func select_card(field, idx):
	var sender_id = multiplayer.get_remote_sender_id()
	var player: Player = players[sender_id]
	var card = player.card_fields[field].cards()[idx]
	player.select_card(card)


@rpc("any_peer")
func next_phase_ready():
	var sender_id = multiplayer.get_remote_sender_id()
	ready_status[sender_id] = true


func _process_phase_transition():
	var next_phase = (phase + 1) % Phase.size()
	phase = next_phase
	print("Current phase: " + Phase.keys()[phase])
	
	if phase == Phase.SET:
		for player in players:
			player.draw()
	elif phase == Phase.CLOCK:
		_open_cards()
		_ready_battle()
		_update_chronos()
	elif phase == Phase.ENCHANT:
		_apply_enchant()
	elif phase == Phase.BATTLE:
		_battle()


func _open_cards():
	for id in players.keys():
		var player: Player = players[id]
		for field in [CardField.Field.BATTLE, CardField.Field.SET]:
			var cards = player.card_fields[field].cards()
			for i in len(cards):
				var card: Card = cards[i]
				player.show_card.rpc(field, i, card.info)


func _battle():
	var total_attack_point = players.values().map(
		func(p): return p.get_attack_point(chronos.is_night())
	).reduce(
		func(a, b): return a + b
	)
	for player in players.values():
		var damage = total_attack_point - 2 * player.get_attack_point(chronos.is_night())
		if damage < 0:
			player.attack(damage)
		else:
			player.hit(damage)


func _update_chronos():
	var total_clock = players.values().map(func(x): return x.get_clock()).reduce(func(a, b): return a + b)
	chronos.turn.rpc(total_clock)


func _apply_enchant():
	pass


func _ready_battle():
	for player: Player in players.values():
		_swap_battle_field_card(player)


func _swap_battle_field_card(player: Player):
	var set_field_cards = player.card_fields[CardField.Field.SET].cards()
	for i in set_field_cards.size():
		var card = set_field_cards[i]
		if card.info["type"] != "character":
			continue
		
		var battle_field_cards = player.card_fields[CardField.Field.BATTLE].cards()
		if battle_field_cards.size() == 0:
			return
		
		var drop_target_field = CardField.Field.ABYSS
		if battle_field_cards[0].info["sendToPower"] > 0:
			drop_target_field = CardField.Field.POWER_CHARGER
		player.move_card.rpc(CardField.Field.BATTLE, 0, drop_target_field)
		player.move_card.rpc(CardField.Field.SET, i, CardField.Field.BATTLE)
		return


func _end_battle():
	pass


func _is_ready_for_next_phase():
	return ready_status.values().all(func(x): return x)
	

func _reset_ready_status():
	for key in ready_status.keys():
		ready_status[key] = false

	
func _on_peer_connected(id):
	players[id] = $"../Opponent"
	ready_status[id] = false
