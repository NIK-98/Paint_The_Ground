extends Control

@onready var option_button = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/OptionButton
@onready var full_screen = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/FullScreen
@onready var v_sync = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/V_Sync
@onready var fps_anzeige = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/FPS_Anzeige
@onready var back = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/VBoxContainer2/back
@onready var fps_max = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/VBoxContainer/FPS_MAX
@onready var fps = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/VBoxContainer/Fps
@onready var screen_option = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2
@onready var einleitung = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/VBoxContainer2/Einleitung
var trailer = preload("res://sceens/trailer.tscn")

@onready var main = get_parent()

var save_grafik_path = "user://savegrafiksettings.save"
	
	
var Resolutions = {"1920x1080 FullHD":Vector2i(1920,1080),
				   "1280x720 HD":Vector2i(1280,720),
				   "1280x800 WXGA":Vector2i(1280,800),
				   "1024x768 XGA":Vector2i(1024,768)
				  }


var id = 0
var save_id = 0
var v_sync_mode = false
var fps_display_mode = false
var einleitugs_display_mode = true
var fullscreen_mode = true
var max_frams = 200
var framelimiter = 200


var loaded = false
var reset = false
	

# Called when the node enters the scene tree for the first time.
func _ready():
	name = "Grafik"
	if OS.get_name() == "Android" or OS.get_name() == "IOS":
		max_frams = 120
		framelimiter = max_frams
		fps.max_value = max_frams
	$CanvasLayer.visible = false

	
func _process(_delta):
	if not loaded:
		loaded = true
		name = "Grafik"
		if OS.get_name() == "Windows" or OS.get_name() == "Linux":
			for i in Resolutions.keys():
				if i == str(DisplayServer.screen_get_size().x,"x",DisplayServer.screen_get_size().y, " Gerät"):
					break
				Resolutions[str(DisplayServer.screen_get_size().x,"x",DisplayServer.screen_get_size().y, " Gerät")] = DisplayServer.screen_get_size()
			Add_Resolutions()
			full_screen.set_pressed_no_signal(fullscreen_mode)
			_on_full_screen_toggled(fullscreen_mode)
			if not fullscreen_mode:
				_on_option_button_item_selected(save_id)
			Set_Resulutuns_text()
			v_sync.set_pressed_no_signal(v_sync_mode)
			_on_v_sync_toggled(v_sync_mode)
		if OS.get_name() == "Android" or OS.get_name() == "IOS":
			screen_option.visible = false
			v_sync.visible = false
		_on_fps_value_changed(max_frams)
		fps_anzeige.set_pressed_no_signal(fps_display_mode)
		einleitung.set_pressed_no_signal(einleitugs_display_mode)
		
		_on_fps_anzeige_toggled(fps_display_mode)
		_on_einleitung_toggled(einleitugs_display_mode)
		if main.get_node("CanvasLayer2/Control/UI").trailer_on:
			var new_trailer = trailer.instantiate()
			main.get_node("CanvasLayer3").add_child(new_trailer)
		set_process(false)
	
	

func _physics_process(_delta):
	if Global.trigger_grafik_menu:
		back.grab_focus()
		Global.trigger_grafik_menu = false
		$CanvasLayer.visible = true
				
				
func save():
	var save_dict = {
		"parent_name" : name,
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"save_id" : save_id,
		"v_sync_mode" : v_sync_mode,
		"fullscreen_mode" : fullscreen_mode,
		"max_frams" : max_frams,
		"fps_display_mode" : fps_display_mode,
		"einleitugs_display_mode" : einleitugs_display_mode
	}
	return save_dict
		
		
func Add_Resolutions():
	var Current_Resulution = get_window().get_size()
	var ID = 0
	for r in Resolutions:
		option_button.add_item(r, ID)
		
		if Resolutions[r] == Current_Resulution:
			option_button.select(ID)
			id = ID
		
		ID += 1


func _on_option_button_item_selected(index):
	Global.ui_sound = true
	reset = false
	var ID = option_button.get_item_text(index)
	id = index
	get_window().set_size(Resolutions[ID])
	Centre_Window()
	

func Centre_Window():
	var Centre_Screen = DisplayServer.screen_get_position()+DisplayServer.screen_get_size()/2
	var Window_Size = get_window().get_size_with_decorations()
	get_window().set_position(Centre_Screen-Window_Size/2)

