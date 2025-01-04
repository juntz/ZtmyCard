class_name DebugPlayer
extends Node

var _player_name: String
var _player: Player
var _logs: Array[String] = []


func _init(player_name: String, player: Player):
	_player_name = player_name
	_player = player
	player.card_moved.connect(_on_card_moved)
	player.hp_changed.connect(_on_hp_changed)


func _ready():
	if Engine.has_singleton("ImGuiGD"):
		ImGuiGD.Connect(_on_imgui_layout)


func _on_imgui_layout():
	ImGui.Begin('Player: ' + _player_name)
	ImGui.Text("Logs")
	ImGui.BeginChild("Logs");
	for log_line in _logs:
		ImGui.Text(log_line)
	ImGui.EndChild()
	ImGui.End()


func _on_hp_changed(hp: int):
	_logs.append('HP: %s' % [hp])


func _on_card_moved(position: int, from: Player.Field, to: Player.Field):
	var from_name = Player.Field.find_key(from)
	var to_name = Player.Field.find_key(to)
	_logs.append('%s[%s] -> [%s]' % [from_name, position, to_name])
