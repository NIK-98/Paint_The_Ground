extends Node2D


const bomb_spawn_grenzen = 250
const spawn_distance_bombe = 250
const spawn_distance_power_up = 500
const spawn_distance_coins = 300
var standart_powerup_spawn_time = 10
var standart_bomben_spawn_time = 5
var standart_coin_spawn_time = 5
var powerup_auswahl = [0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,2]

@onready var werte: VBoxContainer = $Werten/PanelContainer/Wertung/werte
@onready var namenlist: VBoxContainer = $Werten/PanelContainer/Wertung/name
@onready var powerlist: VBoxContainer = $Werten/PanelContainer/Wertung/powerlist
@onready var visual: HBoxContainer = $Werten/PanelContainer2/visual
@onready var main = get_parent().get_parent()
var player_sceen: PackedScene = preload("res://sceens/player.tscn")
var score_label: PackedScene = preload("res://sceens/score_label.tscn")
var powericons: PackedScene = preload("res://sceens/powerupicon.tscn")
var score_visual: PackedScene = preload("res://sceens/wertung_visuel.tscn")
var name_label: PackedScene = preload("res://sceens/Name.tscn")
var powerup: PackedScene = preload("res://sceens/powerup.tscn")
var coin: PackedScene = preload("res://sceens/coin.tscn")
@onready var coins = $Coins
@onready var map = get_node("floor")
@onready var wall = get_node("wall")
@onready var bombe = preload("res://sceens/bombe.tscn")
@onready var freez_ball = preload("res://sceens/freez_ball.tscn")
@onready var npc = preload("res://sceens/npc.tscn")
@onready var power_up = $PowerUP
@onready var Bomben = get_node("Bomben")
@onready var freez_balls = get_node("FreezBalls")
@export var map_enden = Vector2.ZERO
var Max_clients = 4
var loaded_seson = false
var loaded = false
@export var block_cells = []
@export var score = {1:0,2:0,3:0,4:0}
var last_runde = false
var start_gedrückt = 0
@export var bomb_dict = {}


@export var time = 0
@export var bomb_time = 0
@export var start_time = 0

@export var playerlist = []
@export var playernamelist = []
var list_player_id_and_pos = []

func _ready():
	$loby/CenterContainer/HBoxContainer/VBoxContainer/name_input.visible = true
	$loby/CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Enter.visible = true
	$loby/CenterContainer/HBoxContainer/VBoxContainer/Random.visible = true
	$Werten.visible = false
	$CanvasLayer/Time.visible = false
	$CanvasLayer/Bomb_time.visible = false
	$Tap.visible = false
	$loby.visible = true
	main.get_node("CanvasLayer/Back").visible = false
	if not multiplayer.is_server():
		multiplayer.server_disconnected.connect(verbindung_verloren)
		$Timer.queue_free()
		$Timerende.queue_free()
		$Timerbomb.queue_free()
		$Timerrestart.queue_free()
		$Timerpower.queue_free()
		$TimerCoin.queue_free()
		return
		
	$Timerpower.wait_time = standart_powerup_spawn_time
	$Timerbomb.wait_time = standart_bomben_spawn_time
	$TimerCoin.wait_time = standart_coin_spawn_time
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)	
		
	for id in multiplayer.get_peers():
		add_player(id)


	if OS.has_feature("dedicated_server"):
		Max_clients = 5
	if not OS.has_feature("dedicated_server"):
		add_player(1)
		
		
	if $loby.vs_mode:
		for m in range(2):
			if m == 0:
				add_score("Red", false, Color.DARK_RED)
				add_score_visual("Red", false, Color.DARK_RED)
			if m == 1:
				add_score("Blue", false, Color.DEEP_SKY_BLUE)
				add_score_visual("Blue", false, Color.DEEP_SKY_BLUE)
				
	
	var args = OS.get_cmdline_args()
	if OS.has_feature("dedicated_server") and args.has("-t"):
		var argument_wert = args[args.find("-t") + 1] # Wert des spezifischen Arguments
		if argument_wert == "180" or argument_wert == "120" or argument_wert == "60":
			$loby/CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/settime.text = str(argument_wert.to_int()," sec.")
			$Timer.wait_time = argument_wert.to_int()
		else:
			$loby/CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/settime.text = str(120," sec.")
			$Timer.wait_time = 120
	if OS.has_feature("dedicated_server") and args.has("-map"):
		var argument_wert = args[args.find("-map") + 1] # Wert des spezifischen Arguments
		if argument_wert == "2":
			$loby/CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map.text = str("Kleine Map")
			$loby.map_faktor = argument_wert.to_int()
		elif argument_wert == "3":
			$loby/CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map.text = str("Normale Map")
			$loby.map_faktor = argument_wert.to_int()
		elif argument_wert == "5":
			$loby/CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map.text = str("Große Map")
			$loby.map_faktor = argument_wert.to_int()
		else:
			$loby/CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map.text = str("Kleine Map")
			$loby.map_faktor = 2
				
	
