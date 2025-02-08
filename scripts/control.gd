extends Control


@onready var main = $"/root/main/"
@onready var back = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer2/Back
@onready var reset = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer2/Reset
@onready var v_box_button_container = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/ScrollContainer/VBoxContainer

var save_input_setting_path = "user://saveinputsettings.save"

var loaded = false
var reseted = false


func _ready():
	$CanvasLayer.visible = false
	
	
func _process(_delta):	
	if not loaded:
		loaded = true
		name = "Control"
		set_process(false)
		

func _on_reset_pressed() -> void:
	if Global.akzept.is_empty():
		Global.ui_sound = true
		Global.akzept = "Standard Eingabe"
		$CanvasLayer.visible = false
		main.get_node("CanvasLayer/akzeptieren").visible = true
		main.get_node("CanvasLayer/akzeptieren/PanelContainer/VBoxContainer/CenterContainer/HBoxContainer/Ja").grab_focus()
		return
	reseted = true
	for i in v_box_button_container.get_children():
		if i.is_in_group("bind"):
			i.set_process(true)	
	Global.akzept = ""		


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
