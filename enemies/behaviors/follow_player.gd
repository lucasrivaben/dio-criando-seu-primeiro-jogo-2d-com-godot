extends Node

var enemy: Enemy
var sprite: AnimatedSprite2D
var is_knockback: bool = false

@export var speed: float = 1.0
@export var knockback: float = 0.0

func _ready():
	enemy = get_parent()
	sprite = enemy.get_node("AnimatedSprite2D")
	enemy.health

func _physics_process(delta: float) -> void:
	if GameManager.is_game_over:
		return
	
	var difference = GameManager.player_position - enemy.position
	var input_vector = difference.normalized()
	
	if knockback <= 0.5:
		enemy.velocity = input_vector * speed * 100
	else:
		enemy.velocity = -input_vector * knockback * 100
		knockback = lerp(knockback, 0.0, 0.05)
	
	enemy.move_and_slide()
	
	rotate_sprite(input_vector)

func rotate_sprite(input_vector: Vector2) -> void:
		# Girar o personagem
	if input_vector.x > 0:
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true
