class_name Player
extends Node2D

enum Field{NONE, BATTLE, SET, ABYSS, POWER_CHARGER, DECK, HAND, ENCHANT, SELECTION}

signal attack_end

@export var card_scene: PackedScene
@export var controllable: bool
@export var opponent: Player
@export var main: Main
@export var game_master: GameMaster
var draw_require_count = 0
var setable_card_count = 0
var attack_point_addend = 0
var attack_scale = 1.3
var damage_subtrahend = 0
var damage = 0
var swap_day_and_night_attack_point = false
var selection_field_target
var selection_field_parent
@onready var battle_field = $BattleField
@onready var set_field = $SetField
@onready var abyss = $Abyss
@onready var deck_zone = $DeckZone
@onready var hand = $Hand
var card_fields = {}
var prev_battle_field_card = null


@rpc("any_peer")
func show_card(field, idx, info):
	pass


func hp() -> int:
	return $HpBar.hp


func battle_ready():
	if controllable:
		game_master.next_phase_ready()


func set_battle_button_state(enable: bool):
	$ReadyButton.disabled = !enable;


func check_powered(card: Card):
	return card.info["powerCost"] <= get_charged_power()


func get_cards(field: Field) -> Array[Card]:
	return card_fields[field].cards()


func get_attack_point(is_night: bool) -> int:
	if $BattleField.cards().size() <= 0:
		return 0
	
	var card = $BattleField.cards()[0]
	if !check_powered(card):
		return 0
	
	var field_name = "night" if is_night != swap_day_and_night_attack_point else "day"
	var base_attack_point = int(card.info["attackPoint"][field_name])
	return base_attack_point + attack_point_addend;


func get_clock() -> int:
	var cards = get_cards(Field.BATTLE) + get_cards(Field.SET)
	return cards.filter(
		func(c): return c != prev_battle_field_card
	).filter(
		func(c): return check_powered(c)
	).map(
		func(c): return int(c.info["clock"])
	).reduce(
		func(a, b): return a + b,
		0
	)


func get_charged_power():
	return $PowerCharger.cards().map(
		func(c): return c.info["sendToPower"]
	).reduce(
		func(a, b): return a + b,
		0
	)


func attack(damage):
	self.damage = damage
	var card = battle_field_card()
	card.scale = Vector2(attack_scale, attack_scale)
	card.reparent($AttackPoints)
	setable_card_count = 1


func hit(damage):
	damage -= damage_subtrahend
	damage_subtrahend = 0
	if damage <= 0:
		damage = 0
		setable_card_count = 1
	else:
		setable_card_count = 2
	$HpBar.hp -= damage
	$HpBar/HpPathFollow/DamageLabel.text = "-" + str(damage)


func heal(amount):
	$HpBar/HpPathFollow/DamageLabel.text = "+" + str(amount)
	$HpBar.hp += amount
	if $HpBar.hp > 100:
		$HpBar.hp = 100


func end_battle():
	attack_point_addend = 0
	damage_subtrahend = 0
	swap_day_and_night_attack_point = false
	prev_battle_field_card = battle_field_card()


func battle_field_card():
	var cards = card_fields[Field.BATTLE].cards()
	if cards.size() > 0:
		return cards[0]
	return null


func is_all_card_open():
	for field in [Field.BATTLE, Field.SET]:
		for card: Card in card_fields[field].cards():
			if card.is_closed():
				return false
	return true


func send_cards_to_selection_field(cards, target_field, return_field):
	selection_field_parent = return_field
	selection_field_target = target_field
	$SelectionZone.start_selection(cards, _on_card_clicked)


# Called when the node enters the scene tree for the first time.
func _ready():
	card_fields[Field.BATTLE] = $BattleField
	card_fields[Field.SET] = $SetField
	card_fields[Field.ABYSS] = $Abyss
	card_fields[Field.POWER_CHARGER] = $PowerCharger
	card_fields[Field.DECK] = $DeckZone
	card_fields[Field.HAND] = $Hand
	card_fields[Field.ENCHANT] = $EnchantZone
	card_fields[Field.SELECTION] = $MulliganZone/SelectionField
	
	$CardInfoContainer.visible = false
	_init_deck()
	if !controllable:
		$ReadyButton.visible = false
		$MulliganZone.visible = false
	
	$MulliganZone.card_selected.connect(_on_card_selected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func abyss_attribute_count():
	var attributes = {}
	for card in $Abyss.cards():
		attributes[card.info["attribute"]] = null
	return attributes.keys().size()


func _init_deck():
	var f = FileAccess.open("cards/cards.json", FileAccess.READ)
	var json = JSON.parse_string(f.get_as_text())
	var cardInfos = json["cards"]
	f.close()
	
	var deck_card_info = []
	
	var deck_file_path = "user://deck.json"
	if FileAccess.file_exists(deck_file_path) && controllable:
		var deck_file = FileAccess.open(deck_file_path, FileAccess.READ)
		var deck_json = JSON.parse_string(deck_file.get_as_text())
		var card_numbers = deck_json["cards"]
		deck_file.close()
		
		for card_number in card_numbers:
			deck_card_info.append(cardInfos[card_number - 1])
	else:
		deck_card_info = cardInfos.slice(0, 20)
		
	deck_card_info.shuffle()
	for cardInfo in deck_card_info:
		var card = card_scene.instantiate()
		card.image_base_path = json["imageBasePath"]
		card.set_info(cardInfo)
		card.card_entered.connect(_on_card_entered)
		card.card_exited.connect(_on_card_exited)
		card.card_clicked.connect(_on_card_clicked)
		$DeckZone.add_child(card)


func _hit():
	if damage < 0:
		return
	
	$HpBar.hp -= damage
	if $HpBar.hp < 0:
		$HpBar.hp = 0

	
func _on_attack_end(card):
	card.reparent($BattleField)
	card.scale = Vector2(1, 1)
	attack_end.emit()


func _on_ready_button_pressed():
	battle_ready()


func _on_selection_done_button_pressed():
	$MulliganZone/SelectionDoneButton.visible = false
	$MulliganZone.visible = false
	game_master.finish_mulligan()
	game_master.next_phase_ready()


func _on_card_selected(selected, unselected):
	selected.reparent(selection_field_target)
	for card in unselected:
		card.reparent(selection_field_parent)


func _on_card_entered(card: Card):
	$CardInfoContainer.visible = true
	$CardInfoContainer.current_card = card
	$CardInfoContainer/CardInfo.texture = card.get_child(1).texture
	if card.info["powerCost"] > get_charged_power():
		$CardInfoContainer/UnpoweredMask.visible = true
	else:
		$CardInfoContainer/UnpoweredMask.visible = false
	$CardInfoContainer.visible = true
	if card.info.has("effect"):
		var desc = card.info["effect"]["description"];
		if desc.has("ko"):
			$CardInfoContainer/CardInfoLabel.text = desc["ko"]
	else:
		$CardInfoContainer/CardInfoLabel.text = ""


func _on_card_exited(card: Card):
	if $CardInfoContainer.current_card == card:
		$CardInfoContainer.visible = false


func find_card_field(card: Card) -> Field:
	for field in card_fields.keys():
		if get_cards(field).has(card):
			return field
	return Field.NONE


func find_card_index(card: Card, field: Field) -> int:
	return get_cards(field).find(card)


func _on_card_clicked(card: Card):
	game_master.select_card(self, card)
