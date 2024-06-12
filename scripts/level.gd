extends Node2D

@onready var main = get_parent().get_parent()
@export var player_sceen: PackedScene
@export var score_label: PackedScene
@onready var map = get_node("floor")
@onready var bombe = preload("res://sceens/bombe.tscn")
@onready var Bomben = get_node("Bomben")

var old_spawn_bomb: Vector2
const bomb_spawn_genzen = 64

var old_spawn: Vector2

func _ready():
	# We only need to spawn players on the server.
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


func _exit_tree():
	if not multiplayer.is_server():
		return
		
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)
	multiplayer.peer_disconnected.disconnect(del_score)
	
	
func _enter_tree():
	if len(multiplayer.get_peers()) == Global.Max_clients:
		return
	
	
@rpc("call_local")
func voll(id: int):
	OS.alert("Server Voll!")
	get_tree().change_scene_to_file("res://sceens/main.tscn")
	
	
func _input(event):
	if event.is_action("start") and Input.is_action_just_pressed("start"):
		global_alert.rpc("Game Gestartet!")
		reset_game_status.rpc()
		

@rpc("any_peer","call_local")
func global_alert(alert: String):
	OS.alert(alert)	
		
		
@rpc("any_peer","call_local")
func reset_game_status():
	Global.Game_running = true
	Global.Max_clients = len(multiplayer.get_peers())
	
		
func add_player(id: int):
	if len(multiplayer.get_peers()) >= Global.Max_clients:
		voll.rpc_id(id, id)
		return
	var player = player_sceen.instantiate()
	player.player = id
	var randpos = Vector2(randi_range(0,Global.Spielfeld_Size.x-player.get_node("Color").size.x),randi_range(0,Global.Spielfeld_Size.y-player.get_node("Color").size.y))
	if randpos == old_spawn:
		old_spawn = randpos
		del_player(id)
		add_player(id)
		return
		
	player.position = randpos
	player.name = str(id)
	get_node("Players").add_child(player, true)
	old_spawn = randpos
	add_score(id)


func reset_bomben(id: int,anzahl: int):	
	for c in Bomben.get_child_count()-1:
		if Bomben.get_child(c).is_in_group("boom"):
			Bomben.get_child(c).queue_free()
	for i in range(anzahl):
		spawn_new_bombe(id, 8)


func spawn_new_bombe(id: int,abstand: int):
	var new_bombe = bombe.instantiate()
	var randpos = Vector2(randi_range(bomb_spawn_genzen,Global.Spielfeld_Size.x-bomb_spawn_genzen),randi_range(bomb_spawn_genzen,Global.Spielfeld_Size.y-bomb_spawn_genzen))
	if randpos == old_spawn_bomb*abstand:
		old_spawn_bomb = randpos
		reset_bomben(id, 4)
		return
	new_bombe.name = "bombe"
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
