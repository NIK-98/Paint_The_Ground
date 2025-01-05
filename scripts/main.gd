extends Node

var save_path = "user://savetemp.save"
var playersave_path = "user://playersave.save"
var save_audio_setting_path = "user://saveaudiosettings.save"
var save_grafik_path = "user://savegrafiksettings.save"
var save_input_setting_path = "user://saveinputsettings.save"
var save_shop_path = "user://saveshop.save"
var server_browser_new = preload("res://sceens/server_browser.tscn")
@onready var akzeptieren: CenterContainer = $CanvasLayer/akzeptieren
@onready var shop: Button = $CanvasLayer/Menu/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Shop

const passw = "ffw49w3rwhfrw8"

var controll_switcher = false
		
		
func _ready():
	var new_browser = server_browser_new.instantiate()
	new_browser.offset_left = 32.0
	new_browser.offset_top = 568.0
	new_browser.offset_right = 1246.0
	new_browser.offset_bottom = 883.0
	$CanvasLayer2/Control.add_child(new_browser)
	if not OS.has_feature("dedicated_server"):
		load_game("Persist", save_path)
		load_game("playersave", playersave_path)
		load_game("saveaudiosettings", save_audio_setting_path)
		load_game("savegrafik", save_grafik_path)
		load_game("saveinputsettings", save_input_setting_path)
		load_game("saveshop", save_shop_path)
		await get_tree().process_frame
		if FileAccess.file_exists(save_path):
			DirAccess.remove_absolute(save_path)
		return
	var args = OS.get_cmdline_args()
	if args.has("-p"):
		var argument_wert = args[args.find("-p") + 1] # Wert des spezifischen Arguments
		$CanvasLayer2/Control/UI.port = argument_wert
	if not $CanvasLayer2/Control/UI.port.is_valid_int():
		prints("Das Argument '-p' wurde nicht uebergeben, ist der standard Port oder ist fehlerhaft. Port ist der standard port 11111!")
		$CanvasLayer2/Control/UI.port = "11111"
	prints("Port wurde auf ", $CanvasLayer2/Control/UI.port, " gesetzt! achtung ports unter 1024 gehen vermutlich nicht!")
	
	
	$CanvasLayer2/Control/UI.Max_clients = 6
	if DisplayServer.get_name() == "headless":
		$CanvasLayer2/Control/UI.Max_clients = 7
		print("Startet Dedicated Server.")
		$CanvasLayer2/Control/UI._on_host_pressed.call_deferred()
		

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		if FileAccess.file_exists(save_path):
			DirAccess.remove_absolute(save_path)
			
	
func save_game(group: String, path: String):
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	var save_file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, passw)
	var save_nodes = get_tree().get_nodes_in_group(group)
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)

# Note: This can be called from anywhere inside the tree. This function
# is path independent.
func load_game(group: String, path: String):
	if not FileAccess.file_exists(path):
		return # Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group(group)
	for i in save_nodes:
		i.queue_free()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, passw)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()

		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object = load(node_data["filename"]).instantiate()
		get_node(node_data["parent"]).add_child(new_object)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])

		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])
			
			
func _on_leave_pressed():
	Input.action_press("exit")
	Input.action_release("exit")


func _on_back_pressed():
	Input.action_press("cancel")
	Input.action_release("cancel")


func _on_tap_pressed():
	Input.action_press("Info")
	


func _on_tap_released():
	Input.action_release("Info")
			
			
func _on_beenden_pressed():
	if Global.akzept.is_empty():
		Global.ui_sound = true
		Global.akzept = "Beenden"
		$CanvasLayer/Menu.visible = false
		$CanvasLayer/akzeptieren.visible = true
		$CanvasLayer/akzeptieren/PanelContainer/VBoxContainer/CenterContainer/HBoxContainer/Ja.grab_focus()
		return
	await get_tree().create_timer(0.1).timeout
	if $CanvasLayer2/Control/UI.esc_is_pressing and get_node("Level").get_child_count() <= 0:
		$CanvasLayer2/Control/UI.esc_is_pressing = false
		if FileAccess.file_exists(save_path):
			DirAccess.remove_absolute(save_path)
		get_tree().quit()
		return
	if multiplayer.has_multiplayer_peer() and get_node("Level").get_child_count() > 0 and Global.esc_is_pressing_in_game:
		Global.esc_is_pressing_in_game = false
		get_node("Level/level/loby").exit("Verbindung Selber beendet!", true)
		
	$CanvasLayer/Menu.visible = false
	Global.akzept = ""
	

