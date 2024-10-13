extends Node2D


const bomb_spawn_grenzen = 250
const spawn_distance_bombe = 250
const spawn_distance_power_up = 500
var power_up_spawn_time = Global.standart_powerup_spawn_time
var powerup_auswahl = [0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,2]


@onready var main = get_parent().get_parent()
@export var player_sceen: PackedScene
@export var score_label: PackedScene
@export var powericons: PackedScene
@export var score_visual: PackedScene
@export var name_label: PackedScene
@export var powerup: PackedScene
@onready var map = get_node("floor")
@onready var bombe = preload("res://sceens/bombe.tscn")
@onready var npc = preload("res://sceens/npc.tscn")
@onready var power_up = $PowerUP
@onready var Bomben = get_node("Bomben")
@export var Time_out = false
@export var starting = false
var Max_clients = 6
var loaded_seson = false
var loaded = false
var blocked = false
var block_cells = []
var last_runde = false


@export var playerlist = []

func _ready():
	if OS.get_name() == "Windows" or OS.get_name() == "linux":
		$CanvasLayer/Labelzoom.visible = false
	$loby/CenterContainer/VBoxContainer/name_input.visible = true
	$loby/CenterContainer/VBoxContainer/Enter.visible = true
	$loby/CenterContainer/VBoxContainer/Random.visible = true
	$loby/CenterContainer/VBoxContainer/Warten.visible = false
	$Werten.visible = false
	$CanvasLayer/Time.visible = false
	$CanvasLayer/Bomb_time.visible = false
	$Tap.visible = false
	$Timerpower.wait_time = power_up_spawn_time
	$Timerbomb.wait_time = Global.standart_bomben_spawn_time
	main.get_node("CanvasLayer/Back").visible = false
	
	if not multiplayer.is_server():
		multiplayer.server_disconnected.connect(verbindung_verloren)
		return
		
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)
		
		
	for id in multiplayer.get_peers():
		get_parent().get_parent().get_node("Level/level").add_player(id)


	if not OS.has_feature("dedicated_server"):
		get_parent().get_parent().get_node("Level/level").add_player(1)
	
	var args = OS.get_cmdline_args()
	if OS.has_feature("dedicated_server") and args.has("-t"):
		var argument_wert = args[args.find("-t") + 1] # Wert des spezifischen Arguments
		if argument_wert == "180" or argument_wert == "120" or argument_wert == "60":
			$loby/CenterContainer/VBoxContainer/settime.text = str(argument_wert.to_int()," sec.")
			$Timer.wait_time = argument_wert.to_int()
		else:
			$loby/CenterContainer/VBoxContainer/settime.text = str(120," sec.")
			$Timer.wait_time = 120
			
	
	
func update_player_list(id: int, join: bool):
	if join:
		playerlist.append(id)
		print(str("Peer: ",id," Connected!"))
	else:
		playerlist.erase(id)
		print(str("Peer: ",id," Disconnected!"))
		

@rpc("any_peer","call_local")
func visibility_npc_settings():
	if multiplayer.get_peers().is_empty() and not OS.has_feature("dedicated_server"):
		$loby/CenterContainer/VBoxContainer/VBoxContainer.visible = true
	else:
		$loby/CenterContainer/VBoxContainer/VBoxContainer.visible = false


@rpc("any_peer","call_local")
func is_server_run_game():
	Max_clients = 0
	
	
	
func _process(_delta):
	if not loaded and not get_tree().paused:
		loaded = true
		$Timer.connect("timeout", _on_timer_timeout.rpc)
		$Timerende.connect("timeout", _on_timerende_timeout.rpc)
		$Timerbomb.connect("timeout", _on_timerbomb_timeout.rpc)
		$Timerpower.connect("timeout", _on_timerpower_timeout.rpc)


		
	$loby.reset_loby()
	var fps = Engine.get_frames_per_second()
	$"CanvasLayer/fps".text = str("FPS: ", fps)
	if not $Timerbomb.is_stopped():
		$CanvasLayer/Bomb_time.text = str(round($Timerbomb.time_left), " sec. bis zur nächsten Bomben verteilung!")
	if not $Timer.is_stopped():
		$CanvasLayer/Time.text = str(round($Timer.time_left))
		if $Timer.time_left <= 30 and not last_runde:
			last_runde = true
			$Werten/CenterContainer/Letzen_sec.visible = true
			$CanvasLayer/Time.set("theme_override_colors/font_color",Color.CRIMSON)
			$CanvasLayer/Bomb_time.set("theme_override_colors/font_color",Color.CRIMSON)
			power_up_spawn_time = 5
			$Timerbomb.wait_time = 3
			await get_tree().create_timer(2).timeout
			$Werten/CenterContainer/Letzen_sec.visible = false

		
