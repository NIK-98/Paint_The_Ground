extends CanvasLayer

@export var count_players_wait = 0
@export var player_conect_count = 0
@export var dedicated_server_triggrer = false
@export var is_running = false
@export var Max_clients = 6
		
		
		
func _ready():
	Max_clients = 6
	if DisplayServer.get_name() == "headless":
		Max_clients = 7
		
func _process(delta):
	if visible and not dedicated_server_triggrer:
		visible_loby()
		
	if multiplayer.is_server():
		prints(count_players_wait, player_conect_count)
		if not visible and count_players_wait == 1 and not dedicated_server_triggrer:
			exit()
			return
		if $CenterContainer/VBoxContainer/Warten.visible and count_players_wait == 0 and player_conect_count <= 1 and not dedicated_server_triggrer:
			exit()
			return
	
	if not dedicated_server_triggrer:
		if player_conect_count == 1 and count_players_wait > 1:
			update_runnig_status_disconected.rpc()
			update_server_status_disconected.rpc()
			multiplayer.multiplayer_peer.disconnect_peer(multiplayer.get_unique_id())
			multiplayer.multiplayer_peer = null
			get_tree().change_scene_to_file("res://sceens/main.tscn")
			OS.alert("Keine Mitspieler vorhanden!")
			return
	
func visible_loby():
	if count_players_wait == player_conect_count:
		visible = false

	
@rpc("any_peer","call_local")	
func namen_text_update(id, text):
	get_parent().get_node("Players").get_node(str(id)).get_node("Name").text = text
	

@rpc("any_peer","call_local")	
func trigger_server():
	if player_conect_count > 0 and DisplayServer.get_name() != "headless":
		return
	if player_conect_count > 1 and DisplayServer.get_name() == "headless":
		return
	dedicated_server_triggrer = not dedicated_server_triggrer

		
@rpc("any_peer","call_local")
func update_player_count():
	player_conect_count += 1
	

@rpc("any_peer","call_local")
func update_server_status_conected():
	Max_clients = len(multiplayer.get_peers())
	if count_players_wait == player_conect_count:
		is_running = true
	

@rpc("any_peer","call_local")
func update_server_status_disconected():
	Max_clients = 6
	if DisplayServer.get_name() == "headless":
		Max_clients = 7
	count_players_wait = 0
	
	
@rpc("any_peer","call_local")
func reset_var():
	player_conect_count = 0
	count_players_wait = 0
	dedicated_server_triggrer = false
	

@rpc("any_peer","call_local")
func update_runnig_status_disconected():
	is_running = false
	
	
@rpc("any_peer","call_local")
func update_player_wait():
	count_players_wait += 1
	
	
func exit():
	if multiplayer.is_server():
		OS.alert("Keine Spieler gefunden!")
		update_runnig_status_disconected.rpc()
		update_server_status_disconected.rpc()
		reset_var.rpc()
		multiplayer.multiplayer_peer.disconnect_peer(multiplayer.get_unique_id())
		multiplayer.multiplayer_peer = null
		emit_signal("add_player")			
		emit_signal("del_player")
		emit_signal("del_score")
		emit_signal("del_text_tap")
		emit_signal("exit_multiplayer_loby")
		get_tree().get_nodes_in_group("Level")[0].queue_free()
		get_tree().change_scene_to_file("res://sceens/main.tscn")
		return
		
@rpc("any_peer","call_local")
func remove_count_player():
	if player_conect_count > 0:
		player_conect_count -= 1
		
		
@rpc("any_peer","call_local")
func remove_count_player_wait():
	if count_players_wait > 0:
		count_players_wait -= 1
	
	
func exit_dc_server():
	exit()
	update_server_status_disconected.rpc()
	
	
func exit_server_tree():
	remove_count_player.rpc()
	if get_node("CenterContainer/VBoxContainer/Warten").visible:
		remove_count_player_wait.rpc()
	return
	
	
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
		update_server_status_conected.rpc()
		$CenterContainer/VBoxContainer/name_input.visible = false
		$CenterContainer/VBoxContainer/Enter.visible = false
		$CenterContainer/VBoxContainer/Warten.visible = true
		get_parent().add_text_tap.rpc(multiplayer.get_unique_id(), $CenterContainer/VBoxContainer/name_input.text)
		namen_text_update.rpc(multiplayer.get_unique_id(), $CenterContainer/VBoxContainer/name_input.text)
