class_name DebugController
extends Controller

var _player: GamePlayerContext
var _player_name: String
var _field_v = [5]
var _card_v = []
var _field:
	get:
		return _field_v.front()


func _init(player: GamePlayerContext, player_name: String):
	_player = player
	_player_name = player_name


func _ready():
	if Engine.has_singleton("ImGuiGD"):
		ImGuiGD.Connect(_on_imgui_layout)


func _on_imgui_layout():
	ImGui.Begin('Controller: ' + _player_name)
	ImGui.Combo('Field', _field_v, Player.Field.keys())
	var cards = _player.get_cards(_field)
	ImGui.ListBox('Cards', _card_v, cards, len(cards))
	if ImGui.Button('Select'):
		var card = cards[_card_v.front()]
		card_selected.emit(card)
	if ImGui.Button('Ready'):
		player_ready.emit()
	ImGui.End()
