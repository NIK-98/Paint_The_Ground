extends CanvasLayer

@export var player_conect_count = 0
@export var player_wait_count = 0
@export var is_running = false
@export var vs_mode = false
@export var tp_mode = false
@export var load_mode = false
@export var coin_mode = false
@export var shop_mode = false
@export var solo_mode = false
@export var server_first_start = false
@export var player_ready = 0
@onready var difficulty = $CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/Speed
var difficulty_id = 0
var count_settime = 0
var count_map_size = 1
var map_faktor = 2
@export var rady_and_wait = []
@export var wait = []

var blue_team_cound = 0
var red_team_cound = 0
var vaild_team = true

var red_members = 0
var blue_members = 0

var namen = ["Levi","Emil","Liam","Anton","Theo",
			 "Paul","Leano","Elias","Jakob","Samuel",
			 "Felix","Michael","Linus","Aaron","Leo",
			 "Thomas","Lukas","Noah","Leon","Jonas",
			 "David","Levin","Julian","Daniel","Milan",
			 "Lio","Matteo","Valentin","Oskar","Elia",
			 "Alexander","Kian","Finn","Markus","Jan",
			 "Jonathan","Moritz","Joris","Jonah","Tim",
			 "Jasper","Luis","Mika","Oliver","Niklas",
			 "Luca","Lorenz","Tobias","Fabian","Maximilian",
			 "Luan","Lina","Emilia","Emma","Ella",
			 "Ida","Lia","Lea","Amalia","Leonie",
			 "Laura","Lena","Mia","Nora","Mila",
			 "Juna","Anna","Johanna","Malia","Luisa",
			 "Maria","Amelie","Ava","Julia","Marie",
			 "Antonia","Noah","Nele","Elena","Alina",
			 "Leni","Mara","Mathilda","Charlotte","Liom",
			 "Sophie","Livia","Lara","Marlene","Mina",
			 "Sarah","Mira","Hanna","Finn","Romy",
			 "Elisabeth","Katharina","Elsa","Emily","Marla",
			 "Malou","Elisa"
			]
	
	
func _ready():
	visible = true
	$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/npcs.text = str("Solo NPCs: ",Global.count_npcs)
	
	difficulty.text = "Normal"
	difficulty_id = 1
	Global.speed_npcs = Global.npc_normal
	
	if multiplayer.is_server():
		$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/settime.visible = true
		$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/settime.connect("pressed",_on_settime_pressed)
		$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map.connect("pressed",_on_map_pressed)
		$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map.visible = true
	
	
@rpc("any_peer","call_local")
func update_player_wait(positive: bool):
	if positive:
		player_wait_count += 1
	if not positive and player_wait_count > 0:
		player_wait_count -= 1

	
@rpc("any_peer","call_local")	
func namen_text_update(id, text):
	get_parent().get_node("Players").get_node(str(id)).get_node("Name").text = text
	if multiplayer.is_server() or get_parent().get_node("Players").has_node("2"):
		get_parent().update_player_name_list(text,true)

		
@rpc("any_peer","call_local")
func update_player_count(positiv: bool):
	if positiv:
		player_conect_count += 1
	if not positiv and player_conect_count > 0:
		player_conect_count -= 1
		if multiplayer.is_server() and player_wait_count <= 1 and player_conect_count == 1:
			no_players()
		if not OS.has_feature("dedicated_server") and not multiplayer.is_server() and player_wait_count <= 1 and player_conect_count == 1:
			$CenterContainer/HBoxContainer/VBoxContainer/start.text = "Beenden"
			$CenterContainer/HBoxContainer/VBoxContainer/start.visible = true

		
