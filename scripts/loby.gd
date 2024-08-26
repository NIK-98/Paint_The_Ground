extends CanvasLayer

@export var player_conect_count = 0
@export var player_wait_count = 0
@export var is_running = false
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
	if player_conect_count == player_wait_count and $CenterContainer/VBoxContainer/Warten.visible and not hidenloby:
		if DisplayServer.get_name() == "headless":
			return
		set_hidelobyvar.rpc()
		get_parent().get_node("Timerwarte").start()
	
	
@rpc("any_peer","call_local")
func update_player_wait(positive: bool):
	if positive:
		player_wait_count += 1
	elif player_wait_count > 0:
		player_wait_count -= 1


@rpc("any_peer","call_local")	
func set_hidelobyvar():
	hidenloby = not hidenloby
	
@rpc("any_peer","call_local")	
func namen_text_update(id, text):
	get_parent().get_node("Players").get_node(str(id)).get_node("Name").text = text

		
@rpc("any_peer","call_local")
func update_player_count(positiv: bool):
	if positiv:
		player_conect_count += 1
	elif player_conect_count > 0:
		player_conect_count -= 1
	
	
@rpc("any_peer","call_local")
func update_server_status_conected():
	is_running = true
	
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_RESUMED or what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().paused = true
		exit("Verbindung Selber beendet!", true)
		return
				
			

func server_exit():
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	get_parent().wechsel_sceene_wenn_server_disconected()
	
	
func exit(msg: String, show_msg: bool):
	update_player_count.rpc(false)
	if multiplayer and multiplayer.is_server() or DisplayServer.get_name() == "headless":
		if DisplayServer.get_name() != "headless":
			OS.alert("Server beendet!")
		server_exit()
	if multiplayer:
		for i in multiplayer.get_peers():
			get_parent().kicked(i, msg, show_msg)
	
		

func reset_loby():
	if DisplayServer.get_name() == "headless":
		if len(multiplayer.get_peers()) == 0 and is_running:
			server_exit()

	
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
		get_parent().is_server_run_game.rpc()
		update_player_wait.rpc(true)
		check_all_players_exist.rpc()
		$CenterContainer/VBoxContainer/npcs.visible = false
		$CenterContainer/VBoxContainer/name_input.visible = false
		$CenterContainer/VBoxContainer/Enter.visible = false
		$CenterContainer/VBoxContainer/HBoxContainer.visible = false
		$CenterContainer/VBoxContainer/Random.visible = false
		$CenterContainer/VBoxContainer/Warten.visible = true
		get_parent().add_text_tap.rpc(multiplayer.get_unique_id(), $CenterContainer/VBoxContainer/name_input.text)
		namen_text_update.rpc_id(multiplayer.get_unique_id(), multiplayer.get_unique_id(), $CenterContainer/VBoxContainer/name_input.text)
		if player_conect_count == 1 and get_parent().get_node("Players").has_node("1") and not get_parent().loaded_seson:
			get_parent().loaded_seson = true
			get_parent().spawn_npc()

	
	
@rpc("any_peer","call_local")
func check_all_players_exist():
	if player_conect_count == player_wait_count:
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
