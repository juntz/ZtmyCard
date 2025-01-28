class_name GameMaster
extends Node

var _game := Game.new()


func _ready():
	$"../Chronos".chronos = _game.chronos
	_game.players = _ready_players()
	await _game.play_async()
	_end_game()


func _ready_players() -> Array[Player]:
	var players: Array[Player]
	var card_node_factory := CardNodeFactory.new(_game)
	var player_nodes = [$"../Player", $"../Opponent"]
	for player_node in player_nodes:
		var card_nodes = _get_deck(card_node_factory, player_node)
		var cards: Array[Card]
		cards.assign(card_nodes.map(func (x): return x.card))
		var player = Player.new(cards, _game)
		player_node.player = player
		player.card_fields.card_moved.connect(player_node.move_card)
		players.append(player)
	return players


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
	
	card_numbers.shuffle()
	
	for card_number in card_numbers:
		var card = card_node_factory.from_number(card_number)
		card.card_entered.connect(player_node._on_card_entered)
		card.card_exited.connect(player_node._on_card_exited)
		card.card_clicked.connect(player_node._on_card_clicked)
		player_node.get_node("DeckZone").add_child(card)
		deck.append(card)
	return deck


func _end_game():
	$"../GameEndOverlay".visible = true
	$"../GameEndOverlay/AnimationPlayer".play("game_end")
