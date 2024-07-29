extends CanvasLayer

@export var arena_time_manager: Node;
@onready var label = %Label;


func _process(delta):
	if arena_time_manager == null:
		return;
	var elapsed_time = arena_time_manager.get_elapsed_time();
	label.text = format_time_to_string(elapsed_time);


func format_time_to_string(seconds: float):
	var minutes = floor(seconds / 60);
	var remaining_seconds = floor(seconds - (minutes * 60));
	return str(minutes) + ":" + ( "%02d" % remaining_seconds);
