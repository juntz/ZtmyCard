class_name EnchantProcessor
extends Node

const ENCHANT_DELAY_SEC = 1.0
const ENCAHNTING_SCALE = 1.1

signal enchant_end

var main: Main
var player: Player
var opponent: Player
var timer: Timer
var selecting = false
var enchanting_card: Card


func _init(main: Main, player: Player, opponent: Player):
	self.main = main
	self.player = player
	self.opponent = opponent


# Called when the node enters the scene tree for the first time.
func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	player.get_node("SelectionZone").card_selected.connect(_on_card_selected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func apply_enchant(card: Card):
	enchanting_card = card
	timer.stop()
	if card.info["type"] != "enchant":
		enchant_end.emit()
		return
	
	var effect = card.info["effect"]
	if !effect.has("type"):
		enchant_end.emit()
		return
	card.scale *= ENCAHNTING_SCALE
	var type = effect["type"]
	var fields = null
	if effect.has("fields"):
		fields = effect["fields"]
	Callable(self, type).call(fields)
	timer.start(ENCHANT_DELAY_SEC)


func draw(fields):
	player._draw_card($Hand)


func disableClock(fields):
	main.revert_chronos()
		

func modifyTime(fields):
	main.revert_chronos()
	main.turn_chronos(-opponent.battle_field_card().info["clock"])
	
	
func useFromAbyss(fields):
	var abyssCards = player.abyss.cards()
	if abyssCards.size() <= 0:
		return
	
	timer.stop()
	selecting = true
	player.send_cards_to_selection_field(abyssCards, player.set_field, player.abyss)
	
	
func reduceDamage(fields):
	player.damage_reduce = int(fields["amount"])
	
	
func modifyHp(fields):
	_modify_hp(fields)
	
	
func modifyAttackPoint(fields):
	_modify_attack_point(fields)
	
	
func swapHandAndAbyss(fields):
	var abyssCards = player.abyss.cards()
	if abyssCards.size() <= 0:
		return
	
	timer.stop()
	selecting = true
	player.send_cards_to_selection_field(player.hand.cards(), player.abyss, player.hand)
	
	
func swapDayAndNightAttackPoint(fields):
	if fields["target"] == "player":
		player.swap_day_and_night_attack_point = true
	else:
		opponent.swap_day_and_night_attack_point = true	
			

func _modify_hp(fields: Dictionary):
	if fields.has("condition"):
		if !_check_card_condition(fields["condition"]):
			return
	
	player.heal(int(fields["add"]))


func _modify_attack_point(fields: Dictionary):
	var target = player
	if fields.has("condition"):
		if _check_card_condition(fields["condition"]):
			if target.attack_point_modifier:
				target.attack_point_modifier = func(n): return target.attack_point_modifier.call(n) + int(fields["add"])
			else:
				target.attack_point_modifier = func(n): return n + int(fields["add"])


func _check_card_condition(condition: Dictionary) -> bool:
	if condition.has("or"):
		return condition["or"].map(_check_card_condition).reduce(func(a, b): return a || b, false)
	
	if condition.has("attribute"):
		if condition["target"] == "player":
			if !player.battle_field_card():
				return false
			if player.battle_field_card().info["attribute"] != condition["attribute"]:
				return false
		else:
			if !opponent.battle_field_card():
				return false
			if opponent.battle_field_card().info["attribute"] != condition["attribute"]:
				return false
	
	if condition.has("powerCost"):
		if !opponent.battle_field_card():
			return false
		var powerCostCondition = condition["powerCost"]
		var opponentPowerCost = opponent.battle_field_card().info["powerCost"]
		if powerCostCondition.has("greaterThanOrEqual"):
			if opponentPowerCost < powerCostCondition["greaterThanOrEqual"]:
				return false
		if powerCostCondition.has("lessThanOrEqual"):
			if opponentPowerCost > powerCostCondition["lessThanOrEqual"]:
				return false
	
	if condition.has("hpLessOrEqual"):
		if player.hp() > condition["hpLessOrEqual"]:
			return false
	if condition.has("time"):
		if condition["time"] == "night" && !main.is_night():
			return false
		if condition["time"] == "day" && main.is_night():
			return false
	
	if condition.has("timeChanged"):
		if condition["timeChanged"] == "dayToNight" && !(!main.is_prev_night() && main.is_night()):
			return false
		if condition["timeChanged"] == "nightToDay" && !(main.is_prev_night() && !main.is_night()):
			return false
	
	if condition.has("abyss"):
		if player.abyss_attribute_count() < 4:
			return false
				
	return true


func _end_enchant():
	enchanting_card.scale /= ENCAHNTING_SCALE
	enchant_end.emit()


func _on_timer_timeout():
	if !selecting:
		_end_enchant()


func _on_card_selected(selected, unselected):
	selecting = false
	_end_enchant()
