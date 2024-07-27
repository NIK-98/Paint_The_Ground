extends Node2D


const bomb_spawn_genzen = 250


@onready var main = get_parent().get_parent()
@export var player_sceen: PackedScene
@export var score_label: PackedScene
@export var name_label: PackedScene
@onready var map = get_node("floor")
@onready var bombe = preload("res://sceens/bombe.tscn")
@onready var Bomben = get_node("Bomben")
@export var randpos = Vector2(randi_range(bomb_spawn_genzen,Global.Spielfeld_Size.x-bomb_spawn_genzen),randi_range(bomb_spawn_genzen,Global.Spielfeld_Size.y-bomb_spawn_genzen))
@export var oldrandpos = randpos
@export var starting = false

var Time_out = false

func _ready():
	$Werten.visible = false
	$CanvasLayer/Time.visible = false
	$CanvasLayer/Bomb_time.visible = false
	$Tap.visible = false
	# We only need to spawn players on the server.
	multiplayer.server_disconnected.connect(verbindung_verloren)
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)
	multiplayer.peer_disconnected.connect(del_score)
	multiplayer.peer_disconnected.connect(del_text_tap)
		
		
	for id in multiplayer.get_peers():
		add_player(id)


	if not OS.has_feature("dedicated_server"):
		add_player(1)


func _process(_delta):
	$loby.reset_loby()
	var fps = Engine.get_frames_per_second()
	$"CanvasLayer/fps".text = str("FPS: ", fps)
	if not $Timer.is_stopped() and multiplayer.is_server():
		$CanvasLayer/Time.text = str(round($Timer.time_left))
	if not $Timerbomb.is_stopped() and multiplayer.is_server():
		$CanvasLayer/Bomb_time.text = str(round($Timerbomb.time_left), " sec. bis zur nächsten Bomben verteilung!")
		

func exittree():	
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)
	multiplayer.peer_disconnected.disconnect(del_score)
	multiplayer.peer_disconnected.disconnect(del_text_tap)
	

func verbindung_verloren():
	OS.alert("Multiplayer Server wurde beendet.")
	get_tree().change_scene_to_file("res://sceens/main.tscn")
	

@rpc("call_local")
func voll():
	OS.alert("Server Voll!")
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file("res://sceens/main.tscn")
	
		

func add_player(id: int):
	if len(multiplayer.get_peers()) >= $loby.Max_clients-1:
		voll.rpc_id(id)
		return
	if len(multiplayer.get_peers()) < $loby.Max_clients:
		$loby.update_player_count.rpc()
	var player = player_sceen.instantiate()
	player.name = str(id)
	get_node("Players").add_child(player, true)
	add_score(id)

	
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
			

@rpc("any_peer","call_local")
func update_spawn_bomb_position():
	oldrandpos = randpos
	randpos = Vector2(randi_range(bomb_spawn_genzen,Global.Spielfeld_Size.x-bomb_spawn_genzen),randi_range(bomb_spawn_genzen,Global.Spielfeld_Size.y-bomb_spawn_genzen))


func spawn_new_bombe():
	update_spawn_bomb_position.rpc()
	var new_bombe = bombe.instantiate()
	new_bombe.name = "bombe"
	new_bombe.position = randpos
	Bomben.add_child(new_bombe, true)
	
	
func add_score(id: int):
	var new_score_label = score_label.instantiate()
	new_score_label.set("theme_override_colors/font_color",get_node("Players").get_node(str(id)).get_node("Color").color)
	new_score_label.name = str(id)
	get_node("Werten/PanelContainer/Wertung").add_child(new_score_label, true)
	
	
func del_score(id: int):
	if not get_node("Werten/PanelContainer/Wertung").has_node(str(id)):
		return
	get_node("Werten/PanelContainer/Wertung").get_node(str(id)).queue_free()


func _input(_event):
	if Input.is_action_pressed("Info"):
		$Tap.visible = true
	if Input.is_action_just_released("Info"):
		$Tap.visible = false


func kicked(id, antwort):
	OS.alert("Verbindung verloren!", antwort)
	multiplayer.server_disconnected.disconnect(verbindung_verloren)
	kick(id)
	get_tree().change_scene_to_file("res://sceens/main.tscn")
	return
	
	
func kick(id):
	del_text_tap(id)
	del_score(id)
	del_player(id)
	multiplayer.multiplayer_peer.close() # debug meldung: _remove_node_cache: Condition "!pinfo" is true. Continuing.
	
	
func del_player(id: int):
	if not get_node("Players").has_node(str(id)):
		return
	get_node("Players").get_node(str(id)).queue_free()
	

func _on_timer_timeout():
	$Timer.stop()
	$Timerbomb.stop()
	Time_out = true
	

@rpc("any_peer","call_local")
func hide_start():
	$CanvasLayer/Start.visible = false
	
	
func _on_start_pressed():
	hide_start.rpc()
	reset_bomben.rpc()
	wertungs_anzeige_aktivieren.rpc()
	starting_game.rpc()
	

@rpc("any_peer","call_local")
func reset_vars_level():
	if not OS.has_feature("dedicated_server"):
		get_node("Players").get_node(str(multiplayer.get_unique_id())).get_node("CanvasLayer/Winner").visible = false
		get_node("Players").get_node(str(multiplayer.get_unique_id())).get_node("CanvasLayer/Los").visible = false
		get_node("Players").get_node(str(multiplayer.get_unique_id())).ende = false
		get_node("Players").get_node(str(multiplayer.get_unique_id())).loaded = false
		get_node("Players").get_node(str(multiplayer.get_unique_id())).Gametriggerstart = false
		get_node("Players").get_node(str(multiplayer.get_unique_id())).score = 0
		get_node("Scoreboard/CanvasLayer").visible = false
		starting = false
	main.get_node("UI").visible = false
	$Timer.stop()
	$Timerbomb.stop()
	Time_out = false
	$Werten.visible = false
	$CanvasLayer/Time.visible = false
	$CanvasLayer/Bomb_time.visible = false
	$Tap.visible = false
	$CanvasLayer/Start.visible = true
	map.reset_floor()
	
@rpc("any_peer","call_local")
func wertungs_anzeige_aktivieren():
	$Werten.visible = true


@rpc("any_peer","call_local")
func starting_game():
	starting = true
	

@rpc("any_peer","call_local")
func stoped_game():
	starting = false
	

func _on_timerbomb_timeout():
	if is_multiplayer_authority():
		for i in range(Global.Spawn_bomben_limit):
			spawn_new_bombe()


func _on_timerende_timeout():
	if OS.has_feature("dedicated_server"):
		return
	get_node("Scoreboard").update_scoreboard()
	get_node("Scoreboard/CanvasLayer").visible = true
