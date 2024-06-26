class_name Player
extends Node2D

@export var card_scene: PackedScene
@export var controllable: bool
@export var opponent: Player
var card_hover: Card
var card_hover_candidates = []
var ready_status = {
	Main.Phase.DRAW: false,
	Main.Phase.SET: false,
	Main.Phase.OPEN: false,
	Main.Phase.READY: false,
	Main.Phase.CLOCK: false,
	Main.Phase.ENCHANT: false,
	Main.Phase.BATTLE: false,
	Main.Phase.END: false
}
var draw_require_count = 0
var setable_card_count = 0
var attack_point_modifier = null
var attack_scale = 1.3
var damage = 0


func draw():
	for i in range(draw_require_count):
		_draw_card($Hand)
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
			draw_require_count += 1
		elif $SetField.cards().size() < setable_card_count:
			card.reparent($SetField)
			draw_require_count += 1
		return
		
	if card.get_parent() == $SelectionZone/SelectionField:
		card.selectable = false
		card.close_card()
		unset_card_hover(card)
		card.reparent($Abyss)
		draw_require_count += 1
		return
	
	card.reparent($Hand)
	draw_require_count -= 1


func check_powered(card: Card):
	return card.info["powerCost"] <= get_charged_power()


func field_cards():
	return $BattleField.cards() + set_field_cards()


func get_attack_point(is_night: bool) -> int:
	if $BattleField.cards().size() <= 0:
		return 0
	
	var card = $BattleField.cards()[0]
	if !check_powered(card):
		return 0
	
	var field_name = "night" if is_night else "day"
	var base_attack_point = int(card.info["attackPoint"][field_name])
	if attack_point_modifier:
		return attack_point_modifier.call(base_attack_point)
	return base_attack_point


func get_clock() -> int:
	return field_cards().filter(
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


func apply_enchant():
	for card in set_field_cards():
		if card.info["type"] != "enchant":
			continue
		
		var effect = card.info["effect"]
		if !effect.has("type"):
			continue
			
		if effect["type"] == "modifyAttackPoint":
			_modify_attack_point(effect["fields"])


func ready_battle():
	for card in set_field_cards():
		if card.info["type"] != "character":
			continue
			
		var battle_field_cards = $BattleField.cards()
		if battle_field_cards.size() <= 0:
			return
		
		_drop_card(battle_field_cards[0])
		card.reparent($BattleField)


func open_cards():
	for card in field_cards():
		card.selectable = false
		card.show_card()
	await get_tree().create_timer(1).timeout
	ready_status[Main.Phase.READY] = true


func end_battle(is_win: bool):
	_hit()
	attack_point_modifier = null
	for card in set_field_cards():
		_drop_card(card)
	ready_status[Main.Phase.DRAW] = true
	setable_card_count = 1 if is_win else 2


func attack(damage):
	var card = battle_field_card()
	card.scale = Vector2(attack_scale, attack_scale)
	card.reparent($AttackPoints)


func hit(damage):
	self.damage = damage
	ready_status[Main.Phase.END] = true


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
		$CardInfoContainer.visible = false
		
	for card_hover_candidate in card_hover_candidates:
		set_card_hover(card_hover_candidate)


func battle_field_card():
	var cards = $BattleField.cards()
	if cards.size() > 0:
		return cards[0]
	return null
	

func set_field_cards():
	return $SetField.cards()


# Called when the node enters the scene tree for the first time.
func _ready():
	$CardInfoContainer.visible = false
	_init_deck()
	if !controllable:
		$ReadyButton.visible = false
	else:
		for i in range(5):
			_draw_card($SelectionZone/SelectionField)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ready_status[Main.Phase.CLOCK] = field_cards().all(func(c): return !c.flipping)


func _modify_attack_point(fields: Dictionary):
	if fields.has("condition"):
		var condition = fields["condition"]
		if condition.has("attribute"):
			if condition["target"] == "player":
				if battle_field_card().info["attribute"] != condition["attribute"]:
					return
			else:
				if opponent.battle_field_card().info["attribute"] != condition["attribute"]:
					return
	attack_point_modifier = func(n): return n + int(fields["add"])


func _init_deck():
	var f = FileAccess.open("cards/cards.json", FileAccess.READ)
	var json = JSON.parse_string(f.get_as_text())
	var cardInfos = json["cards"]
	cardInfos.shuffle()
	cardInfos = cardInfos.slice(0, 20)
	f.close()
	
	for cardInfo in cardInfos:
		var card = card_scene.instantiate()
		card.set_info(cardInfo)
		$DeckZone.add_child(card)


func _drop_card(card: Card):
	if card.info["sendToPower"] > 0:
		card.reparent($PowerCharger)
	else:
		card.reparent($Abyss)


func _draw_card(dest: Node):
	var deck_cards = $DeckZone.cards()
	if deck_cards.size() <= 0:
		return
	
	var card = deck_cards[-1]
	card.player = self
	card.selectable = true
	if controllable:
		card.show_card()
	card.reparent(dest)


func _set_card_hover(card: Card):
	card_hover = card
	card.set_hover(true)
	if !card.is_closed():
		$CardInfoContainer/CardInfo.texture = card.get_child(1).texture
		if card.info["powerCost"] > get_charged_power():
			$CardInfoContainer/UnpoweredMask.visible = true
		else:
			$CardInfoContainer/UnpoweredMask.visible = false
		$CardInfoContainer.visible = true


func _hit():
	$HpBar.hp -= damage
	if $HpBar.hp < 0:
		$HpBar.hp = 0

	
func _on_attack_end(card):
	card.reparent($BattleField)
	card.scale = Vector2(1, 1)
	ready_status[Main.Phase.END] = true


func _on_draw_button_pressed():
	draw()


func _on_ready_button_pressed():
	ready_status[Main.Phase.OPEN] = true
	ready_status[Main.Phase.ENCHANT] = true
	ready_status[Main.Phase.BATTLE] = true


func _on_selection_done_button_pressed():
	for card in $SelectionZone/SelectionField.cards():
		card.reparent($Hand)
	for card in $Abyss.cards():
		card.reparent($DeckZone)
	$DeckZone.shuffle()
	$SelectionZone.visible = false
	ready_status[Main.Phase.DRAW] = true
