extends Node

@export var experience_manager: ExperienceManager;
@export var upgrade_screen_scene: PackedScene;

var current_upgrades = {};
var upgrade_pool: WeightedTable = WeightedTable.new();

# axe
var upgrade_axe = preload("res://resources/upgrades/axe/axe.tres");
var upgrade_axe_damage = preload("res://resources/upgrades/axe/axe_damage.tres");
var upgrade_axe_attack_speed = preload("res://resources/upgrades/axe/axe_attack_speed.tres");

# sword
var upgrade_sword_damage = preload("res://resources/upgrades/sword/sword_damage.tres");
var upgrade_sword_attack_speed = preload("res://resources/upgrades/sword/sword_attack_speed.tres");

# anvil
var upgrade_anvil = preload("res://resources/upgrades/anvil/anvil.tres");
var upgrade_anvil_count = preload("res://resources/upgrades/anvil/anvil_count.tres");

# player
var upgrade_player_speed = preload("res://resources/upgrades/player/player_speed.tres");

func _ready():
	upgrade_pool.add_item(upgrade_axe, 10);
	upgrade_pool.add_item(upgrade_anvil, 10);
	upgrade_pool.add_item(upgrade_sword_attack_speed, 10);
	upgrade_pool.add_item(upgrade_sword_damage, 10);
	upgrade_pool.add_item(upgrade_player_speed, 10);
	experience_manager.level_up.connect(on_level_up);


func update_upgrade_pool(selected_upgrade: AbilityUpgrade):
	if selected_upgrade.id == upgrade_axe.id:
		upgrade_pool.add_item(upgrade_axe_damage, 10);
		upgrade_pool.add_item(upgrade_axe_attack_speed, 10);		
		
	if selected_upgrade.id == upgrade_anvil_count.id:
		upgrade_pool.add_item(upgrade_anvil_count, 5);

func apply_upgrade(upgrade: AbilityUpgrade):
	if upgrade == null:
		return;
	
	var has_upgrade = current_upgrades.has(upgrade.id)
	if !has_upgrade:
		current_upgrades[upgrade.id] = {
			"resource": upgrade,
			"quantity" : 1
		}
	else:
		current_upgrades[upgrade.id]["quantity"] += 1;
		
	if upgrade.max_quantity > 0:
		var current_quantity = current_upgrades[upgrade.id]["quantity"];
		if current_quantity == upgrade.max_quantity:
			upgrade_pool.remove_item(upgrade);
	update_upgrade_pool(upgrade);		
	GameEvents.ability_upgrade_added.emit(upgrade, current_upgrades);


func pick_upgrades():
	var picked_upgrades: Array[AbilityUpgrade] = [];
	for i in 2:
		if upgrade_pool.items.size() == picked_upgrades.size():
			break;
			
		var picked_upgrade = upgrade_pool.pick_item(picked_upgrades) as AbilityUpgrade;
		picked_upgrades.append(picked_upgrade);
	return picked_upgrades;

	
func on_upgrade_selected(upgrade: AbilityUpgrade):
	apply_upgrade(upgrade);
	

func on_level_up(current_level: int):
	var upgrade_screen_instance = upgrade_screen_scene.instantiate();
	add_child(upgrade_screen_instance);
	var selected_upgrades = pick_upgrades();
	upgrade_screen_instance.set_ability_upgrades(selected_upgrades);
	upgrade_screen_instance.upgrade_selected.connect(on_upgrade_selected)
