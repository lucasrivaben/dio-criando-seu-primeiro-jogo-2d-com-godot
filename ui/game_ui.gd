extends CanvasLayer

@onready var timer_label = $TimerLabel
@onready var meat_label = $Panel/MeatLabel

func _ready() -> void:
	meat_label.text = str(GameManager.meat_counter)

func _process(delta):
	timer_label.text = GameManager.time_elapsed_string
