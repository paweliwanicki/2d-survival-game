extends Button


func _ready():
	pressed.connect(on_pressed);


func on_pressed():
	$RandomAudioPlayer.play_random();
