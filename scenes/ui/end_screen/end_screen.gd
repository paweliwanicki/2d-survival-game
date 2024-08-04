extends CanvasLayer
class_name EndScreen;

@onready var continue_button  = %ContinueSoundButton;
@onready var quit_button  = %QuitSoundButton;
@onready var title_label  = %TitleLabel;
@onready var description_label  = %DescriptionLabel;
@onready var panel_container = %PanelContainer;

func _ready():
	panel_container.pivot_offset = panel_container.size / 2;
	
	var tween = create_tween();
	tween.tween_property(panel_container, "scale", Vector2.ZERO, 0);
	tween.tween_property(panel_container, "scale", Vector2.ONE, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK);
	
	
	get_tree().paused = true;
	continue_button.pressed.connect(on_continue_button_pressed)
	quit_button.pressed.connect(on_quit_button_pressed)
	
	
func set_defeat():
	title_label.text = "Defeat!";
	description_label.text = "You died!";
	
	
func play_jingle(defeat: bool = false):
	if defeat:
		$DefeatStreamPlayer2D.play()
	else:
		$VictoryStreamPlayer2D.play()
	

func on_continue_button_pressed():
	ScreenTransition.transition();
	await ScreenTransition.transitioned_halfway;
	get_tree().paused = false;
	get_tree().change_scene_to_file("res://scenes/ui/meta_menu.tscn");
		
		
func on_quit_button_pressed():
	ScreenTransition.transition();
	await ScreenTransition.transitioned_halfway;
	get_tree().paused = false;
	get_tree().change_scene_to_file("res://scenes/ui/main_menu/main_menu.tscn")