func _on_zurück_pressed():
	Global.ui_sound = true
	$CanvasLayer/Menu.visible = false
	if $CanvasLayer2.visible:
		Global.trigger_host_focus = true
		$CanvasLayer2/Control/UI/Panel/CenterContainer/Net/Options/Option1/o1/Host.grab_focus()
		Global.trigger_host_focus = false
	elif multiplayer.has_multiplayer_peer() and get_node("Level").get_child_count() > 0 and get_node("Level/level/Scoreboard/CanvasLayer").visible:
		Global.trigger_host_focus = true
		get_node("Level/level/Scoreboard/CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/restart").grab_focus()
		Global.trigger_host_focus = false
	elif multiplayer.has_multiplayer_peer() and get_node("Level").get_child_count() > 0 and get_node("Level/level/loby/CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Enter").visible:
		Global.trigger_host_focus = true
		get_node("Level/level/loby/CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Enter").grab_focus()
		Global.trigger_host_focus = false
	elif multiplayer.has_multiplayer_peer() and get_node("Level").get_child_count() > 0 and get_node("Level/level/loby/CenterContainer/HBoxContainer/VBoxContainer/start").visible:	
		Global.trigger_host_focus = true
		get_node("Level/level/loby/CenterContainer/HBoxContainer/VBoxContainer/start").grab_focus()
		Global.trigger_host_focus = false
		


func _on_change_pressed():
	if controll_switcher:
		controll_switcher = false
		$CanvasLayer/joy.joy_start_position = Vector2(137.143,617.143)
		$CanvasLayer/Back.global_position = Vector2(1635.717,558.571)
	else:
		controll_switcher = true
		$CanvasLayer/joy.joy_start_position = Vector2(1692.783,617.143)
		$CanvasLayer/Back.global_position = Vector2(80.162,560)


func _on_audio_pressed():
	Global.ui_sound = true
	$CanvasLayer/Menu.visible = false
	Global.trigger_audio_menu = true


func _on_audio_mouse_entered():
	Global.ui_hover_sound = true


func _on_audio_focus_entered():
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Global.ui_hover_sound = true


func _on_beenden_mouse_entered():
	Global.ui_hover_sound = true


func _on_beenden_focus_entered():
	if not Global.trigger_host_focus:
		Global.ui_hover_sound = true


func _on_zurück_mouse_entered():
	Global.ui_hover_sound = true
	

func _on_zurück_focus_entered():
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Global.ui_hover_sound = true
		

func _physics_process(_delta):
	if has_node("Level/level") and not shop.visible:
		shop.visible = true
	elif not has_node("Level/level") and shop.visible:
		shop.visible = false
	if (Input.is_action_just_pressed("exit") or Input.is_action_just_pressed("exit_con")) and not $Audio_menu/CanvasLayer.visible and not $Grafik/CanvasLayer.visible and not $Control/CanvasLayer.visible and not $shop/CanvasLayer.visible:
		await get_tree().create_timer(0.1).timeout
		Global.esc_is_pressing_in_game = true
		get_node("CanvasLayer/Menu").visible = true
		Global.trigger_host_focus = true
		get_node("CanvasLayer/Menu/PanelContainer/VBoxContainer/Beenden").grab_focus()
		Global.trigger_host_focus = false
		return


func _on_grafik_pressed():
	Global.ui_sound = true
	$CanvasLayer/Menu.visible = false
	Global.trigger_grafik_menu = true


func _on_grafik_focus_entered():
	if not Global.trigger_host_focus:
		Global.ui_hover_sound = true


func _on_grafik_mouse_entered():
	Global.ui_hover_sound = true


func _on_eingabe_pressed() :
	Global.ui_sound = true
	$CanvasLayer/Menu.visible = false
	Global.trigger_input_menu = true


func _on_eingabe_focus_entered():
	if not Global.trigger_host_focus:
		Global.ui_hover_sound = true


func _on_eingabe_mouse_entered():
	Global.ui_hover_sound = true


func _on_deleteuser_pressed() -> void:
	if Global.akzept.is_empty():
		Global.ui_sound = true
		Global.akzept = "Coins Löschen"
		$CanvasLayer/Menu.visible = false
		$CanvasLayer/akzeptieren.visible = true
		$CanvasLayer/akzeptieren/PanelContainer/VBoxContainer/CenterContainer/HBoxContainer/Ja.grab_focus()
		return
	$money/coin_display.saveplayer(true)
	Global.akzept = ""


func _on_deleteuser_focus_entered() -> void:
	if not Global.trigger_host_focus:
		Global.ui_hover_sound = true


func _on_deleteuser_mouse_entered() -> void:
	Global.ui_hover_sound = true


func _on_shop_pressed() -> void:
	Global.ui_sound = true
	$CanvasLayer/Menu.visible = false
	Global.trigger_shop_menu = true


func _on_shop_focus_entered() -> void:
	if not Global.trigger_host_focus:
		Global.ui_hover_sound = true


func _on_shop_mouse_entered() -> void:
	Global.ui_hover_sound = true
