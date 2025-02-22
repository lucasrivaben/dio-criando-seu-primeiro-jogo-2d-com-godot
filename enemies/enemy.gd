class_name Enemy
extends CharacterBody2D

const DAMAGE_DIGIT = preload("res://misc/damage_digit.tscn")

@export_category("Life")
@export var health: float = 10.0
@export var mass: float = 5
@export var death_prefab: PackedScene

@export_category("Drops")
@export var drop_chance: float = 0.1
@export var drop_chances: Array[float]
@export var drop_items: Array[PackedScene]

@onready var follow_player = $FollowPlayer

func damage(amount: float, knockback_strength: float = 0.0) -> void:	
	if health <= 0:
		return
		
	health -= amount
	
	# Piscar Node
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	# Repulsão no inimigo
	if knockback_strength > 0.0:
		knockback(knockback_strength)
	
	# Criar digito de dano
	var damage_digit = DAMAGE_DIGIT.instantiate()
	var digital_mark = get_node("DigitalMark")
	damage_digit.value = amount
	
	if digital_mark:
		damage_digit.global_position = digital_mark.global_position
	else:
		damage_digit.global_position = global_position
	
	get_parent().add_child(damage_digit)
	
	# Processar a morte
	if health <= 0:
		die()

func knockback(knockback_strength: float) -> void:
	# Repulsão no inimigo
	follow_player.knockback = knockback_strength / mass

func die() -> void:
	# Morte
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	
	GameManager.enemies_defeated += 1
	
	# Drop
	if randf() <= drop_chance:
		drop_item()
	
	queue_free()

func drop_item() -> void:
	var template: PackedScene = get_random_drop_item()
	
	var drop = template.instantiate()
	drop.position = position
	get_parent().add_child(drop)

func get_random_drop_item() -> PackedScene:
	if drop_items.size() == 1:
		return drop_items[0]
	
	var max_chance: float = 0.0
	for chance in drop_chances:
		max_chance += chance
	
	var random_value = randf() * max_chance
	
	var needle: float = 0.0
	for i in drop_items.size():
		var drop_item = drop_items[i]
		var drop_chance = drop_chances[i] if i < drop_chances.size() else 1
		if random_value <= drop_chance + needle:
			return drop_item
		needle += drop_chance
	
	return drop_items[0]