@rpc("any_peer","call_local")
func update_options():
	if multiplayer.is_server():
		get_parent().set_coin_mode(get_parent().main.get_node("CanvasLayer2/Control/UI/Panel/CenterContainer/Net/Options/Option1/o2/Coins_Loeschen").button_pressed)
		get_parent().set_shop_mode(get_parent().main.get_node("CanvasLayer2/Control/UI/Panel/CenterContainer/Net/Options/Option1/o2/Shop_Reset").button_pressed)
		get_parent().set_solo_mode(get_parent().main.get_node("CanvasLayer2/Control/UI/Panel/CenterContainer/Net/Options/Option1/o2/Alleine_Spielen").button_pressed)
		get_parent().set_vs_mode(get_parent().main.get_node("CanvasLayer2/Control/UI/Panel/CenterContainer/Net/Options/Option1/o2/vs").button_pressed)
		get_parent().set_tp_mode(get_parent().main.get_node("CanvasLayer2/Control/UI/Panel/CenterContainer/Net/Options/Option1/o2/portal").button_pressed)
		get_parent().set_load_mode(get_parent().main.get_node("CanvasLayer2/Control/UI/Panel/CenterContainer/Net/Options/Option1/o2/Runde_laden").button_pressed)
	var args = OS.get_cmdline_args()
	if OS.has_feature("dedicated_server") and args.has("-tp"):
		var argument_wert = args[args.find("-tp") + 1] # Wert des spezifischen Arguments
		if argument_wert == "true":
			get_parent().set_tp_mode(true)
		elif argument_wert == "false":
			get_parent().set_tp_mode(false)
	
	if OS.has_feature("dedicated_server") and args.has("-vs"):
		var argument_wert = args[args.find("-vs") + 1] # Wert des spezifischen Arguments
		if argument_wert == "true":
			get_parent().set_vs_mode(true)
		elif argument_wert == "false":
			get_parent().set_vs_mode(false)
			
	if OS.has_feature("dedicated_server") and args.has("-no_players"):
		var argument_wert = args[args.find("-no_players") + 1] # Wert des spezifischen Arguments
		if argument_wert == "true":
			get_parent().set_solo_mode(true)
		elif argument_wert == "false":
			get_parent().set_solo_mode(false)
			
	if OS.has_feature("dedicated_server") and args.has("-coinsreset"):
		var argument_wert = args[args.find("-coinsreset") + 1] # Wert des spezifischen Arguments
		if argument_wert == "true":
			get_parent().set_coin_mode(true)
		elif argument_wert == "false":
			get_parent().set_coin_mode(false)
			
	if OS.has_feature("dedicated_server") and args.has("-shopreset"):
		var argument_wert = args[args.find("-shopreset") + 1] # Wert des spezifischen Arguments
		if argument_wert == "true":
			get_parent().set_shop_mode(true)
		elif argument_wert == "false":
			get_parent().set_shop_mode(false)
	
	if OS.has_feature("dedicated_server") and args.has("-load"):
		var argument_wert = args[args.find("-load") + 1] # Wert des spezifischen Arguments
		if argument_wert == "true":
			get_parent().set_load_mode(true)
		elif argument_wert == "false":
			get_parent().set_load_mode(false)
			
	if solo_mode:
		get_parent().is_server_run_game.rpc()
					

