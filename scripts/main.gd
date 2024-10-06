extends Node

var save_path = "user://savetemp.save"
var save_audio_setting_path = "user://saveaudiosettings.save"

var controll_switcher = false
		
		
func _ready():
	if not OS.has_feature("dedicated_server"):
		load_game("Persist", save_path)
		load_game("saveaudiosettings", save_audio_setting_path)
		await get_tree().process_frame
		if FileAccess.file_exists(save_path):
			DirAccess.remove_absolute(save_path)
		return
	var args = OS.get_cmdline_args()
	if args.has("-p"):
		var argument_wert = args[args.find("-p") + 1] # Wert des spezifischen Arguments
		$CanvasLayer2/UI.port = argument_wert
	if not $CanvasLayer2/UI.port.is_valid_int():
		prints("Das Argument '-p' wurde nicht uebergeben, ist der standard Port oder ist fehlerhaft. Port ist der standard port 11111!")
		$CanvasLayer2/UI.port = "11111"
	prints("Port wurde auf ", $CanvasLayer2/UI.port, " gesetzt! achtung ports unter 1024 gehen vermutlich nicht!")
	
	
	$CanvasLayer2/UI.Max_clients = 6
	if DisplayServer.get_name() == "headless":
		$CanvasLayer2/UI.Max_clients = 7
		print("Startet Dedicated Server.")
		$CanvasLayer2/UI._on_host_pressed.call_deferred()
		

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		if FileAccess.file_exists(save_path):
			DirAccess.remove_absolute(save_path)
			
	
func save_game(group: String, path: String):
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	var save_file = FileAccess.open(path, FileAccess.WRITE)
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
	var save_file = FileAccess.open(path, FileAccess.READ)
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
	if $CanvasLayer2/UI.esc_is_pressing and get_node("Level").get_child_count() <= 0:
		$CanvasLayer2/UI.esc_is_pressing = false
		if FileAccess.file_exists(save_path):
			DirAccess.remove_absolute(save_path)
		get_tree().quit()
		return
	if multiplayer.has_multiplayer_peer() and get_node("Level").get_child_count() > 0 and get_node("Level/level/loby").esc_is_pressing_in_game:
		get_node("Level/level/loby").esc_is_pressing_in_game = false
		get_node("Level/level/loby").exit("Verbindung Selber beendet!", true)
		
	$CanvasLayer/Menu.visible = false
	

func _on_zurück_pressed():
	$CanvasLayer/Menu.visible = false
	if $CanvasLayer2.visible:
		$CanvasLayer2/UI/Panel/CenterContainer/Net/Options/Option1/o1/Host.grab_focus()
	elif multiplayer.has_multiplayer_peer() and get_node("Level").get_child_count() > 0 and get_node("Level/level/Scoreboard/CanvasLayer").visible:
		get_node("Level/level/Scoreboard/CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/restart").grab_focus()
		


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
	$CanvasLayer/Menu.visible = false
	Global.trigger_audio_menu = true
