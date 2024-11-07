class_name rebind_button
extends Control

@onready var label: Label = $HBoxContainer/Label
@onready var pc: Button = $HBoxContainer/pc
@onready var con: Button = $HBoxContainer/con
@onready var android: Label = $HBoxContainer/Android

@export var aktion_pc_name: String = "key"
@export var aktion_controler_name: String = "key"
@export var android_name: String = "key"


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
	JOY_BUTTON_PADDLE4: "P4",
}

var X_Box_axis_names = {
	JOY_AXIS_LEFT_X: "LEFT STICK",
	JOY_AXIS_LEFT_Y: "LEFT STICK",
	JOY_AXIS_RIGHT_X: "RIGHT STICK",
	JOY_AXIS_RIGHT_Y: "RIGHT STICK"
}


func _ready() -> void:
	set_process_unhandled_input(false)
	set_aktion_name()
	set_text_key()
	android.text = android_name
	
	
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
				

func set_text_key():
	var action_events = InputMap.action_get_events(aktion_pc_name)
	var action_con_events = InputMap.action_get_events(aktion_controler_name)
	if not action_events.is_empty():
		var action_event = action_events[0]
		if action_event.is_class("InputEventKey"):
			var action_keycode = OS.get_keycode_string(action_event.physical_keycode)
			pc.text = "%s" % action_keycode
	if not action_con_events.is_empty():
		var action_con_event = action_con_events[0]
		if action_con_event.is_class("InputEventJoypadButton"):
			var action_con_keycode = action_con_event.get_button_index()
			con.text = "%s" % X_Box_button_names.get(action_con_keycode)
		if action_con_event.is_class("InputEventJoypadMotion"):
			var action_con_keycode = action_con_event.axis 
			con.text = "%s" % X_Box_axis_names.get(action_con_keycode)
			
			
func _on_pc_toggled(toggled_on: bool) -> void:
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