func no_players():
	if not visible:
		visible = true
		get_tree().paused = true
	if get_parent().get_node("Scoreboard/CanvasLayer").visible or get_parent().get_node("Tap/CenterContainer/PanelContainer/VBoxContainer").get_child_count() > 1:
		get_parent().get_node("Scoreboard/CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/restart").text = "Beenden"
		$CenterContainer/HBoxContainer/VBoxContainer/Warten.text = str(get_parent().playerlist.size()-1," Mitspieler!")
		$CenterContainer/HBoxContainer/VBoxContainer/start.text = "Beenden"
		$CenterContainer/HBoxContainer/VBoxContainer/start.visible = true
		$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer.visible = false
		$CenterContainer/HBoxContainer/VBoxContainer/name_input.visible = false
		$CenterContainer/HBoxContainer/VBoxContainer/Random.visible = false
		return
	if solo_mode:
		$CenterContainer/HBoxContainer/VBoxContainer/Warten.text = "Solo Modus!"
		if vs_mode:
			$CenterContainer/HBoxContainer/VBoxContainer/Warten.text = "Solo VS-Mode!"
		if tp_mode:
			$CenterContainer/HBoxContainer/VBoxContainer/Warten.text = "Solo TP-Mode!"
		if vs_mode and tp_mode:
			$CenterContainer/HBoxContainer/VBoxContainer/Warten.text = "Solo TP/VS-Mode!"
	
	if not $CenterContainer/HBoxContainer/VBoxContainer/start.visible:
		$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer.visible = true
		$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/npcs.disabled = false
		$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/Speed.disabled = false
		$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/settime.visible = true
		$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map.visible = true
		$CenterContainer/HBoxContainer/VBoxContainer/name_input.visible = true
		$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Enter.visible = true
		$CenterContainer/HBoxContainer/VBoxContainer/Random.visible = true
	else:
		$CenterContainer/HBoxContainer/VBoxContainer/Warten.text = str(get_parent().playerlist.size()-1," Mitspieler!")
		$CenterContainer/HBoxContainer/VBoxContainer/start.text = "Beenden"
		$CenterContainer/HBoxContainer/VBoxContainer/start.visible = true
		
	
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_RESUMED or what == NOTIFICATION_WM_GO_BACK_REQUEST or (what == NOTIFICATION_APPLICATION_FOCUS_OUT and (OS.get_name() == "Android" or OS.get_name() == "iOS")):
		exit("Verbindung Selber beendet!", true)
		return
			

func server_exit():
	if vs_mode:
		for m in range(2):
			if m == 0:
				get_parent().del_score("Red")
				get_parent().del_score_visuel("Red")
			if m == 1:
				get_parent().del_score("Blue")
				get_parent().del_score_visuel("Blue")
	if not get_parent().get_node("Scoreboard").Scoreboard_List.is_empty():
		var timesys = Time.get_datetime_dict_from_system()
		get_parent().get_node("Scoreboard").save_scoreboard(str(get_parent().get_node("Scoreboard").load_folder,"/",timesys["day"],".",timesys["month"],".",timesys["year"],",",timesys["hour"],"_",timesys["minute"],"_",timesys["second"],".save"))
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	get_parent().wechsel_sceene_wenn_server_disconected()
	
	
func exit(msg: String, show_msg: bool):
	if OS.has_feature("dedicated_server"):
		return
	if multiplayer and multiplayer.is_server():
		OS.alert("Server beendet!", "Server Meldung")
		server_exit()
	if multiplayer:
		for i in multiplayer.get_peers():
			get_parent().kicked(i, msg, show_msg)
		
		
func update_player_counter(connected: bool, vaild_whait: bool, vaild_count: bool, vaild_rady: bool):
	if vaild_whait:
		update_player_wait.rpc(connected)
	if vaild_count:
		update_player_count.rpc(connected)
	if vaild_rady:
		set_player_rady.rpc(connected)
	update_options.rpc()
	update_rady_status.rpc()
	if vs_mode:
		check_team()


@rpc("any_peer","call_local")
func set_wait_rady(id: int, mode: bool):
	if mode:
		rady_and_wait.append(id)
	else:
		rady_and_wait.erase(id)
	

@rpc("any_peer","call_local")
func set_wait(id: int, mode: bool):
	if mode:
		wait.append(id)
	else:
		wait.erase(id)
	
	
