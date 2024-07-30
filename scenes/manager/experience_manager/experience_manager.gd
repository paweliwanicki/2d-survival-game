extends Node
class_name ExperienceManager;

signal experience_updated(current_experience: float, target_experience: float);
signal level_up(new_level: int);

const TARGET_EXPERIENCE_GROWTH = 5;


var current_experience = 0;
var current_level = 1;
var target_experience = 1;


func _ready():
	GameEvents.experience_vial_collected.connect(on_increment_experience)

func increment_experience(number: float):
	current_experience = min(current_experience + number, target_experience);
	experience_updated.emit(current_experience, target_experience);
	if current_experience == target_experience:
		current_level += 1;
		target_experience += TARGET_EXPERIENCE_GROWTH;
		current_experience = 0;
		experience_updated.emit(current_experience, target_experience);
		level_up.emit(current_level);
	
	

func on_increment_experience(number:float):
	increment_experience(number);	