func set_vs_mode(mode):
	$loby.vs_mode = mode
	

func set_tp_mode(mode):
	$loby.tp_mode = mode


func set_eis_mode(mode):
	$loby.eis_mode = mode
	

func set_solo_mode(mode):
	$loby.solo_mode = mode
	
	
func set_coin_mode(mode):	
	$loby.coin_mode = mode
	

func set_shop_mode(mode):	
	$loby.shop_mode = mode


func set_load_mode(mode):	
	$loby.load_mode = mode
	
	
func score_update(id: int = 0, cell: int = 0):
	for p in $Players.get_children():
		if werte.get_child_count() > 0 and not get_node("loby").vs_mode and werte.has_node(str(p.name)):
			werte.get_node(str(p.name)).wertung(p.name.to_int(), score[p.color_cell])
		elif werte.get_child_count() > 0 and get_node("loby").vs_mode and werte.has_node(str(p.team)):
			werte.get_node(str(p.team)).wertung(p.name.to_int(), score[p.color_cell])
			
		if visual.get_child_count() > 0 and not get_node("loby").vs_mode and visual.has_node(str(p.name)):
			visual.get_node(str(p.name)).update_var(p.name.to_int(), score[p.color_cell])
		elif visual.get_child_count() > 0 and get_node("loby").vs_mode and visual.has_node(str(p.team)):
			visual.get_node(str(p.team)).update_var(p.name.to_int(), score[p.color_cell])
					
	
func update_player_list(id: int, join: bool):
	if join:
		player_list_update.rpc(id,join)
		$loby.update_player_counter(true, false, true, false)
		print(str("Peer: ",id," Connected!"))
	else:
		player_list_update.rpc(id,join)
		$loby.update_player_counter(false, id in $loby.wait, true, id in $loby.rady_and_wait)
		if $loby.rady_and_wait.size() < 1 and not $loby.solo_mode:
			update_anwesend.rpc()
		print(str("Peer: ",id," Disconnected!"))
			

@rpc("any_peer","call_local")
func player_list_update(id: int, join: bool):
	if join:
		playerlist.append(id)
	else:
		playerlist.erase(id)


@rpc("any_peer","call_local")
func player_name_list_update(namen: String, join: bool):
	if join:
		playernamelist.append(namen)
	else:
		playernamelist.erase(namen)
		

func update_player_name_list(namen: String, join: bool):
	if join:
		player_name_list_update.rpc(namen,join)
	else:
		player_name_list_update.rpc(namen,join)
		

@rpc("any_peer","call_local")
func set_npc_settings():
	if multiplayer.get_peers().is_empty() and not OS.has_feature("dedicated_server") and $loby.solo_mode:
		$loby/CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/npcs.disabled = false
		$loby/CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/Speed.disabled = false
		if multiplayer.is_server() or OS.has_feature("dedicated_server"):
			$loby/CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/npcs.text = str("Solo NPCs: ",Global.count_npcs)
			$loby._on_speed_pressed()
		$loby/CenterContainer/HBoxContainer/VBoxContainer/Warten.text = "Solo Modus!"
		if $loby.vs_mode:
			$loby/CenterContainer/HBoxContainer/VBoxContainer/Warten.text = "Solo VS-Mode!"
		if $loby.tp_mode:
			$loby/CenterContainer/HBoxContainer/VBoxContainer/Warten.text = "Solo TP-Mode!"
		if $loby.vs_mode and $loby.tp_mode:
			$loby/CenterContainer/HBoxContainer/VBoxContainer/Warten.text = "Solo TP/VS-Mode!"
		if $loby.eis_mode:
			$loby/CenterContainer/HBoxContainer/VBoxContainer/Warten.text = "Solo Eis-Mode!"
		if $loby.tp_mode and $loby.eis_mode:
			$loby/CenterContainer/HBoxContainer/VBoxContainer/Warten.text = "Solo Eis/TP-Mode!"
		if $loby.vs_mode and $loby.eis_mode:
			$loby/CenterContainer/HBoxContainer/VBoxContainer/Warten.text = "Solo Eis/VS-Mode!"
		if $loby.vs_mode and $loby.eis_mode and $loby.tp_mode:
			$loby/CenterContainer/HBoxContainer/VBoxContainer/Warten.text = "Solo Eis/TP/VS-Mode!"
	else:
		$loby/CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/npcs.disabled = true
		$loby/CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/Speed.disabled = true
		if not multiplayer.is_server() and not OS.has_feature("dedicated_server"):
			$loby/CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/npcs.visible = false
			$loby/CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/Speed.visible = false
			$loby/CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/settime.disabled = true
			$loby/CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Map.disabled = true
	update_anwesend()


