class_name GameOverUI
extends CanvasLayer

const CREDIT_UI = preload("res://ui/credit_ui.tscn")

@onready var time_value_label = %TimeValueLabel
@onready var enemies_defeated_count_label = %EnemiesDefeatedCountLabel

@export var restart_delay: float = 5.0
var restart_cooldown: float

func _ready():
	time_value_label.text = GameManager.time_elapsed_string
	enemies_defeated_count_label.text = str(GameManager.enemies_defeated)
	restart_cooldown = restart_delay


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameManager.is_reading_third_part_licenses:
		return
	
	restart_cooldown -= delta
	if restart_cooldown > 0:
		return
	
	restart_game()

func restart_game() -> void:
	GameManager.reset()
	get_tree().reload_current_scene()

func _on_button_pressed():
	GameManager.is_reading_third_part_licenses = true
	
	var credit_ui = CREDIT_UI.instantiate()
	credit_ui.game_over = self
	get_parent().add_child(credit_ui)
	pass # Replace with function body.
