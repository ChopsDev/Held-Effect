extends CardState
class_name Idle

@export var card : Control
@export var card_point_node : Node2D


func enter():
	pass
	

func exit():
	pass
	

func update(delta: float):
	card.position = lerp(card.position, card_point_node.position, 0.5)
	
