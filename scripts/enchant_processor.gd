class_name EnchantProcessor
extends Node

const ENCHANT_DELAY_SEC = 1.0
const ENCAHNTING_SCALE = 1.1

signal enchant_end

@export var player: Player
@export var opponent: Player
@export var game_master: GameMaster
@export var chronos: Chronos
var timer: Timer
var selecting = false
var enchanting_card: Card


# Called when the node enters the scene tree for the first time.
func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)


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
	if player.check_powered(card):
		Callable(self, type).call(fields)
	timer.start(ENCHANT_DELAY_SEC)


func draw(fields):
	game_master.draw_card(player)


func disableClock(fields):
	chronos.revert.rpc()
		

func modifyTime(fields):
	chronos.revert.rpc()
	chronos.turn.rpc(-opponent.battle_field_card().info["clock"])
	
	
func useFromAbyss(fields):
	var abyssCards = player.card_fields[CardField.Field.ABYSS].cards()
	if abyssCards.size() <= 0:
		return
	
	timer.stop()
	selecting = true
	var selection_zone = player.get_node("SelectionZone")
	selection_zone.start_selection(player, CardField.Field.ABYSS)
	
	var idx = await selection_zone.card_selected
	game_master.move_card.rpc(CardField.Field.ABYSS, idx, CardField.Field.SET)
	selecting = false
	_end_enchant()
	
	
func reduceDamage(fields):
	_reduce_damage.rpc(fields)
	
	
func modifyHp(fields):
	_modify_hp.rpc(fields)
	
	
func modifyAttackPoint(fields):
	_modify_attack_point.rpc(fields)
	
	
func swapHandAndAbyss(fields):
	var abyssCards = player.card_fields[CardField.Field.ABYSS].cards()
	if abyssCards.size() <= 0:
		return
	
	timer.stop()
	selecting = true
	var selection_zone = player.get_node("SelectionZone")
	selection_zone.start_selection(player, CardField.Field.HAND)
	
	var idx = await selection_zone.card_selected
	game_master.move_card.rpc(CardField.Field.ABYSS, -1, CardField.Field.HAND)
	game_master.move_card.rpc(CardField.Field.HAND, idx, CardField.Field.ABYSS)
	selecting = false
	_end_enchant()
	
	
func swapDayAndNightAttackPoint(fields):
	_swap_day_and_night_attack_point.rpc(fields)


@rpc("any_peer", "call_local")
func _modify_hp(fields: Dictionary):
	if fields.has("condition"):
		if !_check_card_condition(fields["condition"]):
			return
	
	var target = _get_target_player(fields)
	target.heal(int(fields["add"]))


@rpc("any_peer", "call_local")
func _modify_attack_point(fields: Dictionary):
	if fields.has("condition"):
		if _check_card_condition(fields["condition"]):
			var target = _get_target_player(fields)
			target.attack_point_addend += int(fields["add"])


@rpc("any_peer", "call_local")
func _reduce_damage(fields: Dictionary):
	var target = _get_target_player(fields)
	target.damage_subtrahend += int(fields["amount"])


@rpc("any_peer", "call_local")
func _swap_day_and_night_attack_point(fields: Dictionary):
	var target = _get_target_player(fields)
	target.swap_day_and_night_attack_point = true


func _get_target_player(fields: Dictionary) -> Player:
	var call_from_local = multiplayer.get_remote_sender_id() == multiplayer.get_unique_id()
	var target_is_player = fields["target"] == "player"
	if call_from_local != target_is_player:
		return opponent
	return player


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
		if condition["time"] == "night" && !chronos.is_night():
			return false
		if condition["time"] == "day" && chronos.is_night():
			return false
	
	if condition.has("timeChanged"):
		if condition["timeChanged"] == "dayToNight" && !(!chronos.is_prev_night() && chronos.is_night()):
			return false
		if condition["timeChanged"] == "nightToDay" && !(chronos.is_prev_night() && !chronos.is_night()):
			return false
	
	if condition.has("abyss"):
		if player.abyss_attribute_count() < 4:
			return false
				
	return true


func _end_enchant():
	if !player.check_powered(enchanting_card):
		enchanting_card.shake()
	enchanting_card.scale /= ENCAHNTING_SCALE
	enchant_end.emit()


func _on_timer_timeout():
	if !selecting:
		_end_enchant()


func _on_card_selected(selected, unselected):
	selecting = false
	_end_enchant()
