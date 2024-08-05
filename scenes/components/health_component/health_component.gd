extends Node
class_name HealthComponent;


signal died;
signal health_changed;
signal health_decreased;


@export var max_health: float = 10;
var current_health: float;


func _ready():
	current_health = max_health;
	
	
func take_damage(damage:float):
	current_health = clamp(current_health - damage, 0, max_health);
	health_changed.emit();
	if damage > 0:
		health_decreased.emit();
		
	Callable(check_death).call_deferred();


func heal(heal_amount: float):
	take_damage(-heal_amount);


func get_health_percent():
	if max_health <= 0:
		return 0;
	return min(current_health / max_health, 1);
		
		


func check_death():
		if current_health == 0:
			died.emit();
			owner.queue_free();
