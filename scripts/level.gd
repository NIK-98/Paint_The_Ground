extends Node2D

@onready var map = get_node("floor")
@onready var main = get_parent().get_parent()
@export var player_sceen: PackedScene
@export var score_label: PackedScene

var old_spawn: Vector2

func _ready():
	# We only need to spawn players on the server.
	if not multiplayer.is_server():
		return

	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)
	multiplayer.peer_disconnected.connect(del_score)
	multiplayer.peer_disconnected.connect(add_score)

	# Spawn already connected players.
	for id in multiplayer.get_peers():
		add_player(id)
		add_score(id)

	# Spawn the local player unless this is a dedicated server export.
	if not OS.has_feature("dedicated_server"):
		add_player(1)
		add_score(1)


func _process(delta):
	var fps = Engine.get_frames_per_second()
	$"Control/CanvasLayer/fps".text = str("FPS: ", fps)
	wertung.rpc()


func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)
	multiplayer.peer_disconnected.disconnect(del_score)
	multiplayer.peer_disconnected.disconnect(add_score)
	
func add_player(id: int):
	var player = player_sceen.instantiate()
	player.player = id
	var randpos = Vector2(randi_range(0,Global.Spielfeld_Size.x-player.get_node("Color").size.x),randi_range(0,Global.Spielfeld_Size.y-player.get_node("Color").size.y))
	
	player.position = randpos
	if randpos == old_spawn:
		del_player(id)
		del_score(id)
		add_player(id)
		add_score(id)
		return
		
	player.name = str(id)
	get_node("Players").add_child(player, true)
	old_spawn = randpos
	
	
func add_score(id: int):
	var new_score_label = score_label.instantiate()
	new_score_label.set("theme_override_colors/font_color",get_node("Players").get_node(str(id)).get_node("Color").color)
	new_score_label.name = "score_label"
		
	new_score_label.name = str(id)
	get_node("Control/CanvasLayer/Wertung").add_child(new_score_label, true)
		

func del_score(id: int):
	if not get_node("Control/CanvasLayer/Wertung").has_node(str(id)):
		return
	get_node("Control/CanvasLayer/Wertung").get_node(str(id)).queue_free()
	
	
func del_player(id: int):
	if not get_node("Players").has_node(str(id)):
		return
	get_node("Players").get_node(str(id)).queue_free()
	
@rpc("any_peer","call_local")
func wertung():
	Global.player_list = []
	Global.score_list = []
	Global.count_score = 0
	print(get_node("Control/CanvasLayer/Wertung").get_child_count())
	for i in get_node("Control/CanvasLayer/Wertung").get_child_count():
		Global.player_list.append(get_node("Control/CanvasLayer/Wertung").get_child(i))
		Global.score_list.append(Global.count_score)
	for i in map.get_used_cells(0):
		var check_cell = map.get_cell_source_id(0,i)
		if check_cell == 1 and len(Global.score_list) == 1 and Global.player_list[0]:
			Global.score_list[0]+=1
			Global.player_list[0].text = str(Global.score_list[0])
		if check_cell == 2 and len(Global.score_list) == 2 and Global.player_list[1]:
			Global.score_list[1]+=1
			Global.player_list[1].text = str(Global.score_list[1])
		if check_cell == 3 and len(Global.score_list) == 3 and Global.player_list[2]:
			Global.score_list[2]+=1
			Global.player_list[2].text = str(Global.score_list[2])
	
