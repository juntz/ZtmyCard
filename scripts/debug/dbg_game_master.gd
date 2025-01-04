extends Node

var _game: Game
var _players: Array[GamePlayerControl] = []
var _logs: Array[String] = []


func _init():
	for player_name in ['Nira', 'Uniguri']:
		var player = GamePlayer.new([])
		add_child(DebugPlayer.new(player_name, player))
		var controller = DebugController.new(player_name)
		add_child(controller)
		_players.append(
				GamePlayerControl.new(player, controller))
	_game = Game.new(_players)
	_game.battle_started.connect(_on_battle_started)
	await _game.play_async()


func _ready():
	if Engine.has_singleton("ImGuiGD"):
		ImGuiGD.Connect(_on_imgui_layout)


func _on_imgui_layout():
	ImGui.Begin('Game Master')
	ImGui.Text("Logs")
	ImGui.BeginChild("Logs");
	for log_line in _logs:
		ImGui.Text(log_line)
	ImGui.EndChild()
	ImGui.End()

func _on_battle_started():
	_logs.append("Battle started")
