extends Node

signal game_over()

var player: Player
var player_position: Vector2 = Vector2.ZERO
var time_elapsed_string: String = "00:00"
var time_elapsed: float = 0.0
var enemies_defeated: int = 0
var meat_counter: int = 0

var is_game_over: bool = false
var is_reading_third_part_licenses: bool = false

func _process(delta):
	time_elapsed += delta
	
	var time_elapsed_in_seconds: int = floori(time_elapsed)
	var seconds: int = time_elapsed_in_seconds % 60
	var minutes: int = time_elapsed_in_seconds / 60
	
	time_elapsed_string = "%02d:%02d" % [minutes, seconds] 

func end_game() -> void:
	if is_game_over:
		return
	
	is_game_over = true
	
	game_over.emit()

func reset() -> void:
	player = null
	player_position = Vector2.ZERO
	is_game_over = false
	is_reading_third_part_licenses = false
	
	time_elapsed_string = "00:00"
	time_elapsed = 0.0
	enemies_defeated = 0
	meat_counter = 0
	
	for connection in game_over.get_connections():
		game_over.disconnect(connection.callable)
