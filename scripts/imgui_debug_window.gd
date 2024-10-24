extends Node

var config = preload("res://properties/imgui_debug_window_settings.tres")
var is_imgui_available: bool:
	get:
		return Engine.has_singleton("ImGuiAPI")
		
var imgui: Object:
	get:
		return Engine.get_singleton("ImGuiAPI")
		
var imgui_gd: Object:
	get:
		return Engine.get_singleton("ImGuiGD")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not is_imgui_available:
		return
	
	imgui.GetIO().ConfigFlags |= imgui.ConfigFlags_DockingEnable
	imgui.GetIO().ConfigFlags |= imgui.ConfigFlags_ViewportsEnable

	imgui_gd.ResetFonts()

	var font : FontFile = load(config.font_path)

	var font_size := 24

	# 한국어 범위 알려줘야함 - 코드는 imgui 원본 소스코드에서 긁어옴(MIT 라이센스)
	var korean_glyph_range  : PackedInt32Array = PackedInt32Array([
		0x0020, 0x00FF,# Basic Latin + Latin Supplement
		0x3131, 0x3163,# Korean alphabets
		0xAC00, 0xD7A3,# Korean characters
		0xFFFD, 0xFFFD,#Invalid
		0,
	])
	
	imgui_gd.AddFont(font, font_size, false, korean_glyph_range)
	imgui_gd.AddFontDefault()
	imgui_gd.RebuildFontAtlas()

var _player : Player = null
var _game_master : GameMaster = null
enum SupportType {
	PLAYER,
	GAME_MASTER,
}


func watch(inst : Object, type : SupportType):
	if not config.visible:
		return 

	if type == SupportType.PLAYER:
		_player = inst as Player

	if type == SupportType.GAME_MASTER:
		_game_master = inst as GameMaster
		

# imgui GDScript 한계상 Primitive 값들의 ref를 전달하기 위해 array를 사용합니다.
# return 값은 UI동작 여부만 나오고. 실제 값은 Array 던진거 받아서 다시 까봐야 합니다. 
# 구조가 좀 바보같지만.
# GDScript에서 GDScript Object의 ref를 GDExtension으로 아름답게 전달하는 방법이 나오지 않는 한 이렇게 사용해야 할 것 같습니다.

func enum_to_str(v: int, enum_obj) -> String:
	for key in enum_obj.keys():
		if enum_obj[key] == v:
			return key

	return "Unknown"

var _set_time : int = 0
var _input_heal : int = 0

func main_window_draw():
	imgui.Begin("Main Window")
	if _game_master == null:
		imgui.Text("Game Master is not set.")
		imgui.End()
		return

	var phase_str := enum_to_str(_game_master.phase as int, GameMaster.Phase)

	imgui.Text("Game Master")
	imgui.Text("Phase: %s" % [phase_str])
	if _game_master.multiplayer:
		imgui.Text("ID? %s" % [_game_master.multiplayer.get_unique_id()])

	var chronos := _game_master.chronos
	var is_night : bool = chronos.is_night()
	var time = chronos.time
	var text := "Day"
	if is_night:
		text = "Night"
	
	imgui.Text("Time? - %s(%d)" % [text, time])
	var _set_time_arr := [_set_time]
	if imgui.InputInt("##choosetime", _set_time_arr):
		_set_time = _set_time_arr[0]
		_set_time = min(_set_time, Chronos.TOTAL_STEP)
		_set_time = max(_set_time, 0)

	if imgui.Button("Set Time (0~18)"):
		chronos.set_time.rpc(_set_time)

	var input = [_player.CHEAT_super_powered]
	if imgui.Checkbox("Super Powered", input):
		_player.CHEAT_super_powered = input[0]

	imgui.Text("Power? - %d" % [_player.get_charged_power()])
	imgui.Text("HP? - %d" % [_player.hp()])

	input = [_input_heal]
	if imgui.InputInt("Heal Amount", input):
		_input_heal = input[0]

	if imgui.Button("Heal"):
		_game_master.force_heal.rpc(_input_heal)

	imgui.End()



var _input_id : String = ""
var json = null
var cardInfos = null
var cardInfosKeyName : Dictionary = {}
@export var card_scene: PackedScene = preload("res://scenes/card.tscn")

func _hand_debugger():
	var hand_cards := _player.get_cards(Player.Field.HAND)
	imgui.Text("Card Count: %d" % [hand_cards.size()])


	imgui.Separator()

	if json == null:
		var f = FileAccess.open("cards/cards.json", FileAccess.READ)
		json = JSON.parse_string(f.get_as_text())
		cardInfos = json["cards"]

		for cardInfo in cardInfos:
			cardInfosKeyName[cardInfo["name"]["ko"] + " - " + str(cardInfo["number"])] = cardInfo


	var _input_id_arr := [_input_id]
	if imgui.InputText("Card Name? (cards.json 참고)", _input_id_arr, 40): 
		_input_id = _input_id_arr[0]
	
	if imgui.Button("Create Card"):
		_game_master._add_card(cardInfosKeyName[_input_id]["number"], Player.Field.HAND)

	if not cardInfosKeyName.is_empty():
		var keys = cardInfosKeyName.keys()
		for key in keys:
			if cardInfosKeyName[key]["name"]["en"].find(_input_id) != -1 || key.find(_input_id) != -1:
				if imgui.Selectable(key):
					_input_id = key


	for i in range(hand_cards.size()):
		var card = hand_cards[i]
		var card_info = card.info
		var card_name = card_info["name"]
		var card_name_str = ""
		if card_name.has("ko"):
			card_name_str = card_name["ko"]
		else:
			card_name_str = card_name["ja"]

		var card_type = card_info["type"]
		
		var card_power_cost = card_info["powerCost"]


		imgui.Text("%s - %s : %s" % [card_name_str, card_type, card_power_cost]); 
		
	
		if card_info.has("attackPoint"):
			var card_attack_point = card_info["attackPoint"]
			imgui.Text("Card Attack Point: Day : %s / Night : %s" % [card_attack_point["day"], card_attack_point["night"]])
		else:
			imgui.Text("Card Attack Point: None")


		imgui.Separator()

func card_field_editor():
	imgui.Begin("Card Field Editor")

	if _player == null: 
		imgui.Text("Player is not set.")
		imgui.End()
		return

	

	if imgui.TreeNode("# Hand Card Editor"):
		_hand_debugger()

	

	imgui.End()
	

func field_editor(): 
	pass 
# imgui는 코드 호출로 UI를 그리는 방식입니다. imgui.Begin으로 시작하고, Text로 넣으면 적당히 예쁘게 그려줍니다.
# 직접 제어를 원한다면 ImDrawList를 사용하면 됩니다.
func _process(_delta: float) -> void:
	if not is_imgui_available:
		return
	
	if not config.visible:
		return

	main_window_draw()
	card_field_editor()
