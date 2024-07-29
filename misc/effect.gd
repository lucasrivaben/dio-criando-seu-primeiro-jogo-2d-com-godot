extends Node2D

@export var damage_amount: float = 1.0
@onready var area = $Area2D

func deal_damage():
	var bodies = area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			
			enemy.damage(damage_amount)