func verbindung_verloren():
	if multiplayer:
		multiplayer.server_disconnected.disconnect(verbindung_verloren)
		OS.alert("Multiplayer Server wurde beendet.", "Server Meldung")
		wechsel_sceene_wenn_server_disconected()
		return
	

func wechsel_sceene_wenn_server_disconected():
	get_tree().change_scene_to_file("res://sceens/main.tscn")
		
		
@rpc("call_local")
func voll():
	OS.alert("Server Voll!", "Server Meldung")
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file("res://sceens/main.tscn")
	

func add_player(id: int):
	if len(multiplayer.get_peers()) >= Max_clients:
		voll.rpc_id(id)
		return
	$loby.is_running = true
	update_player_list(id, true)
	var player = player_sceen.instantiate()
	player.name = str(id)
	get_node("Players").add_child(player, true)
	add_score(id, false)
	add_power_icons(id, false)
	add_score_visual(id, false)
				
	
@rpc("any_peer","call_local")
func add_text_tap(id: int, text: String):
	if is_multiplayer_authority():
		var new_name = name_label.instantiate()
		new_name.name = str(id)
		new_name.set("theme_override_colors/font_color",$Players.get_node(str(id)).get_node("Color").color)
		new_name.text = text
		get_node("Tap/CenterContainer/PanelContainer/VBoxContainer").add_child(new_name, true)
		
		
func del_text_tap(id: int):
	if not get_node("Tap/CenterContainer/PanelContainer/VBoxContainer").has_node(str(id)):
		return
	get_node("Tap/CenterContainer/PanelContainer/VBoxContainer").get_node(str(id)).queue_free()
			
			

@rpc("any_peer","call_local")
func reset_bomben():
	for c in range(Bomben.get_child_count()):
		if Bomben.get_child(c).is_in_group("boom"):
			Bomben.get_child(c).queue_free()


func spawn_new_bombe():
	for i in range(Global.Spawn_bomben_limit):
		var pos = Vector2(randi_range(bomb_spawn_grenzen,Global.Spielfeld_Size.x-bomb_spawn_grenzen),randi_range(bomb_spawn_grenzen,Global.Spielfeld_Size.y-bomb_spawn_grenzen))
		for child in Bomben.get_children():
			if child.position.distance_to(pos) < spawn_distance_bombe:
				return
		var new_bombe = bombe.instantiate()
		new_bombe.name = "bombe"
		new_bombe.position = pos
		Bomben.add_child(new_bombe, true)
		

@rpc("any_peer","call_local")
func reset_powerup():
	for c in range(power_up.get_child_count()):
		if power_up.get_child(c).is_in_group("power"):
			power_up.get_child(c).queue_free()


func spawn_new_powerup():
	for i in range(Global.Spawn_powerup_limit):
		var pos = Vector2(randi_range(bomb_spawn_grenzen,Global.Spielfeld_Size.x-bomb_spawn_grenzen),randi_range(bomb_spawn_grenzen,Global.Spielfeld_Size.y-bomb_spawn_grenzen))
		var new_auswahl = powerup_auswahl.pick_random()
		for child in power_up.get_children():
			if child.position.distance_to(pos) < spawn_distance_bombe:
				return
		var new_power_up = powerup.instantiate()
		new_power_up.name = "powerup"
		new_power_up.position = pos
		new_power_up.powerupid = new_auswahl
		power_up.add_child(new_power_up, true)
		
		
func spawn_npc():
	if $Players.has_node("1"):
		for i in range(Global.count_npcs):
			var new_npc = npc.instantiate()
			new_npc.name = str(multiplayer.get_unique_id())
			get_node("Players").add_child(new_npc, true)
			add_score(new_npc.name, true)
			add_power_icons(new_npc.name, true)
			add_score_visual(new_npc.name, true)
			add_text_tap(new_npc.name.to_int(), str("NPC",i+1))
		

func del_npc(id):
	if $Players.has_node("1"):
		if not get_node("Players").has_node(str(id)):
			return
		get_node("Players").get_node(str(id)).queue_free()
	
	
func add_score(id, np: bool):
	var new_score_label = score_label.instantiate()
	new_score_label.set("theme_override_colors/font_color",get_node("Players").get_node(str(id)).get_node("Color").color)
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
		

func add_score_visual(id, np: bool):
	var new_score_visual = score_visual.instantiate()
	new_score_visual.color = get_node("Players").get_node(str(id)).get_node("Color").color
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


func _input(_event):
	if Input.is_action_pressed("Info"):
		$Tap.visible = true
	if Input.is_action_just_released("Info"):
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
	$loby.update_player_count.rpc(false)
	update_player_list(id, false)
	get_node("Players").get_node(str(id)).queue_free()
	del_text_tap(id)
	del_score(id)
	del_power_icons(id)
	del_score_visuel(id)
	del_npc(id)
	

