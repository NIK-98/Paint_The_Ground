class_name rebind_button
extends Control

@onready var main = $"/root/main/"

@onready var label: Label = $HBoxContainer/Label
@onready var pc: Button = $HBoxContainer/pc
@onready var con: Button = $HBoxContainer/con
@onready var android: Label = $HBoxContainer/Android
@onready var h_button_separator: HSeparator = $"../HSeparator"
@onready var v_box_button_container: VBoxContainer = $".."
@onready var control: Control = $"../../../../../../../../.."

@export var aktion_pc_name: String = "key"
@export var aktion_controler_name: String = "key"
@export var android_name: String = "key"

var loaded = false
var save_pc_text = ""
var save_con_text = ""
var save_pc_code = 0
var save_aktion_pc_name = ""
var save_aktion_controler_name = ""
var save_con_code = 0
var save_ev_con_name = ""

var def_pc_text = ""
var def_con_text = ""


var save_input_setting_path = "user://saveinputsettings.save"


var X_Box_button_names = {
	JOY_BUTTON_A: "A",
	JOY_BUTTON_B: "B",
	JOY_BUTTON_X: "X",
	JOY_BUTTON_Y: "Y",
	JOY_BUTTON_BACK: "BACK",
	JOY_BUTTON_GUIDE: "HOME",
	JOY_BUTTON_START: "MENÜ",
	JOY_BUTTON_LEFT_STICK: "LEFT STICK",
	JOY_BUTTON_RIGHT_STICK: "RIGHT STICK",
	JOY_BUTTON_LEFT_SHOULDER: "LB",
	JOY_BUTTON_RIGHT_SHOULDER: "RB",
	JOY_BUTTON_DPAD_UP: "D-PAD UP",
	JOY_BUTTON_DPAD_DOWN: "D-PAD DOWN",
	JOY_BUTTON_DPAD_LEFT: "D-PAD LEFT",
	JOY_BUTTON_DPAD_RIGHT: "D-PAD RIGHT",
	JOY_BUTTON_MISC1: "SHARE",
	JOY_BUTTON_PADDLE1: "P1",
	JOY_BUTTON_PADDLE2: "P2",
	JOY_BUTTON_PADDLE3: "P3",
	JOY_BUTTON_PADDLE4: "P4"
}

var X_Box_axis_names = {
	JOY_AXIS_LEFT_X: "LEFT STICK",
	JOY_AXIS_LEFT_Y: "LEFT STICK",
	JOY_AXIS_RIGHT_X: "RIGHT STICK",
	JOY_AXIS_RIGHT_Y: "RIGHT STICK"
}
	
	
func set_aktion_name():
	label.text = "Nicht belegt"
	match aktion_pc_name:
		"left":
			label.text = "Links"
		"right":
			label.text = "Rechts"
		"up":
			label.text = "Hoch"
		"down":
			label.text = "Runter"
		"zoomin":
			label.text = "Zoom Rein"
		"zoomout":
			label.text = "Zoom Raus"
		"exit":
			label.text = "Menü"
		"cancel":
			label.text = "Abbrechen"
		"Info":
			label.text = "Spieler-Liste"
		"modus":
			label.text = "Händigkeit"
		"ui_accept":
			label.text = "Bestätigen"
			
			
	match aktion_controler_name:
		"pad_left":
			label.text = "Links"
		"pad_right":
			label.text = "Rechts"
		"pad_up":
			label.text = "Hoch"
		"pad_down":
			label.text = "Runter"
		"zoomin_con":
			label.text = "Zoom Rein"
		"zoomout_con":
			label.text = "Zoom Raus"
		"exit_con":
			label.text = "Menü"
		"cancel_con":
			label.text = "Abbrechen"
		"Info_con":
			label.text = "Spieler-Liste"
		"modus_con":
			label.text = "Händigkeit"
		"ui_accept":
			label.text = "Bestätigen"
	
	
func _ready() -> void:
	set_process_unhandled_input(false)
	android.text = android_name
	set_aktion_name()
	set_text_key()
	def_pc_text = pc.text
	def_con_text = con.text	
	
			
func save():
	var save_dict = {
		"parent_name" : name,
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"aktion_pc_name" : aktion_pc_name,
		"aktion_controler_name" : aktion_controler_name,
		"android_name" : android_name,
		"save_pc_text" : save_pc_text,
		"save_con_text" : save_con_text,
		"save_pc_code" : save_pc_code,
		"save_con_code" : save_con_code,
		"save_ev_con_name" : save_ev_con_name,
		"save_aktion_pc_name" : save_aktion_pc_name,
		"save_aktion_controler_name" : save_aktion_controler_name
	}
	return save_dict
	

func _process(_delta):	
	if not loaded:
		loaded = true
		name = "Button_bind"
		v_box_button_container.move_child(h_button_separator, v_box_button_container.get_child_count())
		if save_pc_text != "":
			pc.text = save_pc_text
		if save_con_text != "":
			con.text = save_con_text
		if aktion_pc_name != "":
			aktion_pc_name = save_aktion_pc_name
		if aktion_controler_name != "":
			aktion_controler_name = save_aktion_controler_name
		if save_pc_code != 0:
			var ev_pc = InputEventKey.new()
			ev_pc.keycode = save_pc_code
			InputMap.action_erase_events(aktion_pc_name)
			InputMap.action_add_event(aktion_pc_name, ev_pc)
		if save_con_code != 0:
			var evb_con = InputEventJoypadButton.new()
			var evm_con = InputEventJoypadMotion.new()
			if evb_con.has_meta(save_ev_con_name):
				evb_con.button_index = save_con_code
				InputMap.action_erase_events(aktion_controler_name)
				InputMap.action_add_event(aktion_controler_name, evb_con)
			if evm_con.has_meta(save_ev_con_name):
				evm_con.axis = save_con_code
				InputMap.action_erase_events(aktion_controler_name)
				InputMap.action_add_event(aktion_controler_name, evm_con)
		android.text = android_name
		set_aktion_name()
		set_process(false)
	
	if control.reseted:
		_reset()
	
	
