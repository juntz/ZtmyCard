class_name GamePlayerControl

signal ready

const MULLIGAN_CARD_COUNT:int = 5

var is_alive: bool:
	get:
		return _player.hp > 0

var _player: GamePlayer
var _controller: Controller


func _init(player: Player, controller: Controller):
	_player = player
	_controller = controller
	controller.player_ready.connect(ready.emit)


func mulligan_async():
	_player.shuffle_deck()
	draw_cards(MULLIGAN_CARD_COUNT)
	var selected_cards = await _controller.request_select_cards_async(
			_player.get_cards_idx(Player.Field.HAND))
	for card in selected_cards:
		_player.move_cards(card,
				Player.Field.HAND,
				Player.Field.DECK)
	_player.shuffle_deck()
	draw_cards(len(selected_cards))


func draw_cards(count: int):
	for i in count:
		_player.draw_card()
