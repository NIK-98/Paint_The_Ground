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
	0: "L_STICK ↑",
	1: "L_STICK ↓",
	2: "L_STICK →",
	3: "L_STICK ←",
	
	4: "R_STICK ↑",
	5: "R_STICK ↓",
	6: "R_STICK →",
	7: "R_STICK ←",
	
	8: "LT",
	9: "RT"
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
		"scrollup":
			label.text = "Scroll hoch"
		"scrolldown":
			label.text = "Scroll runter"
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
		"scrollup_con":
			label.text = "Scroll hoch"
		"scrolldown_con":
			label.text = "Scroll runter"
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
	if FileAccess.file_exists(save_input_setting_path):
		return
	android.text = android_name
	set_aktion_name()
	set_text_key()
	
			
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
		if save_aktion_pc_name != "":
			aktion_pc_name = save_aktion_pc_name
		if save_aktion_controler_name != "":
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


func _physics_process(_delta):
	if pc.text == "drücke eine taste":
		pc.grab_focus()
	if con.text == "drücke eine taste":
		con.grab_focus()
	
func _reset():
	set_process_unhandled_input(false)
	InputMap.load_from_project_settings()
	set_aktion_name()
	set_text_key()
	set_process(false)


func set_text_key():
	var action_events = InputMap.action_get_events(aktion_pc_name)
	var action_con_events = InputMap.action_get_events(aktion_controler_name)
	
	if not action_events.is_empty():
		var action_event = action_events[0]
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
			var action_con_value = action_con_event.axis_value
			if action_con_keycode == 0 and action_con_value == 1:#r
				con.text = "%s" % X_Box_axis_names.get(2)
				save_con_text = "%s" % X_Box_axis_names.get(2)
			if action_con_keycode == 0 and action_con_value == -1:#l
				con.text = "%s" % X_Box_axis_names.get(3)
				save_con_text = "%s" % X_Box_axis_names.get(3)
			if action_con_keycode == 1 and action_con_value == -1:#u
				con.text = "%s" % X_Box_axis_names.get(0)
				save_con_text = "%s" % X_Box_axis_names.get(0)
			if action_con_keycode == 1 and action_con_value == 1:#d
				con.text = "%s" % X_Box_axis_names.get(1)
				save_con_text = "%s" % X_Box_axis_names.get(1)
				
			if action_con_keycode == 2 and action_con_value == 1:#r
				con.text = "%s" % X_Box_axis_names.get(6)
				save_con_text = "%s" % X_Box_axis_names.get(6)
			if action_con_keycode == 2 and action_con_value == -1:#l
				con.text = "%s" % X_Box_axis_names.get(7)
				save_con_text = "%s" % X_Box_axis_names.get(7)
			if action_con_keycode == 3 and action_con_value == -1:#u
				con.text = "%s" % X_Box_axis_names.get(4)
				save_con_text = "%s" % X_Box_axis_names.get(4)
			if action_con_keycode == 3 and action_con_value == 1:#d
				con.text = "%s" % X_Box_axis_names.get(5)
				save_con_text = "%s" % X_Box_axis_names.get(5)
				
			if action_con_keycode == 4:#trigger l
				con.text = "%s" % X_Box_axis_names.get(8)
				save_con_text = "%s" % X_Box_axis_names.get(8)
			if action_con_keycode == 5:#trigger r
				con.text = "%s" % X_Box_axis_names.get(9)
				save_con_text = "%s" % X_Box_axis_names.get(9)
				
				
			save_con_code = action_con_keycode
			save_ev_con_name = "axis"
		save_aktion_controler_name = aktion_controler_name
			
			
func _on_pc_toggled(toggled_on: bool) -> void:
	Global.ui_sound = true
	if toggled_on:
		for i in get_tree().get_nodes_in_group("input_pc"):
			if i.get_parent().get_parent().aktion_pc_name != aktion_pc_name:
				i.get_parent().get_parent().pc.toggle_mode = false
				i.get_parent().get_parent().set_process_unhandled_input(false)
		pc.text = "drücke eine taste"
		set_process_unhandled_input(true)	
	else:
		for i in get_tree().get_nodes_in_group("input_pc"):
			if i.get_parent().get_parent().aktion_pc_name != aktion_pc_name:
				i.get_parent().get_parent().pc.toggle_mode = true
				i.get_parent().get_parent().set_process_unhandled_input(false)
		set_text_key()


func _on_con_toggled(toggled_on: bool) -> void:
	Global.ui_sound = true
	var action_con_event = InputMap.action_get_events(aktion_controler_name)[0]
	if (action_con_event.is_class("InputEventJoypadButton") or action_con_event.is_class("InputEventJoypadMotion")):
		if toggled_on:
			for i in get_tree().get_nodes_in_group("input_con"):
				if i.get_parent().get_parent().aktion_controler_name != aktion_controler_name:
					i.get_parent().get_parent().con.toggle_mode = false
					i.get_parent().get_parent().set_process_unhandled_input(false)
			con.text = "drücke eine taste"
			set_process_unhandled_input(toggled_on)	
		else:
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
		
	if not event is InputEventMouseButton:
		if con.text == "drücke eine taste" and (event is InputEventJoypadButton) or (event is InputEventJoypadMotion and (event.axis_value == 1.0 or event.axis_value == -1.0)):
			rebind_con_button(event)
			con.button_pressed = false
		elif pc.text == "drücke eine taste" and event is not InputEventJoypadButton and event is not InputEventJoypadMotion:
			rebind_pc_button(event)
			pc.button_pressed = false
		else:
			return
			
				
				
func rebind_pc_button(event):
	InputMap.action_erase_events(aktion_pc_name)
	InputMap.action_add_event(aktion_pc_name, event)
	
	set_process_unhandled_input(false)
	set_text_key()
	set_aktion_name()
	

func rebind_con_button(event):
	InputMap.action_erase_events(aktion_controler_name)
	InputMap.action_add_event(aktion_controler_name, event)
	
	set_process_unhandled_input(false)
	set_text_key()
	set_aktion_name()

func _on_focus_entered() -> void:
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Global.ui_hover_sound = true


func _on_mouse_entered() -> void:
	Global.ui_hover_sound = true


func _on_con_focus_exited() -> void:
	get_viewport().set_input_as_handled()


func _on_pc_focus_exited() -> void:
	get_viewport().set_input_as_handled()
