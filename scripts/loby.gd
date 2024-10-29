extends CanvasLayer

@export var player_conect_count = 0
@export var player_wait_count = 0
@export var is_running = false
@export var hidenloby = false
@onready var difficulty = $CenterContainer/VBoxContainer/VBoxContainer/Speed
var difficulty_id = 0
var count_settime = 0
var count_map_size = 1


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
	$CenterContainer/VBoxContainer/VBoxContainer/npcs.text = str("Solo NPCs: ",Global.count_npcs)
	$CenterContainer/VBoxContainer/Warten.connect("visibility_changed", _on_warten_visibility_changed.rpc)
	
	difficulty.text = "Einfach"
	difficulty_id = 1
	Global.speed_npcs = 5
	
	if multiplayer.is_server():
		$CenterContainer/VBoxContainer/settime.visible = true
		$CenterContainer/VBoxContainer/settime.connect("pressed",_on_settime_pressed)
		$CenterContainer/VBoxContainer/Map.visible = true
	
	
@rpc("any_peer","call_local")
func update_player_wait(positive: bool):
	if positive:
		player_wait_count += 1
	elif player_wait_count > 1:
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
	
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_RESUMED or what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		exit("Verbindung Selber beendet!", true)
		return
				
			

func server_exit():
	multiplayer.peer_connected.disconnect(get_parent().add_player)
	multiplayer.peer_disconnected.disconnect(get_parent().del_player)
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	get_parent().wechsel_sceene_wenn_server_disconected()
	
	
func exit(msg: String, show_msg: bool):
	if OS.has_feature("dedicated_server"):
		return
	update_player_count.rpc(false)
	if not $CenterContainer/VBoxContainer/Enter.visible:
		update_player_wait.rpc(false)
	update_warten.rpc()
	if multiplayer and multiplayer.is_server():
		OS.alert("Server beendet!", "Server Meldung")
		server_exit()
	if multiplayer:
		for i in multiplayer.get_peers():
			get_parent().kicked(i, msg, show_msg)
	
		

func reset_loby():
	if OS.has_feature("dedicated_server"):
		if multiplayer.get_peers().is_empty() and is_running:
			server_exit()

	
func _on_enter_pressed():
	Global.ui_sound = true
	var vaild_text = false
	for i in $CenterContainer/VBoxContainer/name_input.text:
		if i == " ":
			vaild_text = false
		else:
			vaild_text = true
	if not vaild_text:
		OS.alert("Bitte Namen Eingeben und \nlehrzeichen am ende vermeiden!", "Server Meldung")
		return
	for i in get_parent().get_node("Players").get_children():
		if i.get_node("Name").text == $CenterContainer/VBoxContainer/name_input.text:
			OS.alert("Name Exsistiert Schon!", "Server Meldung")
			return
		
	if $CenterContainer/VBoxContainer/name_input.text != "":
		get_parent().is_server_run_game.rpc()
		update_player_wait.rpc(true)
		$CenterContainer/VBoxContainer/VBoxContainer.visible = false
		$CenterContainer/VBoxContainer/name_input.visible = false
		$CenterContainer/VBoxContainer/Enter.visible = false
		$CenterContainer/VBoxContainer/Random.visible = false
		$CenterContainer/VBoxContainer/settime.visible = false
		$CenterContainer/VBoxContainer/Map.visible = false
		$CenterContainer/VBoxContainer/Warten.visible = true
		Global.trigger_host_focus = true
		$CenterContainer/VBoxContainer/start.grab_focus()
		Global.trigger_host_focus = false
		get_parent().add_text_tap.rpc(multiplayer.get_unique_id(), $CenterContainer/VBoxContainer/name_input.text)
		namen_text_update.rpc_id(multiplayer.get_unique_id(), multiplayer.get_unique_id(), $CenterContainer/VBoxContainer/name_input.text)
		if player_conect_count == 1 and get_parent().get_node("Players").has_node("1") and not get_parent().loaded_seson:
			get_parent().loaded_seson = true
			get_parent().spawn_npc()
		update_warten.rpc()
		if multiplayer.is_server() or OS.has_feature("dedicated_server"):
			set_visible_warte_map.rpc("CenterContainer/VBoxContainer/warte_map", true)
			await get_tree().create_timer(0.1).timeout
			map_set.rpc(Global.feld_size_mul)
			set_visible_warte_map.rpc("CenterContainer/VBoxContainer/warte_map", false)
		

