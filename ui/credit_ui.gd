extends CanvasLayer

@export var game_over: CanvasLayer
@onready var label = %Label

func _ready():
	game_over.hide()
	label.text = Engine.get_license_text() 

func _on_button_pressed():
	game_over.show()
	GameManager.is_reading_third_part_licenses = false
	self.queue_free()
