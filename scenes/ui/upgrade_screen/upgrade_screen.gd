extends CanvasLayer

signal upgrade_selected(upgrade: AbilityUpgrade);

@export var upgrade_card_scene: PackedScene;

@onready var upgrades_card_container: HBoxContainer = %UpgradesCardContainer;


func _ready():
	get_tree().paused = true;
	

func set_ability_upgrades(upgrades: Array[AbilityUpgrade]):
	var delay = 0;
	for upgrade in upgrades:
		var card_instance = upgrade_card_scene.instantiate();
		upgrades_card_container.add_child(card_instance);
		card_instance.set_ability_upgrade(upgrade);
		card_instance.play_in(delay);
		card_instance.selected.connect(on_upgrade_selected.bind(upgrade));
		delay += .2;
		
func on_upgrade_selected(upgrade:AbilityUpgrade):
	upgrade_selected.emit(upgrade);	
	get_tree().paused = false;
	queue_free();