@rpc("any_peer","call_local")
func update_warten():
	$CenterContainer/VBoxContainer/Warten.text = str(player_wait_count, " Player bereit!")
	if player_conect_count == player_wait_count and $CenterContainer/VBoxContainer/Warten.visible:
		$CenterContainer/VBoxContainer/Warten.text = str("Alle Player bereit!")
		$CenterContainer/VBoxContainer/start.visible = true
	if (player_wait_count == 1 and player_conect_count == 1) or get_parent().loaded_seson:
		get_parent().loaded_seson = false
		$CenterContainer/VBoxContainer/start.text = "Beenden"
		$CenterContainer/VBoxContainer/Warten.text = str("keiner auf dem server!")
		$CenterContainer/VBoxContainer/start.visible = true

func _on_random_pressed():
	Global.ui_sound = true
	namen.shuffle()
	$CenterContainer/VBoxContainer/name_input.text = namen.pick_random()


func _on_npcs_pressed():
	Global.ui_sound = true
	Global.count_npcs += 1
	if Global.count_npcs > Global.npcs_anzahl:
		Global.count_npcs = 1
	$CenterContainer/VBoxContainer/VBoxContainer/npcs.text = str("Solo NPCs: ",Global.count_npcs)


@rpc("any_peer","call_local")
func _on_warten_visibility_changed():
	$CenterContainer/VBoxContainer/Warten.visible = true


func _on_speed_pressed():
	Global.ui_sound = true
	if difficulty_id == 0:
		difficulty.text = "Einfach"
		Global.speed_npcs = 15
		difficulty_id = 1
	elif difficulty_id == 1:
		difficulty.text = "Normal"
		Global.speed_npcs = 20
		difficulty_id = 2
	elif difficulty_id == 2:
		difficulty.text = "Schwer"
		Global.speed_npcs = 30
		difficulty_id = 0


func _on_settime_pressed():
	Global.ui_sound = true
	count_settime += 1
	if count_settime == 1:
		$CenterContainer/VBoxContainer/settime.text = str(180," sec.")
		get_parent().get_node("Timer").wait_time = 180
	if count_settime == 2:
		$CenterContainer/VBoxContainer/settime.text = str(60," sec.")
		get_parent().get_node("Timer").wait_time = 60
	if count_settime == 3:
		$CenterContainer/VBoxContainer/settime.text = str(120," sec.")
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


func _on_start_pressed():
	Global.ui_sound = true
	if player_conect_count <= 1 and not get_parent().get_node("Players").has_node("2") and not OS.has_feature("dedicated_server"):
		exit("Kein Mitspieler auf dem Server Gefunden!", true)
		return
	if player_conect_count <= 1 and OS.has_feature("dedicated_server"):
		exit("Kein Mitspieler auf dem Server Gefunden!", true)
		return
	reset_player_wait.rpc()
	get_parent().reset_vars_level.rpc()
	get_parent().wertungs_anzeige_aktivieren.rpc()
	get_parent().game_restart_timer_start.rpc()
	get_parent().main.get_node("CanvasLayer/change").visible = true
	set_visiblity.rpc("CanvasLayer/start_in", true)
	get_parent().main.get_node("CanvasLayer2/UI").game_started = true
	set_visiblity.rpc(str(name), false)
	
	

@rpc("any_peer","call_local")
func reset_player_wait():
	player_wait_count = 0
	
	
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
		$CenterContainer/VBoxContainer/Map.text = str("Kleine  Map")
		Global.feld_size_mul = 2
	if count_map_size == 2:
		$CenterContainer/VBoxContainer/Map.text = str("Normale  Map")
		Global.feld_size_mul = 3
	if count_map_size == 3:
		$CenterContainer/VBoxContainer/Map.text = str("Große  Map")
		Global.feld_size_mul = 5
		count_map_size = 0



@rpc("any_peer","call_local")
func set_visible_warte_map(nodepath: String, mode: bool):
	var obj = get_node(nodepath)
	if obj:
		if mode:
			obj.visible = mode
		else:	
			obj.visible = mode
			

@rpc("any_peer","call_local")
func map_set(faktor):
	Global.Spielfeld_Size = Global.Standard_Spielfeld_Size*faktor
	if multiplayer.is_server() or OS.has_feature("dedicated_server"):
		get_parent().map.reset_floor.rpc()
