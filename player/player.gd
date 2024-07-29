class_name Player
extends CharacterBody2D

@export_category("Speed")
@export var speed: float = 3.0
@export_category("Sword")
@export var sword_damage: float = 2.0
@export var sword_knockback: float = 10.0
@export var body_knockback: float = 7.0
@export_category("Effect")
@export var effect_damage: float = 1.0
@export var effect_interval: float = 30.0
@export var effect_scene: PackedScene
@export_category("Life")
@export var health: float = 100.0
@export var max_health: float = 100.0
@export var death_prefab: PackedScene

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var sword_area = $SwordArea
@onready var health_progress_bar = $HealthProgressBar
@onready var hitbox_area = $HitboxArea

var input_vector: Vector2 = Vector2.ZERO
var was_running: bool = false
var is_running: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var hitbox_cooldown: float = 0.0
var effect_cooldown: float = 0.0

signal meat_collected(value: int)

func _ready() -> void:
	GameManager.player = self
	meat_collected.connect(
		func(value: int): 
			GameManager.meat_counter += 1
	)

func _process(delta: float) -> void:
	GameManager.player_position = position
	
	read_input() 
	
	update_attack_cooldown(delta)
	if Input.is_action_just_pressed("attack"):
		attack()
	
	play_run_idle_animation()
	
	if not is_attacking:
		rotate_sprite()
	
	# Enemies
	update_hitbox_cooldown(delta)
	
	# Effect
	update_effect_cooldown(delta)
	
	# Health
	update_health_progress_bar()

func _physics_process(delta: float) -> void:
	# Modificar a velocidade
	var target_velocity = input_vector * speed * 100.0
	if is_attacking:
		target_velocity *= 0.25
		
	velocity = lerp(velocity, target_velocity, 0.05)
	
	move_and_slide()

func update_attack_cooldown(delta: float) -> void:
	# Atualizar o temporizador do ataque
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			is_attacking = false;
			is_running = false;
			
			animation_player.play("idle")
			
func update_hitbox_cooldown(delta: float) -> void:
	# Atualizar o temporizador do hitbox
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0:
		return
	
	hitbox_cooldown = 0.5
	
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount: float = 1.0
			
			damage(damage_amount)
			enemy.knockback(body_knockback)
	
func update_effect_cooldown(delta: float) -> void:
	# Atualizar o temporizador
	effect_cooldown -= delta
	if effect_cooldown > 0:
		return
		
	effect_cooldown = effect_interval
	
	# Criar efeito
	var effect = effect_scene.instantiate()
	effect.damage_amount = effect_damage
	effect.position.y -= 32
	add_child(effect)

func update_health_progress_bar() -> void:
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health

func play_run_idle_animation() -> void:
	# Tocar animação
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")

func rotate_sprite() -> void:
	# Girar o personagem
	if input_vector.x > 0:
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true

func read_input() -> void:
	# Obter a input vector
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Remover o deadzone do input vector
	var deadzone: float = 0.15
	if abs(input_vector.x) < deadzone:
		input_vector.x = 0
	if abs(input_vector.y) < deadzone:
		input_vector.y = 0
	
	# Atualizar o was/is running
	was_running = is_running
	is_running = not input_vector.is_zero_approx()

func attack() -> void:
	if is_attacking:
		return
	
	animation_player.play("attack_side_1")
	attack_cooldown = 0.6
	
	is_attacking= true

func deal_damage_to_enemies() -> void:
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction: Vector2
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			
			var dot_product = direction_to_enemy.dot(attack_direction)
			
			if dot_product > 0.3:
				enemy.damage(sword_damage, sword_knockback)

func damage(amount: float) -> void:
	if health <= 0:
		return
	
	health -= amount
	
	# Piscar Node
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	# Processar a morte
	if health <= 0:
		die()

func die() -> void:
	GameManager.end_game()
	
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	
	queue_free()

func heal(amount: float) -> float:
	health += amount
	
	if health > max_health:
		health = max_health
	
	return health

