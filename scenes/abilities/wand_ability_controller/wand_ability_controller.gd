extends Node
const MAX_RANGE = 40;

@export var wand_ability: PackedScene;

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.timeout.connect(on_timer_timeout)
 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


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
		)
	var closest_enemy = enemies[0] as Node2D;	
		
	var wand_instance = wand_ability.instantiate() as Node2D;	
	wand_instance.global_position = closest_enemy.global_position;
	wand_instance.global_position += Vector2.RIGHT.rotated(randf_range(0, TAU)) * 4;
	
	var enemy_direction = closest_enemy.global_position - wand_instance.global_position;
	wand_instance.rotation = enemy_direction.angle();
	player.get_parent().add_child(wand_instance);
