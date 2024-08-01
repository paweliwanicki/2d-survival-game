extends Node
const MAX_RANGE = 60;

@export var sword_ability: PackedScene;

var damage = 5;
var base_wait_time;


# Called when the node enters the scene tree for the first time.
func _ready():
	base_wait_time = $Timer.wait_time;
	$Timer.timeout.connect(on_timer_timeout);
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added);
 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass;


func on_timer_timeout():
	# get enemies group
	var player = get_tree().get_first_node_in_group("player") as Node2D;
	if player == null:
		return;
	var player_position = player.global_position;	
		
	var enemies = get_tree().get_nodes_in_group("enemy");
			
	enemies = enemies.filter(func(enemy: Node2D): 
		return enemy.global_position.distance_squared_to(player_position) < pow(MAX_RANGE,2))	
		
	if enemies.size() == 0:
		return;	
	
	enemies.sort_custom(func(a: Node2D, b: Node2D): 
		var a_position = a.global_position.distance_squared_to(player_position)
		var b_position = b.global_position.distance_squared_to(player_position)
		return a_position < b_position
		);
		
	var closest_enemy = enemies[0] as Node2D;	
	var sword_instance = sword_ability.instantiate() as SwordAbility;	
	
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer");
	foreground_layer.add_child(sword_instance);
	sword_instance.hitbox_component.damage = damage;
	sword_instance.global_position = player.global_position;
	#sword_instance.global_position = closest_enemy.global_position;
	#sword_instance.global_position += Vector2.RIGHT.rotated(randf_range(0, TAU)) * 4;
	
	var enemy_direction = closest_enemy.global_position - sword_instance.global_position;
	var enemy_direction_angle = enemy_direction.angle();
	sword_instance.global_position += Vector2.RIGHT.rotated(enemy_direction_angle) * 10;
	sword_instance.rotation = enemy_direction_angle;


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id != "attack_speed":
		return;

	var percent_reduction = current_upgrades["attack_speed"]["quantity"] * .1;
	$Timer.wait_time = max(0.01, base_wait_time * (1 - percent_reduction));
	$Timer.start();
	
	
	