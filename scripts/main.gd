extends Node
	
var peer = ENetMultiplayerPeer.new()

func _ready():
	get_tree().paused = true
	multiplayer.server_relay = false
	
	Global.Max_clients = 3
	if DisplayServer.get_name() == "headless":
		Global.Max_clients = 4
		print("Startet Dedicated Server.")
		_on_host_pressed.call_deferred()
		

func _process(delta):
	if get_node("Level/level") == null:
		OS.alert("Multiplayer Server wurde beendet.")
		get_tree().change_scene_to_file("res://sceens/main.tscn")
	

func _on_host_pressed():
	var txt : String = $UI/Net/Options/Remote.text
	var port : String = $UI/Net/Options/port.text
	peer.create_server(port.to_int(),Global.Max_clients)
	if not txt.is_valid_ip_address():
		OS.alert("Ist keine richtiege ip adresse.")
		return
	if not port.is_valid_int():
		OS.alert("Ist keine richtieger port.")
		return
		
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Multiplayer Server läuft bereits.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()
		
		
func _on_connect_pressed():
	var txt : String = $UI/Net/Options/Remote.text
	var port : String = $UI/Net/Options/port.text
	if not txt.is_valid_ip_address():
		OS.alert("Ist keine richtiege ip adresse.")
		return
	if not port.is_valid_int():
		OS.alert("Ist keine richtieger port.")
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(txt, port.to_int())
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Konnte Multiplayer client nicht starten.")
		return
	var udp_server = UDPServer.new()
	if udp_server.listen(port.to_int()) == 0:
		OS.alert("Kein Multiplayer Server gefunden.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()


func start_game():
	$UI.hide()
	if multiplayer.is_server():
		change_level(preload("res://sceens/level.tscn"))


func change_level(scene: PackedScene):
	var level = $Level
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	level.add_child(scene.instantiate())


# Der Server kann Das Level mit R Restarten
func _input(event):
	if not multiplayer.is_server():
		return
	if event.is_action("reset") and Input.is_action_just_pressed("reset"):
		change_level.call_deferred(load("res://sceens/level.tscn"))

