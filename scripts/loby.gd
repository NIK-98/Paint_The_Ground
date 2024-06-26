extends CanvasLayer

@export var count_players_wait = 0
@export var player_conect_count = 0
@export var is_running = false
@export var Max_clients = 6
	
	
func _ready():
	Max_clients = 6
	if DisplayServer.get_name() == "headless":
		Max_clients = 7
		
func _process(delta):
	if Input.is_action_just_pressed("exit"):
		exit()
		return
	if visible:
		visible_loby()
	
func visible_loby():
	if count_players_wait == player_conect_count:
		if DisplayServer.get_name() == "headless":
			return
		visible = false

	
@rpc("any_peer","call_local")	
func namen_text_update(id, text):
	get_parent().get_node("Players").get_node(str(id)).get_node("Name").text = text

		
@rpc("any_peer","call_local")
func update_player_count():
	player_conect_count += 1
	

@rpc("any_peer","call_local")
func update_server_status_conected():
	Max_clients = len(multiplayer.get_peers())
	is_running = true
	

@rpc("any_peer","call_local")
func update_server_status_disconected():
	Max_clients = 6
	if DisplayServer.get_name() == "headless":
		Max_clients = 7
		return
	
	
func reset_var():
	count_players_wait = 0
	player_conect_count = 0
	is_running = false
	Max_clients = 6
	if DisplayServer.get_name() == "headless":
		Max_clients = 7
	

@rpc("any_peer","call_local")
func update_runnig_status_disconected():
	is_running = false
	
	
@rpc("any_peer","call_local")
func update_player_wait():
	count_players_wait += 1
	
	
func exit():
	if DisplayServer.get_name() == "headless":
		return
	if multiplayer.is_server():
		OS.alert("Server beendet!")
		get_parent().stoped_game.rpc()
		update_runnig_status_disconected.rpc()
		update_server_status_disconected.rpc()
		multiplayer.multiplayer_peer.disconnect_peer(multiplayer.get_unique_id())
		multiplayer.multiplayer_peer = null
		get_tree().get_nodes_in_group("Level")[0].queue_free()
		get_tree().change_scene_to_file("res://sceens/main.tscn")
		return
	else:
		exit_server_tree()
		get_parent().stoped_game.rpc()
		get_parent().kicked(multiplayer.get_unique_id(), "Verbindung Selber beendet!")
		
@rpc("any_peer","call_local")
func remove_count_player():
	if player_conect_count > 0:
		player_conect_count -= 1
		
		
@rpc("any_peer","call_local")
func remove_count_player_wait():
	if count_players_wait > 0:
		count_players_wait -= 1
	
	
func exit_server_tree():
	remove_count_player.rpc()
	if get_node("CenterContainer/VBoxContainer/Warten").visible:
		remove_count_player_wait.rpc()
		

func reset_loby():
	if len(multiplayer.get_peers()) == 0 and is_running:
		get_parent().stoped_game.rpc()
		reset_var()
		get_parent().reset_vars_level.rpc()
		get_parent().reset_bomben.rpc()
		exit()
	

@rpc("any_peer","call_local")
func is_server_run_game():
	Max_clients = 0
	
func _on_enter_pressed():
	if $CenterContainer/VBoxContainer/name_input.text == "":
		OS.alert("Bitte Namen Eingeben!")
		return
	for i in get_parent().get_node("Players").get_children():
		if i.get_node("Name").text == $CenterContainer/VBoxContainer/name_input.text:
			OS.alert("Name Exsistiert Schon!")
			return
			
	if $CenterContainer/VBoxContainer/name_input.text != "":
		update_player_wait.rpc()
		if is_multiplayer_authority():
			is_server_run_game.rpc()
		else:
			update_server_status_conected.rpc()
		$CenterContainer/VBoxContainer/name_input.visible = false
		$CenterContainer/VBoxContainer/Enter.visible = false
		$CenterContainer/VBoxContainer/Warten.visible = true
		get_parent().add_text_tap.rpc(multiplayer.get_unique_id(), $CenterContainer/VBoxContainer/name_input.text)
		namen_text_update.rpc(multiplayer.get_unique_id(), $CenterContainer/VBoxContainer/name_input.text)
