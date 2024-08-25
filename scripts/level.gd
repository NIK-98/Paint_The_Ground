extends Node2D


const bomb_spawn_genzen = 250


@onready var main = get_parent().get_parent()
@export var player_sceen: PackedScene
@export var score_label: PackedScene
@export var name_label: PackedScene
@onready var map = get_node("floor")
@onready var bombe = preload("res://sceens/bombe.tscn")
@onready var npc = preload("res://sceens/npc.tscn")
@onready var Bomben = get_node("Bomben")
@export var starting = false
@export var playerlist = []
@export var Max_clients = 6
var loaded_seson = false
var loaded = false
var blocked = false

var Time_out = false

func _ready():
	$loby/CenterContainer/VBoxContainer/name_input.visible = true
	$loby/CenterContainer/VBoxContainer/Enter.visible = true
	$loby/CenterContainer/VBoxContainer/HBoxContainer.visible = true
	$loby/CenterContainer/VBoxContainer/Random.visible = true
	$loby/CenterContainer/VBoxContainer/Warten.visible = false
	$Werten.visible = false
	$CanvasLayer/Time.visible = false
	$CanvasLayer/Bomb_time.visible = false
	$Tap.visible = false
	
	


@rpc("any_peer","call_local")
func visibility_npc_settings():
	if multiplayer.get_peers().is_empty() and not OS.has_feature("dedicated_server"):
		$loby/CenterContainer/VBoxContainer/npcs.visible = true
	else:
		$loby/CenterContainer/VBoxContainer/npcs.visible = false


@rpc("any_peer","call_local")
func is_server_run_game():
	Max_clients = 0
	
	
	
func _process(_delta):
	if not loaded and not get_tree().paused:
		loaded = true
		$Timer.connect("timeout", _on_timer_timeout.rpc)
		$Timerende.connect("timeout", _on_timerende_timeout.rpc)
		$Timerbomb.connect("timeout", _on_timerbomb_timeout)
		$Timerwarte.connect("timeout", _on_timerwarte_timeout.rpc)
		
	$loby.reset_loby()
	var fps = Engine.get_frames_per_second()
	$"CanvasLayer/fps".text = str("FPS: ", fps)
	if not OS.has_feature("dedicated_server"):
		if not $Timer.is_stopped():
			$CanvasLayer/Time.text = str(round($Timer.time_left))
		if not $Timerbomb.is_stopped():
			$CanvasLayer/Bomb_time.text = str(round($Timerbomb.time_left), " sec. bis zur nächsten Bomben verteilung!")


		
func verbindung_verloren():
	if multiplayer:
		multiplayer.server_disconnected.disconnect(verbindung_verloren)
		OS.alert("Multiplayer Server wurde beendet.")
		call_deferred("wechsel_sceene_wenn_server_disconected")
		return
	

func wechsel_sceene_wenn_server_disconected():
	get_tree().change_scene_to_file("res://sceens/main.tscn")
		

func add_player(id: int):
	var player = player_sceen.instantiate()
	player.name = str(id)
	get_node("Players").add_child(player, true)
	add_score(id, false)
	


@rpc("any_peer","call_local")
func update_player_list(id: int, append: bool):
	if append:
		playerlist.append(id)
	else:
		for i in playerlist:
			if i == id:
				playerlist.erase(i)
				break
				
	
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
		var new_bombe = bombe.instantiate()
		new_bombe.name = "bombe"
		new_bombe.position = Vector2(randi_range(bomb_spawn_genzen,Global.Spielfeld_Size.x-bomb_spawn_genzen),randi_range(bomb_spawn_genzen,Global.Spielfeld_Size.y-bomb_spawn_genzen))
		Bomben.add_child(new_bombe, true)
		
		
func spawn_npc():
	if $Players.has_node("1"):
		for i in range(Global.count_npcs):
			var new_npc = npc.instantiate()
			new_npc.name = str(multiplayer.get_unique_id())
			get_node("Players").add_child(new_npc, true)
			add_score(new_npc.name, true)
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
	get_node("Werten/PanelContainer/Wertung").add_child(new_score_label, true)
	if np:
		new_score_label.is_npc = np
		
	
func del_score(id):
	if not get_node("Werten/PanelContainer/Wertung").has_node(str(id)):
		return
	get_node("Werten/PanelContainer/Wertung").get_node(str(id)).queue_free()


func _input(_event):
	if Input.is_action_pressed("Info"):
		$Tap.visible = true
	if Input.is_action_just_released("Info"):
		$Tap.visible = false


func kicked(id, antwort, show_msg: bool):
	if show_msg:
		OS.alert(antwort)
	$loby.update_player_count.rpc(false)
	multiplayer.multiplayer_peer.disconnect_peer(id)
	wechsel_sceene_wenn_server_disconected()
	
	
func del_player(id: int):
	if not get_node("Players").has_node(str(id)):
		return
	get_node("Players").get_node(str(id)).queue_free()
	del_text_tap(id)
	del_score(id)
	del_npc(id)
	if not multiplayer.is_server():
		multiplayer.server_disconnected.disconnect(verbindung_verloren)
	

@rpc("any_peer","call_local")
func _on_timer_timeout():
	set_timer_subnode.rpc("Timer", false)
	set_timer_subnode.rpc("Timerbomb", false)
	set_timer_subnode.rpc("Timerende", true)
	sync_time_out()
	

@rpc("any_peer","call_local")
func sync_time_out():
	Time_out = true
	

func reset_vars_level():
	main.get_node("CanvasLayer2/UI").visible = false
	map.reset_floor()
	
	
@rpc("any_peer","call_local")
func wertungs_anzeige_aktivieren():
	$Werten.visible = true


@rpc("any_peer","call_local")
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


@rpc("any_peer","call_local")
func set_timer_subnode(nodepath: String, mode: bool):
	var obj = get_node(nodepath)
	if obj:
		if mode:
			obj.start()
		else:	
			obj.stop()
	

func _on_timerbomb_timeout():
	if OS.has_feature("dedicated_server"):
		spawn_new_bombe()
		return
	if is_multiplayer_authority():
		spawn_new_bombe()
		return
	

@rpc("any_peer","call_local")
func _on_timerende_timeout():
	set_timer_subnode.rpc("Timerende", false)
	stoped_game()
	if OS.has_feature("dedicated_server"):
		return
	get_node("Scoreboard").update_scoreboard()
	$Scoreboard.set_visible_false.rpc("CanvasLayer", true)
	
	
	

@rpc("any_peer","call_local")
func _on_timerwarte_timeout():
	set_timer_subnode.rpc("Timerwarte", false)
	if $loby.player_wait_count <= 1 and not $Players.has_node("1"):
		if not OS.has_feature("dedicated_server"):
			kicked(multiplayer.get_unique_id(), "Kein Mitspieler auf dem Server Gefunden!", true)
		$loby.exit(false)
		return
	if $loby.player_wait_count == 1 and $Players.has_node("1") and not loaded_seson:
		loaded_seson = true
		spawn_npc()
	if not OS.has_feature("dedicated_server"):
		reset_vars_level()
		$loby.visible = false
		$loby/CenterContainer/VBoxContainer/Warten.visible = false
		wertungs_anzeige_aktivieren()
	reset_bomben()
	set_timer_subnode.rpc("Timer", true)
	set_timer_subnode.rpc("Timerbomb", true)
	starting_game()
