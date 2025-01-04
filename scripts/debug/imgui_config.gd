extends Node


func _ready():
	if Engine.has_singleton("ImGuiAPI"):
		ImGui.GetIO().ConfigFlags |= ImGui.ConfigFlags_DockingEnable
		ImGui.GetIO().ConfigFlags |= ImGui.ConfigFlags_ViewportsEnable