func _reset():
	set_process_unhandled_input(false)
	pc.text = def_pc_text
	con.text = def_con_text
	InputMap.load_from_project_settings()
	set_aktion_name()
	set_text_key()
	set_process(false)


func set_text_key():
	var action_events = InputMap.action_get_events(aktion_pc_name)
	var action_con_events = InputMap.action_get_events(aktion_controler_name)
	if not action_events.is_empty():
		var action_event = action_events[0]
		prints(action_event)
		if action_event.is_class("InputEventKey"):
			var action_keycode = OS.get_keycode_string(action_event.physical_keycode)
			if aktion_pc_name == "ui_accept":
				action_keycode = OS.get_keycode_string(action_event.keycode)
			if action_keycode != "":
				pc.text = "%s" % action_keycode
				save_pc_text = "%s" % action_keycode
			else:
				pc.text = save_pc_text
				save_pc_text = "%s" % pc.text
			save_pc_code = action_event.physical_keycode
		save_aktion_pc_name = aktion_pc_name
		
	if not action_con_events.is_empty():
		var action_con_event = action_con_events[0]
		for x in action_con_events:
			if x.is_class("InputEventJoypadButton") and aktion_controler_name == "ui_accept":
				action_con_event = x
		if action_con_event.is_class("InputEventJoypadButton"):
			var action_con_keycode = action_con_event.get_button_index()
			con.text = "%s" % X_Box_button_names.get(action_con_keycode)
			save_con_text = "%s" % X_Box_button_names.get(action_con_keycode)
			save_con_code = action_con_keycode
			save_ev_con_name = "button_index"
		if action_con_event.is_class("InputEventJoypadMotion"):
			var action_con_keycode = action_con_event.axis
			con.text = "%s" % X_Box_axis_names.get(action_con_keycode)
			save_con_text = "%s" % X_Box_axis_names.get(action_con_keycode)
			save_con_code = action_con_keycode
			save_ev_con_name = "axis"
		save_aktion_controler_name = aktion_controler_name
			
			
func _on_pc_toggled(toggled_on: bool) -> void:
	control.reseted = false
	if Global.sperre_con:
		return
	Global.ui_sound = true
	if Input.get_connected_joypads().size() <= 1:
		if toggled_on:
			Global.sperre_pc = true
			pc.text = "drücke eine taste"
			set_process_unhandled_input(true)
			for i in get_tree().get_nodes_in_group("input_pc"):
				if i.get_parent().get_parent().aktion_pc_name != aktion_pc_name:
					i.get_parent().get_parent().pc.toggle_mode = false
					i.get_parent().get_parent().set_process_unhandled_input(false)		
		else:
			Global.sperre_pc = false
			for i in get_tree().get_nodes_in_group("input_pc"):
				if i.get_parent().get_parent().aktion_pc_name != aktion_pc_name:
					i.get_parent().get_parent().pc.toggle_mode = true
					i.get_parent().get_parent().set_process_unhandled_input(false)
			set_text_key()


func _on_con_toggled(toggled_on: bool) -> void:
	if Global.sperre_pc:
		return
	Global.ui_sound = true	
	if Input.get_connected_joypads().size() > 1:
		if toggled_on:
			Global.sperre_con = true
			con.text = "drücke eine taste"
			set_process_unhandled_input(toggled_on)
			for i in get_tree().get_nodes_in_group("input_con"):
				if i.get_parent().get_parent().aktion_controler_name != aktion_controler_name:
					i.get_parent().get_parent().con.toggle_mode = false
					i.get_parent().get_parent().set_process_unhandled_input(false)		
		else:
			Global.sperre_con = false
			for i in get_tree().get_nodes_in_group("input_con"):
				if i.get_parent().get_parent().aktion_controler_name != aktion_controler_name:
					i.get_parent().get_parent().con.toggle_mode = true
					i.get_parent().get_parent().set_process_unhandled_input(false)
			set_text_key()
		

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("ui_accept"):
		# Markiere die Eingabe als verarbeitet, damit sie nicht weitergegeben wird
		get_viewport().set_input_as_handled()
		return  # Beende die Funktion, um die Eingabe zu ignorieren
	if Input.get_connected_joypads().size() > 1 and con.text == "drücke eine taste":
		rebind_con_button(event)
		con.button_pressed = false
	elif pc.text == "drücke eine taste":
		rebind_pc_button(event)
		pc.button_pressed = false
		
	
func rebind_pc_button(event):
	InputMap.action_erase_events(aktion_pc_name)
	InputMap.action_add_event(aktion_pc_name, event)
	
	set_process_unhandled_input(false)
	set_text_key()
	set_aktion_name()
	Global.sperre_pc = false
	

func rebind_con_button(event):
	InputMap.action_erase_events(aktion_controler_name)
	InputMap.action_add_event(aktion_controler_name, event)
	
	set_process_unhandled_input(false)
	set_text_key()
	set_aktion_name()
	Global.sperre_con = false


func _on_focus_entered() -> void:
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Global.ui_hover_sound = true


func _on_mouse_entered() -> void:
	Global.ui_hover_sound = true
