extends Control


var block_host = false
var Max_clients = 6
@onready var port = $Panel/CenterContainer/Net/Options/Option1/o1_port/port.text
@onready var connectport = $Panel/CenterContainer/Net/Options/Option2/o4/port.text
@onready var ip = $Panel/CenterContainer/Net/Options/Option2/o3/remote1/Remote.text
@onready var ip_list = $Panel/CenterContainer/Net/Options/Option1/ScrollContainer/yourip/ip_list
@onready var update_time_ips = $Panel/CenterContainer/Net/Options/Option1/ScrollContainer/yourip/Label2
@onready var ips_update_timer = $ips_update_timer

var save_path = "user://savetemp.save"


var loaded = false
var esc_is_pressing = false
var local_address: PackedStringArray

var udp_server = UDPServer.new()
var udp_port = 6969

var udp_client := PacketPeerUDP.new()
var udp_server_found = false
var udp_requests = 3
var delta_time = 0.0

var auto_conect_ips = []
var server_address_to_connect_to = ""
var game_started = false



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
	udp_client.set_broadcast_enabled(true)
	udp_client.set_dest_address("255.255.255.255", udp_port)
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		$Panel/CenterContainer/Net/Info.visible = true
	if OS.get_name() == "Windows" or OS.get_name() == "linux":
		$Panel/CenterContainer/Net/InfoPC.visible = true
	
	
func _process(_delta):
	if not loaded:
		loaded = true
		name = "UI"
		$Panel/CenterContainer/Net/Options/Option2/o4/port.text = connectport
		$Panel/CenterContainer/Net/Options/Option2/o3/remote1/Remote.text = ip
		port = str(port)
		$Panel/CenterContainer/Net/Options/Option1/o1_port/port.text = port
		
	
	update_time_ips.text = str("update in ",floor(ips_update_timer.time_left),"s")
	
	
	if not game_started:
		udp_server.poll()
		if udp_server.is_connection_available():
			var udp_peer : PacketPeerUDP = udp_server.take_connection()
			var packet = udp_peer.get_packet()
			print("Recieved : %s from %s:%s" %
					[
						packet.get_string_from_ascii(),
						udp_peer.get_packet_ip(),
						udp_peer.get_packet_port(),
					]
			)
			# Reply to valid udp_peer with server IP address example
			var str_ips = ""
			for l in local_address:
				if (l.split('.').size() == 4) and (l.begins_with("10.") or check_address_bereich(l,"172",16,31) or l.begins_with("192.168.")):
					str_ips += str(l,",")
			udp_peer.put_packet(str_ips.to_ascii_buffer())
		
	
	

	if $Panel/CenterContainer/Net/Options/Option2/o3/remote1/Remote.text == "auto":
		udp_client.put_packet("Valid_Request".to_ascii_buffer())
		if udp_client.get_available_packet_count() > 0:
			server_address_to_connect_to = udp_client.get_packet().get_string_from_ascii()
			await check_ip(server_address_to_connect_to)
			
	
	if get_parent().get_parent().has_node("Level/level/loby") and not get_parent().get_parent().get_node("Level/level/loby").visible:
		set_process(false)	
		

func check_ip(str_liste: String):
	var temp_str = ""
	auto_conect_ips = []
	for x in str_liste:
		if x != ",":
			temp_str += x
		else:
			auto_conect_ips.append(temp_str)
			temp_str = ""
	print(auto_conect_ips)
	for ips in auto_conect_ips:
		var peer = ENetMultiplayerPeer.new()
		connectport = $Panel/CenterContainer/Net/Options/Option2/o4/port.text
		connectport = connectport.to_int()
		var check = peer.create_client(ips, connectport)
		if check == OK:
			peer = null
			$Panel/CenterContainer/Net/Options/Option2/o3/remote1/Remote.text = str(ips)
			return
	


func get_local_ips():
	var interfaces = IP.get_local_interfaces()
	local_address = []
	for iface in interfaces:
		if ((OS.get_name() == "linux" or OS.get_name() == "Android" or OS.get_name() == "IOS") and not iface["name"].begins_with("lo")) or ((OS.get_name() == "Windows") and not iface["friendly"].begins_with("v")):
			var addr = iface["addresses"]
			for a in addr:
				local_address.append(a)

		
	for r in ip_list.get_children():
		r.queue_free()
	for i in local_address:
		if (i.split('.').size() == 4) and (i.begins_with("10.") or check_address_bereich(i,"172",16,31) or i.begins_with("192.168.")):
			var addr = preload("res://sceens/myip.tscn")
			var new_addr = addr.instantiate()
			new_addr.text = str(i)
			ip_list.add_child(new_addr)
		
	
	
	
func check_address_bereich(curent_ip: String, ip_block: String, anfang: int, ende: int):
	for i in range(anfang,ende+1):
		if curent_ip.begins_with(str(ip_block,".",i,".")):
			return true
	return false
		
		
