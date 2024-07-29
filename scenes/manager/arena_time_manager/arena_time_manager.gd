extends Node

@onready var timer = $Timer;


func get_elapsed_time():
	return timer.wait_time - timer.time_left;
