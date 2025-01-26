extends Node

var _game: GameMaster
var _players: Array[GamePlayer] = []
var _logs: Array[String] = []


func _init():
	var chronos = GameChronos.new()
	for player_name in ['Nira', 'Uniguri']:
		var context = GamePlayerContext.new([
			GameCard.new()
		])
		var controller = DebugController.new(context, player_name)
		add_child(controller)
		var player = GamePlayer.new(context, controller, chronos)
		_players.append(player)
		var debug_player = DebugPlayer.new(context)
		debug_player.player_name = player_name
		add_child(debug_player)
	_game = GameMaster.new(_players)
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
