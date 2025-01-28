class_name PlayerNode
extends Node2D

enum Field{NONE, BATTLE, SET, ABYSS, POWER_CHARGER, DECK, HAND, ENCHANT, SELECTION}

signal on_hit

@export var card_scene: PackedScene
@export var controllable: bool
@export var game_master: GameMaster
var player: Player
var draw_require_count = 0
var attack_point_addend = 0
var damage_subtrahend = 0
var damage_got = 0
var swap_day_and_night_attack_point = false
var card_fields = {}
var prev_battle_field_card = null

var CHEAT_super_powered = false


func hp() -> int:
	return $HpBar.hp


func set_battle_button_state(enable: bool):
	$ReadyButton.disabled = !enable;


func get_cards(field: Field) -> Array[CardNode]:
	return card_fields[field].cards()


func move_card(card: Card, to: CardFields.Field):
	var node = _get_card_node(card)
	var to_field = _get_field(to)
	node.show_card()
	node.reparent(to_field)


func _get_card_node(card: Card) -> CardNode:
	for field in card_fields.values():
		for c in field.cards():
			if c.card == card:
				return c
	return null


func _get_field(base_field: CardFields.Field) -> CardField:
	var field: Field
	match base_field:
		CardFields.Field.SET_A, CardFields.Field.SET_B, CardFields.Field.SET_C:
			field = Field.SET
		_:
			field = Field[CardFields.Field.find_key(base_field)]
	return card_fields[field]


func attack(damage):
	damage_got = damage
	$AnimationPlayer.play("attack_start")
	await $AnimationPlayer.animation_finished
	on_hit.emit()
	$AnimationPlayer.play("attack_end")
	await $AnimationPlayer.animation_finished


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
		for card: CardNode in card_fields[field].cards():
			if card.is_closed():
				return false
	return true


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
	
	if !controllable:
		$ReadyButton.visible = false
		$MulliganZone.visible = false
	
	$MulliganZone.card_selected.connect(_on_mulligan_card_selected)


func abyss_attribute_count():
	var attributes = {}
	for card in $Abyss.cards():
		attributes[card.info["attribute"]] = null
	return attributes.keys().size()


func _hit():
	if damage_got < 0:
		return
	
	$HpBar.hp -= damage_got
	if $HpBar.hp < 0:
		$HpBar.hp = 0

	
func _on_attack_end(card):
	card.reparent($BattleField)
	card.scale = Vector2(1, 1)


func _on_ready_button_pressed():
	player.player_ready()


func _on_selection_done_button_pressed():
	$MulliganZone/SelectionDoneButton.visible = false
	$MulliganZone.visible = false
	player.player_ready()


func _on_card_entered(card: CardNode):
	$"../CardInfoContainer".set_card(card, true)


func _on_card_exited(card: CardNode):
	if $"../CardInfoContainer".card == card:
		$"../CardInfoContainer".unset_card()


func _on_mulligan_card_selected(card: CardNode):
	player.select_card(card.card)


func find_card_field(card: CardNode) -> Field:
	for field in card_fields.keys():
		if get_cards(field).has(card):
			return field
	return Field.NONE


func find_card_index(card: CardNode, field: Field) -> int:
	return get_cards(field).find(card)


func _on_card_clicked(card: CardNode):
	player.select_card(card.card)