@rpc("any_peer","call_local")
func cell_blocker(block: bool, id: int):
	if block:
		block_cells.append(get_node("Players").get_node(str(id)).color_cell)
	else:
		block_cells.erase(get_node("Players").get_node(str(id)).color_cell)
		
		
@rpc("any_peer","call_local")
func _on_timer_timeout():
	set_timer_subnode.rpc("Timer", false)
	set_timer_subnode.rpc("Timerbomb", false)
	set_timer_subnode.rpc("Timerpower", false)
	set_timer_subnode.rpc("Timerende", true)
	sync_time_out()
	reset_vars_level()
	

@rpc("any_peer","call_local")
func sync_time_out():
	Time_out = true
	

func reset_vars_level():
	main.get_node("CanvasLayer2/UI").visible = false
	map.reset_floor()
	reset_powerup()
	reset_bomben()
	
	
	
@rpc("any_peer","call_local")
func wertungs_anzeige_aktivieren():
	$Werten.visible = true


func starting_game():
	starting = true
	Time_out = false
	

@rpc("any_peer","call_local")
func stoped_game():
	starting = false
	$Werten.visible = false
	$CanvasLayer/Time.visible = false
	$CanvasLayer/Bomb_time.visible = false
	$Tap.visible = false
	$CanvasLayer/Time.set("theme_override_colors/font_color",Color.BLACK)
	$CanvasLayer/Bomb_time.set("theme_override_colors/font_color",Color.BLACK)
	last_runde = false
	power_up_spawn_time = Global.standart_powerup_spawn_time
	$Timerbomb.wait_time = Global.standart_bomben_spawn_time


@rpc("any_peer","call_local")
func set_timer_subnode(nodepath: String, mode: bool):
	if multiplayer != null and multiplayer.is_server() or is_multiplayer_authority() or OS.has_feature("dedicated_server"):
		var obj = get_node(nodepath)
		if obj:
			if mode:
				obj.start()
			else:	
				obj.stop()
	

@rpc("any_peer","call_local")
func _on_timerbomb_timeout():
	if OS.has_feature("dedicated_server"):
		spawn_new_bombe()
		return
	if is_multiplayer_authority():
		spawn_new_bombe()
		return
		

@rpc("any_peer","call_local")
func _on_timerpower_timeout():
	if OS.has_feature("dedicated_server"):
		spawn_new_powerup()
		$Timerpower.wait_time = power_up_spawn_time
		return
	if is_multiplayer_authority():
		spawn_new_powerup()
		$Timerpower.wait_time = power_up_spawn_time
		return
		

@rpc("any_peer","call_local")
func _on_timerende_timeout():
	set_timer_subnode.rpc("Timerende", false)
	stoped_game()
	if not OS.has_feature("dedicated_server"):
		get_node("Scoreboard").update_scoreboard()
	Global.trigger_host_focus = true
	$Scoreboard/CanvasLayer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/restart.grab_focus()
	Global.trigger_host_focus = false
	$Scoreboard.set_visible_false.rpc("CanvasLayer", true)


func _on_zoomin_pressed() -> void:
	$Players.get_node(str(multiplayer.get_unique_id())).get_node("Camera2D").zoom *= 0.9  # Zoom in
	# Zoom-Grenzen anwenden
	$Players.get_node(str(multiplayer.get_unique_id())).get_node("Camera2D").zoom.x = clamp($Players.get_node(str(multiplayer.get_unique_id())).get_node("Camera2D").zoom.x, $Players.get_node(str(multiplayer.get_unique_id())).min_zoom, $Players.get_node(str(multiplayer.get_unique_id())).max_zoom)
	$Players.get_node(str(multiplayer.get_unique_id())).get_node("Camera2D").zoom.y = clamp($Players.get_node(str(multiplayer.get_unique_id())).get_node("Camera2D").zoom.y, $Players.get_node(str(multiplayer.get_unique_id())).min_zoom, $Players.get_node(str(multiplayer.get_unique_id())).max_zoom)


func _on_zoomout_pressed() -> void:
	$Players.get_node(str(multiplayer.get_unique_id())).get_node("Camera2D").zoom *= 1.1 # Zoom out
	# Zoom-Grenzen anwenden
	$Players.get_node(str(multiplayer.get_unique_id())).get_node("Camera2D").zoom.x = clamp($Players.get_node(str(multiplayer.get_unique_id())).get_node("Camera2D").zoom.x, $Players.get_node(str(multiplayer.get_unique_id())).min_zoom, $Players.get_node(str(multiplayer.get_unique_id())).max_zoom)
	$Players.get_node(str(multiplayer.get_unique_id())).get_node("Camera2D").zoom.y = clamp($Players.get_node(str(multiplayer.get_unique_id())).get_node("Camera2D").zoom.y, $Players.get_node(str(multiplayer.get_unique_id())).min_zoom, $Players.get_node(str(multiplayer.get_unique_id())).max_zoom)
