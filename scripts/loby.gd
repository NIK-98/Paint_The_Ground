extends CanvasLayer

@export var player_conect_count = 0
@export var is_running = false
@export var Max_clients = 6
@export var hidenloby = false

var j_namen = ["Levi",
			   "Emil",
			   "Liam",
			   "Anton",
			   "Theo",
			   "Paul",
			   "Leano",
			   "Elias",
			   "Jakob",
			   "Samuel",
			   "Felix",
			   "Michael",
			   "Linus",
			   "Aaron",
			   "Leo",
			   "Thomas",
			   "Lukas",
			   "Noah",
			   "Leon",
			   "Jonas",
			   "David",
			   "Levin",
			   "Julian",
			   "Daniel",
			   "Milan",
			   "Lio",
			   "Matteo",
			   "Valentin",
			   "Oskar",
			   "Elia",
			   "Alexander",
			   "Kian",
			   "Finn",
			   "Markus",
			   "Jan",
			   "Jonathan",
			   "Moritz",
			   "Joris",
			   "Jonah",
			   "Tim",
			   "Jasper",
			   "Luis",
			   "Mika",
			   "Oliver",
			   "Niklas",
			   "Luca",
			   "Lorenz",
			   "Tobias",
			   "Fabian",
			   "Maximilian",
			   "Luan"]
var m_namen = ["Lina",
			   "Emilia",
			   "Emma",
			   "Ella",
			   "Ida",
			   "Lia",
			   "Lea",
			   "Amalia",
			   "Leonie",
			   "Laura",
			   "Lena",
			   "Mia",
			   "Nora",
			   "Mila",
			   "Juna",
			   "Anna",
			   "Johanna",
			   "Malia",
			   "Luisa",
			   "Maria",
			   "Amelie",
			   "Ava",
			   "Julia",
			   "Marie",
			   "Antonia",
			   "Noah",
			   "Nele",
			   "Elena",
			   "Alina",
			   "Leni",
			   "Mara",
			   "Mathilda",
			   "Charlotte",
			   "Liom",
			   "Sophie",
			   "Livia",
			   "Lara",
			   "Marlene",
			   "Mina",
			   "Sarah",
			   "Mira",
			   "Hanna",
			   "Finn",
			   "Romy",
			   "Elisabeth",
			   "Katharina",
			   "Elsa",
			   "Emily",
			   "Marla",
			   "Malou",
			   "Elisa"
			   ]
var curent_list = []
var player_names = []

	
var esc_is_pressing_in_game = false
	
func _ready():
	visible = true
	$CenterContainer/VBoxContainer/npcs.text = str("Solo NPCs: ",Global.count_npcs)
	reset_loby()
		
func _process(_delta):
	if Input.is_action_just_pressed("exit"):
		esc_is_pressing_in_game = true
		get_parent().get_parent().get_parent().get_node("CanvasLayer/Beenden").visible = true
		get_parent().get_parent().get_parent().get_node("CanvasLayer/Beenden/PanelContainer/VBoxContainer/Ja").grab_focus()
		return
	if visible:
		visible_loby()
	
func visible_loby():
	if player_conect_count == len(player_names) and $CenterContainer/VBoxContainer/Warten.visible and not hidenloby:
		if DisplayServer.get_name() == "headless":
			return
		set_hidelobyvar.rpc()
		get_parent().get_node("Timerwarte").start()
		

@rpc("any_peer","call_local")
func update_player_names(namen):
	player_names.append(namen)


@rpc("any_peer","call_local")	
func set_hidelobyvar():
	hidenloby = not hidenloby
	
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
func reset_var():
	hidenloby = false
	player_conect_count = 0
	is_running = false
	Max_clients = 6
	if DisplayServer.get_name() == "headless":
		Max_clients = 7
	
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_RESUMED or what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if not multiplayer.has_multiplayer_peer():
			return
		exit(false)
		return
				
			

func server_exit():
	for n in get_parent().get_node("Werten/PanelContainer/Wertung").get_children():
		if n.is_npc:
			n.queue_free()
	await get_tree().process_frame
	multiplayer.multiplayer_peer.close()
	get_tree().get_nodes_in_group("Level")[0].queue_free()
	get_tree().change_scene_to_file("res://sceens/main.tscn")

func exit(show_msg: bool):
	if multiplayer.is_server() or DisplayServer.get_name() == "headless":
		if DisplayServer.get_name() != "headless":
			OS.alert("Server beendet!")
		server_exit()
		return
	else:
		exit_server_tree()
		get_parent().kicked(multiplayer.get_unique_id(), "Verbindung Selber beendet!", show_msg)
		return
			
@rpc("any_peer","call_local")
func remove_count_player():
	if player_conect_count > 0:
		player_conect_count -= 1
		player_names.pop_back()
	
	
func exit_server_tree():
	remove_count_player.rpc()
		

func reset_loby():
	if DisplayServer.get_name() == "headless":
		if len(multiplayer.get_peers()) == 0 and is_running:
			server_exit()


@rpc("any_peer","call_local")
func is_server_run_game():
	Max_clients = 0
	
func _on_enter_pressed():
	var vaild_text = false
	for i in $CenterContainer/VBoxContainer/name_input.text:
		if i == " ":
			vaild_text = false
		else:
			vaild_text = true
	if not vaild_text:
		OS.alert("Bitte Namen Eingeben und \nlehrzeichen am ende vermeiden!")
		return
	for i in get_parent().get_node("Players").get_children():
		if i.get_node("Name").text == $CenterContainer/VBoxContainer/name_input.text:
			OS.alert("Name Exsistiert Schon!")
			return
			
	if $CenterContainer/VBoxContainer/name_input.text != "":
		is_server_run_game.rpc()
		update_player_names.rpc($CenterContainer/VBoxContainer/name_input.text)
		check_all_players_exist.rpc()
		$CenterContainer/VBoxContainer/name_input.visible = false
		$CenterContainer/VBoxContainer/Enter.visible = false
		$CenterContainer/VBoxContainer/HBoxContainer.visible = false
		$CenterContainer/VBoxContainer/Random.visible = false
		$CenterContainer/VBoxContainer/Warten.visible = true
		get_parent().add_text_tap.rpc(multiplayer.get_unique_id(), $CenterContainer/VBoxContainer/name_input.text)
		namen_text_update.rpc_id(multiplayer.get_unique_id(), multiplayer.get_unique_id(), $CenterContainer/VBoxContainer/name_input.text)


@rpc("any_peer","call_local")
func check_all_players_exist():
	if player_conect_count == len(player_names):
		update_server_status_conected.rpc()
	
	
func _on_j_pressed():
	curent_list = j_namen


func _on_m_pressed():
	curent_list = m_namen


func _on_random_pressed():
	if curent_list != []:
		$CenterContainer/VBoxContainer/name_input.text = curent_list.pick_random()
	else:
		OS.alert("Mänlich oder Weiblich Wällen", "Auswahl")


func _on_npcs_pressed():
	Global.count_npcs += 1
	if Global.count_npcs > Global.npcs_anzahl:
		Global.count_npcs = 1
	$CenterContainer/VBoxContainer/npcs.text = str("Solo NPCs: ",Global.count_npcs)
		