func Set_Resulutuns_text():
	var Resolutions_text = str(get_window().get_size().x,"x",get_window().get_size().y)
	for i in Resolutions.keys():
		if i.begins_with(Resolutions_text):
			option_button.set_text(i)
			option_button.select(id)
			

func _on_full_screen_toggled(toggled_on):
	Global.ui_sound = true
	reset = false
	if toggled_on:
		fullscreen_mode = true
		get_window().set_mode(Window.MODE_EXCLUSIVE_FULLSCREEN)
		option_button.visible = false
	else:
		fullscreen_mode = false
		get_window().set_mode(Window.MODE_WINDOWED)
		for i in Resolutions.keys():
			if i.begins_with(str(get_window().get_size())):
				option_button.set_text(i)
		option_button.select(id)
		Centre_Window()
		option_button.visible = true
		_on_option_button_item_selected(id)
		Set_Resulutuns_text()


func _on_reset_pressed():
	if Global.akzept.is_empty():
		Global.ui_sound = true
		Global.akzept = "Standard Grafik"
		$CanvasLayer.visible = false
		main.get_node("CanvasLayer/akzeptieren").visible = true
		main.get_node("CanvasLayer/akzeptieren/PanelContainer/VBoxContainer/CenterContainer/HBoxContainer/Ja").grab_focus()
		return
	if OS.get_name() == "Windows" or OS.get_name() == "Linux":
		option_button.visible = false
		full_screen.set_pressed_no_signal(true)
		_on_full_screen_toggled(true)
	Engine.max_fps = 0
	fps_max.text = "Unbegrenzt FPS"
	fps.value = fps.max_value
	max_frams = fps.max_value
	fps_anzeige.set_pressed_no_signal(false)
	einleitung.set_pressed_no_signal(true)
	v_sync.set_pressed_no_signal(false)
	_on_v_sync_toggled(false)
	_on_einleitung_toggled(true)
	_on_fps_anzeige_toggled(false)
	reset = true
	Global.akzept = ""


func _on_v_sync_toggled(toggled_on: bool) -> void:
	Global.ui_sound = true
	reset = false
	if toggled_on:
		v_sync_mode = true
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		v_sync_mode = false
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


func _on_back_pressed():
	Global.ui_sound = true
	if not FileAccess.file_exists(save_grafik_path):
		save_id = id
		get_parent().save_game("savegrafik", save_grafik_path)
	else:
		save_id = id
		DirAccess.remove_absolute(save_grafik_path)
		get_parent().save_game("savegrafik", save_grafik_path)
		
	Global.ui_sound = true
	$CanvasLayer.visible = false
	get_parent().get_node("CanvasLayer/Menu").visible = true
	Global.trigger_host_focus = true
	get_parent().get_node("CanvasLayer/Menu/PanelContainer/VBoxContainer/Beenden").grab_focus()
	Global.trigger_host_focus = false
	
	if reset and FileAccess.file_exists(save_grafik_path):
		DirAccess.remove_absolute(save_grafik_path)
	

func _on_mouse_entered():
	Global.ui_hover_sound = true


func _on_focus_entered():
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Global.ui_hover_sound = true


func _on_fps_value_changed(value):
	Global.ui_sound = true
	if value < framelimiter:
		Engine.max_fps = value
		fps_max.text = str(value, " Max FPS")
		fps.value = value
		max_frams = value
	else:
		Engine.max_fps = 0
		fps_max.text = "Unbegrenzt FPS"
		fps.value = value
		max_frams = fps.max_value


func _on_fps_anzeige_toggled(toggled_on: bool) -> void:
	Global.ui_sound = true
	reset = false
	if toggled_on:
		fps_display_mode = true
		main.get_node("CanvasLayer/fps").visible = fps_display_mode
	else:
		fps_display_mode = false
		main.get_node("CanvasLayer/fps").visible = fps_display_mode


func _on_einleitung_toggled(toggled_on: bool) -> void:
	Global.ui_sound = true
	reset = false
	if toggled_on:
		einleitugs_display_mode = true
	else:
		einleitugs_display_mode = false
		main.get_node("CanvasLayer2/Control/UI").trailer_on = false
