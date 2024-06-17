extends Node2D


const bomb_spawn_genzen = 250


@onready var main = get_parent().get_parent()
@export var player_sceen: PackedScene
@export var score_label: PackedScene
@onready var map = get_node("floor")
@onready var bombe = preload("res://sceens/bombe.tscn")
@onready var Bomben = get_node("Bomben")
@export var randpos = Vector2(randi_range(bomb_spawn_genzen,Global.Spielfeld_Size.x-bomb_spawn_genzen),randi_range(bomb_spawn_genzen,Global.Spielfeld_Size.y-bomb_spawn_genzen))
@export var oldrandpos = randpos

var old_spawn: Vector2
var Time_out = false

func _ready():
	$CanvasLayer/Time.visible = false
	$CanvasLayer/Bomb_time.visible = false
	$Camera2D.enabled = false
	# We only need to spawn players on the server.
	multiplayer.server_disconnected.connect(verbindung_verloren)
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)
	multiplayer.peer_disconnected.connect(del_score)
		
		
	for id in multiplayer.get_peers():
		add_player(id)


	if not OS.has_feature("dedicated_server"):
		add_player(1)


func _process(delta):
	var fps = Engine.get_frames_per_second()
	$"CanvasLayer/fps".text = str("FPS: ", fps)
	if not $Timer.is_stopped() and multiplayer.is_server():
		$CanvasLayer/Time.text = str(round($Timer.time_left))
	if not $Timerbomb.is_stopped() and multiplayer.is_server():
		$CanvasLayer/Bomb_time.text = str(round($Timerbomb.time_left), " sec. bis zur nächsten Bomben verteilung!")
		


func _exit_tree():
	multiplayer.server_disconnected.disconnect(verbindung_verloren)
	if not multiplayer.is_server():
		return
		
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)
	multiplayer.peer_disconnected.disconnect(del_score)
	
	
func _enter_tree():
	if len(multiplayer.get_peers()) == Global.Max_clients:
		return
	

func verbindung_verloren():
	OS.alert("Multiplayer Server wurde beendet.")
	get_tree().change_scene_to_file("res://sceens/main.tscn")
	

@rpc("call_local")
func voll(id: int):
	OS.alert("Server Voll!")
	get_tree().change_scene_to_file("res://sceens/main.tscn")
	
		

func add_player(id: int):
	if len(multiplayer.get_peers()) >= Global.Max_clients:
		voll.rpc_id(id, id)
		return
	var player = player_sceen.instantiate()
	player.player = id
	var randpos = Vector2(floor(randi_range(500,Global.Spielfeld_Size.x+player.get_node("Color").size.x)),floor(randi_range(500,Global.Spielfeld_Size.y-player.get_node("Color").size.y)))
	player.position = randpos
	player.name = str(id)
	player.color_cell = len(multiplayer.get_peers())+1
	get_node("Players").add_child(player, true)
	add_score(id)


@rpc("call_local")
func reset_bomben(anzahl: int):	
	for c in Bomben.get_child_count()-1:
		if Bomben.get_child(c).is_in_group("boom"):
			Bomben.get_child(c).queue_free()
			
			
@rpc("any_peer","call_local")
func update_spawn_bomb_position():
	oldrandpos = randpos
	randpos = Vector2(randi_range(bomb_spawn_genzen,Global.Spielfeld_Size.x-bomb_spawn_genzen),randi_range(bomb_spawn_genzen,Global.Spielfeld_Size.y-bomb_spawn_genzen))


@rpc("any_peer","call_local")
func spawn_new_bombe():
	var new_bombe = bombe.instantiate()
	new_bombe.name = "bombe"
	update_spawn_bomb_position.rpc()
	new_bombe.position = randpos
	Bomben.add_child(new_bombe)
	
	
func add_score(id: int):
	var new_score_label = score_label.instantiate()
	new_score_label.set("theme_override_colors/font_color",get_node("Players").get_node(str(id)).get_node("Color").color)
	new_score_label.name = str(id)
	get_node("CanvasLayer/Wertung").add_child(new_score_label, true)
		

func del_score(id: int):
	if not get_node("CanvasLayer/Wertung").has_node(str(id)):
		return
	get_node("CanvasLayer/Wertung").get_node(str(id)).queue_free()
	
	
func del_player(id: int):
	if not get_node("Players").has_node(str(id)):
		return
	get_node("Players").get_node(str(id)).queue_free()
	

func _on_timer_timeout():
	$Timer.stop()
	$Timerbomb.stop()
	Time_out = true
	
	

@rpc("any_peer","call_local")
func visible_start():
	for i in get_node("CanvasLayer").get_children():
		if i.is_in_group("start"):
			i.visible = false
	Global.Max_clients = 0
	
	
func _on_start_pressed():
	visible_start.rpc()
	reset_bomben.rpc_id(1, Global.Spawn_bomben_limit)

func _on_timerbomb_timeout():
	if is_multiplayer_authority():
		for i in range(Global.Spawn_bomben_limit):
			spawn_new_bombe.rpc()
