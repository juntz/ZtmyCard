class_name DebugController
extends Controller

var _player_name: String
var _from = []
var _to = []


func _init(player_name: String):
	_player_name = player_name


func _ready():
	if Engine.has_singleton("ImGuiGD"):
		ImGuiGD.Connect(_on_imgui_layout)


func _on_imgui_layout():
	ImGui.Begin('Controller: ' + _player_name)
	ImGui.Combo('From', _from, Player.Field.keys())
	ImGui.Combo('To', _to, Player.Field.keys())
	if ImGui.Button('Move'):
		pass
	
	if ImGui.Button('Ready'):
		player_ready.emit()
	ImGui.End()