@rpc("any_peer","call_local")
func update_rady_status():
	if player_conect_count == player_ready and not vs_mode:
		$CenterContainer/HBoxContainer/VBoxContainer/Warten.text = str("Alle Spieler bereit!")
		if multiplayer.is_server():
			$CenterContainer/HBoxContainer/VBoxContainer/start.visible = true
			Global.trigger_host_focus = true
			$"CenterContainer/HBoxContainer/VBoxContainer/start".grab_focus()
			Global.trigger_host_focus = false
		if OS.has_feature("dedicated_server"):
			if player_conect_count < 1:
				server_exit()
				return
			vor_start_trigger()
	elif player_conect_count == player_ready and vs_mode and vaild_team:
		$CenterContainer/HBoxContainer/VBoxContainer/Warten.text = str("Alle Spieler bereit!")
		if multiplayer.is_server():
			$CenterContainer/HBoxContainer/VBoxContainer/start.visible = true
			Global.trigger_host_focus = true
			$"CenterContainer/HBoxContainer/VBoxContainer/start".grab_focus()
			Global.trigger_host_focus = false
		if OS.has_feature("dedicated_server"):
			if player_conect_count < 1:
				server_exit()
				return
			vor_start_trigger()
	if multiplayer.is_server() and player_wait_count <= 1 and player_conect_count == 1 and not get_parent().loaded_seson and len(get_parent().playerlist) <= 1:
		no_players()
	if not OS.has_feature("dedicated_server") and not multiplayer.is_server() and player_wait_count <= 1 and player_conect_count == 1 and not get_parent().loaded_seson and len(get_parent().playerlist) <= 1:
		$CenterContainer/HBoxContainer/VBoxContainer/start.text = "Beenden"
		$CenterContainer/HBoxContainer/VBoxContainer/start.visible = true


func start_ext_server():
	server_set_map()
	get_parent().map.reset_floor.rpc()
	reset_wait_count.rpc()
	
			
func reset_loby():
	if OS.has_feature("dedicated_server"):
		if multiplayer.get_peers().is_empty() and is_running:
			server_exit()


func check_teams():
	blue_team_cound = 0
	red_team_cound = 0
	vaild_team = false
	for team in get_parent().get_node("Players").get_children():
		if team.team == "Blue":
			blue_team_cound += 1
		elif team.team == "Red":
			red_team_cound += 1
	if player_conect_count > 1 and blue_team_cound > 0 and red_team_cound > 0:
		vaild_team = true
	elif get_parent().playerlist.size() == 1:
		if (blue_team_cound == 0 and red_team_cound > 0) or (red_team_cound == 0 and blue_team_cound > 0):
			vaild_team = true
	else:
		vaild_team = false
	
	
func _on_enter_pressed():
	Global.ui_sound = true
	if $CenterContainer/HBoxContainer/VBoxContainer/name_input.text.is_empty():
		OS.alert("Bitte Namen Eingeben!", "Server Meldung")
		return
	$CenterContainer/HBoxContainer/VBoxContainer/name_input.text = $CenterContainer/HBoxContainer/VBoxContainer/name_input.text.lstrip(" ")
	$CenterContainer/HBoxContainer/VBoxContainer/name_input.text = $CenterContainer/HBoxContainer/VBoxContainer/name_input.text.rstrip(" ")
	
	for i in get_parent().get_node("Players").get_children():
		if i.get_node("Name").text == $CenterContainer/HBoxContainer/VBoxContainer/name_input.text:
			OS.alert("Name Exsistiert Schon!", "Server Meldung")
			return
	if $CenterContainer/HBoxContainer/VBoxContainer/name_input.text != "":
		get_parent().is_server_run_game.rpc()
		get_parent().main.get_node("CanvasLayer2/Control/Server_Browser").queue_free()
		$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/npcs.disabled = true
		difficulty.disabled = true
		$CenterContainer/HBoxContainer/VBoxContainer/name_input.visible = false
		$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Enter.visible = false
		$CenterContainer/HBoxContainer/VBoxContainer/Random.visible = false
		$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/settime.visible = false
		$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map.visible = false
		$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer.visible = false
		Global.trigger_host_focus = true
		$CenterContainer/HBoxContainer/VBoxContainer/start.grab_focus()
		Global.trigger_host_focus = false
		get_parent().add_text_tap.rpc(multiplayer.get_unique_id(), $CenterContainer/HBoxContainer/VBoxContainer/name_input.text)
		namen_text_update.rpc(multiplayer.get_unique_id(), $CenterContainer/HBoxContainer/VBoxContainer/name_input.text)
		if vs_mode:
			$CenterContainer/HBoxContainer/team.visible = true
		if player_conect_count == 1 and get_parent().get_node("Players").has_node("1") and not get_parent().loaded_seson:
			get_parent().loaded_seson = true
			get_parent().spawn_npc()
		set_wait.rpc(multiplayer.get_unique_id(), true)
		update_player_counter(true, true, false, false)
		vor_start_trigger()
		if not solo_mode and player_conect_count == 1 and player_wait_count == 1:
			$CenterContainer/HBoxContainer/VBoxContainer/Warten.text = str(get_parent().playerlist.size()-1," Mitspieler!")
			$CenterContainer/HBoxContainer/VBoxContainer/start.text = "Beenden"
			$CenterContainer/HBoxContainer/VBoxContainer/start.visible = true
		if not server_first_start:
			set_server_first_start.rpc(true)
		if multiplayer.is_server():
			server_set_map()
			
		
