extends Control


var block_host = false
var Max_clients = 6
@onready var port = $Panel/CenterContainer/Net/Options/Option1/o1_port/port.text
@onready var connectport = $Panel/CenterContainer/Net/Options/Option2/o4/port.text
@onready var ip = $Panel/CenterContainer/Net/Options/Option2/o3/remote1/Remote.text
@onready var ip_list = $Panel/CenterContainer/Net/Options/Option1/ScrollContainer/yourip/ip_list


var loaded = false
var esc_is_pressing = false
var old_ips = []


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
	get_tree().paused = true
	
	
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
	
	
	get_local_ips()


func get_local_ips():
	var local_interfaces = IP.get_local_interfaces()
	for r in ip_list.get_children():
		r.queue_free()
	for i in local_interfaces:
		if (OS.has_feature("windows") and i["friendly"].begins_with("Ethernet") or i["friendly"].begins_with("WLAN")) or ((OS.has_feature("linux") or OS.has_feature("android")) and i["name"].begins_with("en") or i["name"].begins_with("eth") or i["name"].begins_with("wl")):
			for address in i["addresses"]:
				if (address.split('.').size() == 4) and address.begins_with("10.") or check_address_bereich(address,16,31) or address.begins_with("192.168."):
					var addr = preload("res://sceens/myip.tscn")
					var new_addr = addr.instantiate()
					new_addr.text = str(address)
					ip_list.add_child(new_addr)
		
	
	
	
func check_address_bereich(curent_ip: String, anfang: int, ende: int):
	for i in range(anfang,ende):
		if curent_ip.begins_with(str("172.",i,".")):
			return true
	return false
		
		
func _on_host_pressed():
	get_tree().paused = false
	if block_host:
		get_tree().paused = true
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
		get_tree().paused = true
		return
	port = port.to_int()
	var check = peer.create_server(port, Max_clients)
	if check != OK:
		OS.alert("Server kann nicht erstellt werden!")
		if port < 1024:
			OS.alert("Versuchen sie einen port über 1024!")
		get_tree().paused = true
		return
	multiplayer.multiplayer_peer = peer
	get_parent().visible = false
	
	change_level(load("res://sceens/level.tscn"))

		
func _on_connect_pressed():
	get_tree().paused = false
	if block_host:
		get_tree().paused = true
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
		get_tree().paused = true
		return
	var peer = ENetMultiplayerPeer.new()
	connectport = connectport.to_int()
	peer.create_client(ip, connectport)
	multiplayer.multiplayer_peer = peer
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Konnte Multiplayer client nicht starten.")
		block_host = false
		get_tree().paused = true
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
			get_tree().paused = true
	if not block_host:
		multiplayer.multiplayer_peer.close()
		get_tree().paused = true
		return
	get_parent().visible = false
	
	
func change_level(scene: PackedScene):
	# Remove old level if any.
	var level = get_parent().get_parent().get_node("Level")
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	# Add new level.
	level.add_child(scene.instantiate())
