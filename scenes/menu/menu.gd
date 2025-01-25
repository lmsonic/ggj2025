extends Control
@onready var btn_play: Button = $MarginContainer/Control/VBoxContainer/Stage1Button
@onready var btn_exit :Control= $MarginContainer/Control/VBoxContainer/ExitButton


func _ready() -> void:
	# needed for gamepads to work
	btn_play.grab_focus()
	if OS.has_feature('web'):
		btn_exit.queue_free() # exit button dosn't make sense on HTML5

func _on_ExitButton_pressed() -> void:
	# gently shutdown the game
	var transitions :Transitions= get_node_or_null("/root/Transitions")
	if transitions:
		transitions.fade_in({
			'show_progress_bar': false
		})
		await transitions.anim.animation_finished
		await get_tree().create_timer(0.3).timeout
	get_tree().quit()


func _on_stage_2_button_pressed() -> void:
	Game.change_scene_to_file("res://scenes/stage2.tscn")


func _on_stage_1_button_pressed() -> void:
	Game.change_scene_to_file("res://scenes/stage1.tscn")
