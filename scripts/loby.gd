extends CanvasLayer

@export var count_players_wait = 0
@export var player_conect_count = 0
	
	
func _process(delta):
	if visible:
		visible_loby()
	
	
func visible_loby():
	if count_players_wait == player_conect_count:
		visible = false
	

@rpc("any_peer","call_local")	
func namen_text_update(id, text):
	get_parent().get_node("Players").get_node(str(id)).get_node("Name").text = text
		
@rpc("any_peer","call_local")
func update_player_count():
	player_conect_count += 1
	

@rpc("any_peer","call_local")
func update_player_wait():
	count_players_wait += 1
	

func _enter_tree():
	update_player_count.rpc()
	
	
func _on_enter_pressed():
	Global.Max_clients = 0
	if $CenterContainer/VBoxContainer/name_input.text == "":
		OS.alert("Bitte Namen Eingeben!")
		return
	for i in get_parent().get_node("Players").get_children():
		if i.get_node("Name").text == $CenterContainer/VBoxContainer/name_input.text:
			OS.alert("Name Exsistiert Schon!")
			return
	if $CenterContainer/VBoxContainer/name_input.text != "":
		update_player_wait.rpc()
		$CenterContainer/VBoxContainer/name_input.visible = false
		$CenterContainer/VBoxContainer/Enter.visible = false
		$CenterContainer/VBoxContainer/Warten.visible = true
	namen_text_update.rpc(multiplayer.get_unique_id(), $CenterContainer/VBoxContainer/name_input.text)