func _on_host_pressed():
	Global.ui_sound = true
	get_tree().paused = false
	if block_host:
		get_tree().paused = true
		return
		
	port = $Panel/CenterContainer/Net/Options/Option1/o1_port/port.text
	connectport = $Panel/CenterContainer/Net/Options/Option2/o4/port.text
	ip = $Panel/CenterContainer/Net/Options/Option2/o3/remote1/Remote.text
	if not FileAccess.file_exists(save_path):
		get_parent().get_parent().save_game("Persist", save_path)
	else:
		DirAccess.remove_absolute(save_path)
		get_parent().get_parent().save_game("Persist", save_path)
	
	var peer = ENetMultiplayerPeer.new()
	if OS.get_cmdline_args().size() <= 1 and not FileAccess.file_exists(get_parent().get_parent().save_path):
		port = $Panel/CenterContainer/Net/Options/Option1/o1_port/port.text
	port = str(port)
	if not port.is_valid_int():
		OS.alert("Ist keine richtieger port.", "Server Meldung")
		get_tree().paused = true
		return
	port = port.to_int()
	var check = peer.create_server(port, Max_clients)
	if check != OK:
		OS.alert("Server kann nicht erstellt werden!", "Server Meldung")
		if port < 1024:
			OS.alert("Versuchen sie einen port über 1024!", "Server Meldung")
		get_tree().paused = true
		return
	multiplayer.multiplayer_peer = peer
	get_parent().visible = false
	
	change_level(load("res://sceens/level.tscn"))
	
	udp_server.listen(udp_port, "0.0.0.0")

		
func _on_connect_pressed():
	Global.ui_sound = true
	get_tree().paused = false
	if block_host:
		get_tree().paused = true
		return
		
	port = $Panel/CenterContainer/Net/Options/Option1/o1_port/port.text
	connectport = $Panel/CenterContainer/Net/Options/Option2/o4/port.text
	ip = $Panel/CenterContainer/Net/Options/Option2/o3/remote1/Remote.text
	if not FileAccess.file_exists(save_path):
		get_parent().get_parent().save_game("Persist", save_path)
	else:
		DirAccess.remove_absolute(save_path)
		get_parent().get_parent().save_game("Persist", save_path)
		
	block_host = true
	if OS.get_cmdline_args().size() <= 1 and not FileAccess.file_exists(get_parent().get_parent().save_path):
		connectport = $Panel/CenterContainer/Net/Options/Option2/o4/port.text
	if not connectport.is_valid_int():
		OS.alert("Ist keine richtieger port.", "Server Meldung")
		block_host = false
		get_tree().paused = true
		return
	var peer = ENetMultiplayerPeer.new()
	connectport = connectport.to_int()
	peer.create_client(ip, connectport)
	multiplayer.multiplayer_peer = peer
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Konnte Multiplayer client nicht starten.", "Server Meldung")
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
			OS.alert("Verbindung fehlgeschlagen!", "Server Meldung")
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
	if Input.is_action_just_pressed("zoomout"):
		if $Panel/CenterContainer/Net/Options/Option1/ScrollContainer.scroll_vertical < max(0, $Panel/CenterContainer/Net/Options/Option1/ScrollContainer/yourip.size.y - $Panel/CenterContainer/Net/Options/Option1/ScrollContainer.size.y):
			$Panel/CenterContainer/Net/Options/Option1/ScrollContainer.scroll_vertical += 100
			return
		if $Panel.scroll_vertical < max(0, $Panel/CenterContainer.size.y - $Panel.size.y):
			$Panel.scroll_vertical += 100
			return
	if Input.is_action_just_pressed("zoomin"):
		if $Panel/CenterContainer/Net/Options/Option1/ScrollContainer.scroll_vertical >= min(0, $Panel/CenterContainer/Net/Options/Option1/ScrollContainer/yourip.size.y - $Panel/CenterContainer/Net/Options/Option1/ScrollContainer.size.y) and $Panel.scroll_vertical <= min(0, $Panel/CenterContainer.size.y - $Panel.size.y):
			$Panel/CenterContainer/Net/Options/Option1/ScrollContainer.scroll_vertical -= 100
			return
		if $Panel.scroll_vertical >= min(0, $Panel/CenterContainer.size.y - $Panel.size.y):
			$Panel.scroll_vertical -= 100
			return
	if Input.is_action_just_pressed("modus"):
		get_parent().get_parent()._on_change_pressed()
	if Input.is_action_just_pressed("cancel"):
		block_host = false
		$Panel/CenterContainer/Net/Connecting.text = ""
	if Input.is_action_just_pressed("exit") and visible and not get_parent().get_parent().get_node("Audio_menu/CanvasLayer").visible and not get_parent().get_parent().get_node("Grafik/CanvasLayer").visible:
		await get_tree().create_timer(0.1).timeout
		esc_is_pressing = true
		get_parent().get_parent().get_node("CanvasLayer/Menu").visible = true
		Global.trigger_host_focus = true
		get_parent().get_parent().get_node("CanvasLayer/Menu/PanelContainer/VBoxContainer/Beenden").grab_focus()
		Global.trigger_host_focus = false


func _on_host_connect_toggled(toggled_on: bool) -> void:
	Global.ui_sound = true
	if toggled_on:
		$Panel/CenterContainer/Net/Options/Option1.hide()
		$Panel/CenterContainer/Net/Options/Option2.show()
	else:
		$Panel/CenterContainer/Net/Options/Option2.hide()
		$Panel/CenterContainer/Net/Options/Option1.show()


func _on_host_connect_mouse_entered():
	Global.ui_hover_sound = true


func _on_host_connect_focus_entered():
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Global.ui_hover_sound = true


func _on_host_mouse_entered():
	Global.ui_hover_sound = true


func _on_host_focus_entered():
	if not Global.trigger_host_focus:
		Global.ui_hover_sound = true


func _on_connect_mouse_entered():
	Global.ui_hover_sound = true


func _on_connect_focus_entered():
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Global.ui_hover_sound = true