@rpc("any_peer","call_local")
func update_anwesend():
	if $loby.wait.size() <= 1 and $loby.solo_mode:
		return
	$loby/CenterContainer/HBoxContainer/VBoxContainer/Warten.text = str(playerlist.size()-1," Mitspieler!")
	if $loby.vs_mode:
		$loby/CenterContainer/HBoxContainer/VBoxContainer/Warten.text = str(playerlist.size()-1," VS-Mode Mitspieler!")
	if $loby.tp_mode:
		$loby/CenterContainer/HBoxContainer/VBoxContainer/Warten.text = str(playerlist.size()-1," TP-Mode Mitspieler!")
	if $loby.vs_mode and $loby.tp_mode:
		$loby/CenterContainer/HBoxContainer/VBoxContainer/Warten.text = str(playerlist.size()-1," TP/VS-Mode Mitspieler!")
	if $loby.eis_mode:
		$loby/CenterContainer/HBoxContainer/VBoxContainer/Warten.text = str(playerlist.size()-1," Eis-Mode Mitspieler!")
	if $loby.tp_mode and $loby.eis_mode:
		$loby/CenterContainer/HBoxContainer/VBoxContainer/Warten.text = str(playerlist.size()-1," Eis/TP-Mode Mitspieler!")
	if $loby.vs_mode and $loby.eis_mode:
		$loby/CenterContainer/HBoxContainer/VBoxContainer/Warten.text = str(playerlist.size()-1," Eis/VS-Mode Mitspieler!")
	if $loby.vs_mode and $loby.eis_mode and $loby.tp_mode:
		$loby/CenterContainer/HBoxContainer/VBoxContainer/Warten.text = str(playerlist.size()-1," Eis/TP/VS-Mode Mitspieler!")
		

@rpc("any_peer","call_local")
func is_server_run_game():
	Max_clients = 0
	main.get_node("CanvasLayer2/Control/UI").game_started = false
	main.get_node("CanvasLayer2/Control/UI").set_process(false)
	
	
func _process(_delta):
	if not multiplayer.is_server() and not OS.has_feature("dedicated_server"):
		set_process(false)
		return
	if not loaded and not get_tree().paused and (multiplayer.is_server() or OS.has_feature("dedicated_server")):
		loaded = true
		$Timer.connect("timeout", _on_timer_timeout)
		$Timerende.connect("timeout", _on_timerende_timeout)
		$Timerbomb.connect("timeout", _on_timerbomb_timeout)
		$Timerpower.connect("timeout", _on_timerpower_timeout)
		$TimerCoin.connect("timeout", _on_timercoin_timeout)
		$Timerrestart.connect("timeout", _on_timerrestart_timeout)
	
	score_update()
	if $loby.server_first_start and playerlist.size() == $loby.player_ready and playerlist.size() > 0:
		$loby.set_server_first_start.rpc(false)
		if OS.has_feature("dedicated_server"):
			$loby.start_ext_server()
		else:
			if not $loby.solo_mode and $loby.player_conect_count > 1 and $loby.player_wait_count > 1:
				$loby/CenterContainer/HBoxContainer/VBoxContainer/start.text = "start"
				$loby/CenterContainer/HBoxContainer/VBoxContainer/start.visible = true
			if not $loby.solo_mode and $loby.player_conect_count <= 1 and $loby.player_wait_count <= 1:
				$loby/CenterContainer/HBoxContainer/VBoxContainer/start.text = "Beenden"
				$loby/CenterContainer/HBoxContainer/VBoxContainer/start.visible = true
			if $loby.solo_mode:
				$loby/CenterContainer/HBoxContainer/VBoxContainer/start.text = "start"
				$loby/CenterContainer/HBoxContainer/VBoxContainer/start.visible = true
	$loby.reset_loby()
			
			
