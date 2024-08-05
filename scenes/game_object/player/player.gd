extends CharacterBody2D;

var number_colliding_bodies = 0;
var base_speed = 0;

@export var arena_time_manager: Node;

@onready var collision_area2d = $CollisionArea2D;
@onready var damage_interval_timer = $DamageIntervalTimer;
@onready var health_bar = $HealthBar;
@onready var health_component: HealthComponent = $HealthComponent;
@onready var abilities = $Abilities;
@onready var animation_player = $AnimationPlayer;
@onready var visuals = $Visuals;
@onready var velocity_component = $VelocityComponent


func _ready():
	base_speed = velocity_component.max_speed;
	collision_area2d.body_entered.connect(on_body_entered)
	collision_area2d.body_entered.connect(on_body_exited)
	damage_interval_timer.timeout.connect(on_damage_interval_timer_timeout)
	health_component.health_decreased.connect(on_health_decreased);
	health_component.health_changed.connect(on_health_changed);
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)
	update_health_display();

func _process(delta):
	var movement_vector = get_movement_vector();
	var direction = movement_vector.normalized();
	velocity_component.accelerate_in_direction(direction);
	velocity_component.move(self);
	
	if movement_vector.x != 0 || movement_vector.y != 0:
		animation_player.play("walk");
	else:
		animation_player.play("RESET");
	
	var move_sign = sign(movement_vector.x);
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1);
	
	
func get_movement_vector(): 
	var x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left");	
	var y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up");
	return Vector2(x,y);
	
	
func check_is_taking_damage():
	if number_colliding_bodies == 0 || !damage_interval_timer.is_stopped():
		return;	
	health_component.take_damage(2);
	damage_interval_timer.start();


func update_health_display():
	health_bar.value = health_component.get_health_percent();


func on_body_entered(other_body: Node2D):
	number_colliding_bodies += 1;
	check_is_taking_damage();


func on_body_exited(other_body: Node2D):
	number_colliding_bodies -= 1;


func on_damage_interval_timer_timeout():
	check_is_taking_damage();


func on_health_changed():
	update_health_display();


func on_health_decreased():
	GameEvents.emit_player_damaged();
	on_health_changed();
	$HitRandomAudioPlayer2DComponent.play_random();
	
	
func on_ability_upgrade_added(ability_upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if not ability_upgrade is Ability:
		return;
	
	var ability = ability_upgrade as Ability;	
	abilities.add_child(ability.ability_controller_scene.instantiate());	
	
	if ability_upgrade.id == "player_speed":
		velocity_component.max_speed = base_speed + (base_speed * current_upgrades["player_speed"]["quantity"] * .1)
	


func on_arena_difficulty_increased(difficulty: int):
	var heal_regeneration_quantity = MetaProgression.get_upgrade_count("health_regeneration");
	if heal_regeneration_quantity > 0 && health_component.current_health < health_component.max_health:
		var is_thirty_second_interval = (difficulty % 1) == 0;
		if is_thirty_second_interval:
			health_component.heal(heal_regeneration_quantity);
