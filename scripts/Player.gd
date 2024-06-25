class_name Player
extends Node2D

@export var card_scene: PackedScene
@export var controllable: bool
var card_hover: Card
var card_hover_candidates = []
var ready_status = {
	Main.Phase.DRAW: true,
	Main.Phase.SET: false,
	Main.Phase.OPEN: false,
	Main.Phase.READY: false,
	Main.Phase.CLOCK: false,
	Main.Phase.BATTLE: false,
	Main.Phase.END: false
}
var draw_require_count = 5
var setable_card_count = 0


func draw():
	for i in range(draw_require_count):
		_draw_card()
	draw_require_count = 0
	ready_status[Main.Phase.SET] = true


func card_clicked(card: Card):
	if card != card_hover:
		return
		
	if !card.selectable:
		return
	
	if card.get_parent() == $Hand:
		if $BattleField.cards().size() <= 0 && (card.info["type"] == "character"):
			card.reparent($BattleField)
			$ReadyButton.disabled = false
			draw_require_count += 1
		elif $SetField.cards().size() < setable_card_count:
			card.reparent($SetField)
			draw_require_count += 1
		return
		
	if card.get_parent() == $BattleField:
		card.reparent($Hand)
		$ReadyButton.disabled = true
	card.reparent($Hand)
	draw_require_count -= 1


func get_set_cards():
	return get_battle_field_card() + get_set_field_cards()


func get_attack_point(is_night: bool):
	var card = $BattleField.cards()[0]
	var field_name = "night" if is_night else "day"
	return card.info["attackPoint"][field_name]


func ready_battle():
	for card in get_set_field_cards():
		if card.info["type"] == "character":
			var battle_field_cards = $BattleField.cards()
			if battle_field_cards.size() > 0:
				battle_field_cards[0].reparent($Abyss)
			card.reparent($BattleField)
			return


func open_cards():
	for card in get_set_cards():
		card.selectable = false
		card.show_card()
	await get_tree().create_timer(1).timeout
	ready_status[Main.Phase.READY] = true


func clean_up_battle():
	for card in get_set_field_cards():
		card.reparent($Abyss)
	ready_status[Main.Phase.DRAW] = true


func hit(damage):
	$HpBar.hp -= damage
	if $HpBar.hp < 0:
		$HpBar.hp = 0


func set_card_hover(card):
	if !card_hover_candidates.has(card):
		card_hover_candidates.append(card)
	
	if card.is_closed():
		return
	
	if !card_hover:
		_set_card_hover(card)
		return
		
	if card.order > card_hover.order:
		card_hover.set_hover(false)
		_set_card_hover(card)
		

func unset_card_hover(card):
	card_hover_candidates.erase(card)
	if card == card_hover:
		card.set_hover(false)
		card_hover = null
		$CardInfo.visible = false
		
	for card_hover_candidate in card_hover_candidates:
		set_card_hover(card_hover_candidate)


func get_battle_field_card():
	return $BattleField.cards()
	

func get_set_field_cards():
	return $SetField.cards()


# Called when the node enters the scene tree for the first time.
func _ready():
	#if !controllable:
		#$ReadyButton.visible = false
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ready_status[Main.Phase.CLOCK] = get_set_cards().all(func(c): return !c.flipping)


func _draw_card():
	var deck_cards = $DeckZone.cards()
	if deck_cards.size() <= 0:
		return
	
	var card = deck_cards[-1]
	card.player = self
	card.selectable = true
	if controllable:
		card.show_card()
	card.reparent($Hand)


func _set_card_hover(card: Card):
	card_hover = card
	card.set_hover(true)
	if !card.is_closed():
		$CardInfo.texture = card.get_child(1).texture
		$CardInfo.visible = true
	

func _on_draw_button_pressed():
	draw()


func _on_ready_button_pressed():
	ready_status[Main.Phase.OPEN] = true
	ready_status[Main.Phase.BATTLE] = true
	ready_status[Main.Phase.END] = true
