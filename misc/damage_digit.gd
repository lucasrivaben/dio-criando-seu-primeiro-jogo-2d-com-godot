extends Node2D

var value: float = 0.0
@onready var label = $Node2D/Label

func _ready():
	label.text = str(value)