func server_set_map():
	map_set.rpc(map_faktor)
	get_parent().map_enden = get_parent().get_node("floor").map_to_local(Global.Spielfeld_Size)
		
		
func _on_random_pressed():
	Global.ui_sound = true
	namen.shuffle()
	$CenterContainer/HBoxContainer/VBoxContainer/name_input.text = namen.pick_random()


func _on_npcs_pressed():
	Global.ui_sound = true
	Global.count_npcs += 1
	if Global.count_npcs > Global.npcs_anzahl:
		Global.count_npcs = 1
	$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/npcs.text = str("Solo NPCs: ",Global.count_npcs)



func _on_speed_pressed():
	Global.ui_sound = true
	if difficulty_id == 0:
		difficulty.text = "Einfach"
		Global.speed_npcs = Global.npc_einfach
		difficulty_id = 1
	elif difficulty_id == 1:
		difficulty.text = "Normal"
		Global.speed_npcs = Global.npc_normal
		difficulty_id = 2
	elif difficulty_id == 2:
		difficulty.text = "Schwer"
		Global.speed_npcs = Global.npc_schwer
		difficulty_id = 0


func _on_settime_pressed():
	Global.ui_sound = true
	count_settime += 1
	if count_settime == 1:
		$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/settime.text = str(180," sec.")
		get_parent().get_node("Timer").wait_time = 180
	if count_settime == 2:
		$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/settime.text = str(60," sec.")
		get_parent().get_node("Timer").wait_time = 60
	if count_settime == 3:
		$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/settime.text = str(120," sec.")
		get_parent().get_node("Timer").wait_time = 120
		count_settime = 0


func _on_random_mouse_entered():
	Global.ui_hover_sound = true


func _on_random_focus_entered():
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Global.ui_hover_sound = true


func _on_npcs_mouse_entered():
	Global.ui_hover_sound = true


func _on_npcs_focus_entered():
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Global.ui_hover_sound = true


func _on_speed_mouse_entered():
	Global.ui_hover_sound = true


func _on_speed_focus_entered():
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Global.ui_hover_sound = true


func _on_settime_mouse_entered():
	Global.ui_hover_sound = true
	
	
func _on_settime_focus_entered():
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Global.ui_hover_sound = true


func _on_enter_mouse_entered():
	Global.ui_hover_sound = true


func _on_enter_focus_entered():
	if not Global.trigger_host_focus:
		Global.ui_hover_sound = true


@rpc("any_peer","call_local")
func set_player_rady(rady: bool):
	if rady:
		player_ready += 1
		$CenterContainer/HBoxContainer/VBoxContainer/Warten.text = str(player_ready, " Spieler bereit!")
	elif player_ready > 0:
		player_ready -= 1
		$CenterContainer/HBoxContainer/VBoxContainer/Warten.text = str(player_ready, " Spieler bereit!")
		
		
@rpc("any_peer","call_local")
func set_server_first_start(mode: bool):
	server_first_start = mode
	
	
