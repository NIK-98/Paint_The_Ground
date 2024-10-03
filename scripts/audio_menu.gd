extends Control

@onready var master = $"CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/master"
@onready var effects = $"CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/effects"
@onready var music = $"CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/music"
@onready var main = $"/root/main/"

var master_bus = AudioServer.get_bus_index("Master")
var effects_bus = AudioServer.get_bus_index("Effects")
var music_bus = AudioServer.get_bus_index("music")
var master_volume = 0
var effects_volume = 0
var music_volume = 0

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
		"music_volume" : music_volume
	}
	return save_dict
	
	
func _ready():
	$CanvasLayer.visible = false
	

func _process(delta):
	if Global.trigger_audio_menu:
		Global.trigger_audio_menu = false
		$CanvasLayer.visible = true
		$CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer2/Back.grab_focus()
		
		
	if not loaded:
		name = "Audio_menu"
		loaded = true
		master.value = master_volume
		AudioServer.set_bus_volume_db(master_bus, master.value)
		effects.value = effects_volume
		AudioServer.set_bus_volume_db(effects_bus, effects.value)
		music.value = music_volume
		AudioServer.set_bus_volume_db(music_bus, music.value)
		main.music_1.play()
		
		
func _on_master_value_changed(value):
	master_volume = master.value
	AudioServer.set_bus_volume_db(master_bus, value)
	
	if value == -30:
		AudioServer.set_bus_mute(master_bus,true)
	else:
		AudioServer.set_bus_mute(master_bus,false)


func _on_effects_value_changed(value):
	effects_volume = effects.value
	AudioServer.set_bus_volume_db(effects_bus, value)
	
	if value == -30:
		AudioServer.set_bus_mute(effects_bus,true)
	else:
		AudioServer.set_bus_mute(effects_bus,false)


func _on_music_value_changed(value):
	music_volume = music.value
	AudioServer.set_bus_volume_db(music_bus, value)
	
	if value == -30:
		AudioServer.set_bus_mute(music_bus,true)
	else:
		AudioServer.set_bus_mute(music_bus,false)
	

func _on_back_pressed():
	$CanvasLayer.visible = false
	if not FileAccess.file_exists(save_audio_setting_path):
		main.save_game("saveaudiosettings", save_audio_setting_path)
	else:
		DirAccess.remove_absolute(save_audio_setting_path)
		main.save_game("saveaudiosettings", save_audio_setting_path)
	main.get_node("CanvasLayer/Menu").visible = true


func _on_reset_pressed():
	if FileAccess.file_exists(save_audio_setting_path):
		DirAccess.remove_absolute(save_audio_setting_path)
		
	master_volume = 0
	effects_volume = 0
	music_volume = 0
	
	master.value = master_volume
	AudioServer.set_bus_volume_db(master_bus, master.value)
	effects.value = effects_volume
	AudioServer.set_bus_volume_db(effects_bus, effects.value)
	music.value = music_volume
	AudioServer.set_bus_volume_db(music_bus, music.value)
