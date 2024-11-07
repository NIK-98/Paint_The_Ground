extends Control


@onready var main = $"/root/main/"
@onready var back = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer2/Back
@onready var reset = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer2/Reset


var save_input_setting_path = "user://saveinputsettings.save"

var loaded = false
var reseted = false


func save():
	var save_dict = {
		"parent_name" : name,
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y
	}
	return save_dict


func _ready():
	name = "Control"
	$CanvasLayer.visible = false
	
	
func _process(_delta):	
	if not loaded:
		loaded = true
		name = "Control"
		set_process(false)
	
	
func _physics_process(_delta):
	if Global.trigger_input_menu:
		back.grab_focus()
		Global.trigger_input_menu = false
		$CanvasLayer.visible = true	
		

func _on_reset_pressed() -> void:
	Global.ui_sound = true
	reseted = true


func _on_back_pressed() -> void:
	Global.ui_sound = true
	$CanvasLayer.visible = false
	if not FileAccess.file_exists(save_input_setting_path):
		main.save_game("saveinputsettings", save_input_setting_path)
	else:
		DirAccess.remove_absolute(save_input_setting_path)
		main.save_game("saveinputsettings", save_input_setting_path)
	main.get_node("CanvasLayer/Menu").visible = true
	Global.trigger_host_focus = true
	main.get_node("CanvasLayer/Menu/PanelContainer/VBoxContainer/Beenden").grab_focus()
	Global.trigger_host_focus = false
	if reseted and FileAccess.file_exists(save_input_setting_path):
		DirAccess.remove_absolute(save_input_setting_path)


func _on_focus_entered():
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Global.ui_hover_sound = true


func _on_mouse_entered():
	Global.ui_hover_sound = true
