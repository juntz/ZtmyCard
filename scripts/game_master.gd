class_name GameMaster
extends Node

enum Phase{SET, OPEN, CLOCK, ENCHANT, BATTLE}

const MULLIGAN_COUNT = 5

var players = {}
var phase = Phase.BATTLE
var ready_status = {}
@onready var chronos: Chronos = $"../Chronos"
var enchant_processor: EnchantProcessor


# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	var id = multiplayer.get_unique_id()
	players[id] = $"../Player"
	ready_status[id] = _get_init_ready_status()
	chronos.turn_done.connect(_on_chronos_turn_done)
	enchant_processor = EnchantProcessor.new($"..", $"../Player", $"../Opponent")
	add_child(enchant_processor)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _is_ready_for_next_phase():
		_process_phase_transition()
		_reset_ready_status()
	if phase == Phase.OPEN:
		if players.values().all(func(x): return x.is_all_card_open()):
			next_phase_ready()


func select_card(player: Player, card: Card):
	if card.get_parent() == player.card_fields[CardField.Field.SELECTION]:
		card.selectable = false
		card.unset_hover()
		_move_card(player, card, CardField.Field.ABYSS)
		player.draw_require_count += 1
		return true
	
	if card.get_parent() == player.card_fields[CardField.Field.HAND]:
		if player.controllable:
			pass
		if player.card_fields[CardField.Field.BATTLE].cards().size() <= 0 && (card.info["type"] == "character"):
			_move_card(player, card, CardField.Field.BATTLE)
			player.draw_require_count += 1
		elif player.card_fields[CardField.Field.SET].cards().size() < player.setable_card_count:
			_move_card(player, card, CardField.Field.SET)
			player.draw_require_count += 1
		else:
			return false
		return true
	
	_move_card(player, card, CardField.Field.HAND)
	player.draw_require_count -= 1
	return true


func next_phase_ready():
	var id = multiplayer.get_unique_id()
	var next_phase = _get_next_phase()
	ready_status[id][next_phase] = true
	next_phase_ready_remote.rpc(next_phase)
	print("Player " + str(id) + " is ready for the next phase (" + Phase.keys()[next_phase] + ").")


@rpc("any_peer")
func next_phase_ready_remote(target_phase: Phase):
	var sender_id = multiplayer.get_remote_sender_id()
	ready_status[sender_id][target_phase] = true


func _move_card(player: Player, card: Card, to: CardField.Field):
	var from = player.find_card_field(card)
	var idx = player.find_card_index(card, from)
	move_card.rpc(from, idx, to)


@rpc("any_peer", "call_local")
func move_card(from, idx, to):
	var player = _get_player()
	var from_field = player.card_fields[from]
	var card = from_field.cards()[idx]
	var to_field = player.card_fields[to]
	card.reparent(to_field)
	

@rpc("any_peer")
func open_card(from, idx, info):
	var player = _get_player()
	var from_field = player.card_fields[from]
	var card: Card = from_field.cards()[idx]
	card.set_info(info)
	card.show_card()


func finish_mulligan():
	var player = _get_player()
	for card in player.card_fields[CardField.Field.SELECTION].cards():
		_move_card(player, card, CardField.Field.HAND)
	for card in player.card_fields[CardField.Field.ABYSS].cards():
		card.close_card()
		card.selectable = false
		_move_card(player, card, CardField.Field.DECK)
	player.card_fields[CardField.Field.DECK].shuffle()


func _ready_mulligan():
	var player = _get_player()
	for i in range(MULLIGAN_COUNT):
		_draw_card(player, CardField.Field.SELECTION)


func _get_init_ready_status():
	var result = {}
	for status in Phase.values():
		result[status] = false
	return result


# Return the player who calls this function
func _get_player() -> Player:
	var id = multiplayer.get_remote_sender_id()
	if id == 0:
		id = multiplayer.get_unique_id()
	return players[id]


func _process_phase_transition():
	phase = _get_next_phase()
	print("Current phase: " + Phase.keys()[phase])
	
	if phase == Phase.SET:
		for player: Player in players.values():
			for i in range(player.draw_require_count):
				_draw_card(player)
			player.set_battle_button_state(true)
	elif phase == Phase.OPEN:
		_get_player().set_battle_button_state(false)
		_open_cards()
	elif phase == Phase.CLOCK:
		_ready_battle()
		_update_chronos()
	elif phase == Phase.ENCHANT:
		_apply_enchant()
	elif phase == Phase.BATTLE:
		_battle()
		_end_battle()


func _draw_card(player: Player, to = CardField.Field.HAND):
	var deck_cards = player.card_fields[CardField.Field.DECK].cards()
	if deck_cards.size() == 0:
		return
	
	var card: Card = deck_cards[-1]
	_move_card(player, card, to)
	card.show_card()
	if player.controllable:
		card.selectable = true


func _drop_card(player: Player, card: Card):
	var target_card_field = CardField.Field.POWER_CHARGER \
		if int(card.info["sendToPower"]) > 0 else \
		CardField.Field.ABYSS
	_move_card(player, card, target_card_field)


func _open_cards():
	var player = _get_player()
	for field in [CardField.Field.BATTLE, CardField.Field.SET]:
		var cards = player.card_fields[field].cards()
		for i in len(cards):
			var card: Card = cards[i]
			open_card.rpc(field, i, card.info)


func _battle():
	var total_attack_point = players.values().map(
		func(p): return p.get_attack_point(chronos.is_night())
	).reduce(
		func(a, b): return a + b
	)
	for player: Player in players.values():
		var damage = total_attack_point - 2 * player.get_attack_point(chronos.is_night())
		if damage < 0:
			player.attack(damage)
		else:
			player.hit(damage)
			
	next_phase_ready()


func _update_chronos():
	var total_clock = players.values().map(func(x): return x.get_clock()).reduce(func(a, b): return a + b)
	chronos.turn(total_clock)


func _apply_enchant():
	enchant_processor.enchant_end.connect(_on_enchant_end)
	_on_enchant_end()


func _on_enchant_end():
	var player = _get_player()
	var set_field = player.card_fields[CardField.Field.SET]
	var cards = set_field.cards()
	if cards.size() > 0:
		var card = cards[0]
		_move_card(player, card, CardField.Field.ENCHANT)
		enchant_processor.apply_enchant(card)
	else:
		enchant_processor.enchant_end.disconnect(_on_enchant_end)
		next_phase_ready()


func _ready_battle():
	var player = _get_player()
	_swap_battle_field_card(player)
	for field in [CardField.Field.BATTLE, CardField.Field.SET]:
		for card in player.card_fields[field].cards():
			card.selectable = false


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
		move_card.rpc(CardField.Field.BATTLE, 0, drop_target_field)
		move_card.rpc(CardField.Field.SET, i, CardField.Field.BATTLE)
		return


func _end_battle():
	var player = _get_player()
	for card in player.card_fields[CardField.Field.ENCHANT].cards():
		_drop_card(player, card)


func _is_ready_for_next_phase():
	var next_phase = _get_next_phase()
	return ready_status.values().all(func(x): return x[next_phase])
	
	
func _get_next_phase() -> Phase:
	return (phase + 1) % Phase.size()


func _reset_ready_status():
	for key in ready_status.keys():
		ready_status[key][phase] = false

	
func _on_peer_connected(id):
	players[id] = $"../Opponent"
	ready_status[id] = _get_init_ready_status()
	_ready_mulligan()


func _on_chronos_turn_done():
	next_phase_ready()
