class_name Player
extends Node2D

@export var card_scene: PackedScene
var hp = 100
var card_hover: Card
var card_hover_candidates = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$HpLabel.text = "HP: " + str(hp)


func draw():
	var card = card_scene.instantiate()
	card.player = self
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
			return
		
		if $SetField.is_more_card_available():
			$Hand.remove_card(card)
			$SetField.add_card(card)
			return
			
	if card.get_parent() == $BattleField:
		$BattleField.unset_card(card)
		$Hand.add_card(card)
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


func _on_draw_button_pressed():
	draw()
