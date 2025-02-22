extends Control


var block_host = false
var Max_clients = 4
@onready var port = $Panel/CenterContainer/Net/Options/Option1/o1_port/port.text
@onready var connectport = $Panel/CenterContainer/Net/Options/Option2/o4/port.text
@onready var ip = $Panel/CenterContainer/Net/Options/Option2/o3/remote1/Remote.text
@onready var vs = $Panel/CenterContainer/Net/Options/Option1/o2/vs
@onready var Coins_Loeschen = $Panel/CenterContainer/Net/Options/Option1/o2/Coins_Loeschen
@onready var namen = $Panel/CenterContainer/Net/Options/Option1/o1_port/namen
@onready var shop_reset = $Panel/CenterContainer/Net/Options/Option1/o2/Shop_Reset
@onready var alleine_spielen = $Panel/CenterContainer/Net/Options/Option1/o2/Alleine_Spielen
@onready var popup_edit = get_parent().get_parent().get_parent().get_node("CanvasLayer/keyboard/PanelContainer/CenterContainer/VBoxContainer/popup_edit")
@onready var keyboard = get_parent().get_parent().get_parent().get_node("CanvasLayer/keyboard")
@onready var versions_info = $Versions_Info
var trailer = preload("res://sceens/trailer.tscn")

var save_path = "user://savetemp.save"


var loaded = false
var esc_is_pressing = false
var local_address: PackedStringArray

var auto_conect_ips = []
var server_port_to_connect_to = ""
var game_started = false
var vs_mode = false
var coin_mode = false
var shop_mode = false
var solo_mode = false
var trailer_on = true
var host_mode = false


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
		"vs_mode" : vs_mode,
		"coin_mode" : coin_mode,
		"shop_mode" : shop_mode,
		"solo_mode" : solo_mode,
		"trailer_on" : trailer_on,
		"host_mode" : host_mode
	}
	return save_dict
	
	
func _ready():
	name = "UI"
	versions_info.text = str("Entwickler: Nik-Dev\nVersion: ", ProjectSettings.get("application/config/version"))
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
		if coin_mode:
			Coins_Loeschen.set_pressed(true)
		else:
			Coins_Loeschen.set_pressed(false)
		if shop_mode:
			shop_reset.set_pressed(true)
		else:
			shop_reset.set_pressed(false)
		if solo_mode:
			alleine_spielen.set_pressed(true)
		else:
			alleine_spielen.set_pressed(false)
		if host_mode:
			$Panel/CenterContainer/Net/Options/Option1.hide()
			$Panel/CenterContainer/Net/Options/Option2.show()
			get_parent().get_node("Server_Browser").show()
			$Versions_Info.hide()
		else:
			$Panel/CenterContainer/Net/Options/Option2.hide()
			get_parent().get_node("Server_Browser").hide()
			$Panel/CenterContainer/Net/Options/Option1.show()
			$Versions_Info.show()
			
		
	
	if (Input.is_action_just_pressed("modus") or Input.is_action_just_pressed("modus_con")):
		get_parent().get_parent().get_parent()._on_change_pressed()
	if (Input.is_action_just_pressed("cancel") or Input.is_action_just_pressed("cancel_con")):
		block_host = false
		$Panel/CenterContainer/Net/Connecting.text = ""
	
	if get_parent().get_parent().get_parent().has_node("Level/level/loby") and not get_parent().get_parent().get_parent().get_node("Level/level/loby").visible:
		set_process(false)
			
	
func check_address_bereich(curent_ip: String, ip_block: String, anfang: int, ende: int):
	for i in range(anfang,ende+1):
		if curent_ip.begins_with(str(ip_block,".",i,".")):
			return true
	return false
		
		
func _on_host_pressed():
	Global.ui_sound = true
	get_tree().paused = false
			
	if namen.text.is_empty():
		OS.alert("Bitte Namen Eingeben!", "Server Meldung")
		get_tree().paused = true
		return
	namen.text = namen.text.lstrip(" ")
	namen.text = namen.text.rstrip(" ")
		
	if block_host:
		get_tree().paused = true
		return
		
	port = $Panel/CenterContainer/Net/Options/Option1/o1_port/port.text
	connectport = $Panel/CenterContainer/Net/Options/Option2/o4/port.text
	ip = $Panel/CenterContainer/Net/Options/Option2/o3/remote1/Remote.text
	if not FileAccess.file_exists(save_path):
		get_parent().get_parent().get_parent().save_game("Persist", save_path)
	else:
		DirAccess.remove_absolute(save_path)
		get_parent().get_parent().get_parent().save_game("Persist", save_path)
	
	var peer = ENetMultiplayerPeer.new()
	if OS.get_cmdline_args().size() <= 1 and not FileAccess.file_exists(get_parent().get_parent().get_parent().save_path):
		port = $Panel/CenterContainer/Net/Options/Option1/o1_port/port.text
	port = str(port)
	if not port.is_valid_int():
		OS.alert("Ist keine richtieger port!\nGieb eine Zahl ein.", "Server Meldung")
		get_tree().paused = true
		return
	port = port.to_int()
	var check = peer.create_server(port, Max_clients)
	if check != OK:
		OS.alert("Server kann nicht erstellt werden!", "Server Meldung")
		if port < 1024:
			OS.alert("Versuchen sie einen port über 1024!", "Server Meldung")
		if port > 65535:
			OS.alert("Versuchen sie einen port unter 65536!", "Server Meldung")
		get_tree().paused = true
		return
	multiplayer.multiplayer_peer = peer
	get_parent().visible = false
	
	change_level(load("res://sceens/level.tscn"))
	if not solo_mode:
		var server_send = preload("res://sceens/server_sender.tscn").instantiate()
		get_parent().get_node("Server_Browser").add_child(server_send)
	get_parent().get_parent().get_parent().shop.visible = true
	

		
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
		get_parent().get_parent().get_parent().save_game("Persist", save_path)
	else:
		DirAccess.remove_absolute(save_path)
		get_parent().get_parent().get_parent().save_game("Persist", save_path)
		
	block_host = true
	if OS.get_cmdline_args().size() <= 1 and not FileAccess.file_exists(get_parent().get_parent().get_parent().save_path):
		connectport = $Panel/CenterContainer/Net/Options/Option2/o4/port.text
	if not connectport.is_valid_int():
		OS.alert("Ist keine richtieger port!\nGieb eine Zahl ein.", "Server Meldung")
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
	get_parent().get_parent().get_parent().shop.visible = true
	
	
