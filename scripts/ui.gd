extends Control


var block_host = false
var Max_clients = 6
@onready var port = $Panel/CenterContainer/Net/Options/Option1/o1_port/port.text
@onready var connectport = $Panel/CenterContainer/Net/Options/Option2/o4/port.text
@onready var ip = $Panel/CenterContainer/Net/Options/Option2/o3/remote1/Remote.text

var loaded = false
var esc_is_pressing = false


func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"ip" : ip,
		"connectport" : connectport,
		"port" : port,
		"Max_clients" : Max_clients
	}
	return save_dict
	
	
func _ready():
	name = "UI"
	if OS.has_feature("dedicated_server"):
		return
	
func _process(_delta):
	if not loaded:
		loaded = true
		name = "UI"
		$Panel/CenterContainer/Net/Options/Option2/o4/port.text = connectport
		$Panel/CenterContainer/Net/Options/Option2/o3/remote1/Remote.text = ip
		port = str(port)
		$Panel/CenterContainer/Net/Options/Option1/o1_port/port.text = port
		
	if Input.is_action_just_pressed("cancel"):
		block_host = false
		$Panel/CenterContainer/Net/Connecting.text = ""
	if Input.is_action_just_pressed("exit") and visible:
		esc_is_pressing = true
		get_parent().get_parent().get_node("CanvasLayer/Beenden").visible = true
		get_parent().get_parent().get_node("CanvasLayer/Beenden/PanelContainer/VBoxContainer/Ja").grab_focus()

func _on_host_pressed():
	if block_host:
		return
		
	port = $Panel/CenterContainer/Net/Options/Option1/o1_port/port.text
	connectport = $Panel/CenterContainer/Net/Options/Option2/o4/port.text
	ip = $Panel/CenterContainer/Net/Options/Option2/o3/remote1/Remote.text
	get_parent().get_parent().save_game()
	
	var peer = ENetMultiplayerPeer.new()
	if OS.get_cmdline_args().size() <= 1 and not FileAccess.file_exists(get_parent().get_parent().save_path):
		port = $Panel/CenterContainer/Net/Options/Option1/o1_port/port.text
	port = str(port)
	if not port.is_valid_int():
		OS.alert("Ist keine richtieger port.")
		return
	port = port.to_int()
	var check = peer.create_server(port, Max_clients)
	if check != OK:
		OS.alert("Server kann nicht erstellt werden!")
		if port < 1024:
			OS.alert("Versuchen sie einen port über 1024!")
		return
	multiplayer.multiplayer_peer = peer
	get_parent().visible = false
	
	multiplayer.peer_connected.connect(get_parent().get_parent().get_node("Level/level").add_player)
	multiplayer.peer_disconnected.connect(get_parent().get_parent().get_node("Level/level").del_player)
		
		
	for id in multiplayer.get_peers():
		get_parent().get_parent().get_node("Level/level").add_player(id)


	if not OS.has_feature("dedicated_server"):
		get_parent().get_parent().get_node("Level/level").add_player(1)

		
func _on_connect_pressed():
	if block_host:
		return
		
	port = $Panel/CenterContainer/Net/Options/Option1/o1_port/port.text
	connectport = $Panel/CenterContainer/Net/Options/Option2/o4/port.text
	ip = $Panel/CenterContainer/Net/Options/Option2/o3/remote1/Remote.text
	get_parent().get_parent().save_game()
		
	block_host = true
	if OS.get_cmdline_args().size() <= 1 and not FileAccess.file_exists(get_parent().get_parent().save_path):
		connectport = $Panel/CenterContainer/Net/Options/Option2/o4/port.text
	if not connectport.is_valid_int():
		OS.alert("Ist keine richtieger port.")
		block_host = false
		return
	var peer = ENetMultiplayerPeer.new()
	connectport = connectport.to_int()
	peer.create_client(ip, connectport)
	multiplayer.multiplayer_peer = peer
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Konnte Multiplayer client nicht starten.")
		block_host = false
		return
	var i = 0
	while peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTING and block_host:
		i += 1
		$Panel/CenterContainer/Net/Connecting.text = str("Verbindung wird aufgebaut...", i)
		await get_tree().create_timer(1).timeout
		if i >= 20:
			block_host = false
			OS.alert("Verbindung fehlgeschlagen!")
			$Panel/CenterContainer/Net/Connecting.text = ""
	if not block_host:
		multiplayer.multiplayer_peer.close()
		return
	get_parent().visible = false
	multiplayer.server_disconnected.connect(get_parent().get_parent().get_node("Level/level").verbindung_verloren)
	

func start_game():
	if multiplayer.is_server():
		change_level(preload("res://sceens/level.tscn"))


func change_level(scene: PackedScene):
	var level = get_parent().get_parent().get_node("Level")
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	level.add_child(scene.instantiate())
