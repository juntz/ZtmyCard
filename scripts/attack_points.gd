extends Node2D

signal attack_end(card: Card)

@export var main: Main
var step = 0
var points
var target
var target_scale = 1.3


# Called when the node enters the scene tree for the first time.
func _ready():
	points = [
		$AttackPoint1,
		$AttackPoint2,
		$AttackPoint1
	]
	target = $AttackPoint2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_card_transition_end(card):
	if step >= points.size():
		card.transition_end.disconnect(_on_card_transition_end)
		#card.scale = Vector2(1, 1)
		attack_end.emit(card)
		step = 0
		return
	
	if card.get_parent() == target:
		main.shake(abs($"../../Player".damage) / 20.0)
	
	if card.get_parent() != points[step]:
		card.reparent(points[step])
	step += 1


func _on_child_entered_tree(node):
	if node is Card:
		node.transition_end.connect(_on_card_transition_end)
		node.scale = Vector2(target_scale, target_scale)
		_on_card_transition_end(node)