func change_level(scene: PackedScene):
	# Remove old level if any.
	var level = get_parent().get_parent().get_parent().get_node("Level")
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	# Add new level.
	level.add_child(scene.instantiate())


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


func _on_host_connect_pressed() -> void:
	Global.ui_sound = true
	if not get_parent().get_node("Server_Browser").visible:
		$Panel/CenterContainer/Net/Options/Option1.hide()
		$Panel/CenterContainer/Net/Options/Option2.show()
		get_parent().get_node("Server_Browser").show()
		$Versions_Info.hide()
		host_mode = true
	else:
		$Panel/CenterContainer/Net/Options/Option2.hide()
		get_parent().get_node("Server_Browser").hide()
		$Panel/CenterContainer/Net/Options/Option1.show()
		$Versions_Info.show()
		host_mode = false


func _on_focus_entered() -> void:
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Global.ui_hover_sound = true


func _on_mouse_entered() -> void:
	Global.ui_hover_sound = true


func _on_coins_loeschen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		coin_mode = true
	else:
		coin_mode = false


func _on_shop_reset_toggled(toggled_on: bool) -> void:
	if toggled_on:
		shop_mode = true
	else:
		shop_mode = false


func _on_alleine_spielen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		solo_mode = true
	else:
		solo_mode = false


func _on_input_gui_input(event: InputEvent) -> void:
	if Global.menu or event.is_action_pressed("exit_con") or event.is_action_pressed("exit"):
		return
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		if event.is_pressed() and Input.get_connected_joypads().size() <= 0 or event.is_action("ui_accept") and Input.get_connected_joypads().size() > 0:
			edit_text_select()
	elif event.is_pressed() and Input.get_connected_joypads().size() <= 1 or event.is_action("ui_accept") and Input.get_connected_joypads().size() > 1:
		edit_text_select()
	

func edit_text_select():
	if $Panel/CenterContainer/Net/Options/Option2/o4/port.has_focus():
		keyboard.selected_node = $Panel/CenterContainer/Net/Options/Option2/o4/port
		keyboard.parent_fild_length = $Panel/CenterContainer/Net/Options/Option2/o4/port.max_length
		popup_edit.text = $Panel/CenterContainer/Net/Options/Option2/o4/port.text
		keyboard.last_focus_path = $Panel/CenterContainer/Net/Options/Option2/o4/port.get_path()
	if $Panel/CenterContainer/Net/Options/Option2/o3/remote1/Remote.has_focus():
		keyboard.selected_node = $Panel/CenterContainer/Net/Options/Option2/o3/remote1/Remote
		keyboard.parent_fild_length = $Panel/CenterContainer/Net/Options/Option2/o3/remote1/Remote.max_length
		popup_edit.text = $Panel/CenterContainer/Net/Options/Option2/o3/remote1/Remote.text
		keyboard.last_focus_path = $Panel/CenterContainer/Net/Options/Option2/o3/remote1/Remote.get_path()
	if $Panel/CenterContainer/Net/Options/Option1/o1_port/namen.has_focus():
		keyboard.selected_node = $Panel/CenterContainer/Net/Options/Option1/o1_port/namen
		keyboard.parent_fild_length = $Panel/CenterContainer/Net/Options/Option1/o1_port/namen.max_length
		popup_edit.text = $Panel/CenterContainer/Net/Options/Option1/o1_port/namen.text
		keyboard.last_focus_path = $Panel/CenterContainer/Net/Options/Option1/o1_port/namen.get_path()
	if $Panel/CenterContainer/Net/Options/Option1/o1_port/port.has_focus():
		keyboard.selected_node = $Panel/CenterContainer/Net/Options/Option1/o1_port/port
		keyboard.parent_fild_length = $Panel/CenterContainer/Net/Options/Option1/o1_port/port.max_length
		popup_edit.text = $Panel/CenterContainer/Net/Options/Option1/o1_port/port.text
		keyboard.last_focus_path = $Panel/CenterContainer/Net/Options/Option1/o1_port/port.get_path()
	keyboard.selected = true
			


func _on_anleitung_pressed() -> void:
	Global.ui_sound = true
	Global.stop_main_theama = true
	var new_trailer = trailer.instantiate()
	get_parent().get_parent().get_parent().get_node("CanvasLayer3").add_child(new_trailer)


func _on_anleitung_focus_entered() -> void:
	if not Global.trigger_host_focus:
		Global.ui_hover_sound = true


func _on_anleitung_mouse_entered() -> void:
	Global.ui_hover_sound = true
