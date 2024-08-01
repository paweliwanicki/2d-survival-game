extends Node

@export var axe_ability_scene: PackedScene;

var base_damage = 10;
var additional_damage_percent = 1;
var base_wait_time;

func _ready():
	base_wait_time = $Timer.wait_time;
	$Timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added);
	
func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player");
	if player == null:
		return;
		
	var foreground = get_tree().get_first_node_in_group("foreground_layer")	as Node2D
		
	if foreground == null:
		return;
			
	var axe_instance = axe_ability_scene.instantiate() as Node2D;
	foreground.add_child(axe_instance);
	axe_instance.global_position = player.global_position;
	axe_instance.hitbox_component.damage = base_damage * additional_damage_percent;


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	var current_upgrade_quantity = current_upgrades[upgrade.id]["quantity"];
	
	if upgrade.id == "axe_attack_speed":
		var percent_reduction = current_upgrade_quantity * .1;
		$Timer.wait_time = max(0.01, base_wait_time * (1 - percent_reduction));
		$Timer.start();
	
	if upgrade.id == "axe_damage":
		additional_damage_percent = 1 + (current_upgrade_quantity * .1);
