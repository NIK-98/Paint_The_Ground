extends Control


var block_host = false
var Max_clients = 6
@onready var port = $Panel/CenterContainer/Net/Options/Option1/o1_port/port.text
@onready var connectport = $Panel/CenterContainer/Net/Options/Option2/o4/port.text
@onready var ip = $Panel/CenterContainer/Net/Options/Option2/o3/remote1/Remote.text
@onready var ip_list = $Panel/CenterContainer/Net/Options/Option1/ScrollContainer/yourip/ip_list
@onready var update_time_ips = $Panel/CenterContainer/Net/Options/Option1/ScrollContainer/yourip/Label2
@onready var ips_update_timer = $ips_update_timer
@onready var vs = $Panel/CenterContainer/Net/Options/Option1/o2/vs
@onready var namen = $Panel/CenterContainer/Net/Options/Option1/o1_port/namen

var save_path = "user://savetemp.save"


var loaded = false
var esc_is_pressing = false
var local_address: PackedStringArray

var auto_conect_ips = []
var server_port_to_connect_to = ""
var game_started = false
var vs_mode = false



func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"ip" : ip,
		"connectport" : connectport,
		"port" : port,
		"Max_clients" : Max_clients,
		"vs_mode" : vs_mode
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
		for n in get_parent().get_children():
			if n.is_in_group("SB"):
				get_parent().move_child(n,get_parent().get_child_count())
		$Panel/CenterContainer/Net/Options/Option2/o4/port.text = connectport
		$Panel/CenterContainer/Net/Options/Option2/o3/remote1/Remote.text = ip
		port = str(port)
		$Panel/CenterContainer/Net/Options/Option1/o1_port/port.text = port
		if vs_mode:
			vs.set_pressed(true)
		else:
			vs.set_pressed(false)
		
	
	update_time_ips.text = str("update in ",floor(ips_update_timer.time_left),"s")
			
	
	if get_parent().get_parent().has_node("Audio_menu/CanvasLayer") and get_parent().get_parent().has_node("Grafik/CanvasLayer") and get_parent().get_parent().has_node("Control/CanvasLayer"):
		if visible and (Input.is_action_just_pressed("exit") or Input.is_action_just_pressed("exit_con")) and not get_parent().get_parent().get_node("Audio_menu/CanvasLayer").visible and not get_parent().get_parent().get_node("Grafik/CanvasLayer").visible and not get_parent().get_parent().get_node("Control/CanvasLayer").visible:
			await get_tree().create_timer(0.1).timeout
			esc_is_pressing = true
			get_parent().get_parent().get_node("CanvasLayer/Menu").visible = true
			Global.trigger_host_focus = true
			get_parent().get_parent().get_node("CanvasLayer/Menu/PanelContainer/VBoxContainer/Beenden").grab_focus()
			Global.trigger_host_focus = false
	
	if (Input.is_action_just_pressed("modus") or Input.is_action_just_pressed("modus_con")):
		get_parent().get_parent()._on_change_pressed()
	if (Input.is_action_just_pressed("cancel") or Input.is_action_just_pressed("cancel_con")):
		block_host = false
		$Panel/CenterContainer/Net/Connecting.text = ""
	
	if get_parent().get_parent().has_node("Level/level/loby") and not get_parent().get_parent().get_node("Level/level/loby").visible:
		set_process(false)


func get_local_ips():
	var interfaces = IP.get_local_interfaces()
	local_address = []
	for iface in interfaces:
		if ((OS.get_name() == "Linux" or OS.get_name() == "Android" or OS.get_name() == "IOS") and not iface["name"].begins_with("lo")) or ((OS.get_name() == "Windows") and not iface["friendly"].begins_with("v")):
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
	var server_send = preload("res://sceens/server_sender.tscn").instantiate()
	get_parent().get_node("Server_Browser").add_child(server_send)
	

		
func _on_connect_pressed():
	Global.ui_sound = true
	get_tree().paused = false
	if block_host:
		get_tree().paused = true
		return
		
	port = $Panel/CenterContainer/Net/Options/Option1/o1_port/port.text
	connectport = $Panel/CenterContainer/Net/Options/Option2/o4/port.text
	ip = $Panel/CenterContainer/Net/Options/Option2/o3/remote1/Remote.text
	prints(ip,port)
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
	if get_parent().get_parent().has_node("Control/CanvasLayer") and not get_parent().get_parent().get_node("Control/CanvasLayer").visible:
		if (Input.is_action_just_pressed("zoomout") or Input.is_action_just_pressed("zoomout_con")):
			if $Panel/CenterContainer/Net/Options/Option1/ScrollContainer.scroll_vertical < max(0, $Panel/CenterContainer/Net/Options/Option1/ScrollContainer/yourip.size.y - $Panel/CenterContainer/Net/Options/Option1/ScrollContainer.size.y):
				$Panel/CenterContainer/Net/Options/Option1/ScrollContainer.scroll_vertical += 100
				return
		if (Input.is_action_just_pressed("zoomin") or Input.is_action_just_pressed("zoomin_con")):
			if $Panel/CenterContainer/Net/Options/Option1/ScrollContainer.scroll_vertical >= min(0, $Panel/CenterContainer/Net/Options/Option1/ScrollContainer/yourip.size.y - $Panel/CenterContainer/Net/Options/Option1/ScrollContainer.size.y):
				$Panel/CenterContainer/Net/Options/Option1/ScrollContainer.scroll_vertical -= 100
				return
				

func _on_host_connect_toggled(toggled_on: bool) -> void:
	Global.ui_sound = true
	if toggled_on:
		$Panel/CenterContainer/Net/Options/Option1.hide()
		$Panel/CenterContainer/Net/Options/Option2.show()
		get_parent().get_node("Server_Browser").show()
	else:
		$Panel/CenterContainer/Net/Options/Option2.hide()
		get_parent().get_node("Server_Browser").hide()
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


func _on_vs_toggled(toggled_on: bool):
	if toggled_on:
		vs_mode = true
	else:
		vs_mode = false
