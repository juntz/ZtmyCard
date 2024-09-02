extends Node

var config : ImGuiDebugConfig = preload("res://imgui_debug_window_settings.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ImGui.GetIO().ConfigFlags |= ImGui.ConfigFlags_DockingEnable
	ImGui.GetIO().ConfigFlags |= ImGui.ConfigFlags_ViewportsEnable

	ImGuiGD.ResetFonts()

	var font : FontFile = load(config.font_path)

	var font_size := 24

	# 한국어 범위 알려줘야함 - 코드는 ImGui 원본 소스코드에서 긁어옴(MIT 라이센스)
	var korean_glyph_range  : PackedInt32Array = PackedInt32Array([
		0x0020, 0x00FF,# Basic Latin + Latin Supplement
		0x3131, 0x3163,# Korean alphabets
		0xAC00, 0xD7A3,# Korean characters
		0xFFFD, 0xFFFD,#Invalid
		0,
	])
	
	ImGuiGD.AddFont(font, font_size, false, korean_glyph_range)
	ImGuiGD.AddFontDefault()
	ImGuiGD.RebuildFontAtlas()

# ImGui GDScript 한계상 Primitive 값들의 ref를 전달하기 위해 array를 사용합니다.
# return 값은 UI동작 여부만 나오고. 실제 값은 Array 던진거 받아서 다시 까봐야 합니다. 
# 구조가 좀 바보같지만.
# GDScript에서 GDScript Object의 ref를 GDExtension으로 아름답게 전달하는 방법이 나오지 않는 한 이렇게 사용해야 할 것 같습니다.

func main_window_draw():
	ImGui.Begin("Main Window")
	ImGui.Text("Hello, world!")
	ImGui.End()


func field_editor(): 
	pass 
# ImGui는 코드 호출로 UI를 그리는 방식입니다. ImGui.Begin으로 시작하고, Text로 넣으면 적당히 예쁘게 그려줍니다.
# 직접 제어를 원한다면 ImDrawList를 사용하면 됩니다.
func _process(delta: float) -> void:
	if not config.visible:
		return
	main_window_draw()
