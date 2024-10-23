extends Control

@onready var option_button = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/OptionButton
@onready var full_screen = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/FullScreen
@onready var v_sync = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/V_Sync
@onready var back = $CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer2/back

var save_grafik_path = "user://savegrafiksettings.save"
	
	
var Resolutions = {"3840x2160":Vector2i(3840,2160),
				   "2560x1440":Vector2i(2560,1440),
				   "1920x1080":Vector2i(1920,1080),
				   "1366x768":Vector2i(1366,768),
				   "1536x864":Vector2i(1536,864),
				   "1280x720":Vector2i(1280,720),
				   "1280x800":Vector2i(1280,800),
				   "1440x900":Vector2i(1440,900),
				   "1600x900":Vector2i(1600,900),
				   "1024x600":Vector2i(1024,600),
				   "800x600": Vector2i(800,600)}

var id = 0
var v_sync_mode = false
var fullscreen_mode = true


var loaded = false
	

# Called when the node enters the scene tree for the first time.
func _ready():
	name = "Grafik"
	$CanvasLayer.visible = false
	Add_Resolutions()
	Check_mode()
	
	
func _process(_delta):
	if not loaded:
		loaded = true
		name = "Grafik"
		v_sync.set_pressed_no_signal(v_sync_mode)
		_on_v_sync_toggled(v_sync_mode)
		full_screen.set_pressed_no_signal(fullscreen_mode)
		_on_full_screen_toggled(fullscreen_mode)
		_on_option_button_item_selected(id)
		option_button.select(id)
		if not FileAccess.file_exists(save_grafik_path):
			set_default_size()
		Set_Resulutuns_text()
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
		"id" : id,
		"v_sync_mode" : v_sync_mode,
		"fullscreen_mode" : fullscreen_mode,
	}
	return save_dict
	
		 
func Check_mode():
	var _window = get_window()
	var mode = _window.get_mode()
	
	if mode == Window.MODE_EXCLUSIVE_FULLSCREEN:
		option_button.visible = false
		full_screen.set_pressed_no_signal(true)
		
		
func Add_Resolutions():
	var Current_Resulution = get_window().get_size()
	var ID = 0
	
	for r in Resolutions:
		option_button.add_item(r, ID)
		
		if Resolutions[r] == Current_Resulution:
			option_button.select(ID)
		
		ID += 1


func _on_option_button_item_selected(index):
	Global.ui_sound = true
	var ID = option_button.get_item_text(index)
	id = index
	get_window().set_size(Resolutions[ID])
	Centre_Window()
	
	
func set_default_size():
	var default_Resulution = DisplayServer.screen_get_size()
	var ID = 0
	
	for r in Resolutions:
		if Resolutions[r] == default_Resulution:
			option_button.select(ID)
			option_button.set_text(str(DisplayServer.screen_get_size().x,"x",DisplayServer.screen_get_size().y))
			Global.ui_sound = true
			get_window().set_size(Resolutions[option_button.get_item_text(ID)])
			Centre_Window()
			return
		
		ID += 1
	option_button.select(6)
	option_button.set_text("1280x800")
	

func Centre_Window():
	var Centre_Screen = DisplayServer.screen_get_position()+DisplayServer.screen_get_size()/2
	var Window_Size = get_window().get_size_with_decorations()
	get_window().set_position(Centre_Screen-Window_Size/2)

func Set_Resulutuns_text():
	var Resolutions_text = str(get_window().get_size().x,"x",get_window().get_size().y)
	option_button.set_text(Resolutions_text)

func _on_full_screen_toggled(toggled_on):
	Global.ui_sound = true
	if toggled_on:
		fullscreen_mode = true
		get_window().set_mode(Window.MODE_EXCLUSIVE_FULLSCREEN)
		option_button.visible = false
	else:
		fullscreen_mode = false
		get_window().set_mode(Window.MODE_WINDOWED)
		Centre_Window()
		option_button.visible = true


func _on_reset_pressed():
	Global.ui_sound = true
	if FileAccess.file_exists(save_grafik_path):
		DirAccess.remove_absolute(save_grafik_path)
	option_button.visible = false
	get_window().set_mode(Window.MODE_EXCLUSIVE_FULLSCREEN)
	Set_Resulutuns_text()
	Centre_Window()
	Check_mode()
	v_sync.set_pressed_no_signal(false)
	_on_v_sync_toggled(false)


func _on_v_sync_toggled(toggled_on: bool) -> void:
	Global.ui_sound = true
	if toggled_on:
		v_sync_mode = true
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		v_sync_mode = false
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


func _on_back_pressed():
	Global.ui_sound = true
	if not FileAccess.file_exists(save_grafik_path):
		get_parent().save_game("savegrafik", save_grafik_path)
	else:
		DirAccess.remove_absolute(save_grafik_path)
		get_parent().save_game("savegrafik", save_grafik_path)
		
	Global.ui_sound = true
	$CanvasLayer.visible = false
	get_parent().get_node("CanvasLayer/Menu").visible = true
	Global.trigger_host_focus = true
	get_parent().get_node("CanvasLayer/Menu/PanelContainer/VBoxContainer/Beenden").grab_focus()
	Global.trigger_host_focus = false
	

func _on_mouse_entered():
	Global.ui_hover_sound = true


func _on_focus_entered():
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Global.ui_hover_sound = true
