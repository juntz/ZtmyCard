class_name Player
extends Node2D

@export var card_scene: PackedScene
@export var controllable: bool
var hp = 100
var card_hover: Card
var card_hover_candidates = []
var battle_ready = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$HpLabel.text = "HP: " + str(hp)


func draw():
	var card = card_scene.instantiate()
	card.player = self
	if controllable:
		card.show_card()
	$Hand.add_card(card)


func card_clicked(card):
	if card != card_hover:
		return
		
	if !card.selectable:
		return
	
	if card.get_parent() == $Hand:
		if !$BattleField.card_set:
			$Hand.remove_card(card)
			$BattleField.set_card(card)
			$ReadyButton.disabled = false
			return
		
		if $SetField.is_more_card_available():
			$Hand.remove_card(card)
			$SetField.add_card(card)
			return
			
	if card.get_parent() == $BattleField:
		$BattleField.unset_card()
		$Hand.add_card(card)
		$ReadyButton.disabled = true
		return
		
	if card.get_parent() == $SetField:
		$SetField.remove_card(card)
		$Hand.add_card(card)


func set_card_hover(card):
	if !card_hover_candidates.has(card):
		card_hover_candidates.append(card)
	
	if !card_hover:
		card_hover = card
		card.set_hover(true)
		return
		
	if card.order > card_hover.order:
		card_hover.set_hover(false)
		card_hover = card
		card.set_hover(true)
		

func unset_card_hover(card):
	card_hover_candidates.erase(card)
	if card == card_hover:
		card.set_hover(false)
		card_hover = null
		
	for card_hover_candidate in card_hover_candidates:
		set_card_hover(card_hover_candidate)


func get_battle_field_card():
	return $BattleField.card_set
	

func get_set_field_cards():
	return $SetField.get_cards()


func get_set_cards():
	var result = get_set_field_cards()
	result.append(get_battle_field_card())
	return result


func get_attack_point(is_night: bool):
	var card = $BattleField.card_set
	return card.night_attack_point if is_night else card.day_attack_point


func ready_battle():
	for card in get_set_cards():
		card.show_card()
		
	for card in get_set_field_cards():
		if card.type == Card.CardType.CHARACTER:
			$BattleField.drop_card()
			$SetField.remove_card(card)
			$BattleField.set_card(card)
			return


func clean_up_battle():
	for card in get_set_field_cards():
		$SetField.remove_card(card)
		card.position = Vector2()
		$Abyss.add_child(card)


func _on_draw_button_pressed():
	draw()


func _on_ready_button_pressed():
	battle_ready = true