func _physics_process(_delta):
	game_update()
		
	
func game_update():
	if multiplayer.is_server() or OS.has_feature("dedicated_server"):
		time = int($Timer.time_left)
		bomb_time = int($Timerbomb.time_left)
		start_time = int($Timerrestart.time_left)
		if not $Timer.is_stopped() and time <= 20 and not last_runde:
			last_runde = true
			$Timerbomb.wait_time = 3
			$Timerpower.wait_time = 4
			$TimerCoin.wait_time = 2
			update_lastrund.rpc()
		update_timer_texte.rpc(time, bomb_time, start_time)
		sort_score_list.rpc()
		
		
@rpc("any_peer","call_local")
func update_timer_texte(t, t_bomb, t_start):
	$CanvasLayer/Time.text = str(round(t))
	$CanvasLayer/Bomb_time.text = str(round(t_bomb), " sec. bis zur nächsten Bomben verteilung!")
	$CanvasLayer/start_in.text = str("Start in ", round(t_start), " Sec.")

			
@rpc("any_peer","call_local")
func update_lastrund():
	$Werten/CenterContainer/Letzen_sec.visible = true
	$CanvasLayer/Time.set("theme_override_colors/font_color",Color.CRIMSON)
	$CanvasLayer/Bomb_time.set("theme_override_colors/font_color",Color.CRIMSON)
	await get_tree().create_timer(2).timeout
	$Werten/CenterContainer/Letzen_sec.visible = false
	

@rpc("any_peer","call_local")
func sort_score_list():
	if $CanvasLayer/Time.visible:
		var new_order = []
		for i in werte.get_children():
			new_order.append([i.name,i.text.to_int()])
		new_order.sort_custom(sort_ascending_score_list)
		var lists = [werte, powerlist, namenlist, visual]
		for list in lists:
			for l in list.get_children():
				for o in new_order:
					if o.has(l.name):
						list.move_child(l,new_order.find(o))
					

func sort_ascending_score_list(a, b):
	if a[1] > b[1]:
		return true
	return false


func verbindung_verloren():
	if multiplayer:
		multiplayer.server_disconnected.disconnect(verbindung_verloren)
		OS.alert("Multiplayer Server wurde beendet.", "Server Meldung")
		wechsel_sceene_wenn_server_disconected()
		return
	

func wechsel_sceene_wenn_server_disconected():
	get_tree().change_scene_to_file("res://sceens/main.tscn")
		
		
@rpc("call_local")
func voll(msg: String):
	OS.alert(msg, "Server Meldung")
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file("res://sceens/main.tscn")
	

func add_player(id: int):
	if $loby.solo_mode:
		voll.rpc_id(id, "Zutritt verweigert!")
		return
	if len(multiplayer.get_peers()) >= Max_clients:
		voll.rpc_id(id, "Server Voll!")
		return
	$loby.is_running = true
	update_player_list(id, true)
	var player = player_sceen.instantiate()
	player.name = str(id)
	get_node("Players").add_child(player, true)
	if not $loby.vs_mode:
		add_score(id, false)
		add_score_visual(id, false)
	else:
		$loby.switch_team.rpc(id,false)
		$loby.check_team()
	add_power_icons(id, false)
	set_npc_settings.rpc()
	
	if $loby.coin_mode and not $loby.shop_mode:
		remove_exiting_coins.rpc_id(id)
	
	elif $loby.shop_mode and not $loby.coin_mode:
		reset_shop.rpc_id(id)
		
	elif $loby.coin_mode and $loby.shop_mode:
		reset_shop_and_coins.rpc_id(id)
	
	
@rpc("call_local")
func remove_exiting_coins():
	Global.akzept = "!!Coins Löschen!!"
	main.get_node("CanvasLayer/akzeptieren").visible = true
	main.get_node("CanvasLayer/akzeptieren/PanelContainer/VBoxContainer/CenterContainer/HBoxContainer/Ja").grab_focus()
	