func _on_start_pressed():
	Global.ui_sound = true
	if vs_mode and player_wait_count > 1:
		check_teams()
		if not vaild_team:
			blue_team_cound = 0
			red_team_cound = 0
			vaild_team = false
			OS.alert("Nur ein Team erkannt!", "Server Meldung")
			return
	if $CenterContainer/HBoxContainer/VBoxContainer/start.text == "Beenden":
		server_exit()
		return
	if $CenterContainer/HBoxContainer/VBoxContainer/start.text != "Beenden":
		if server_first_start and not OS.has_feature("dedicated_server") and player_ready != get_parent().playerlist.size() and get_parent().playerlist.size() > 0:
			$CenterContainer/HBoxContainer/VBoxContainer/start.visible = false
			$CenterContainer/HBoxContainer/team.visible = false
			set_wait_rady.rpc(multiplayer.get_unique_id(), true)
			update_player_counter(true, false, false, true)
			update_rady_status.rpc()
			return
		if player_ready != get_parent().playerlist.size() and get_parent().playerlist.size() > 0:
			update_rady_status.rpc()
			return
	if $CenterContainer/HBoxContainer/VBoxContainer/start.text != "start":
		$CenterContainer/HBoxContainer/VBoxContainer/warte_map.visible = true
	update_rady_status.rpc()
	if vs_mode and player_wait_count > 1:
		check_teams()
		if not vaild_team:
			blue_team_cound = 0
			red_team_cound = 0
			vaild_team = false
			OS.alert("Nur ein Team erkannt!", "Server Meldung")
			return
	if not $CenterContainer/HBoxContainer/VBoxContainer/Warten.text.begins_with("Solo"):
		if player_conect_count <= 1 and not get_parent().get_node("Players").has_node("2") and not OS.has_feature("dedicated_server"):
			exit("Kein Mitspieler auf dem Server Gefunden!", true)
			return
		if player_conect_count <= 1 and OS.has_feature("dedicated_server"):
			exit("Kein Mitspieler auf dem Server Gefunden!", true)
			return
	get_parent().main.get_node("Grafik").zoom_option.visible = true
	get_parent().map.reset_floor.rpc()
	reset_wait_count.rpc()
	if $CenterContainer/HBoxContainer/team.visible:
		set_visiblity.rpc("loby/CenterContainer/HBoxContainer/team", false)
	$CenterContainer/HBoxContainer/VBoxContainer/start.visible = false
	
	
func vor_start_trigger():
	if player_conect_count == 1 and player_wait_count == 1 and not solo_mode:
		$CenterContainer/HBoxContainer/VBoxContainer/start.text = "Beenden"
		$CenterContainer/HBoxContainer/VBoxContainer/start.visible = true
	else:
		$CenterContainer/HBoxContainer/VBoxContainer/start.text = "Bereit"
		$CenterContainer/HBoxContainer/VBoxContainer/start.visible = true
		
	
	
func start_trigger():
	$CenterContainer/HBoxContainer/VBoxContainer/warte_map.visible = false
	get_parent().wertungs_anzeige_aktivieren()
	get_parent().get_node("CanvasLayer/start_in").visible = true
	

@rpc("any_peer","call_local")
func reset_wait_count():
	player_wait_count = 0
	player_ready = 0
	rady_and_wait = []
	wait = []
	get_parent().main.get_node("CanvasLayer2/Control/UI").game_started = true
	
	
@rpc("any_peer","call_local")
func set_visiblity(nodepath: String, mode: bool):
	var obj = get_parent().get_node(nodepath)
	if obj:
		if mode:
			obj.visible = mode
		else:	
			obj.visible = mode


func _on_start_mouse_entered() -> void:
	Global.ui_hover_sound = true


func _on_start_focus_entered() -> void:
	if not Global.trigger_host_focus:
		Global.ui_hover_sound = true


func _on_map_focus_entered():
	if not Global.trigger_host_focus:
		Global.ui_hover_sound = true


func _on_map_mouse_entered():
	Global.ui_hover_sound = true


