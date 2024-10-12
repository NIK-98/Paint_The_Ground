extends Control

@onready var master = $"CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/master"
@onready var effects = $"CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/effects"
@onready var music = $"CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/music"
@onready var ui = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/UI
@onready var main = $"/root/main/"

var master_bus = AudioServer.get_bus_index("Master")
var effects_bus = AudioServer.get_bus_index("Effects")
var music_bus = AudioServer.get_bus_index("music")
var ui_bus = AudioServer.get_bus_index("UI")
var master_volume = 0
var effects_volume = 0
var music_volume = 0
var ui_volume = 0

var save_audio_setting_path = "user://saveaudiosettings.save"

var loaded = false

func save():
	var save_dict = {
		"parent_name" : name,
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"master_volume" : master_volume,
		"effects_volume" : effects_volume,
		"music_volume" : music_volume,
		"ui_volume" : ui_volume
	}
	return save_dict
	
	
func _ready():
	$CanvasLayer.visible = false
	

func _process(_delta):
	if Global.trigger_audio_menu:
		$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer2/Back.grab_focus()
		Global.trigger_audio_menu = false
		$CanvasLayer.visible = true
		
		
	if not loaded:
		name = "Audio_menu"
		loaded = true
		master.value = master_volume
		AudioServer.set_bus_volume_db(master_bus, master.value)
		effects.value = effects_volume
		AudioServer.set_bus_volume_db(effects_bus, effects.value)
		ui.value = ui_volume
		AudioServer.set_bus_volume_db(ui_bus, ui.value)
		music.value = music_volume
		AudioServer.set_bus_volume_db(music_bus, music.value)
		Global.music1_sound = true
		
		
func _on_master_value_changed(value):
	master_volume = master.value
	AudioServer.set_bus_volume_db(master_bus, value)
	
	if value == -30:
		AudioServer.set_bus_mute(master_bus,true)
	else:
		AudioServer.set_bus_mute(master_bus,false)
		
	Global.ui_hover_sound = true


func _on_effects_value_changed(value):
	effects_volume = effects.value
	AudioServer.set_bus_volume_db(effects_bus, value)
	
	if value == -30:
		AudioServer.set_bus_mute(effects_bus,true)
	else:
		AudioServer.set_bus_mute(effects_bus,false)
		
	Global.ui_hover_sound = true

func _on_ui_value_changed(value):
	ui_volume = ui.value
	AudioServer.set_bus_volume_db(ui_bus, value)
	
	if value == -30:
		AudioServer.set_bus_mute(ui_bus,true)
	else:
		AudioServer.set_bus_mute(ui_bus,false)
		
	Global.ui_hover_sound = true


func _on_music_value_changed(value):
	music_volume = music.value
	AudioServer.set_bus_volume_db(music_bus, value)
	
	if value == -30:
		AudioServer.set_bus_mute(music_bus,true)
	else:
		AudioServer.set_bus_mute(music_bus,false)
	
	Global.ui_hover_sound = true
	

func _on_back_pressed():
	Global.ui_sound = true
	$CanvasLayer.visible = false
	if not FileAccess.file_exists(save_audio_setting_path):
		main.save_game("saveaudiosettings", save_audio_setting_path)
	else:
		DirAccess.remove_absolute(save_audio_setting_path)
		main.save_game("saveaudiosettings", save_audio_setting_path)
	main.get_node("CanvasLayer/Menu").visible = true
	Global.trigger_host_focus = true
	main.get_node("CanvasLayer/Menu/PanelContainer/VBoxContainer/Beenden").grab_focus()
	Global.trigger_host_focus = false


func _on_reset_pressed():
	Global.ui_sound = true
	if FileAccess.file_exists(save_audio_setting_path):
		DirAccess.remove_absolute(save_audio_setting_path)
		
	master_volume = 0
	effects_volume = 0
	ui_volume = 0
	music_volume = 0
	
	master.value = master_volume
	AudioServer.set_bus_volume_db(master_bus, master.value)
	effects.value = effects_volume
	AudioServer.set_bus_volume_db(effects_bus, effects.value)
	ui.value = ui_volume
	AudioServer.set_bus_volume_db(ui_bus, ui.value)
	music.value = music_volume
	AudioServer.set_bus_volume_db(music_bus, music.value)


func _on_reset_mouse_entered():
	Global.ui_hover_sound = true


func _on_reset_focus_entered():
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Global.ui_hover_sound = true


func _on_back_mouse_entered():
	Global.ui_hover_sound = true


func _on_back_focus_entered():
	if not Global.trigger_audio_menu:
		Global.ui_hover_sound = true


func _on_master_mouse_entered():
	Global.ui_hover_sound = true


func _on_master_focus_entered():
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Global.ui_hover_sound = true


func _on_effects_mouse_entered():
	Global.ui_hover_sound = true


func _on_effects_focus_exited():
	Global.ui_hover_sound = true


func _on_ui_mouse_entered():
	Global.ui_hover_sound = true


func _on_ui_focus_entered():
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Global.ui_hover_sound = true


func _on_music_mouse_entered():
	Global.ui_hover_sound = true


func _on_music_focus_entered():
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Global.ui_hover_sound = true
