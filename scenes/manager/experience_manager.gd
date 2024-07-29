extends Node

var current_experience = 0;

func _ready():
	GameEvents.experience_vial_collected.connect(on_increment_experience)

func increment_experience(number: float):
	current_experience += number;
	print(current_experience);
	

func on_increment_experience(number:float):
	increment_experience(number);	