func _on_map_pressed():
	Global.ui_sound = true
	count_map_size += 1
	if count_map_size == 1:
		$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map.text = str("Kleine  Map")
		map_faktor = 2
	if count_map_size == 2:
		$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map.text = str("Normale  Map")
		map_faktor = 3
	if count_map_size == 3:
		$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map.text = str("Große  Map")
		map_faktor = 4
		count_map_size = 0
		

@rpc("any_peer","call_local")
func map_set(factor):
	Global.Spielfeld_Size = Global.Standard_Spielfeld_Size*factor


func _on_team_toggled(toggled_on):
	if vs_mode:
		if not toggled_on:
			switch_team.rpc(multiplayer.get_unique_id(),toggled_on)
		elif toggled_on:
			switch_team.rpc(multiplayer.get_unique_id(),toggled_on)
		check_team()
		update_rady_status.rpc()
	
	
@rpc("any_peer","call_local")
func switch_team(id: int, switch_to_blue: bool):
	if not switch_to_blue:
		join_red(id)
		if id == multiplayer.get_unique_id():
			$CenterContainer/HBoxContainer/team.set("theme_override_colors/font_color", Color.RED)
			$CenterContainer/HBoxContainer/team.set("theme_override_colors/font_focus_color", Color.RED)
			$CenterContainer/HBoxContainer/team.set("theme_override_colors/font_hover_color", Color.RED)
			$CenterContainer/HBoxContainer/team.set("theme_override_colors/font_pressed_color", Color.RED)
			$CenterContainer/HBoxContainer/team.set("theme_override_colors/font_hover_pressed_color", Color.RED)
	elif switch_to_blue:
		join_blue(id)
		if id == multiplayer.get_unique_id():
			$CenterContainer/HBoxContainer/team.set("theme_override_colors/font_color", Color.DEEP_SKY_BLUE)
			$CenterContainer/HBoxContainer/team.set("theme_override_colors/font_focus_color", Color.DEEP_SKY_BLUE)
			$CenterContainer/HBoxContainer/team.set("theme_override_colors/font_hover_color", Color.DEEP_SKY_BLUE)
			$CenterContainer/HBoxContainer/team.set("theme_override_colors/font_pressed_color", Color.DEEP_SKY_BLUE)
			$CenterContainer/HBoxContainer/team.set("theme_override_colors/font_hover_pressed_color", Color.DEEP_SKY_BLUE)
		

func check_team():
	check_team_member.rpc()
	if get_parent().get_node("Players").has_node("2"):
		check_npc_team_member()
			
			
@rpc("any_peer","call_local")
func check_team_member():
	red_members = 0
	blue_members = 0
	for m in get_parent().get_node("Players").get_children():
		if m.get_node("Name").text.is_empty():
			continue
		if m.team == "Red":
			red_members += 1
		if m.team == "Blue":
			blue_members += 1
	$CenterContainer/HBoxContainer/team/red.text = str(red_members)
	$CenterContainer/HBoxContainer/team/blue.text = str(blue_members)


func check_npc_team_member():
	if Global.count_npcs == 1 and get_parent().get_node("Players/1").team == "Blue":
		switch_team(2,false)
	elif Global.count_npcs == 2 and get_parent().get_node("Players/1").team == "Blue":
		switch_team(2,false)
		switch_team(3,false)
	elif Global.count_npcs == 3 and get_parent().get_node("Players/1").team == "Blue":
		switch_team(2,false)
		switch_team(3,false)
		switch_team(4,true)
		
	elif Global.count_npcs == 1 and get_parent().get_node("Players/1").team == "Red":
		switch_team(2,true)
	elif Global.count_npcs == 2 and get_parent().get_node("Players/1").team == "Red":
		switch_team(2,true)
		switch_team(3,true)
	elif Global.count_npcs == 3 and get_parent().get_node("Players/1").team == "Red":
		switch_team(2,true)
		switch_team(3,true)
		switch_team(4,false)
	check_team_member()
			
	$CenterContainer/HBoxContainer/team/blue.text = str(blue_members)
	$CenterContainer/HBoxContainer/team/red.text = str(red_members)
		
	
