extends PanelContainer

@onready var name_label: Label = %NameLabel;
@onready var description_label: Label = %DescriptionLabel;
@onready var progress_bar = %ProgressBar;
@onready var purchase_sound_button = %PurchaseSoundButton;
@onready var progress_label = %ProgressLabel
@onready var count_label = %CountLabel

var upgrade: MetaUpgrade;


func _ready():
	purchase_sound_button.pressed.connect(on_purchase_sound_button_pressed)

func set_meta_upgrade(meta_upgrade: MetaUpgrade):
	self.upgrade = meta_upgrade;
	name_label.text = meta_upgrade.name;
	description_label.text = meta_upgrade.description;
	update_progress();
	

func update_progress():
	
	var current_quantity = 0;
	
	if MetaProgression.save_data["meta_upgrades"].has(upgrade.id):
		current_quantity = 	MetaProgression.save_data["meta_upgrades"][upgrade.id]["quantity"];

	var currency = MetaProgression.save_data["meta_upgrade_currency"];
	var percent = currency  / upgrade.price;
	var is_maxed =  current_quantity >= upgrade.max_quantity;
	percent = min(percent,1);
	progress_bar.value = percent;
	progress_label.text = str(currency) + "/" + str(upgrade.price) 
	count_label.text = "x%d" % current_quantity;
	purchase_sound_button.disabled = percent < 1 || is_maxed;
	if is_maxed:
		purchase_sound_button.text = "Max";
		
	
	
func select_card():
	$AnimationPlayer.play("selected");

			
func on_purchase_sound_button_pressed():
	if upgrade == null:
		return;
	MetaProgression.add_meta_upgrade(upgrade);
	MetaProgression.save_data["meta_upgrade_currency"] -= upgrade.price;
	MetaProgression.save_file();
	get_tree().call_group("meta_upgrade_card", "update_progress");
	select_card();