@rpc("call_local")
func reset_shop():
	Global.akzept = "!!Shop Zurücksetzen!!"
	main.get_node("CanvasLayer/akzeptieren").visible = true
	main.get_node("CanvasLayer/akzeptieren/PanelContainer/VBoxContainer/CenterContainer/HBoxContainer/Ja").grab_focus()
	
	
@rpc("call_local")
func reset_shop_and_coins():
	Global.akzept = "!!Shop und Coins Zurücksetzen!!"
	main.get_node("CanvasLayer/akzeptieren").visible = true
	main.get_node("CanvasLayer/akzeptieren/PanelContainer/VBoxContainer/CenterContainer/HBoxContainer/Ja").grab_focus()
	
	
@rpc("any_peer","call_local")
func add_text_tap(id: int, text: String):
	if is_multiplayer_authority():
		var new_name = name_label.instantiate()
		new_name.name = str(id)
		new_name.text = text
		new_name.namen = text
		new_name.set("theme_override_colors/font_color",$Players.get_node(str(id)).get_node("Color").color)
		list_player_id_and_pos.append([id, playerlist.find(id)])
		var child = new_name.duplicate()
		child.set("theme_override_font_size", 5)
		get_node("Tap/CenterContainer/PanelContainer/VBoxContainer").add_child(new_name, true)
		get_node("Werten/PanelContainer/Wertung/name").add_child(child, true)
		if list_player_id_and_pos.size() == playerlist.size():
			for p in list_player_id_and_pos:
				name_list_order.rpc(p[0],p[1])


@rpc("any_peer","call_local")
func name_list_order(id: int, pos: int):
	get_node("Tap/CenterContainer/PanelContainer/VBoxContainer").move_child(get_node("Tap/CenterContainer/PanelContainer/VBoxContainer").get_node(str(id)), pos+1)
	get_node("Werten/PanelContainer/Wertung/name").move_child(get_node("Werten/PanelContainer/Wertung/name").get_node(str(id)), pos)
		
			
func del_text_tap(id: int):
	if not get_node("Tap/CenterContainer/PanelContainer/VBoxContainer").has_node(str(id)):
		return
	get_node("Tap/CenterContainer/PanelContainer/VBoxContainer").get_node(str(id)).queue_free()
	if not get_node("Werten/PanelContainer/Wertung/name").has_node(str(id)):
		return
	get_node("Werten/PanelContainer/Wertung/name").get_node(str(id)).queue_free()
					

func reset_bomben():
	for c in range(Bomben.get_child_count()):
		if Bomben.get_child(c).is_in_group("boom"):
			Bomben.get_child(c).queue_free()
			

func reset_freez_ball():
	for c in range(freez_balls.get_child_count()):
		if freez_balls.get_child(c).is_in_group("freez"):
			freez_balls.get_child(c).queue_free()
	
	
func spawn_new_bombe():
	for i in range(Global.Spawn_bomben_limit):
		var pos = map.map_to_local(map.dict_floor_with_portal_id[randi_range(1,4)].keys().pick_random())
		for child in Bomben.get_children():
			if child.position.distance_to(pos) < spawn_distance_bombe and child.position.distance_to(pos) < spawn_distance_power_up and child.position.distance_to(pos) < spawn_distance_coins:
				return
			if wall.get_cell_source_id(wall.local_to_map(pos)) == 0:
				return
		var new_bombe = bombe.instantiate()
		new_bombe.name = "bombe"
		new_bombe.position = pos
		Bomben.add_child(new_bombe, true)
		

func spawn_new_freez_ball(count: int = 1):
	for i in range(count):
		var pos = map.map_to_local(map.dict_floor_with_portal_id[randi_range(1,4)].keys().pick_random())
		var new_freez_ball = freez_ball.instantiate()
		new_freez_ball.name = "freez_ball"
		new_freez_ball.position = pos
		freez_balls.add_child(new_freez_ball, true)
		

func reset_powerup():
	for c in range(power_up.get_child_count()):
		if power_up.get_child(c).is_in_group("power"):
			power_up.get_child(c).queue_free()


func spawn_new_powerup():
	for i in range(Global.Spawn_powerup_limit):
		var pos = map.map_to_local(map.dict_floor_with_portal_id[randi_range(1,4)].keys().pick_random())
		var new_auswahl = powerup_auswahl.pick_random()
		for child in power_up.get_children():
			if child.position.distance_to(pos) < spawn_distance_bombe and child.position.distance_to(pos) < spawn_distance_power_up and child.position.distance_to(pos) < spawn_distance_coins:
				return
			if wall.get_cell_source_id(wall.local_to_map(pos)) == 0:
				return
		var new_power_up = powerup.instantiate()
		new_power_up.name = "powerup"
		new_power_up.position = pos
		new_power_up.powerupid = new_auswahl
		power_up.add_child(new_power_up, true)
		
		
