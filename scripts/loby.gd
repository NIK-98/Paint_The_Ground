extends CanvasLayer

@export var count_players_wait = 0
@export var player_conect_count = 0
@export var dedicated_server_triggrer = false
		
		
func _process(delta):
	if visible and not dedicated_server_triggrer:
		visible_loby()
	
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
func trigger_server():
	if player_conect_count > 0 and DisplayServer.get_name() != "headless":
		return
	if player_conect_count > 1 and DisplayServer.get_name() == "headless":
		return
	dedicated_server_triggrer = not dedicated_server_triggrer
	
@rpc("any_peer","call_local")	
func namen_text_update(id, text):
	get_parent().get_node("Players").get_node(str(id)).get_node("Name").text = text
		
@rpc("any_peer","call_local")
func update_player_count():
	player_conect_count += 1
	

@rpc("any_peer","call_local")
func update_server_status_conected():
	Global.Max_clients = 0
	if count_players_wait == player_conect_count:
		Global.is_running = true
	

@rpc("any_peer","call_local")
func update_server_status_disconected():
	Global.Max_clients = Global.start_clients_limit
	player_conect_count = 0
	

@rpc("any_peer","call_local")
func update_runnig_status_disconected():
	Global.is_running = false
	
	
@rpc("any_peer","call_local")
func update_player_wait():
	count_players_wait += 1
	
	
@rpc("any_peer","call_local")
func exit():
	if multiplayer.is_server():
		update_runnig_status_disconected.rpc()
		update_server_status_disconected.rpc()
		multiplayer.multiplayer_peer.disconnect_peer(multiplayer.get_unique_id())
		multiplayer.multiplayer_peer = null
		emit_signal("add_player")			
		emit_signal("del_player")
		emit_signal("del_score")
		get_tree().get_nodes_in_group("Level")[0].queue_free()
		get_tree().change_scene_to_file("res://sceens/main.tscn")
		return
	if player_conect_count > 0:
		player_conect_count -= 1
	
	
func exit_server_tree():
	exit.rpc()
	update_server_status_disconected.rpc()


func _enter_tree():
	if DisplayServer.get_name() == "headless":
		trigger_server.rpc()
		return
	update_player_count.rpc()
	trigger_server.rpc()
	
	
func _on_enter_pressed():
	update_server_status_conected.rpc()
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
	namen_text_update.rpc(multiplayer.get_unique_id(), $CenterContainer/VBoxContainer/name_input.text)
