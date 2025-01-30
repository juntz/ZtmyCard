class_name GameMaster
extends Node

var players: Array[Player]
var player_nodes: Array[PlayerNode]:
	get:
		return [$"../Player", $"../Opponent"]
var chronos_node: ChronosNode:
	get:
		return $"../Chronos"
var _game := Game.new()
var _game_signal_processor: GameSignalProcessor


func _ready():
	_ready_players()
	_game.players = players
	_game_signal_processor = GameSignalProcessor.new(_game, self)
	if !multiplayer.is_server():
		return
	await multiplayer.peer_connected
	await _game.play_async()
	_end_game()


func execute_command(command: Command):
	_execute_command.rpc(
			var_to_bytes_with_objects(command))


@rpc("call_local")
func _execute_command(serialized_command):
	# TODO: It is recommended to use a different serialization method for security reasons.
	# https://docs.godotengine.org/en/stable/classes/class_%40globalscope.html#class-globalscope-method-bytes-to-var-with-objects
	var command: Command = bytes_to_var_with_objects(serialized_command)
	if command is not Command:
		push_error("The received command is invalid or unrecognized.")
		return
	command.game_master = self
	await command.execute_async()


func _ready_players() -> void:
	var card_node_factory := CardNodeFactory.new(_game)
	for player_node in player_nodes:
		var card_nodes = _get_deck(card_node_factory, player_node)
		var cards: Array[Card]
		cards.assign(card_nodes.map(func (x): return x.card))
		var player = Player.new(cards, _game)
		player_node.player = player
		players.append(player)


func _get_deck(card_node_factory: CardNodeFactory, player_node: PlayerNode) -> Array[CardNode]:
	var deck: Array[CardNode]
	var card_numbers: Array
	var deck_file_path = "user://deck.json"
	if FileAccess.file_exists(deck_file_path):
		var deck_file = FileAccess.open(deck_file_path, FileAccess.READ)
		var deck_json = JSON.parse_string(deck_file.get_as_text())
		card_numbers = deck_json["cards"]
		deck_file.close()
	else:
		card_numbers = range(1, 21)
	
	for i in len(card_numbers):
		var card_number = card_numbers[i]
		var card = card_node_factory.from_number(card_number)
		card.name = "Card%s" % i 
		card.card_entered.connect(player_node._on_card_entered)
		card.card_exited.connect(player_node._on_card_exited)
		card.card_clicked.connect(player_node._on_card_clicked)
		player_node.get_node("DeckZone").add_child(card)
		deck.append(card)
	return deck


func _end_game():
	$"../GameEndOverlay".visible = true
	$"../GameEndOverlay/AnimationPlayer".play("game_end")