func reset_coins():
	for c in range(coins.get_child_count()):
		if coins.get_child(c).is_in_group("coin"):
			coins.get_child(c).queue_free()


func spawn_new_coins():
	for i in range(Global.Spawn_coins_limit):
		var pos = map.map_to_local(map.dict_floor_with_portal_id[randi_range(1,4)].keys().pick_random())
		for child in coins.get_children():
			if child.position.distance_to(pos) < spawn_distance_bombe and child.position.distance_to(pos) < spawn_distance_power_up and child.position.distance_to(pos) < spawn_distance_coins:
				return
			if wall.get_cell_source_id(wall.local_to_map(pos)) == 0:
				return
		var new_coin = coin.instantiate()
		new_coin.name = "coin"
		new_coin.position = pos
		coins.add_child(new_coin, true)
		
		
func spawn_npc():
	if $Players.has_node("1"):
		for i in range(Global.count_npcs):
			var new_npc = npc.instantiate()
			new_npc.name = str(multiplayer.get_unique_id())
			get_node("Players").add_child(new_npc, true)
			if not $loby.vs_mode:
				add_score(new_npc.name, true)
				add_score_visual(new_npc.name, true)
			else:
				$loby.join_blue(new_npc.name.to_int())
			add_power_icons(new_npc.name, true)
			add_text_tap(new_npc.name.to_int(), str("NPC",i+1))
			update_player_name_list(str("NPC",i+1),true)
		Global.ui_sound = true
		if $loby.vs_mode:
			$loby.check_team()
		

func del_npc(id):
	if $Players.has_node("1"):
		if not get_node("Players").has_node(str(id)):
			return
		get_node("Players").get_node(str(id)).queue_free()
	
	
func add_score(id, np: bool, color_vs = null):
	var new_score_label = score_label.instantiate()
	if not $loby.vs_mode:
		new_score_label.set("theme_override_colors/font_color",get_node("Players").get_node(str(id)).get_node("Color").color)
	else:
		new_score_label.set("theme_override_colors/font_color",color_vs)
	new_score_label.name = str(id)
	get_node("Werten/PanelContainer/Wertung/werte").add_child(new_score_label, true)
	if np:
		new_score_label.is_npc = np
		

func add_power_icons(id, np: bool):
	var new_powericons = powericons.instantiate()
	new_powericons.name = str(id)
	get_node("Werten/PanelContainer/Wertung/powerlist").add_child(new_powericons, true)
	if np:
		new_powericons.is_npc = np
		

func add_score_visual(id, np: bool, color_vs = null):
	var new_score_visual = score_visual.instantiate()
	if not $loby.vs_mode:
		new_score_visual.color = get_node("Players").get_node(str(id)).get_node("Color").color
	else:
		new_score_visual.color = color_vs
	new_score_visual.name = str(id)
	get_node("Werten/PanelContainer2/visual").add_child(new_score_visual, true)
	if np:
		new_score_visual.is_npc = np
		
	
func del_score(id):
	if not get_node("Werten/PanelContainer/Wertung/werte").has_node(str(id)):
		return
	get_node("Werten/PanelContainer/Wertung/werte").get_node(str(id)).queue_free()
	
	

func del_power_icons(id):
	if not get_node("Werten/PanelContainer/Wertung/powerlist").has_node(str(id)):
		return
	get_node("Werten/PanelContainer/Wertung/powerlist").get_node(str(id)).queue_free()
	
	
func del_score_visuel(id):
	if not get_node("Werten/PanelContainer2/visual").has_node(str(id)):
		return
	get_node("Werten/PanelContainer2/visual").get_node(str(id)).queue_free()


func _input(event):
	if Input.is_action_pressed("Info") or Input.is_action_pressed("Info_con"):
		$Tap.visible = true
	if Input.is_action_just_released("Info") or Input.is_action_just_released("Info_con"):
		$Tap.visible = false


