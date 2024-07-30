extends Node

@export var upgrade_pool: Array[AbilityUpgrade];
@export var experience_manager: ExperienceManager;
@export var upgrade_screen_scene: PackedScene;

var current_upgrades = {};


func _ready():
	experience_manager.level_up.connect(on_level_up);


func apply_upgrade(upgrade: AbilityUpgrade):
	if upgrade == null:
		return;
	var selected_upgrade = upgrade_pool.pick_random() as AbilityUpgrade;
	var has_upgrade = current_upgrades.has(upgrade.id)
	if !has_upgrade:
		current_upgrades[selected_upgrade.id] = {
			"resource": selected_upgrade,
			"quantity" : 1
		}
	else:
		current_upgrades[selected_upgrade.id]["quantity"] += 1;
		
	GameEvents.ability_upgrade_added.emit(selected_upgrade, current_upgrades);


func pick_upgrades():
	var selected_upgrades: Array[AbilityUpgrade] = [];
	var filtered_upgrades = upgrade_pool.duplicate();
	for i in 2:
		var selected_upgrade = filtered_upgrades.pick_random() as AbilityUpgrade;
		selected_upgrades.append(selected_upgrade);
		filtered_upgrades = filtered_upgrades.filter(func (upgrade):  return upgrade.id != selected_upgrade.id);
	return selected_upgrades;

	
func on_upgrade_selected(upgrade: AbilityUpgrade):
	apply_upgrade(upgrade);
	

func on_level_up(current_level: int):
	var upgrade_screen_instance = upgrade_screen_scene.instantiate();
	add_child(upgrade_screen_instance);
	var selected_upgrades = pick_upgrades();
	upgrade_screen_instance.set_ability_upgrades(selected_upgrades);
	upgrade_screen_instance.upgrade_selected.connect(on_upgrade_selected)