func join_red(id):
	get_parent().get_node("Players").get_node(str(id)).team = "Red"
	get_parent().get_node("Players").get_node(str(id)).color_cell = 2
	get_parent().get_node("Players").get_node(str(id)).get_node("Color").color = Color.DARK_RED
	
	if get_parent().get_node("Tap/CenterContainer/PanelContainer/VBoxContainer").has_node(str(id)):
		change_names_colors_vs.rpc(id)
	
	get_parent().get_node("Players").get_node(str(id)).get_node("Name").set("theme_override_colors/font_color",Color.DARK_RED)
	if id != 2 and id != 3 and id != 4:
		get_parent().get_node("Players").get_node(str(id)).get_node("CanvasLayer/Winner").set_color(Color.DARK_RED)
		get_parent().get_node("Players").get_node(str(id)).get_node("CanvasLayer/Los").set_color(Color.DARK_RED)
		

func join_blue(id):
	get_parent().get_node("Players").get_node(str(id)).team = "Blue"
	get_parent().get_node("Players").get_node(str(id)).color_cell = 4
	get_parent().get_node("Players").get_node(str(id)).get_node("Color").color = Color.DEEP_SKY_BLUE
	
	if get_parent().get_node("Tap/CenterContainer/PanelContainer/VBoxContainer").has_node(str(id)):
		change_names_colors_vs.rpc(id)
		
	get_parent().get_node("Players").get_node(str(id)).get_node("Name").set("theme_override_colors/font_color",Color.DEEP_SKY_BLUE)
	if id != 2 and id != 3 and id != 4:
		get_parent().get_node("Players").get_node(str(id)).get_node("CanvasLayer/Winner").set_color(Color.DEEP_SKY_BLUE)
		get_parent().get_node("Players").get_node(str(id)).get_node("CanvasLayer/Los").set_color(Color.DEEP_SKY_BLUE)


@rpc("any_peer","call_local")
func change_names_colors_vs(id):
	get_parent().get_node("Tap/CenterContainer/PanelContainer/VBoxContainer").get_node(str(id)).set("theme_override_colors/font_color",get_parent().get_node("Players").get_node(str(id)).get_node("Color").color)
	get_parent().get_node("Werten/PanelContainer/Wertung/name").get_node(str(id)).set("theme_override_colors/font_color",get_parent().get_node("Players").get_node(str(id)).get_node("Color").color)


func _on_name_input_gui_input(event: InputEvent) -> void:
	if Global.menu or event.is_action_pressed("exit_con") or event.is_action_pressed("exit"):
		return
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		if event.is_pressed() and Input.get_connected_joypads().size() <= 0 or event.is_action("ui_accept") and Input.get_connected_joypads().size() > 0:
			edit_text_select()
	elif event.is_pressed() and Input.get_connected_joypads().size() <= 1 or event.is_action("ui_accept") and Input.get_connected_joypads().size() > 1:
		edit_text_select()
		
		
func edit_text_select():
	if $CenterContainer/HBoxContainer/VBoxContainer/name_input.has_focus():
		get_parent().main.get_node("CanvasLayer2/Control/UI").keyboard.selected_node = $CenterContainer/HBoxContainer/VBoxContainer/name_input
		get_parent().main.get_node("CanvasLayer2/Control/UI").keyboard.parent_fild_length = $CenterContainer/HBoxContainer/VBoxContainer/name_input.max_length
		get_parent().main.get_node("CanvasLayer2/Control/UI").popup_edit.text = $CenterContainer/HBoxContainer/VBoxContainer/name_input.text
		get_parent().main.get_node("CanvasLayer2/Control/UI").keyboard.last_focus_path = $CenterContainer/HBoxContainer/VBoxContainer/name_input.get_path()
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		get_parent().main.get_node("CanvasLayer2/Control/UI").keyboard.selected = true
