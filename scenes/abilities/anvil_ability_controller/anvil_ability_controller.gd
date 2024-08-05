extends Node
const MAX_RANGE = 200;
const BASE_RANGE = 200;

@export var anvil_ability_scene: PackedScene;

var base_damage = 15;
var additional_damage_percent = 1;
var base_wait_time;
var anvil_count = 0;


func _ready():
	base_wait_time = $Timer.wait_time;
	$Timer.timeout.connect(on_timer_timeout);
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added);
 

func _process(delta):
	pass;


func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D;
	if player == null:
		return;

	var direction = Vector2.RIGHT.rotated(randf_range(0,TAU))
	var additional_rotation_degrees = 360.0 / (anvil_count + 1);
	var anvil_distance = randf_range(0, BASE_RANGE);
	
	for i in anvil_count + 1:
		var adjusted_direction = direction.rotated(deg_to_rad(i * additional_rotation_degrees))
		var spawn_position = player.global_position + (adjusted_direction * anvil_distance);
		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position, 1);
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters);
		if !result.is_empty():
			spawn_position = result["position"];
		
		var anvil_ability = anvil_ability_scene.instantiate() as Node2D; 
		get_tree().get_first_node_in_group("foreground_layer").add_child(anvil_ability);
		anvil_ability.global_position = spawn_position;
		anvil_ability.hitbox_component.damage = base_damage;



func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	var current_upgrade_quantity = current_upgrades[upgrade.id]["quantity"];
	
	if upgrade.id == "anvil_count":
		anvil_count = current_upgrade_quantity * upgrade.value;