func kicked(id, antwort, show_msg: bool):
	if multiplayer and show_msg:
		OS.alert(antwort, "Server Meldung")
		multiplayer.server_disconnected.disconnect(verbindung_verloren)
	if multiplayer and id in multiplayer.get_peers():
		multiplayer.multiplayer_peer.disconnect_peer(id)
		wechsel_sceene_wenn_server_disconected()
	
	
func del_player(id: int):
	if not get_node("Players").has_node(str(id)):
		return
	update_player_list(id, false)
	update_player_name_list(get_node("Players").get_node(str(id)).get_node("Name").text,false)
	get_node("Players").get_node(str(id)).queue_free()
	del_text_tap(id)
	if not $loby.vs_mode:
		del_score(id)
		del_score_visuel(id)
	del_power_icons(id)
	del_npc(id)
	

@rpc("any_peer","call_local")
func cell_blocker(block: bool, cell: int):
	if block:
		block_cells.append(cell)
	else:
		block_cells.erase(cell)
		
		
func _on_timer_timeout():
	$Timer.stop()
	$Timerbomb.stop()
	$Timerpower.stop()
	$TimerCoin.stop()
	$Timerende.start()
	reset_vars_level.rpc_id(1)


@rpc("any_peer","call_local")
func reset_vars_level():
	if multiplayer.is_server() or OS.has_feature("dedicated_server"):
		reset_powerup()
		reset_bomben()
		reset_coins()
		reset_freez_ball()
	
	
	
@rpc("any_peer","call_local")
func wertungs_anzeige_aktivieren():
	$Werten.visible = true
	

@rpc("any_peer","call_local")
func stoped_game():
	$Werten.visible = false
	$CanvasLayer/Time.visible = false
	$CanvasLayer/Bomb_time.visible = false
	$Tap.visible = false
	$CanvasLayer/Time.set("theme_override_colors/font_color",Color.BLACK)
	$CanvasLayer/Bomb_time.set("theme_override_colors/font_color",Color.BLACK)
	last_runde = false
	if multiplayer.is_server() or OS.has_feature("dedicated_server"):
		$Timerbomb.wait_time = standart_bomben_spawn_time
		$Timerpower.wait_time = standart_powerup_spawn_time
		$TimerCoin.wait_time = standart_coin_spawn_time
	

func _on_timerbomb_timeout():
	spawn_new_bombe()
		

func _on_timerpower_timeout():
	spawn_new_powerup()
	
	
func _on_timercoin_timeout():
	spawn_new_coins()
	
	
func _on_timerende_timeout():
	$Timerende.stop()
	stoped_game.rpc()
	get_node("Scoreboard").update_scoreboard()
	$Scoreboard.set_visiblety.rpc("CanvasLayer", true)
	if not main.get_node("CanvasLayer/Menu").visible:
		Global.trigger_host_focus = true
		$Scoreboard/CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/restart.grab_focus()
		Global.trigger_host_focus = false
	

@rpc("any_peer","call_local")
func start_button_gedrückt():
	start_game.rpc_id(1)


@rpc("any_peer","call_local")
func start_game():
	start_gedrückt += 1
	if start_gedrückt == len(playerlist):
		$loby.visible = false
		$Timerrestart.start()
		$CanvasLayer/start_in.visible = false
		$loby.start_trigger()
		start_gedrückt = 0
		

@rpc("any_peer","call_local")
func set_visiblety(nodepath: String, mode: bool):
	var obj = get_node(nodepath)
	if obj:
		if mode:
			obj.visible = mode
		else:	
			obj.visible = mode
		

func setup_freez_ball(map_faktor: int):	
	if $loby.tp_mode:
		if map_faktor == 2:
			spawn_new_freez_ball(4)
		if map_faktor == 3:
			spawn_new_freez_ball(5)
		if map_faktor == 4:
			spawn_new_freez_ball(6)
	else:
		if map_faktor == 2:
			spawn_new_freez_ball(2)
		if map_faktor == 3:
			spawn_new_freez_ball(3)
		if map_faktor == 4:
			spawn_new_freez_ball(4)
		
		
func _on_timerrestart_timeout():
	if $loby.eis_mode:
		setup_freez_ball($loby.map_faktor)
	$Timerrestart.stop()
	$Timer.start()
	$Timerbomb.start()
	$Timerpower.start()
	$TimerCoin.start()
	$CanvasLayer/Time.visible = true
	$CanvasLayer/Bomb_time.visible = true
	$CanvasLayer/start_in.visible = false
	game_update()
