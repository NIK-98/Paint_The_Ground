extends Control


var block_host = false
var Max_clients = 6
@onready var port = $Panel/CenterContainer/Net/Options/Option1/o1_port/port.text
@onready var connectport = $Panel/CenterContainer/Net/Options/Option2/o4/port.text
@onready var ip = $Panel/CenterContainer/Net/Options/Option2/o3/remote1/Remote.text
@onready var ip_list = $Panel/CenterContainer/Net/Options/Option1/ScrollContainer/yourip/ip_list
@onready var update_time_ips = $Panel/CenterContainer/Net/Options/Option1/ScrollContainer/yourip/Label2
@onready var ips_update_timer = $ips_update_timer


var loaded = false
var esc_is_pressing = false
var local_address: PackedStringArray


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
	get_local_ips()
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
	
	update_time_ips.text = str("update in ",floor(ips_update_timer.time_left),"s")


func get_local_ips():
	if IP.get_local_addresses() != local_address:
		local_address = IP.get_local_addresses()
		for r in ip_list.get_children():
			r.queue_free()
		for i in local_address:
			if (i.split('.').size() == 4) and i.begins_with("10.") or check_address_bereich(i,16,31) or i.begins_with("192.168."):
				var addr = preload("res://sceens/myip.tscn")
				var new_addr = addr.instantiate()
				new_addr.text = str(i)
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
		if i >= 10:
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


func _on_ips_update_timeout():
	get_local_ips()
	

func _input(_event):
	if Input.is_action_just_pressed("modus"):
		get_parent().get_parent()._on_change_pressed()


func _on_host_connect_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$Panel/CenterContainer/Net/Options/Option1.hide()
		$Panel/CenterContainer/Net/Options/Option2.show()
	else:
		$Panel/CenterContainer/Net/Options/Option2.hide()
		$Panel/CenterContainer/Net/Options/Option1.show()
